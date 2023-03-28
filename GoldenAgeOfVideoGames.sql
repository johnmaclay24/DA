
CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold NUMERIC(5, 2),
  year INT
);


CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score NUMERIC(4, 2),   
    user_score NUMERIC(4, 2)
);


CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score NUMERIC(4, 2)  
);


CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score NUMERIC(4, 2)  
);


CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score NUMERIC(4, 2)  
);


-- Select all information for the top ten best-selling games
-- Order results from best-selling game down to tenth best-selling

SELECT *
FROM game_sales
ORDER BY games_sold DESC
LIMIT 10;

-- Join games_sales and reviews
-- Select a count of the number of games where both critic_score and user_score are null
-- Make sure that the data does not have too many missing values 
SELECT 
    count(g.game) 
FROM game_sales AS g
FULL JOIN reviews AS r
ON g.game = r.game
WHERE critic_score IS NULL AND user_score IS NULL;

-- Select release year and average critic score for each year, rounded and aliased
-- Join game_sales and reviews tables
-- Group by release year
-- Order data from highest to lowest avg_critic_score and limit to 10 results

SELECT 
    year,
    ROUND(AVG(critic_score),2) AS avg_critic_score
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
ORDER BY avg_critic_score DESC
LIMIT 10;

-- Update the query so that it only returns years that have more than four reviewed games

SELECT 
    year,
    ROUND(AVG(critic_score),2) AS avg_critic_score,
    COUNT(g.game) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(g.game) > 4
ORDER BY avg_critic_score DESC
LIMIT 10;

-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 
-- Order the results from highest to lowest avg_critic_score

SELECT
    year,
    avg_critic_score
FROM top_critic_years

EXCEPT

SELECT 
    year,
    avg_critic_score
FROM top_critic_years_more_than_four_games
ORDER BY avg_critic_score DESC;
        
SELECT 
    year,
    ROUND(AVG(user_score),2) AS avg_user_score,
    COUNT(g.game) AS num_games
FROM game_sales AS g
INNER JOIN reviews AS r
ON g.game = r.game
GROUP BY year
HAVING COUNT(g.game) > 4
ORDER BY avg_user_score DESC
LIMIT 10;

-- Select the year results that appear on both tables

SELECT year
FROM top_critic_years_more_than_four_games

INTERSECT 

SELECT year
FROM top_user_years_more_than_four_games;

-- Select year and sum of games_sold, aliased as total_games_sold; order results by total_games_sold descending
-- Filter game_sales based on whether each year is in the list returned in the previous task

SELECT
    year,
    SUM(games_sold) AS total_games_sold
FROM game_sales
WHERE year IN 
( 
    SELECT year
    FROM top_critic_years_more_than_four_games

    INTERSECT 

    SELECT year
    FROM top_user_years_more_than_four_games )

GROUP BY year
ORDER BY total_games_sold DESC;
    
