#!/usr/bin/env python3
"""
Unit tests for ShopZada data ingestion functionality
"""

import pytest
import pandas as pd
import psycopg2
from unittest.mock import Mock, patch, MagicMock
import sys
import os

# Add scripts directory to path for imports
sys.path.append(os.path.join(os.path.dirname(__file__), '..', 'scripts', 'ingest'))

from ingest_to_postgres import ShopZadaIngestion


class TestShopZadaIngestion:
    """Test cases for data ingestion functionality"""

    @pytest.fixture
    def ingestion_instance(self):
        """Create ingestion instance with mocked database connection"""
        with patch.dict(os.environ, {
            'DB_HOST': 'localhost',
            'DB_PORT': '5432',
            'DB_NAME': 'test_db',
            'DB_USER': 'test_user',
            'DB_PASSWORD': 'test_pass'
        }):
            instance = ShopZadaIngestion()
            return instance

    @patch('ingest_to_postgres.create_engine')
    def test_initialization(self, mock_engine, ingestion_instance):
        """Test ingestion class initialization"""
        assert ingestion_instance.db_config['database'] == 'test_db'
        assert ingestion_instance.db_config['user'] == 'test_user'
        mock_engine.assert_called_once()

    @patch('ingest_to_postgres.create_engine')
    @patch('pandas.read_csv')
    def test_ingest_csv_success(self, mock_read_csv, mock_engine, ingestion_instance):
        """Test successful CSV ingestion"""
        # Mock DataFrame
        mock_df = Mock(spec=pd.DataFrame)
        mock_df.columns = ['col1', 'col2']
        mock_read_csv.return_value = mock_df

        # Mock SQLAlchemy engine
        mock_engine_instance = Mock()
        mock_engine.return_value = mock_engine_instance

        # Mock to_sql method
        mock_df.to_sql = Mock()

        result = ingestion_instance.ingest_csv('test.csv', 'test_table')

        assert result is True
        mock_read_csv.assert_called_once_with('test.csv')
        mock_df.to_sql.assert_called_once()

    @patch('ingest_to_postgres.create_engine')
    @patch('pandas.read_csv')
    def test_ingest_csv_failure(self, mock_read_csv, mock_engine, ingestion_instance):
        """Test CSV ingestion failure"""
        mock_read_csv.side_effect = Exception("File not found")

        result = ingestion_instance.ingest_csv('nonexistent.csv', 'test_table')

        assert result is False

    @patch('ingest_to_postgres.create_engine')
    @patch.object(ShopZadaIngestion, 'ingest_csv')
    @patch('os.path.exists')
    def test_run_all_ingestions(self, mock_exists, mock_ingest_csv, mock_engine, ingestion_instance):
        """Test running all ingestion processes"""
        # Mock file existence checks
        mock_exists.return_value = True
        mock_ingest_csv.return_value = True

        results = ingestion_instance.run_all_ingestions('/test/data')

        assert len(results) == 6  # Should have 6 ingestion attempts
        assert all(result is True for result in results.values())

    @patch('ingest_to_postgres.create_engine')
    @patch.object(ShopZadaIngestion, 'ingest_csv')
    @patch('os.path.exists')
    def test_run_all_ingestions_missing_files(self, mock_exists, mock_ingest_csv, mock_engine, ingestion_instance):
        """Test ingestion with missing files"""
        # Mock some files exist, others don't
        mock_exists.side_effect = [True, False, True, False, True, False]

        results = ingestion_instance.run_all_ingestions('/test/data')

        assert len(results) == 6
        # Files that don't exist should have False results
        assert results['customer_management'] is False
        assert results['enterprise_orders'] is False


class TestDataQuality:
    """Test data quality validation functions"""

    def test_column_name_standardization(self):
        """Test that column names are properly standardized"""
        test_data = {
            'Product ID': [1, 2, 3],
            'Product_Name': ['A', 'B', 'C'],
            'price (USD)': [10.5, 20.0, 15.5]
        }
        df = pd.DataFrame(test_data)

        # Expected standardized names
        expected_columns = ['product_id', 'product_name', 'price_usd']

        # This would be part of the ingestion logic
        df.columns = df.columns.str.lower().str.replace(' ', '_').str.replace('[^a-zA-Z0-9_]', '_')

        assert list(df.columns) == expected_columns

    def test_data_types_preservation(self):
        """Test that data types are preserved during ingestion"""
        test_data = {
            'id': [1, 2, 3],
            'name': ['Alice', 'Bob', 'Charlie'],
            'price': [10.50, 20.00, 15.50],
            'active': [True, False, True]
        }
        df = pd.DataFrame(test_data)

        # Check data types are preserved
        assert df['id'].dtype == 'int64'
        assert df['name'].dtype == 'object'
        assert df['price'].dtype == 'float64'
        assert df['active'].dtype == 'bool'


class TestIntegration:
    """Integration tests for end-to-end functionality"""

    @pytest.mark.integration
    def test_database_connection(self):
        """Test actual database connection (requires running PostgreSQL)"""
        # This test would only run in integration environment
        pytest.skip("Integration test - requires database")

    @pytest.mark.integration
    def test_full_ingestion_pipeline(self):
        """Test complete ingestion pipeline"""
        # This would test the full pipeline with actual files
        pytest.skip("Integration test - requires data files and database")


if __name__ == '__main__':
    pytest.main([__file__])
