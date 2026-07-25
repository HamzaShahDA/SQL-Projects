# Layoffs Data Cleaning

This project uses SQL Server to clean a dataset containing global company-layoff records.

## Dataset

The dataset includes information such as:

* Company
* Location
* Industry
* Number of employees laid off
* Layoff percentage
* Date
* Company stage
* Country
* Funds raised

The original dataset is available in the [`data`](./data) folder.

## Cleaning Process

The SQL script:

* Creates a staging table
* Copies the original data into the staging table
* Identifies duplicate records using `ROW_NUMBER()`
* Prepares the dataset for additional cleaning and analysis
* Preserves the original imported data

## Files

```text
layoffs-analysis/
├── data/
│   └── layoffs.csv
├── sql/
│   └── layoffs-data-cleaning.sql
└── README.md
```

## Tools Used

* SQL Server
* DBeaver
* Git
* GitHub

## Running the Project

1. Import `layoffs.csv` into SQL Server.
2. Open `layoffs-data-cleaning.sql`.
3. Update the database or table names where necessary.
4. Run the queries section by section.
5. Check the staging-table results before modifying records.
