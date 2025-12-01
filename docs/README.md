# ShopZada Data Warehouse Project

## Overview
This project implements a comprehensive Data Warehouse solution for ShopZada, a global e-commerce company, using a Kimball star schema methodology. The solution integrates fragmented data from Business, Customer Management, Enterprise, Marketing, and Operations departments into a unified analytical platform.

## Architecture
The DWH follows a three-layer architecture:
- **Staging Layer**: Raw data ingestion with minimal transformation
- **Warehouse Layer**: Kimball star schema with dimensions and facts
- **Presentation Layer**: Analytical views and aggregates for BI consumption

## Technology Stack
- **Database**: PostgreSQL 15 (containerized)
- **Orchestration**: Apache Airflow 2.7.3
- **BI Tool**: Metabase (latest)
- **Ingestion**: Python (pandas, SQLAlchemy)
- **Containerization**: Docker Compose

## Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Git (for cloning the repository)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dwh_finalproject_3CSD_group1
   ```

2. **Start the infrastructure**
   ```bash
   docker-compose -f infra/docker-compose.yml up -d
   ```

3. **Verify services are running**
   ```bash
   docker-compose ps
   ```
   Expected output:
   - Postgres: http://localhost:5432
   - Airflow: http://localhost:8080 (admin/admin)
   - Metabase: http://localhost:3000

4. **Load sample data**
   Place CSV files in the `sql/data/raw/` directory:
   - `business.csv`
   - `customer.csv`
   - `enterprise.csv`
   - `transactional_data.csv`
   - `campaign_data.csv`
   - `operations.csv`

5. **Run the ETL pipeline**
   - Access Airflow UI at http://localhost:8080
   - Enable the `shopzada_dwh_pipeline` DAG
   - Trigger manual run or wait for scheduled execution

6. **Access BI Dashboard**
   - Open Metabase at http://localhost:3000
   - Connect to Postgres database (host: postgres, db: shopzada_dwh)
   - Create dashboard with the provided SQL queries

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
