-- Top 10 artists with the highest number of tracks in the Top 100
SELECT 
    a.artist_name, 
    COUNT(*) AS total_tracks_in_top_100
FROM SPOTIFY_DB.SPOTIFY_TOP_100.SONGS s
JOIN SPOTIFY_DB.SPOTIFY_TOP_100.ARTISTS a 
    ON a.artist_id = s.artist_id
GROUP BY a.artist_name
ORDER BY total_tracks_in_top_100 DESC
LIMIT 10;

-- Analyze the average popularity of songs added in the last quarter
WITH quarter_analysis AS (
    SELECT 
        *, 
        CASE 
            -- Define songs added in the last 3 months
            WHEN EXTRACT(MONTH FROM added_date) >= EXTRACT(MONTH FROM GETDATE()) - 3 
            THEN 'yes' 
            ELSE 'no' 
        END AS last_quarter
    FROM SPOTIFY_DB.SPOTIFY_TOP_100.SONGS
)
SELECT 
    last_quarter, 
    ROUND(AVG(popularity), 2) AS avg_popularity
FROM quarter_analysis
GROUP BY last_quarter;

-- Combined analysis of artists: Popularity, average song duration, and rankings
WITH artist_statistics AS (
    -- Step 1: Calculate artist statistics (average popularity, average duration, and appearances in Top 100)
    SELECT 
        a.artist_name,
        a.artist_id,
        ROUND(AVG(s.popularity), 2) AS avg_popularity_score,
        ROUND(AVG(s.song_duration_ms / 1000), 2) AS avg_song_duration_min,
        COUNT(*) AS track_appearances_in_top_100
    FROM SPOTIFY_DB.SPOTIFY_TOP_100.SONGS s
    JOIN SPOTIFY_DB.SPOTIFY_TOP_100.ARTISTS a 
        ON a.artist_id = s.artist_id
    GROUP BY a.artist_name, a.artist_id
),
album_statistics AS (
    -- Step 2: Calculate the total number of tracks for each artist from their albums
    SELECT 
        a.artist_id,
        SUM(a.total_tracks) AS total_tracks_in_album
    FROM SPOTIFY_DB.SPOTIFY_TOP_100.ALBUMS a
    JOIN SPOTIFY_DB.SPOTIFY_TOP_100.SONGS s 
        ON s.album_id = a.album_id
    GROUP BY a.artist_id
),
final_table AS (
    -- Step 3: Merge artist statistics and rank artists by average popularity score
    SELECT 
        artist_statistics.artist_name,
        artist_statistics.avg_popularity_score,
        artist_statistics.avg_song_duration_min,
        artist_statistics.track_appearances_in_top_100,
        album_statistics.total_tracks_in_album,
        RANK() OVER(ORDER BY artist_statistics.avg_popularity_score DESC) AS ranking
    FROM artist_statistics
    JOIN album_statistics 
        ON artist_statistics.artist_id = album_statistics.artist_id
)
-- Step 4: Retrieve the top 5 and bottom 5 artists based on ranking
SELECT 
    artist_name,
    avg_popularity_score,
    avg_song_duration_min,
    track_appearances_in_top_100,
    total_tracks_in_album
FROM final_table
WHERE ranking <= 5 
   OR ranking >= (SELECT MAX(ranking) - 4 FROM final_table);

-- Retrieve the song with the highest popularity
SELECT 
    song_name, 
    popularity
FROM SPOTIFY_DB.SPOTIFY_TOP_100.SONGS
WHERE popularity = (SELECT MAX(popularity) FROM SPOTIFY_DB.SPOTIFY_TOP_100.SONGS);
