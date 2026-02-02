-- Core Movie Data  
  
SELECT 
    d.director AS director,
	  w.writer AS writer,
    m.title AS title,
    CONVERT(DATE, m.release_date) AS release_date,
    genre AS genre,
    m.runtime AS runtime,
    m.budget AS budget,
    m.gross AS gross,
    (m.gross - m.budget) / m.budget AS roi
FROM 
    Movies m
JOIN 
    Directors d ON m.director_id = d.id
JOIN 
	Writers w ON w.id = m.writer_id
JOIN 
	Genres g ON m.genre_id = g.id
WHERE YEAR(release_date) > '1990'
	AND m.budget IS NOT NULL
	AND rating IS NOT NULL
  AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity') -- Removed these outliers, as their ROIs are astronomically high.
	AND rating IN('G', 'PG', 'PG-13', 'R', 'NC-17');

-- Which genres have the highest ROI percentage? 

WITH genre_roi AS (
    SELECT
        g.genre AS genre,
        AVG(m.gross) AS avg_gross,
        AVG(m.budget) AS avg_budget,
        AVG(m.gross - m.budget) AS avg_profit,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi,
		COUNT(*) AS num_movies
    FROM Movies m
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE m.budget IS NOT NULL 
	    AND YEAR(release_date) > 1990 
	    AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity') 
    GROUP BY g.genre
)

SELECT
    genre,
    ROUND(avg_gross, 0) AS avg_gross,
    ROUND(avg_budget, 0) AS avg_budget,
    ROUND(avg_profit, 0) AS avg_profit,
    ROUND(avg_roi * 100, 0) AS avg_roi_percentage,
	num_movies AS num_movies
FROM genre_roi
WHERE num_movies > 2 
ORDER BY avg_roi DESC;

-- Find the average ROI by genre and rating.

SELECT 
    genre,
    rating,
    COUNT(*) AS num_movies,
    ROUND(AVG((gross - budget) / budget) * 100, 2) AS avg_roi_percentage
FROM
    Movies m
        JOIN
    Genres g ON m.genre_id = g.id
WHERE
    budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project' , 'Paranormal Activity')
        AND rating IN ('G' , 'R', 'PG', 'PG-13', 'Not Rated', 'NC-17')
        AND YEAR(release_date) > 1990
GROUP BY genre , rating
HAVING COUNT(*) > 5
ORDER BY avg_roi_percentage DESC;

-- Find the ROI by genre and release month.

WITH monthly_genre_roi AS (
    SELECT
        DATENAME(MONTH, m.release_date) AS release_month,
        g.genre AS genre,
        AVG(m.gross) AS avg_gross,
        AVG(m.budget) AS avg_budget,
        AVG(m.gross - m.budget) AS avg_profit,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi,
		COUNT(*) AS num_movies
    FROM Movies m
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE
        m.budget > 0
        AND m.budget IS NOT NULL
        AND m.title NOT IN ('The Blair Witch Project', 'Paranormal Activity', 'The Gallows') -- Removed "The Gallows" because it caused the average ROI to go from 917% to 6160%
		    AND YEAR(release_date) > 1990
    GROUP BY DATENAME(month, m.release_date), g.genre
)

SELECT
    release_month,
    genre,
    ROUND(avg_gross, 0) AS avg_gross,
    ROUND(avg_budget, 0) AS avg_budget,
    ROUND(avg_profit, 0) AS avg_profit,
    ROUND(avg_roi * 100, 0) AS avg_roi_percentage,
	num_movies AS Num_movies
FROM monthly_genre_roi
WHERE num_movies > 2
ORDER BY avg_roi_percentage DESC, release_month;

-- Find the ROI by runtime for all movies across all genres.

WITH runtime_category_movies AS (
    SELECT
        CASE
            WHEN runtime <= 90 THEN 'Under 90 minutes'
            WHEN runtime <= 120 THEN '90-120 minutes'
            WHEN runtime <= 150 THEN '120-150 minutes'
            ELSE 'Over 150 minutes'
        END AS runtime_category,
        (gross - budget) / budget AS roi
    FROM Movies
    WHERE budget IS NOT NULL 
		  AND YEAR(release_date) >1990
      AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
)

SELECT
    runtime_category,
    ROUND(AVG(roi),2) * 100 AS avg_roi
FROM runtime_category_movies
GROUP BY runtime_category
ORDER BY avg_roi DESC;

-- Find the ROI for movies based on genre and runtime.

SELECT 
    TOP 10 genre,
    CASE
        WHEN runtime < 90 THEN 'Under 90 minutes'
        WHEN runtime BETWEEN 90 AND 120 THEN '90-120 minutes'
        WHEN runtime BETWEEN 121 AND 150 THEN '121-150 minutes'
        ELSE 'Over 150 minutes'
    END AS runtime_category,
	COUNT(*) AS num_movies,
    AVG((gross - budget) / budget) * 100 AS avg_roi
FROM 
    Movies m
JOIN Genres g
ON m.genre_id = g.id
WHERE 
    budget IS NOT NULL -- Filter out NULL values
	AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
	AND YEAR(release_date) > '1990'
GROUP BY 
    genre, 
    CASE
        WHEN runtime < 90 THEN 'Under 90 minutes'
        WHEN runtime BETWEEN 90 AND 120 THEN '90-120 minutes'
        WHEN runtime BETWEEN 121 AND 150 THEN '121-150 minutes'
        ELSE 'Over 150 minutes'
    END
HAVING COUNT(*) > 2
ORDER BY avg_roi DESC;

-- Find the ROI by runtime for horror movies. 

SELECT
    runtime_category,
    ROUND(AVG(roi), 2) AS avg_roi
FROM (
    SELECT
        CASE
            WHEN runtime <= 90 THEN 'Under 90 minutes'
            WHEN runtime <= 120 THEN '90-120 minutes'
            WHEN runtime <= 150 THEN '120-150 minutes'
            ELSE 'Over 150 minutes'
        END AS runtime_category,
        (gross - budget) / budget AS roi
    FROM Movies m
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE budget IS NOT NULL 
	AND genre = 'horror'
	AND YEAR(release_date) > 1990
  AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
) AS runtime_category_movies
GROUP BY runtime_category
ORDER BY avg_roi DESC;

-- Find the director with the highest average ROI in each genre, where the director has made more than 2 movies in that genre.

WITH director_genre_avg_roi AS (
    SELECT
        d.director AS director_name,
        g.genre AS genre,
		COUNT(*) AS num_movies,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi
    FROM Directors d
    JOIN Movies m ON d.id = m.director_id
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE m.budget IS NOT NULL
      AND YEAR(release_date) > '1990'
    GROUP BY d.director, g.genre
	HAVING COUNT(*) > 2
)

SELECT
    genre,
    director_name,
	num_movies,
    ROUND(avg_roi * 100, 2) AS avg_roi_percentage
FROM (
    SELECT
        genre,
        director_name,
		num_movies,
        avg_roi,
        ROW_NUMBER() OVER (PARTITION BY genre ORDER BY avg_roi DESC) AS row_num
    FROM director_genre_avg_roi
) ranked_directors
WHERE row_num = 1
ORDER BY avg_roi_percentage DESC;

-- Find the ROI for directors by genre with 2+ movies in that genre. 

WITH director_genre_roi AS (
    SELECT 
        g.genre,
		m.director_id,
        d.director,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi,
        COUNT(*) AS num_movies
    FROM 
        Movies m
    JOIN 
        Directors d ON m.director_id = d.id
	JOIN 
		Genres g ON m.genre_id = g.id
	WHERE budget IS NOT NULL
		AND YEAR(release_date) > '1990'
		AND m.budget IS NOT NULL
		AND rating IS NOT NULL
		AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
		AND rating IN('G', 'PG', 'PG-13', 'R', 'NC-17')
    GROUP BY 
        g.genre, m.director_id, d.director
    HAVING 
        COUNT(*) > 2  
)
SELECT 
    genre,
    director,
	director_id,
	num_movies,
    avg_roi
FROM 
    director_genre_roi
WHERE avg_roi > 0
ORDER BY avg_roi DESC;

-- Find the highest average ROI by horror movie directors with more than 2 movies in the genre.

WITH horror_movies AS (
    SELECT
        d.director AS director,
        COUNT(*) AS movie_count, 
        AVG((m.gross - m.budget) / m.budget) AS avg_roi
    FROM Movies m
    JOIN Directors d ON m.director_id = d.id
	JOIN Genres g ON m.genre_id = g.id
    WHERE g.genre = 'Horror'
        AND m.budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
		AND YEAR(release_date) > '1990'
    GROUP BY d.director
    HAVING COUNT(*) > 2
)

SELECT
    TOP 10 director,
    movie_count, 
    ROUND(avg_roi * 100, 2) AS avg_roi_percentage
FROM horror_movies
ORDER BY avg_roi_percentage DESC;

-- Find the ROI for horror writers where their ROI in that genre is higher than the average ROI for all movies.

WITH horror_movies AS ( -- average ROI for all horror movies
    SELECT
        w.writer AS writer,
        COUNT(*) AS movie_count,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi
    FROM Movies m
    JOIN Writers w ON m.writer_id = w.id
    JOIN Genres g ON m.genre_id = g.id
    WHERE g.genre = 'horror'
        AND m.budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
        AND YEAR(release_date) > '1990'
    GROUP BY w.writer
    HAVING COUNT(*) > 2 -- with more than 2 movies in the genre
),
all_movies_avg_roi AS ( -- average ROI for all movies
    SELECT AVG((gross - budget) / budget) AS overall_avg_roi
    FROM Movies
    WHERE budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
        AND YEAR(release_date) > '1990'
)

SELECT
    writer,
    movie_count, 
    ROUND(avg_roi * 100, 2) AS avg_roi_percentage
FROM horror_movies
CROSS JOIN all_movies_avg_roi -- This is only way to join the tables since they don't have a matching column.
WHERE avg_roi > overall_avg_roi -- ROI for horror writer must be higher than average ROI for all movies.
ORDER BY avg_roi_percentage DESC;

-- Find the ROI for writers by genre with 2+ movies in that genre.

WITH writer_genre_roi AS (
    SELECT 
        g.genre,
		m.writer_id,
        w.writer,
        AVG((m.gross - m.budget) / m.budget) AS avg_roi,
        COUNT(*) AS num_movies
    FROM 
        Movies m
    JOIN 
        Writers w ON m.writer_id = w.id
	JOIN 
		Genres g ON m.genre_id = g.id
	WHERE budget IS NOT NULL
		AND YEAR(release_date) > '1990'
		AND m.budget IS NOT NULL
		AND rating IS NOT NULL
		AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
		AND rating IN('G', 'PG', 'PG-13', 'R', 'NC-17')
    GROUP BY 
        g.genre, m.writer_id, w.writer
    HAVING 
        COUNT(*) > 2  -- Only consider writers with more than 2 movies in the genre
)
SELECT 
    genre,
    writer,
	writer_id,
	num_movies,
    avg_roi
FROM 
    writer_genre_roi
WHERE avg_roi > 0
ORDER BY avg_roi DESC;

-- How does a movie's score affect the average ROI? 

SELECT 
    score AS movie_score,
    ROUND(AVG(gross), 0) AS avg_gross,
    ROUND(AVG(budget), 0) AS avg_budget,
    ROUND(AVG(gross - budget), 0) AS avg_profit,
    ROUND(AVG((gross - budget) / budget) * 100, 2) AS avg_roi_percentage
FROM
    Movies
WHERE
    budget IS NOT NULL
    AND title NOT IN ('The Blair Witch Project' , 'Paranormal Activity', 'The Gallows')
    AND YEAR(release_date) > '1990'
GROUP BY score
ORDER BY avg_roi_percentage DESC;

-- Find the percentage of the total ROI for the horror movie genre based on budget category.

WITH horror_movies_budget AS (
    SELECT
        CASE
            WHEN budget <= 10000000 THEN 'Under $10 million'
            WHEN budget <= 20000000 THEN '$10-20 million'
            WHEN budget <= 30000000 THEN '$20-30 million'
            WHEN budget <= 40000000 THEN '$30-40 million'
            WHEN budget <= 50000000 THEN '$40-50 million'
            ELSE 'Over $50 million'
        END AS budget_category,
        (gross - budget) / budget AS roi
    FROM Movies m
	JOIN 
	Genres g ON m.genre_id = g.id
    WHERE genre = 'Horror' 
          AND budget IS NOT NULL
          AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
          AND YEAR(release_date) > '1990'
)

SELECT
    hmb.budget_category,
    ROUND(AVG(roi) * 100, 2) AS avg_roi_percentage,
    (SUM(roi) / (SELECT SUM(roi) FROM horror_movies_budget)) * 100 AS percentage_of_total_roi
FROM horror_movies_budget hmb
GROUP BY hmb.budget_category
ORDER BY budget_category;

-- Find the average ROI for movies by genre and budget category.

WITH movies_budget AS (
    SELECT
		g.genre,
        CASE
            WHEN budget <= 10000000 THEN 'Under $10 million'
            WHEN budget <= 20000000 THEN '$10-20 million'
            WHEN budget <= 30000000 THEN '$20-30 million'
            WHEN budget <= 40000000 THEN '$30-40 million'
            WHEN budget <= 50000000 THEN '$40-50 million'
            WHEN budget <= 75000000 THEN '$50-75 million'
            WHEN budget <= 100000000 THEN '$75-100 million'
            WHEN budget <= 150000000 THEN '$100-150 million'
            WHEN budget <= 200000000 THEN '$150-200 million'
            WHEN budget <= 250000000 THEN '$200-250 million'
            ELSE 'Over $250 million'
        END AS budget_category,
        (gross - budget) / budget AS roi
    FROM Movies m
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE budget IS NOT NULL
          AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
          AND YEAR(release_date) > '1990'
)

SELECT
	genre,
    hmb.budget_category,
	COUNT(*) AS num_movies,
    ROUND(AVG(roi) * 100, 2) AS avg_roi_percentage
FROM movies_budget hmb
GROUP BY hmb.budget_category, genre
HAVING COUNT(*) > 2
ORDER BY avg_roi_percentage DESC;

-- Find the effect the MPAA Rating has on a movie's ROI. (NOTHING CONCLUSIVE) 

SELECT 
    m.rating AS mpaa_rating,
    ROUND(AVG((m.gross - m.budget) / m.budget) * 100,
            2) AS avg_roi_percentage
FROM
    Movies m
WHERE
    m.budget IS NOT NULL
        AND m.rating IS NOT NULL
        AND m.title NOT IN ('The Blair Witch Project' , 'Paranormal Activity')
        AND m.rating IN ('G' , 'PG', 'PG-13', 'R', 'NC-17')
        AND YEAR(release_date) > '1990'
GROUP BY m.rating
ORDER BY avg_roi_percentage DESC
