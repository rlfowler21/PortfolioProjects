-- Investigating the Relationship Between Movie Budget and Vote Average--
SELECT
  budget,
  vote_average
FROM 
eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
  budget > 0
ORDER BY
  vote_average desc

-- Measuring the Correlation Between Budget and Vote Average--
SELECT
  Corr(budget,vote_average) as correlation
FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
budget > 0 
-- correlation shows no meaningful linear relationship (-0.024)

-- Investigating the Relationship Between Movie Budget and Profit --
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

-- Measuring the Correlation Between Budget and Profit --
SELECT
  Corr(budget,profit) as correlation
FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
WHERE
budget > 0 
and profit > 0 
-- correlation shows a moderate linear relationship (0.629)

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

-- Using genre_data CTE to Rank Genre by Average Profit --
WITH genre_data AS (
  SELECT
    JSON_EXTRACT_ARRAY(genres) AS genre_array ,
    revenue,
    profit
  FROM
  eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data
),
ranked_genres AS (
  SELECT
    genre,
    AVG(profit) AS avg_profit,
    ROW_NUMBER() OVER (ORDER BY AVG(profit) DESC) AS rank
  FROM
    genre_data,
    UNNEST(genre_array) AS genre
  WHERE
    genre IS NOT NULL
    AND revenue > 0
  GROUP BY
    genre
)

SELECT
  genre,
  AVG(profit) as avg_profit
FROM
genre_data,
unnest(genre_array) as genre
WHERE
  genre is not null
  and revenue > 0 
GROUP BY
  genre
ORDER BY
  avg_profit desc

-- Using ranked genre_data CTE to Compare Difference in Average Profit Between Genres --
WITH genre_data AS (
  SELECT
    JSON_EXTRACT_ARRAY(genres) AS genre_array,
    revenue,
    profit
  FROM
    `eighth-physics-440919-t4.Movie_Popularity_Portfolio.Movie_Data`
),
ranked_genres AS (
  SELECT
    genre,
    AVG(profit) AS avg_profit,
    ROW_NUMBER() OVER (ORDER BY AVG(profit) DESC) AS rank
  FROM
    genre_data,
    UNNEST(genre_array) AS genre
  WHERE
    genre is not null
    AND revenue > 0
  GROUP BY
    genre
)

SELECT
  genre,
  avg_profit,
  avg_profit - COALESCE(LAG(avg_profit) OVER (ORDER BY rank), avg_profit) AS profit_difference
FROM
  ranked_genres
ORDER BY
  rank

