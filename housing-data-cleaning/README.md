# Housing Data Cleaning

This project uses SQL Server to clean a housing-sales dataset while preserving the original imported table.

## Dataset

The dataset contains property-sale records such as parcel identifiers, sale dates, property and owner addresses, sale prices, legal references, and property details.

The original CSV file is available in the [`data`](./data) folder.

## Cleaning Steps

The SQL script:

- Creates a separate working table from the imported dataset
- Converts sale dates into a dedicated `date` column
- Fills missing property addresses using other records with the same parcel identifier
- Splits property addresses into address and city columns
- Splits owner addresses into address, city, and state columns
- Standardizes `Y` and `N` values in `SoldAsVacant`
- Removes duplicate records using a CTE and `ROW_NUMBER()`
- Removes source address columns from the cleaned working table after validation

## Files

```text
housing-data-cleaning/
├── data/
│   └── housing-data.csv
├── sql/
│   └── housing-data-cleaning.sql
└── README.md
```

## Running the Project

1. Import `housing-data.csv` into SQL Server.
2. Name the imported table `Nashville Housing Data for Data Cleaning (reuploaded)`, or update the source-table name in the script.
3. Open `housing-data-cleaning.sql` in DBeaver or another SQL Server client.
4. Run the script section by section.
5. Review the final `nashville_housing_clean` table.

The script recreates the cleaned working table when it is run, while leaving the original imported table unchanged.
