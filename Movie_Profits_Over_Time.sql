
-- Investigating the relationship between movie budget and vote average--
SELECT
  budget,
  vote_average
FROM 
eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
  budget > 0
ORDER BY
  vote_average desc

-- Measuring the correlation between budget and vote average--
SELECT
  Corr(budget,vote_average) as correlation
FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
budget > 0 
-- correlation shows no meaningful linear relationship 

-- Investigating the relationship between movie budget and profit --
SELECT
  budget,
  profit
FROM 
eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
  budget > 0
  and profit > 0
ORDER BY
  profit desc

-- Measuring the correlation between budget and profit --
SELECT
  Corr(budget,profit) as correlation
FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
budget > 0 
and profit > 0 
-- correlation shows a moderate linear relationship 

-- Finding Most Common Genre --
--genres are grouped in a string format so must first be converted to an array to be unnested for the analysis 

  WITH genre_data AS (
  SELECT
    JSON_EXTRACT_ARRAY(genres) AS genre_array 
  FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
)

SELECT
  genre,
  COUNT(*) AS genre_count
FROM
  genre_data,
  UNNEST(genre_array) AS genre
GROUP BY
  genre
ORDER BY
  genre_count DESC

-- Using genre_data CTE to Rank Genre by Average Revenue --
WITH genre_data AS (
  SELECT
    JSON_EXTRACT_ARRAY(genres) AS genre_array ,
    revenue
  FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
)

SELECT
  genre,
  AVG(revenue) as avg_revenue
FROM
genre_data,
unnest(genre_array) as genre
WHERE
  genre is not null
  and revenue > 0 
GROUP BY
  genre
ORDER BY
  avg_revenue desc

-- Investigating the change in movie profits over time -- 
SELECT
  extract(year from release_date) as year,
  sum(profit) as total_yearly_profit,
FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE 
release_date is not null
GROUP BY
  year
ORDER BY
  total_yearly_profit desc
-- movie profits dropped dramatically when COVID was at its peak

-- Comparing 2010-2024 average movie profit differences to observe the change during COVID --  

WITH profit_by_year AS (
  SELECT
    EXTRACT(YEAR FROM release_date) AS year,
    SUM(profit) AS total_profit
  FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
  WHERE
    EXTRACT(YEAR FROM release_date) between 2010 AND 2024
    AND revenue > 0
    AND budget > 0
  GROUP BY
    year
)

SELECT
  year,
  total_profit,
  total_profit - LAG(total_profit) OVER (ORDER BY year) AS profit_difference
FROM
  profit_by_year
ORDER BY
  year;


