-- Netflix Project
CREATE TABLE Netflix (
    show_id VARCHAR(50),
    type_1 VARCHAR(50),
    title VARCHAR(150),
    director VARCHAR(250),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(50),
    duration VARCHAR(50),
    listed_in VARCHAR(100),
    description VARCHAR(250)
);

SElECT DISTINCT type FROM Netflix;


-- 1. movies vs tv shows

SELECT type_1, COUNT (*) AS total_releases FROM netflix GROUP BY type_1;

-- 2. most common ratings

SELECT 
    type_1, 
    rating, 
    COUNT(*) AS count, 
    RANK() OVER (PARTITION BY type_1 ORDER BY COUNT(*) DESC) AS ranking
FROM 
    Netflix
GROUP BY 
    type_1, rating;

-- 3. listing of all the movies released in a specific year

SELECT * FROM netflix 
WHERE 
    type_1 = 'Movie'
	AND
    release_year = 2020

-- 4.Top 5 countries with the most releases 

SELECT 
     UNNEST (string_to_array(country, ', ')) AS new_country,
     COUNT(DISTINCT show_id) AS total_releases
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. longest movies

SELECT * FROM Netflix
WHERE 
    type_1 = 'Movie'
	AND
    duration = (SELECT MAX(duration) FROM Netflix)

-- 6. all the releases from in last 5 years

SELECT *
FROM Netflix
WHERE TO_DATE(date_added, 'Month DD, yyyy') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. list all the movies\ tv shows by 'Martin Scorsese'

SELECT * FROM Netflix WHERE director ILIKE '%Martin Scorsese%';


-- 8. list all the tv shows with more than 5 seasons

SELECT *, 
       SPLIT_PART(duration, ' ', 1)::INTEGER AS seasons
FROM Netflix
WHERE 
    type_1 = 'TV Show'
    AND SPLIT_PART(duration, ' ', 1)::INTEGER > 5;

-- 9. the amount of movies/tv shows by genre

SELECT
     UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre,
	 COUNT(show_id) AS genre_count
FROM Netflix
GROUP BY 1
ORDER BY genre

-- 10. calculate the average number of content released by Germany and the top 5 years with highst avergae content

SELECT 
     EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	 COUNT(*) AS yearly_releases,
	 ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM Netflix WHERE country = 'Germany')::numeric * 100, 0) AS Average_releases_per_year
FROM Netflix
WHERE country = 'Germany'
GROUP BY 1
ORDER BY 1
LIMIT 5

-- 11. list all the documentaries

SELECT * FROM Netflix
WHERE
    listed_in ILIKE '%Documentaries%'

-- 12. list all the releases without a director

SELECT * FROM Netflix
WHERE
    director IS null
ORDER BY 1

-- 13. list all the movies\tv shows that 'Adam Sandler' appeared in the last 10 years

SELECT * FROM Netflix
WHERE 
    casts ILIKE '%adam sandler%' 
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10

-- 14. list top 10 actors who have appeared in the highest number of releases in Germany

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
    COUNT(DISTINCT show_id) AS total_releases
FROM Netflix
WHERE country ILIKE '%Germany%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

-- 15. Categorize the releases based on the presence of the keywords 'kill' and 'violence' fro example 
-- --  in the description field. Label releases containing these keywords as 'PG-13' and all 
-- --  other releases as 'Rated-G'. Count how many items fall into each category.

WITH new_category
AS
(SELECT *,
    case
	WHEN description ILIKE '%violence%'
	OR 
	description ILIKE '%kill%'
	OR 
	description ILIKE '%sex%'
	OR 
	description ILIKE '%nudity%'
	THEN 'PG-13'
	ELSE 'Rated-G'
	END Category
FROM Netflix
)
SELECT
    category,
	COUNT(*) AS total_releases
	FROM new_category
	GROUP BY 1
	ORDER BY 1 ASC

    




