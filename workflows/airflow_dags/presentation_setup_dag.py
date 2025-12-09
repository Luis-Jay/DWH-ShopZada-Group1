"""
ShopZada Data Warehouse - Presentation Setup DAG

This DAG handles the creation of presentation layer objects:
- Analytical views
- Materialized views
- BI-ready structures
"""

import sys
import os
from datetime import datetime, timedelta
import logging

sys.path.insert(0, os.path.abspath('/opt/airflow/scripts'))

from airflow.decorators import dag
from airflow.operators.empty import EmptyOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

DEFAULT_ARGS = {
    'owner': 'shopzada_data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['data-team@shopzada.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

@dag(
    dag_id='shopzada_presentation_setup',
    default_args=DEFAULT_ARGS,
    description='Create presentation layer views and materialized views',
    schedule_interval=None,  # Manual only
    tags=['shopzada', 'presentation', 'views'],
    catchup=False,
    max_active_runs=1,
    template_searchpath=['/opt/airflow/sql', '/opt/airflow/sql/ddl', '/opt/airflow/sql/views', '/opt/airflow/sql/materialized'],
)
def presentation_setup():
    """
    Presentation setup DAG for ShopZada DWH
    """

    start_presentation = EmptyOperator(task_id='start_presentation_setup')

    create_warehouse_schema = PostgresOperator(
        task_id='create_warehouse_schema',
        postgres_conn_id='postgres_default',
        sql='warehouse_schema.sql',
    )

    create_presentation_schema = PostgresOperator(
        task_id='create_presentation_schema',
        postgres_conn_id='postgres_default',
        sql='presentation_schema.sql',
    )

    create_customer_segments_view = PostgresOperator(
        task_id='create_customer_segments_view',
        postgres_conn_id='postgres_default',
        sql='view_customer_segments.sql',
    )

    create_campaign_effectiveness_view = PostgresOperator(
        task_id='create_campaign_effectiveness_view',
        postgres_conn_id='postgres_default',
        sql='view_campaign_effectiveness.sql',
    )

    create_merchant_performance_view = PostgresOperator(
        task_id='create_merchant_performance_view',
        postgres_conn_id='postgres_default',
        sql='view_merchant_performance.sql',
    )

    create_daily_sales_agg = PostgresOperator(
        task_id='create_daily_sales_agg',
        postgres_conn_id='postgres_default',
        sql='mat_agg_daily_sales.sql',
    )

    end_presentation = EmptyOperator(task_id='end_presentation_setup')

    # Dependencies - create schemas first, then views
    start_presentation >> create_warehouse_schema
    start_presentation >> create_presentation_schema

    create_warehouse_schema >> create_customer_segments_view
    create_warehouse_schema >> create_campaign_effectiveness_view
    create_warehouse_schema >> create_merchant_performance_view
    create_warehouse_schema >> create_daily_sales_agg

    create_presentation_schema >> create_customer_segments_view
    create_presentation_schema >> create_campaign_effectiveness_view
    create_presentation_schema >> create_merchant_performance_view
    create_presentation_schema >> create_daily_sales_agg

    create_customer_segments_view >> end_presentation
    create_campaign_effectiveness_view >> end_presentation
    create_merchant_performance_view >> end_presentation
    create_daily_sales_agg >> end_presentation

presentation_setup_dag = presentation_setup()
