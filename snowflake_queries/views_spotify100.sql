-- Total Record Check View Creation
CREATE OR REPLACE VIEW TOTAL_RECORD_CHECK AS (
    WITH alb AS (
        SELECT COUNT(*) AS TOTAL_ALBUMS
        FROM ALBUMS
    ),
    art AS (
        SELECT COUNT(*) AS TOTAL_ARTISTS
        FROM ARTISTS
    ),
    song AS (
        SELECT COUNT(*) AS TOTAL_SONGS
        FROM SONGS
    )
    SELECT 
        alb.TOTAL_ALBUMS,
        art.TOTAL_ARTISTS,
        song.TOTAL_SONGS
    FROM alb, art, song
);

-- Top 5 Artists with Most Songs in the Top 100 Playlist
CREATE OR REPLACE VIEW TOP_10_ARTISTS AS (
    SELECT 
        a.ARTIST_NAME, 
        COUNT(*) AS "Total Tracks in Top 100"
    FROM SONGS s
    JOIN ARTISTS a 
        ON a.ARTIST_ID = s.ARTIST_ID
    GROUP BY a.ARTIST_NAME
    ORDER BY "Total Tracks in Top 100" DESC
    LIMIT 10
);

-- Average Popularity for Songs Added in the Last Quarter vs Older Songs
CREATE OR REPLACE VIEW TIME_POPULARITY_ANALYSIS AS (
    WITH quarter_analysis AS (
        SELECT 
            s.POPULARITY,
            CASE 
                WHEN EXTRACT(MONTH FROM s.ADDED_DATE) >= EXTRACT(MONTH FROM GETDATE()) - 3 
                THEN 'yes' 
                ELSE 'no' 
            END AS LAST_QUARTER
        FROM SONGS s
    )
    SELECT 
        LAST_QUARTER, 
        AVG(POPULARITY) AS AVERAGE_POPULARITY
    FROM quarter_analysis
    GROUP BY LAST_QUARTER
);

-- Top 5 and Bottom 5 Artists by Popularity, Song Duration, and Track Appearances
CREATE OR REPLACE VIEW TOP_BOT_ARTISTS_ANALYTICS AS (
    WITH cte1 AS (
        SELECT 
            a.ARTIST_NAME,
            a.ARTIST_ID,
            ROUND(AVG(s.POPULARITY), 2) AS "Avg Popularity Score",
            ROUND(AVG(s.SONG_DURATION_MS / 1000), 2) AS "Avg Song Duration/min",
            COUNT(*) AS "Track Appearances in Top 100"
        FROM SONGS s
        JOIN ARTISTS a 
            ON a.ARTIST_ID = s.ARTIST_ID
        GROUP BY a.ARTIST_NAME, a.ARTIST_ID
    ),
    cte2 AS (
        -- Total tracks for each artist across albums
        SELECT 
            a.ARTIST_ID, 
            SUM(a.TOTAL_TRACKS) AS "Total Tracks in Album"
        FROM ALBUMS a
        JOIN SONGS s 
            ON s.ALBUM_ID = a.ALBUM_ID
        GROUP BY a.ARTIST_ID
    ),
    final_table AS (
        -- Merging artist statistics and ranking by average popularity
        SELECT 
            cte1.ARTIST_NAME,
            "Avg Popularity Score",
            "Avg Song Duration/min",
            "Track Appearances in Top 100",
            "Total Tracks in Album",
            RANK() OVER(ORDER BY "Avg Popularity Score" DESC) AS RANKING
        FROM cte1
        JOIN cte2 
            ON cte1.ARTIST_ID = cte2.ARTIST_ID
    )
    -- Selecting the top 10 and bottom 10 artists based on ranking
    SELECT 
        ARTIST_NAME,
        "Avg Popularity Score",
        "Avg Song Duration/min",
        "Track Appearances in Top 100",
        "Total Tracks in Album"
    FROM final_table
    WHERE RANKING <= 10 
       OR RANKING >= (SELECT MAX(RANKING) - 9 FROM final_table)
);

-- Top Song Based on Popularity
CREATE OR REPLACE VIEW TOP_SONG AS (
    SELECT 
        SONG_NAME, 
        POPULARITY
    FROM SONGS
    WHERE POPULARITY = (SELECT MAX(POPULARITY) FROM SONGS)
);
