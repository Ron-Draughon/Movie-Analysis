# **How to Make $1 Billion by Maximizing ROI in Movie Production** 
*By Ron Draughon*

**Problem Statement:** Fledgling Movie Studio is standing on the precipice of a significant financial opportunity. Armed with $100 million in venture capital, the studio aims to produce a movie (or group of movies) with the highest possible Return on Investment (ROI). By generating the highest possible ROI for the investors of their upcoming movie(s), the studio aims to secure future investments, attract potential long-term partners, and position itself as a formidable player in the highly competitive film industry.

**Executive Summary:** In my analysis aimed at helping Fledgling Movie Studio maximize ROI for its upcoming movie (or movies), several key insights have been identified based on various influential factors such as genre, release date, budget, runtime, writers, and directors.

**Data Sources:** The dataset used for this analysis was sourced from Kaggle, available at [this link](https://www.kaggle.com/datasets/danielgrijalvas/movies). It comprises over 7,000 movies scraped from IMDb.

**Data Limitations:** It's important to acknowledge the limitations of the dataset used for analysis:

- The "genre" category was derived from selecting the first of two or three genres listed on the movie's IMDb page, leading to some misrepresentations in movie categorization.
- The sample size for some genres was skewed due to the methodology used in the data scraping. For instance, according to the dataset, the family genre only had 3 movies released since 1990, which is clearly inaccurate.
- To ensure a more accurate analysis, two movies with exceptionally high ROIs ("Paranormal Activity" 1,288,939% and "The Blair Witch Project" 414,299) were excluded due to their disproportionate influence on the results.

**Analysis Steps:**

1. **Data Extraction:** Retrieve relevant movie data from the dataset sourced from Kaggle.
1. **Data Cleaning and Formatting:** Cleanse and format the data in Excel, including handling missing values, duplicates, and inconsistencies.
1. **Data Transfer to SQL:** Transfer the cleaned and formatted data from Excel to SQL for further analysis.
1. **Data Transformation:** Perform necessary transformations such as calculating ROI, joining tables to gather relevant information, and grouping movies by genre, release month, rating, budget, runtime, writer, and director.

Here are the findings of my analysis based on movies released since 1990.

1. **Horror Genre Dominates in ROI:**

   
![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/918b43c7-46be-4f0f-a78e-c7c46eb4d982)


```
WITH GenreROI AS (
  SELECT
    g.genre AS Genre,
    AVG(m.gross) AS AvgGross,
    AVG(m.budget) AS AvgBudget,
    AVG(m.gross - m.budget) AS AvgProfit,
    AVG((m.gross - m.budget) / m.budget) AS AvgROI,
    COUNT(*) AS Num_movies
  FROM Movies m
  JOIN Genres g
  ON m.genre_id = g.id
  WHERE m.budget IS NOT NULL 
    AND YEAR(release_date) > 1990 
    AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
  GROUP BY g.genre
)

SELECT
  Genre,
  ROUND(AvgGross, 0) AS AvgGross,
  ROUND(AvgBudget, 0) AS AvgBudget,
  ROUND(AvgProfit, 0) AS AvgProfit,
  ROUND(AvgROI * 100, 0) AS AvgROI_Percentage,
  Num_movies
FROM GenreROI
WHERE Num_movies > 2 
ORDER BY AvgROI DESC;
```

- Horror movies significantly outperform movies from every other genre in terms of average ROI by almost 2-to-1, and almost 4 times the industry average of 274%.
- Horror movies also have less competition in the genre than movies in other genres.

2. **Genre and Release Month:**

**** "The Gallows" was removed from this segment of the analysis as its inclusion caused the ROI for horror movies in July to skyrocket to over 6000% (up from 580%).

![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/b8cdee8d-48f0-4fb6-accf-e4893d1661f7)

```
WITH MonthlyGenreROI AS (
    SELECT
        MONTH(m.release_date) AS ReleaseMonth,
        g.genre AS Genre,
        AVG(m.gross) AS AvgGross,
        AVG(m.budget) AS AvgBudget,
        AVG(m.gross - m.budget) AS AvgProfit,
        AVG((m.gross - m.budget) / m.budget) AS AvgROI,
		COUNT(*) AS Num_movies
    FROM Movies m
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE
        m.budget > 0
        AND m.budget IS NOT NULL
		--AND m.budget <= 50000000
        AND m.title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
		AND YEAR(release_date) > 1990
    GROUP BY MONTH(m.release_date), g.genre
)

SELECT
    ReleaseMonth,
    Genre,
    ROUND(AvgGross, 0) AS AvgGross,
    ROUND(AvgBudget, 0) AS AvgBudget,
    ROUND(AvgProfit, 0) AS AvgProfit,
    ROUND(AvgROI * 100, 0) AS AvgROI_Percentage,
	Num_movies
FROM MonthlyGenreROI
WHERE Num_movies > 2
ORDER BY AvgROI_Percentage DESC, ReleaseMonth
```

- Horror movies tend to yield the highest average ROIs in specific months, with April, October, and January standing out as particularly lucrative release periods.
- Seasonal trends indicate that movies in the horror genre perform exceptionally well in the lead-up to Halloween (October) and during the spring months (April).

  
3. **ROI by Genre and Rating:**

![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/0fb1889c-4a97-48ed-a4b5-17eeb7fd5f0a)

```
SELECT 
    genre,
    rating,
    COUNT(*) AS Num_movies,
    ROUND(AVG((gross - budget) / budget) * 100, 2) AS AvgROI_Percentage
FROM
    Movies m
        JOIN
    Genres g ON m.genre_id = g.id
WHERE
    budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project' , 'Paranormal Activity')
        AND rating IN ('G' , 'R', 'PG', 'PG-13')
        AND YEAR(release_date) > 1990
GROUP BY genre , rating
HAVING COUNT(*) > 5
ORDER BY AvgROI_Percentage DESC;
```

- Horror movies exhibit considerably higher average ROIs compared to other genres, regardless of rating. PG-13 and R-rated horror movies, in particular, show the most robust performances, with PG-13 movies performing slightly better in terms of average ROI.

4. **Runtime Considerations (Horror):**

![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/697d49f8-c0e2-487e-95f3-9dbbeb593f97)

```
SELECT 
    RuntimeCategory, ROUND(AVG(ROI), 2) AS AvgROI
FROM
    (SELECT 
        CASE
                WHEN runtime <= 90 THEN 'Under 90 minutes'
                WHEN runtime <= 120 THEN '90-120 minutes'
                WHEN runtime <= 150 THEN '120-150 minutes'
                ELSE 'Over 150 minutes'
            END AS RuntimeCategory,
            (gross - budget) / budget AS ROI
    FROM
        Movies m
    JOIN Genres g ON m.genre_id = g.id
    WHERE
        budget IS NOT NULL AND genre = 'horror'
            AND YEAR(release_date) > 1990
            AND title NOT IN ('The Blair Witch Project' , 'Paranormal Activity')) AS RuntimeCategoryMovies
GROUP BY RuntimeCategory
```

- Shorter runtimes (under 90 minutes) are associated with the highest average ROIs in horror movies, emphasizing the value of concise storytelling.
- Longer runtimes show diminishing returns, suggesting potential challenges in maintaining audience engagement for extended periods.

5. **Budget Impact on ROI (Horror):**
![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/160bfc9d-1c76-4177-b915-3cd2f4db46fa)


- Horror movies with budgets under $10 million have significantly higher ROI than those with larger budgets.  
- Budgets between $10-50 million show a significant drop in ROI for horror movies but are still at or around the industry average of 274%.
- Horror movies with a budget of over $50 million have an astronomical drop-off in ROI (only 0.54%).


6. **Writer and Director Impact on ROI (Horror):**

![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/1b94b1ba-63b6-4d1e-86b9-330763ca8c57)

```
WITH HorrorMovies AS (
    SELECT
        d.director AS Director,
        COUNT(*) AS MovieCount, 
        AVG((m.gross - m.budget) / m.budget) AS AvgROI
    FROM Movies m
    JOIN Directors d ON m.director_id = d.id
	JOIN Genres g
	ON m.genre_id = g.id
    WHERE g.genre = 'Horror'
        AND m.budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
		AND YEAR(release_date) > 1990
    GROUP BY d.director
    HAVING COUNT(*) > 2
)

SELECT
    TOP 10 Director,
    MovieCount, -- Show the number of horror movies by each director
    ROUND(AvgROI * 100, 2) AS AvgROI_Percentage
FROM HorrorMovies
ORDER BY AvgROI_Percentage DESC;
```
![image](https://github.com/Ron-Draguhon/Movie-Analysis/assets/56360122/b12c2db9-ab52-47d8-87ad-73e4abf95ea7)

```
WITH HorrorMovies AS (
    SELECT
        w.writer AS Writer,
        COUNT(*) AS MovieCount, 
        AVG((m.gross - m.budget) / m.budget) AS AvgROI
    FROM Movies m
    JOIN Writers w ON m.writer_id = w.id
    JOIN Genres g ON m.genre_id = g.id
    WHERE g.genre = 'horror'
        AND m.budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
        AND YEAR(release_date) > '1990'
    GROUP BY w.writer
    HAVING COUNT(*) > 2
),
AllMoviesAvgROI AS (
    SELECT AVG((gross - budget) / budget) AS OverallAvgROI
    FROM Movies
    WHERE budget IS NOT NULL
        AND title NOT IN ('The Blair Witch Project', 'Paranormal Activity')
        AND YEAR(release_date) > '1990'
)

SELECT
    Writer,
    MovieCount, -- Show the number of horror movies by each writer
    ROUND(AvgROI * 100, 2) AS AvgROI_Percentage
FROM HorrorMovies
CROSS JOIN AllMoviesAvgROI -- This is only way to join the tables since they don't have a matching column
WHERE AvgROI > OverallAvgROI -- Higher than average ROI 
ORDER BY AvgROI_Percentage DESC;
```

- Writer Leigh Whannell and director James Wan demonstrate consistently higher average ROIs than others in their field, averaging over 3000% ROI per film. Collaboration between these experienced individuals may enhance Fledgling Movie Studio's chances of achieving financial success.

**Recommendations:**

- **Produce Horror Movies:** In terms of ROI, horror movies dominate films from every other genre with almost 4 times the industry average of 274%.
- **Focus on Lower Budget Horror Movies:** Given the strong correlation between lower budgets and higher ROIs, Fledgling Movie Studio should produce horror movies with budgets under $10 million and avoid making horror movies with a budget of over $50 million.
- **Strategic Release Planning:** Align movie release dates within peak months for the horror genre (April, October, and January) to capitalize on audience interest.
- **Optimal Runtimes:** Aim for shorter runtimes, particularly under 90 minutes, to maximize audience engagement and ROI.
- **Select Experienced Writers and Directors:** Collaborate with writers and directors who have a proven track record of delivering high ROIs in the horror genre, such as writer Leigh Whannell and director James Wan.

**Conclusion:** By incorporating these recommendations, Fledgling Movie Studio can strategically position itself to produce movies with the highest possible ROI. Leveraging insights from the analysis, if the movies the studio produces bring in the industry average for the horror genre, the initial investment of $100 million should bring in over $1 billion in profit.
