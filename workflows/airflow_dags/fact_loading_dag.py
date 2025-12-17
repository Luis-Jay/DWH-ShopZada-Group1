"""
ShopZada Data Warehouse - Fact Loading DAG

This DAG handles the loading of fact tables in the warehouse layer.
"""

import sys
import os
from datetime import datetime, timedelta

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
    dag_id='shopzada_fact_loading',
    default_args=DEFAULT_ARGS,
    description='Load fact tables in the warehouse',
    schedule_interval=None,  # Manual only
    tags=['shopzada', 'facts', 'warehouse'],
    catchup=False,
    max_active_runs=1,
    template_searchpath=['/opt/airflow/scripts'],
)
def fact_loading():
    """
    Fact loading DAG for ShopZada DWH
    """

    start_facts = EmptyOperator(task_id='start_fact_loading')

    load_fact_orders = PostgresOperator(
        task_id='load_fact_orders',
        postgres_conn_id='postgres_default',
        sql='transform/warehouse/fact_orders_lightning.sql',
    )

    load_fact_campaign_performance = PostgresOperator(
        task_id='load_fact_campaign_performance',
        postgres_conn_id='postgres_default',
        sql='transform/warehouse/fact_campaign_performance.sql',
    )

    end_facts = EmptyOperator(task_id='end_fact_loading')

    # Dependencies - sequential execution to avoid conflicts
    start_facts >> load_fact_orders >> load_fact_campaign_performance >> end_facts

fact_loading_dag = fact_loading()
