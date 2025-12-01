import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import os
from datetime import datetime

class ShopZadaIngestion:
    def __init__(self):
        self.db_config = {
            'host': os.getenv('DB_HOST', 'localhost'),
            'port': os.getenv('DB_PORT', '5432'),
            'database': os.getenv('DB_NAME', 'shopzada_dwh'),
            'user': os.getenv('DB_USER', 'shopzada'),
            'password': os.getenv('DB_PASSWORD', 'shopzada123')
        }
        self.engine = create_engine(
            f"postgresql://{self.db_config['user']}:{self.db_config['password']}@"
            f"{self.db_config['host']}:{self.db_config['port']}/{self.db_config['database']}"
        )
    
    def ingest_csv(self, file_path, table_name, schema='staging'):
        """
        Generic CSV ingestion function
        """
        try:
            # Read CSV
            df = pd.read_csv(file_path)
            
            # Add loaded_at timestamp
            df['loaded_at'] = datetime.now()
            
            # Load to database
            df.to_sql(
                table_name,
                self.engine,
                schema=schema,
                if_exists='replace',
                index=False
            )
            
            print(f"✓ Successfully loaded {len(df)} rows into {schema}.{table_name}")
            return True
            
        except Exception as e:
            print(f"✗ Error loading {file_path}: {str(e)}")
            return False
    
    def run_all_ingestions(self, data_folder):
        """
        Ingest all ShopZada datasets
        """
        ingestions = [
            ('business_department.csv', 'business_products'),
            ('customer_management.csv', 'customer_management'),
            ('enterprise_department.csv', 'enterprise_orders'),
            ('marketing_transactions.csv', 'marketing_transactions'),
            ('marketing_campaigns.csv', 'marketing_campaigns'),
            ('operations_department.csv', 'operations_fulfillment')
        ]

        results = {}
        for file_name, table_name in ingestions:
            file_path = os.path.join(data_folder, file_name)
            if os.path.exists(file_path):
                results[table_name] = self.ingest_csv(file_path, table_name)
            else:
                print(f"⚠ Warning: File not found - {file_path}")
                results[table_name] = False

        return results

if __name__ == "__main__":
    ingestion = ShopZadaIngestion()
    results = ingestion.run_all_ingestions('sql/data/raw')
    print("\n=== Ingestion Summary ===")
    for table, success in results.items():
        status = "✓ SUCCESS" if success else "✗ FAILED"
        print(f"{table}: {status}")
