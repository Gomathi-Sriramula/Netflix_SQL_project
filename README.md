#  Netflix Project - SQL Analysis

  ![Netflix Logo](https://github.com/Gomathi-Sriramula/Netflix_SQL_project/blob/main/netflix_logo.jpg)
# Netflix Project - SQL Analysis

## Project Overview

Analyze Netflix dataset using SQL to extract insights and solve business problems such as content counts, top actors, genres, and trends.

## Table Structure

```sql
CREATE TABLE netflix(
    show_id VARCHAR(6),
    type VARCHAR(10),
    title VARCHAR(150),
    director VARCHAR(208),
    casts VARCHAR(1000),
    country VARCHAR(150),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(10),
    duration VARCHAR(15),
    listed_in VARCHAR(25),
    description VARCHAR(250)
);
```

## Business Problems & SQL Queries

### 1. Count Movies vs TV Shows

```sql
SELECT type, COUNT(type) FROM netflix GROUP BY type;
```

### 2. Most Common Rating for Movies and TV Shows

```sql
SELECT type, t.rating FROM (
    SELECT type, COUNT(rating), rating,
           RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS rank
    FROM netflix 
    GROUP BY type, rating
) t
WHERE t.rank = 1;
```

### 3. Movies Released in 2021

```sql
SELECT title FROM netflix WHERE release_year = 2021 AND type='Movie';
```

### 4. Top 5 Countries by Content

```sql
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
       COUNT(show_id) AS total_content
FROM netflix
GROUP BY country
ORDER BY COUNT(show_id) DESC
LIMIT 5;
```

### 5. Longest Movie

```sql
SELECT title, duration
FROM netflix
WHERE duration LIKE '%min' AND type='Movie'
ORDER BY CAST(REPLACE(duration, ' min', '') AS INT) DESC
FETCH FIRST 1 ROWS ONLY;
```

### 6. Content Added in Last 5 Years

```sql
SELECT date_added 
FROM netflix 
WHERE TO_DATE(date_added,'Month-DD-YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

### 7. Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix WHERE director ILIKE '%Rajiv Chilaka%';
```

### 8. TV Shows with More Than 5 Seasons

```sql
SELECT title,
       CAST(REPLACE(REPLACE(duration,'Season',''),' s','') AS INT) AS tv_shows
FROM netflix
WHERE type='TV Show' AND CAST(REPLACE(REPLACE(duration,'Season',''),' s','') AS INT) > 5;
```

**OR using CTE:**

```sql
WITH tv AS (
    SELECT title,
           CAST(REPLACE(REPLACE(duration,'Season',''),' s','') AS INT) AS tv_shows
    FROM netflix
    WHERE type='TV Show'
)
SELECT * FROM tv WHERE tv_shows > 5;
```

### 9. Number of Content Items per Genre

```sql
SELECT COUNT(show_id) AS total_content, 
       UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genres
FROM netflix
GROUP BY UNNEST(STRING_TO_ARRAY(listed_in, ','))
ORDER BY COUNT(show_id) DESC;
```

### 10. Average Content Release per Year in India

```sql
SELECT EXTRACT(YEAR FROM TO_DATE(date_added,'Month-DD-YYYY')) AS year,
       COUNT(show_id) AS yearly_content,
       ROUND((COUNT(show_id)::NUMERIC / 
              (SELECT COUNT(show_id) FROM netflix WHERE country='India')::NUMERIC) * 100, 2) AS avg_content_per_year
FROM netflix
WHERE country='India'
GROUP BY 1
ORDER BY 1;
```

### 11. Documentaries

```sql
SELECT COUNT(*) AS num_shows
FROM netflix n,
     UNNEST(STRING_TO_ARRAY(n.listed_in, ',')) AS genre
WHERE TRIM(genre) = 'Documentaries';
```

**OR simpler:**

```sql
SELECT COUNT(*) FROM netflix WHERE listed_in ILIKE '%Documentaries%';
```

### 12. Content Without Director

```sql
SELECT * FROM netflix WHERE director IS NULL;
```

### 13. Movies with Salman Khan in Last 10 Years

```sql
SELECT COUNT(*)
FROM netflix
WHERE "casts" ILIKE '%Salman Khan%'
  AND TO_DATE(date_added, 'Month-DD-YYYY') >= CURRENT_DATE - INTERVAL '10 years';
```

### 14. Top 10 Actors in Indian Content

```sql
SELECT UNNEST(STRING_TO_ARRAY(casts,',')) AS actors, COUNT(show_id) AS no_of_movies_acted
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

### 15. Categorize Content Based on Keywords in Description

```sql
SELECT 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad'
        ELSE 'good'
    END AS rating,
    COUNT(*) AS num_items
FROM netflix
GROUP BY 
    CASE 
        WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'bad'
        ELSE 'good'
    END;
```
