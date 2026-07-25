# Housing Data Cleaning

This project uses SQL Server to clean and prepare a housing dataset for analysis.

## Dataset

The dataset contains property-sale records, including sale dates, addresses, parcel information, property details, and sale values.

The original dataset is available in the [`data`](./data) folder.

## Cleaning Tasks

The SQL script includes:

* Standardizing date values
* Identifying missing property addresses
* Filling missing addresses using matching parcel records
* Reviewing duplicate and inconsistent records
* Preparing the dataset for further analysis

## Files

```text
housing-data-cleaning/
├── data/
│   └── housing-data.csv
├── sql/
│   └── housing-data-cleaning.sql
└── README.md
```

## Tools Used

* SQL Server
* DBeaver
* Git
* GitHub

## Running the Project

1. Import `housing-data.csv` into SQL Server.
2. Open `housing-data-cleaning.sql`.
3. Update the database or table names where necessary.
4. Execute the queries section by section.
5. Review the results before running update or delete statements.
