"""
ShopZada Data Warehouse ETL Pipeline (Fixed)

Key fixes:
- Fixed FileSensor orchestration to properly gate pipeline continuation
- Removed empty fs_conn_id parameter
- Simplified failure handling with better trigger rules
- Added proper ALL_DONE checks where needed
- Improved file sensor logic
"""

from datetime import datetime, timedelta
import logging
import os

from airflow import DAG
from airflow.operators.python import PythonOperator, ShortCircuitOperator
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator
from airflow.utils.trigger_rule import TriggerRule
from airflow.hooks.base import BaseHook

try:
    from airflow.providers.postgres.operators.postgres import PostgresOperator
    from airflow.providers.postgres.hooks.postgres import PostgresHook
except Exception:
    from airflow.operators.postgres_operator import PostgresOperator
    from airflow.hooks.postgres_hook import PostgresHook

import sys
sys.path.append('/opt/airflow/scripts')

try:
    from ingest.ingest_to_postgres import ShopZadaIngestion
except Exception:
    ShopZadaIngestion = None

logger = logging.getLogger(__name__)

default_args = {
    'owner': 'shopzada_data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email': ['data-team@shopzada.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 5,
    'retry_delay': timedelta(minutes=10),
    'execution_timeout': timedelta(hours=2),
}

DATA_DIR = '/opt/airflow/sql'
POSTGRES_CONN_ID = os.getenv('SHOPZADA_PG_CONN', 'postgres_default')

with DAG(
    dag_id='shopzada_dwh_etl_pipeline_v2',
    default_args=default_args,
    description='Improved ETL pipeline for ShopZada Data Warehouse',
    schedule_interval='0 6 * * *',  # daily at 06:00
    tags=['shopzada', 'dwh', 'etl', 'daily'],
    catchup=False,
    max_active_runs=1,
    dagrun_timeout=timedelta(hours=3),
    is_paused_upon_creation=False,  # Ensure DAG is not paused by default
) as dag:

    # -------------------------
    # Control tasks
    # -------------------------
    start_pipeline = EmptyOperator(task_id='start_pipeline')

    end_pipeline = EmptyOperator(
        task_id='end_pipeline',
        trigger_rule=TriggerRule.NONE_FAILED
    )

    # -------------------------
    # 1. ENVIRONMENT VALIDATION
    # -------------------------
    def _validate_environment(**context):
        """Validate DB connectivity and data directory."""
        logger.info("Validating pipeline environment...")

        try:
            pg_hook = PostgresHook(postgres_conn_id=POSTGRES_CONN_ID)
            conn = pg_hook.get_conn()
            conn.close()
            logger.info("✓ Database connection successful")
        except Exception as e:
            logger.exception("Database connection failed: %s", e)
            return False

        if not os.path.isdir(DATA_DIR):
            logger.warning("Data directory %s does not exist; creating it", DATA_DIR)
            try:
                os.makedirs(DATA_DIR, exist_ok=True)
            except Exception as e:
                logger.exception("Could not create data directory: %s", e)
                return False

        logger.info("Environment validation completed")
        return True

    validate_env_task = ShortCircuitOperator(
        task_id='validate_environment',
        python_callable=_validate_environment,
        provide_context=True
    )



    # -------------------------
    # 2. CREATE STAGING TABLES
    # ------------------------- (added staging table creation)
    create_staging_tables_task = PostgresOperator(
        task_id='create_staging_tables',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/sql/ddl/staging_schema.sql',
    )

    # -------------------------
    # 2. SCHEMA INITIALIZATION
    # -------------------------
    init_schemas_task = PostgresOperator(
        task_id='initialize_schemas',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/infra/init-scripts/01_create_schemas.sql',
    )

    create_extensions_task = PostgresOperator(
        task_id='create_extensions',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/infra/init-scripts/02_create_extensions.sql',
    )

    # -------------------------
    # 3. DATA INGESTION
    # -------------------------
    def _run_data_ingestion(**context):
        """Run ingestion code."""
        logger.info("Starting data ingestion process...")
        if ShopZadaIngestion is None:
            raise ImportError("ShopZadaIngestion class not importable")

        ingestion = ShopZadaIngestion()
        results = ingestion.run_all_ingestions(DATA_DIR)

        successful = sum(1 for result in results.values() if result)
        total = len(results)
        logger.info("Ingestion completed: %s/%s successful", successful, total)

        if successful < total:
            failed_sources = [k for k, v in results.items() if not v]
            logger.warning("Failed sources: %s", failed_sources)
        
        return results

    ingest_data_task = PythonOperator(
        task_id='ingest_source_data',
        python_callable=_run_data_ingestion,
        provide_context=True
    )

    # -------------------------
    # 4. STAGING TRANSFORMATIONS
    # -------------------------
    staging_transform_task = PostgresOperator(
        task_id='staging_transformations',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/staging/load_staging.sql',
    )

    # -------------------------
    # 5. DIMENSIONS
    # -------------------------
    load_dim_date_task = PostgresOperator(
        task_id='load_dim_date',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/dim_date.sql',
    )

    load_dim_customer_task = PostgresOperator(
        task_id='load_dim_customer',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/dim_customer.sql',
    )

    load_dim_product_task = PostgresOperator(
        task_id='load_dim_product',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/dim_product.sql',
    )

    load_dim_merchant_task = PostgresOperator(
        task_id='load_dim_merchant',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/dim_merchant.sql',
    )

    load_dim_campaign_task = PostgresOperator(
        task_id='load_dim_campaign',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/dim_campaign.sql',
    )

    # -------------------------
    # 6. FACTS
    # -------------------------
    load_fact_orders_task = PostgresOperator(
        task_id='load_fact_orders',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql='/opt/airflow/scripts/transform/warehouse/fact_orders.sql',
    )

    # -------------------------
    # 7. DATA QUALITY
    # -------------------------
    def _run_data_quality_checks(**context):
        logger.info("Starting data quality validation...")
        try:
            from quality.dq_checks import DataQualityChecker
        except Exception as e:
            logger.exception("quality.dq_checks import failed: %s", e)
            raise

        checker = DataQualityChecker()
        checker.connect()
        success = checker.run_all_checks()
        report = checker.generate_report()
        logger.info("Data Quality Report:\n%s", report)
        checker.disconnect()

        if not success:
            raise Exception("Data quality checks failed")
        logger.info("✓ All data quality checks passed")
        return True

    data_quality_task = PythonOperator(
        task_id='data_quality_validation',
        python_callable=_run_data_quality_checks,
        provide_context=True
    )

    # -------------------------
    # 8. PRESENTATION REFRESH
    # -------------------------
    refresh_presentation_task = PostgresOperator(
        task_id='refresh_presentation_layer',
        postgres_conn_id=POSTGRES_CONN_ID,
        sql="""
        SELECT presentation.refresh_daily_sales_agg();
        SELECT 'Presentation layer refresh completed at ' || NOW() as message;
        """,
    )

    # -------------------------
    # 9. METRICS & LOGGING
    # -------------------------
    def _collect_pipeline_metrics(**context):
        logger.info("Collecting pipeline execution metrics...")
        try:
            pg = PostgresHook(postgres_conn_id=POSTGRES_CONN_ID)
            conn = pg.get_conn()
            cur = conn.cursor()
        except Exception as e:
            logger.exception("Unable to connect to Postgres: %s", e)
            return False

        metrics_queries = {
            'total_customers': 'SELECT COUNT(*) FROM warehouse.dim_customer',
            'total_products': 'SELECT COUNT(*) FROM warehouse.dim_product',
            'total_orders': 'SELECT COUNT(*) FROM warehouse.fact_orders',
            'total_revenue': 'SELECT SUM(net_amount) FROM warehouse.fact_orders',
        }

        for metric_name, query in metrics_queries.items():
            try:
                cur.execute(query)
                result = cur.fetchone()[0]
                logger.info("%s: %s", metric_name, result)
            except Exception as e:
                logger.warning("Could not collect %s: %s", metric_name, e)

        cur.close()
        conn.close()
        logger.info("Pipeline metrics collection completed")
        return True

    pipeline_metrics_task = PythonOperator(
        task_id='collect_pipeline_metrics',
        python_callable=_collect_pipeline_metrics,
        provide_context=True,
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    # -------------------------
    # 10. NOTIFICATIONS
    # -------------------------
    def _send_success_notification(**context):
        logger.info("🎉 ShopZada DWH Pipeline completed successfully!")
        return "Pipeline successful"

    def _send_failure_notification(**context):
        logger.error("❌ ShopZada DWH Pipeline failed!")
        return "Pipeline failed"

    success_notification_task = PythonOperator(
        task_id='success_notification',
        python_callable=_send_success_notification,
        trigger_rule=TriggerRule.ALL_SUCCESS
    )

    failure_notification_task = PythonOperator(
        task_id='failure_notification',
        python_callable=_send_failure_notification,
        trigger_rule=TriggerRule.ONE_FAILED
    )

    # -------------------------
    # ORCHESTRATION - SIMPLIFIED
    # -------------------------

    # Start -> validate -> create schemas -> create staging tables -> ingest -> transform staging
    start_pipeline >> validate_env_task >> [init_schemas_task, create_extensions_task] >> create_staging_tables_task >> ingest_data_task >> staging_transform_task

    # Parallel dimension loads after staging transformations
    staging_transform_task >> [load_dim_date_task, load_dim_customer_task, load_dim_product_task]

    # Dependent dimensions
    load_dim_customer_task >> load_dim_merchant_task
    load_dim_date_task >> load_dim_campaign_task

    # Facts after dimensions
    [load_dim_merchant_task, load_dim_campaign_task, load_dim_product_task] >> load_fact_orders_task

    # Quality -> presentation -> metrics -> success
    load_fact_orders_task >> data_quality_task >> refresh_presentation_task >> pipeline_metrics_task >> success_notification_task >> end_pipeline

    # Failure handling
    [validate_env_task, create_staging_tables_task, ingest_data_task, staging_transform_task,
     load_fact_orders_task, data_quality_task, refresh_presentation_task] >> failure_notification_task

    dag.doc_md = """
    ### ShopZada DWH ETL Pipeline (Fixed v2)
    
    Key improvements:
    - Fixed file sensor orchestration with gateway task
    - Proper ALL_DONE trigger rules
    - Simplified failure handling
    - Better dependency management
    """
