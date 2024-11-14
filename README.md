# Netflix-Data-analysis-project-using-postgreSQL

![Netflix Logo](https://github.com/agomaa20011/Netflix-analysis-project-using-postgreSQL/blob/main/pngegg.png)

##Overview

This project explores a Netflix dataset using SQL to derive insights into content trends, popular genres, and country-specific releases. By analyzing columns such as content type, release year, genres, and cast details, we aim to understand patterns in Netflix's content library over recent years.

## Key Insights
1. **Release Trends**: Analyzed content release trends year by year to identify growth patterns in Netflix’s offerings.
2. **Genre Popularity**: Examined popular genres based on content frequency and type (e.g., movies vs. TV shows).
3. **Cast and Collaborations**: Uncovered frequently appearing actors and common collaborations across titles.
4. **Country Analysis**: Focused on content released in Germany, identifying annual average releases and trends over time.

## Dataset
this dataset is sourced from kaggle datasets

[DATASET LINK](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schemas
```
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
```

## Problems and solutions

### 1. movies vs tv shows

```
SELECT type_1, COUNT (*) AS total_releases FROM netflix GROUP BY type_1;
```

### 2. most common ratings

```
SELECT 
    type_1, 
    rating, 
    COUNT(*) AS count, 
    RANK() OVER (PARTITION BY type_1 ORDER BY COUNT(*) DESC) AS ranking
FROM 
    Netflix
GROUP BY 
    type_1, rating;
```

### 3. listing of all the movies released in a specific year

```
SELECT * FROM netflix 
WHERE 
    type_1 = 'Movie'
	AND
    release_year = 2020
```

### 4.Top 5 countries with the most releases 

```
SELECT 
     UNNEST (string_to_array(country, ', ')) AS new_country,
     COUNT(DISTINCT show_id) AS total_releases
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

### 5. longest movies

```
SELECT * FROM Netflix
WHERE 
    type_1 = 'Movie'
	AND
    duration = (SELECT MAX(duration) FROM Netflix)
```

### 6. all the releases from in last 5 years

```
SELECT *
FROM Netflix
WHERE TO_DATE(date_added, 'Month DD, yyyy') >= CURRENT_DATE - INTERVAL '5 years';
```

### 7. list all the movies\ tv shows by 'Martin Scorsese'

```
SELECT * FROM Netflix WHERE director ILIKE '%Martin Scorsese%';
```

### 8. list all the tv shows with more than 5 seasons

```
SELECT *, 
       SPLIT_PART(duration, ' ', 1)::INTEGER AS seasons
FROM Netflix
WHERE 
    type_1 = 'TV Show'
    AND SPLIT_PART(duration, ' ', 1)::INTEGER > 5;
```

### 9. the amount of movies/tv shows by genre

```
SELECT
     UNNEST(STRING_TO_ARRAY(listed_in, ', ')) AS genre,
	 COUNT(show_id) AS genre_count
FROM Netflix
GROUP BY 1
ORDER BY genre
```

### 10. calculate the average number of content released by Germany and the top 5 years with highst avergae content

```
SELECT 
     EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year,
	 COUNT(*) AS yearly_releases,
	 ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM Netflix WHERE country = 'Germany')::numeric * 100, 0) AS Average_releases_per_year
FROM Netflix
WHERE country = 'Germany'
GROUP BY 1
ORDER BY 1
LIMIT 5
```

### 11. list all the documentaries

```
SELECT * FROM Netflix
WHERE
    listed_in ILIKE '%Documentaries%'
```

### 12. list all the releases without a director

```
SELECT * FROM Netflix
WHERE
    director IS null
ORDER BY 1
```

### 13. list all the movies\tv shows that 'Adam Sandler' appeared in the last 10 years

```
SELECT * FROM Netflix
WHERE 
    casts ILIKE '%adam sandler%' 
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10
```

### 14. list top 10 actors who have appeared in the highest number of releases in Germany

```
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ', ')) AS actors,
    COUNT(DISTINCT show_id) AS total_releases
FROM Netflix
WHERE country ILIKE '%Germany%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```

### 15. Categorize the releases based on the presence of the keywords 'kill' and 'violence' for example 
 in the description field. Label releases containing these keywords as 'PG-13' and all 
 other releases as 'Rated-G'. Count how many items fall into each category.

```
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
```
## Summary

This project provides an in-depth SQL analysis of the Netflix catalog to uncover insights related to content distribution, genre trends, and actor involvement. Using PostgreSQL, we examined various features of the dataset, including content type (movies vs. TV shows), genre classifications, director and cast details, country-based release counts, and content ratings. This analysis helped illustrate how Netflix’s catalog has evolved over time and highlighted the factors that contribute to popular content on the platform.

## Key Queries and Findings

1. Movies vs. TV Shows: A breakdown of Netflix’s total releases into movies and TV shows, allowing us to observe the balance of content types.
2. Content Ratings: Ranked common ratings for movies and TV shows, providing insights into the primary audiences Netflix targets.
3. Year-Specific Releases: Filtered movies released in 2020 to analyze trends in a particular year.
4. Top Releasing Countries: Identified the top five countries contributing the most content, illustrating Netflix’s global content production reach.
5. Longest Movies: Retrieved the longest movie on the platform to showcase exceptional content lengths.
6. Recent Releases: Filtered all content released in the last five years to highlight the growth in Netflix's catalog over recent years.
7. Director-Specific Content: Listed titles directed by Martin Scorsese, emphasizing director-based filtering for viewers' interests.
8. TV Shows with Multiple Seasons: Listed all TV shows with over five seasons, indicating longer-running and potentially popular series.
9. Genre Analysis: Analyzed genres by content volume, providing insight into the most popular content types on Netflix.
10. Country-Based Content Averages: Focused on content released in Germany, calculating yearly averages to observe consistent growth in specific regions.
11. Documentary Content: Extracted all documentaries from the catalog for genre-specific analysis.
12. Releases Without Directors: Listed releases without a credited director, which could indicate collaborative or anonymous content.
13. Actor Involvement: Filtered for titles featuring Adam Sandler in the last 10 years to highlight recent appearances.
14. Top Actors in Germany: Listed the top 10 actors with the highest number of appearances in German releases, showcasing actor popularity and collaboration patterns.
15. Content Categorization by Keywords: Labeled releases as 'PG-13' or 'Rated-G' based on the presence of keywords in descriptions (e.g., "violence" or "nudity"), offering a simplified view of content maturity ratings.

## Conclusion

Through this analysis, we observed several trends and insights regarding Netflix’s approach to content creation and distribution. The platform’s extensive variety in genre and country-specific releases highlights its efforts to diversify its offerings to cater to different audiences worldwide. With a detailed breakdown of genres, ratings, and content lengths, this analysis helps identify Netflix’s strategic focus on high-engagement content, popular genres, and frequently featured actors. Future work could involve analyzing viewership data or user ratings to draw connections between content offerings and audience preferences on Netflix.

## Dashboard

### General look

[Top Releasing Country]([./images/top_releasing_country.png](https://github.com/agomaa20011/Netflix-analysis-project-using-postgreSQL-Power-bi/blob/main/DASHBOARD.PNG))

### Releases between 1990 and 2009

[Top Releasing Country](https://github.com/agomaa20011/Netflix-analysis-project-using-postgreSQL-Power-bi/blob/main/DASHBOARD%201990-2009.PNG)

### Releases between 1990 and 2022

[Top Releasing Country](https://github.com/agomaa20011/Netflix-analysis-project-using-postgreSQL-Power-bi/blob/main/DASHBOARD%202010-2022.PNG)
