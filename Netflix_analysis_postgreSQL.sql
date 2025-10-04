-- HEY !!! NETFLIX Project
CREATE TABLE netflix(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country	VARCHAR(150),
	date_added VARCHAR(50),
	release_year	 INT,
	rating	VARCHAR(10),
	duration VARCHAR(15),
	listed_in	VARCHAR(25),
	description VARCHAR(250)
)


-- 15. Business Problems

-- 1.Count the number of MOVIES vs Tv Shows.

SELECT type,count(type)from netflix group by type;

--2. Find the most Common rating for movies and TV Shows.


select type,t.rating from
(
SELECT type,COUNT(rating),rating,
RANK() over(partition by type order by COUNT(RATING) DESC) as rank
from netflix 
group by type,rating
order BY TYPE,count(rating) DESC
) t
where t.rank=1;


--3. List all movies released in a specific year (e.g., 2021)


SELECT title from netflix where release_year=2021 and type='Movie';


--4.Find the top 5 Countries with the most content on Netflix



SELECT 
TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as new_country,
COUNT(SHOW_ID) as total_content
from netflix
group by country
ORDER BY Count(show_id) DESC
lIMIT 5;


-- 5.Identify the longest Movie?


SELECT title, duration
FROM netflix
WHERE duration LIKE '%min' and type='Movie'
ORDER BY CAST(REPLACE(duration, ' min', '') AS INT) DESC
FETCH FIRST 1 ROWS ONLY;

-- 6. Find Content added in last 5 years

SELECT date_added 
from netflix 
where TO_DATE(date_added,'month-dd-yyyy')>=CURRENT_DATE-INTERVAL '5 years';


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'


SELECT * from netflix
where director ILIKE '%Rajiv Chilaka%';

--8.List all the TV shows with more than 5 Seasons


select title,
CAST(replace(replace(duration,'Season',''),' s','') AS INT) as tv_shows
from netflix
where type='TV Show' and CAST(replace(replace(duration,'Season',''),' s','') AS INT)>5;

   (OR)


WITH tv as (
select title,
CAST(replace(replace(duration,'Season',''),' s','') AS INT) as tv_shows
from netflix
where type='TV Show')

SELECT * FROM tv where tv.tv_shows>5;


-- 9. Count the number of content items in each genre.

SELECT 
COUNT(show_id) as total_content,UNNEST(string_to_array(listed_in,',')) as genres 
from netflix
group by UNNEST(string_to_array(listed_in,',')) 
ORDER BY  COUNT(show_id) DESC;

-- 10. Find each year and the average numbers of content release in INDIA on netflix.
-- Return top 5 year with highesyt average content release.

SELECT EXTRACT( year from TO_DATE(date_added,'month-dd-yyyy')) as year,count(show_id) as yearly_content,
round((count(show_id)::numeric/(select count(show_id) from netflix where country ='India')::numeric)* 100,2) as avg_content_per_year from netflix 
where country='India'
GROUP BY 1
ORDER BY 1;


--11.List all the movies that are documentaries.
SELECT COUNT(*) AS num_shows
FROM netflix n,
     UNNEST(string_to_array(n.listed_in, ',')) AS genre
WHERE TRIM(genre) = 'Documentaries';
  (or)

  SELECT COUNT(*) FROM NETFLIX WHERE listed_in ILIKE '%Documentaries%';

 --12.Find all content without Director.

 SELECT * from NETFLIX where director is NULL;

--13.Find in How many movies actor 'Salman Khan' appeared in last 10 years.

SELECT COUNT(*)
FROM netflix
WHERE "casts" ILIKE '%Salman Khan%'
  AND TO_DATE(release_year, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '10 years';

 --14.Find the top 10 Actors who have appeared in the highest number of movies produced in India.


 SELECT UNNEST(string_to_array(casts,',')) as actors,count(show_id) AS no_of_movies_acted
 from NETFLIX
 where country ILIKE '%India%'
 group by 1
 ORDER BY 2 DESC
 LIMIT 10;


 --15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field,
 --Label Content containing these keywords as 'Bad' and all other content as 'good' .Count how many items fall into each Category.
 
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










