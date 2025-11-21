from airflow import DAG

try:
    from airflow.operators.python import PythonOperator  # type: ignore[import-not-found]
except ImportError:  # Airflow <2.0 fallback / editor without providers
    from airflow.operators.python_operator import PythonOperator  # type: ignore

try:
    from airflow.providers.postgres.operators.postgres import PostgresOperator
except ImportError:  # Fall back for environments without the provider package
    from airflow.operators.postgres_operator import PostgresOperator
from datetime import datetime, timedelta
import sys
sys.path.append('/opt/airflow/scripts/ingest')
from ingest_to_postgres import ShopZadaIngestion

default_args = {
    'owner': 'shopzada_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'shopzada_dwh_pipeline',
    default_args=default_args,
    description='ShopZada Data Warehouse ETL Pipeline',
    schedule_interval='@daily',
    catchup=False
)

# Task 1: Ingest raw data
def run_ingestion():
    ingestion = ShopZadaIngestion()
    return ingestion.run_all_ingestions('/data/raw')

ingest_task = PythonOperator(
    task_id='ingest_raw_data',
    python_callable=run_ingestion,
    dag=dag
)

# Task 2: Load dimensions
load_dim_date = PostgresOperator(
    task_id='load_dim_date',
    postgres_conn_id='postgres_default',
    sql='/opt/airflow/sql/warehouse/dim_date.sql',
    dag=dag
)

load_dim_customer = PostgresOperator(
    task_id='load_dim_customer',
    postgres_conn_id='postgres_default',
    sql='/opt/airflow/sql/warehouse/dim_customer.sql',
    dag=dag
)

# Task 3: Load facts
load_fact_sales = PostgresOperator(
    task_id='load_fact_sales',
    postgres_conn_id='postgres_default',
    sql='/opt/airflow/sql/warehouse/fact_sales.sql',
    dag=dag
)

# Task dependencies
ingest_task >> [load_dim_date, load_dim_customer] >> load_fact_sales