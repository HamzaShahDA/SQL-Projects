# Layoffs Data Cleaning

This project uses SQL Server to clean a dataset of global company layoffs while preserving the original imported table.

## Dataset

The dataset contains:

- Company
- Location
- Industry
- Employees laid off
- Layoff percentage
- Date
- Company stage
- Country
- Funds raised

The original CSV file is available in the [`data`](./data) folder.

## Cleaning Steps

The SQL script:

- Creates a staging table from the original imported dataset
- Converts text representations of missing values into SQL `NULL`
- Trims company names
- Converts the original date field into a SQL `date` column
- Standardizes cryptocurrency industry values
- Standardizes United States country values
- Fills missing industries using matching company and location records
- Removes duplicate records using a CTE and `ROW_NUMBER()`
- Removes records where both layoff measures are missing

## Files

```text
layoffs-analysis/
├── data/
│   └── layoffs.csv
├── sql/
│   └── layoffs-data-cleaning.sql
└── README.md
```

## Running the Project

1. Import `layoffs.csv` into SQL Server.
2. Name the imported table `layoffs$`, or update the source-table name in the script.
3. Open `layoffs-data-cleaning.sql` in DBeaver or another SQL Server client.
4. Run the script section by section.
5. Review the final `layoffs_staging` table.

The script recreates the staging table when it is run, while leaving the original imported table unchanged.
