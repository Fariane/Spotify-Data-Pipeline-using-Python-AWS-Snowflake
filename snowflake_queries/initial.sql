-- Create the database
CREATE OR REPLACE DATABASE spotify_db;

-- Create the schema for top_100 data
CREATE OR REPLACE SCHEMA spotify_top_100;

-- Create a storage integration stage to connect to AWS S3
-- The storage integration 's3_init_spotify_bucket' must be configured in advance
CREATE OR REPLACE STAGE manage_db.external_stages.spotify_s3_bucket
    URL = 's3://spotify-etl-projet-fariane/transformed_data/'
    STORAGE_INTEGRATION = s3_init_spotify_bucket
    FILE_FORMAT = manage_db.file_formats.csv_file;

-- Define the CSV file format
CREATE OR REPLACE FILE FORMAT manage_db.file_formats.csv_file
    TYPE = 'CSV'
    FIELD_DELIMITER = ','             
    SKIP_HEADER = 1                   
    FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create table for albums
CREATE OR REPLACE TABLE spotify_db.spotify_top_100.albums (
    album_id STRING,
    album_name STRING,
    release_date DATE,
    total_tracks INT,
    album_url STRING
);

-- Create table for artists
CREATE OR REPLACE TABLE spotify_db.spotify_top_100.artists (
    artist_id STRING,
    artist_name STRING,
    artist_url STRING
);

-- Create table for songs
CREATE OR REPLACE TABLE spotify_db.spotify_top_100.songs (
    song_id STRING,
    song_name STRING,
    song_duration_ms INT,
    song_url STRING,
    popularity INT,
    added_date DATE,
    album_id STRING,
    artist_id STRING
);

-- Test the connection to the external S3 stage
LIST @manage_db.external_stages.spotify_s3_bucket;

-- Load data into the albums table
COPY INTO spotify_db.spotify_top_100.albums
FROM @manage_db.external_stages.spotify_s3_bucket
PATTERN = 'album_data/.*'
FORCE = TRUE;

-- Load data into the artists table
COPY INTO spotify_db.spotify_top_100.artists
FROM @manage_db.external_stages.spotify_s3_bucket
PATTERN = 'artist_data/.*'
FORCE = TRUE;

-- Load data into the songs table
COPY INTO spotify_db.spotify_top_100.songs
FROM @manage_db.external_stages.spotify_s3_bucket
PATTERN = 'song_data/.*'
FORCE = TRUE;

-- Verify the number of records in each table
SELECT COUNT(*) FROM spotify_db.spotify_top_100.albums;
SELECT COUNT(*) FROM spotify_db.spotify_top_100.artists;
SELECT COUNT(*) FROM spotify_db.spotify_top_100.songs;

-- Truncate tables for testing purposes
TRUNCATE TABLE spotify_db.spotify_top_100.albums;
TRUNCATE TABLE spotify_db.spotify_top_100.artists;
TRUNCATE TABLE spotify_db.spotify_top_100.songs;

-- Describe the S3 stage for debugging
DESC STAGE manage_db.external_stages.spotify_s3_bucket;
