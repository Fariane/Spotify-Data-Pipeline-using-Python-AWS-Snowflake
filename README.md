#  🎵 Spotify Data Pipeline (ETL) Project Using Python, AWS & Snowflake

## Project Overview
This project involves implementing an ETL pipeline that utilizes the Spotify API, AWS, and Snowflake. The pipeline extracts music data (albums, artists, and tracks) from the Spotify API, transforms it using AWS Lambda, and stores the processed data in AWS S3. Finally, the data is ingested into Snowflake for meaningful analysis and visualization. 

## Architecture
![Architecture Diagram](spotify_pipeline_architecture_dgrm.png)

## Key Components

### Data Extraction
- **Spotify API:** Retrieve music data, including track details, artist information, and albums, using the Spotify API.
- **Authentication:** Implement OAuth 2.0 for secure access to the Spotify API.
- **Scheduling:** Use Amazon CloudWatch to trigger the pipeline on a daily basis to automatically extract the latest data
  
### Data Transformation
- **Data Cleaning:** Cleanse the raw data by handling missing values, duplicates, and inconsistencies.
- **Data Formatting:** Transform the data into structured formats (e.g., JSON or CSV) for compatibility with downstream processes.
- **Enrichment:** Add additional attributes or aggregate information to enhance the data for analysis.

### Data Loading
- **AWS S3:** Store both raw and processed data in AWS S3 for scalable and cost-effective storage.
- **Snowpipes:** Automatically loads transformed CSV files into Snowflake tables (`Album`, `Artist`, and `Songs`) as soon as they are detected in S3..


## Project Execution Flow
1. **Data Extraction:** AWS Lambda function is triggered daily via Amazon CloudWatch to extract data from the Spotify API. Extracted data is stored in Amazon S3 (raw data).

2. **Data Transformation:** Another Lambda function is triggered by S3 object put event. It transforms the raw data and stores it in another Amazon S3 bucket (transformed data).

3. **Data Loading:** Snowpipe automatically ingests transformed data into Snowflake tables for querying and analysis.


### Analytics
- **SQL Development:** SQL scripts enable meaningful analysis of the data ingested into Snowflake.

## Tools and Technologies

### Programming Languages :
- **Python** for API interactions and ETL scripting

### AWS Services:
- **AWS Lambda:** For data extraction and transformation.
- **Amazon CloudWatch:** To trigger Lambda functions on a scheduled basis.
- **Amazon S3:** For storing raw and transformed data.
  
### Data Warehouse
- **Snowflake:** Serves as the centralized data warehouse, with automated ingestion via Snowpipe.

### Libraries:
- `spotipy` for Spotify API interactions, 
- `pandas` for data manipulation,
- `boto3` for interacting with AWS services

## Benefits
- **Automation:** The ETL pipeline automates the entire data processing workflow, reducing manual effort and ensuring up-to-date data.
- **Scalability:** AWS services and Snowflake provide robust scalability to handle large data volumes efficiently.
- **Flexibility:** The modular design allows for easy integration with other data sources and analytics tools.

## Future Enhancements
- **Business Intelligence:** Integrate with BI tools such as Power BI or Tableau to develop advanced dashboards and insights.
- **Advanced Analytics:** Implement machine learning models to predict song popularity or detect trends in music genres.
- **Real-Time Streaming:** Consider transitioning to a real-time streaming solution to process live data from Spotify. 
