# ShopZada Data Warehouse Project

## Overview
This project implements a comprehensive Data Warehouse solution for ShopZada, a global e-commerce company, using a Kimball star schema methodology. The solution integrates heterogeneous datasets from Business, Customer Management, Enterprise, Marketing, and Operations departments into a unified analytical platform.

**Key Features:**
- **Heterogeneous Data Sources**: Handles Excel, CSV, Parquet, Pickle, JSON, and HTML files
- **Automated ETL Pipeline**: Apache Airflow orchestrates the entire data workflow
- **Data Quality Assurance**: Comprehensive validation and monitoring
- **BI-Ready Presentation Layer**: Optimized views and materialized aggregates
- **Containerized Infrastructure**: Complete Docker setup for reproducible environments

## Architecture
The DWH follows a three-layer architecture:
- **Staging Layer**: Raw data ingestion from heterogeneous sources with minimal transformation
- **Warehouse Layer**: Kimball star schema with conformed dimensions and facts
- **Presentation Layer**: Analytical views, materialized aggregates, and BI-ready structures

## Technology Stack
- **Database**: PostgreSQL 15 (containerized)
- **Orchestration**: Apache Airflow 2.7.3
- **BI Tool**: Metabase (latest)
- **Ingestion**: Python (pandas, SQLAlchemy) with multi-format support
- **Containerization**: Docker Compose
- **Data Quality**: Custom Python validation framework

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git (for cloning the repository)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/Luis-Jay/DWH-ShopZada-Group1.git
   cd dwh_finalproject_3CSD_group1
   ```

2. **Start the infrastructure**
   ```bash
   docker-compose -f infra/docker-compose.yml up --build -d
   ```

3. **Verify services are running**
   ```bash
   docker-compose ps
   ```
   Expected output:
   - Postgres: healthy (port 5432)
   - Airflow: healthy (http://localhost:8080, admin/admin)
   - Metabase: running (http://localhost:3000)

4. **Data Sources**
   Raw data files are pre-loaded in `Project Dataset/` directory with the following structure:
   ```
   Project Dataset/
   ├── Business Department/ (Excel)
   ├── Customer Management Department/ (Pickle, JSON, CSV)
   ├── Enterprise Department/ (HTML, Parquet, CSV)
   ├── Marketing Department/ (CSV)
   └── Operations Department/ (CSV, Parquet, JSON, HTML, Excel)
   ```

5. **Run the ETL pipeline**
   - Access Airflow UI at http://localhost:8080 (username: admin, password: admin)
   - Enable the `shopzada_dwh_etl_pipeline_v2` DAG
   - Trigger manual run or wait for scheduled execution (daily at 06:00)

6. **Access BI Dashboard**
   - Open Metabase at http://localhost:3000
   - First-time setup: Create admin account
   - Add Postgres database connection:
     - Host: postgres
     - Database: shopzada_dwh
     - User: shopzada
     - Password: shopzada123
   - Explore available views: view_customer_segments, view_campaign_effectiveness, view_merchant_performance
   - Use materialized view: mat_agg_daily_sales for time-series analysis

## Project Structure
```
dwh_finalproject_3CSD_group1/
├── infra/
│   ├── docker-compose.yml
│   └── .env
├── scripts/
│   ├── ingest/
│   │   └── ingest_to_postgres.py
│   ├── transform/
│   │   ├── build_star_schema.sql
│   │   └── warehouse/
│   └── quality/
│       └── dq_checks.py
├── workflows/
│   └── airflow_dags/
│       └── shopzada_pipeline_dag.py
├── sql/
│   ├── ddl/
│   │   ├── staging_schema.sql
│   │   ├── warehouse_schema.sql
│   │   └── presentation_schema.sql
│   ├── views/
│   └── materialized/
├── dashboard/
│   └── metabase_notes.md
├── docs/
│   ├── README.md
│   └── data_dictionary.xlsx
├── presentation/
│   └── deck.pptx
└── test/
    ├── test_ingest.py
    └── test_transforms.py
```

## Data Dictionary
See `docs/data_dictionary.xlsx` for complete field definitions and mappings.

## Troubleshooting

### Common Issues

1. **Port conflicts**
   ```bash
   # Check if ports are available
   netstat -tulpn | grep :5432
   # Stop conflicting services or change ports in docker-compose.yml
   ```

2. **Database connection issues**
   ```bash
   # Check container logs
   docker-compose logs postgres
   # Verify environment variables in .env file
   ```

3. **Airflow DAG not appearing**
   ```bash
   # Restart Airflow scheduler
   docker-compose restart airflow-scheduler
   # Check DAG folder permissions
   ```

4. **Metabase connection failed**
   - Ensure Postgres container is healthy
   - Verify database credentials
   - Check network connectivity between containers

### Logs and Monitoring
- **Application logs**: `docker-compose logs <service-name>`
- **Database logs**: `docker-compose logs postgres`
- **Airflow logs**: Available in Airflow UI under DAG runs

## Development

### Running Tests
```bash
# Run all tests
python -m pytest test/

# Run specific test file
python -m pytest test/test_ingest.py
```

### Code Quality
- Follow PEP 8 style guidelines
- Add docstrings to all functions
- Include unit tests for new functionality
- Update documentation for any changes

## Contributing
1. Create a feature branch
2. Make changes with tests
3. Update documentation
4. Submit pull request

## License
This project is part of the ShopZada Data Engineering course final project.

## Support
For issues or questions, please create an issue in the repository or contact the development team.
