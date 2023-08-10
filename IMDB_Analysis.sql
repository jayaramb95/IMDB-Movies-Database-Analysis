USE imdb;

-- Segment 1:

-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 'movie' AS TableName, COUNT(*) AS RowCount FROM movie
UNION ALL
SELECT 'genre' AS TableName, COUNT(*) AS RowCount FROM genre
UNION ALL
SELECT 'names' AS TableName, COUNT(*) AS RowCount FROM names
UNION ALL
SELECT 'ratings' AS TableName, COUNT(*) AS RowCount FROM ratings
UNION ALL
SELECT 'role_mapping' AS TableName, COUNT(*) AS RowCount FROM role_mapping
UNION ALL
SELECT 'director_mapping' AS TableName, COUNT(*) AS RowCount FROM director_mapping;

-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT SUM(CASE WHEN m.id IS NULL THEN 1 ELSE 0 END) AS Null_Count_Movie_ID,
	   SUM(CASE WHEN m.title IS NULL THEN 1 ELSE 0 END) AS Null_Count_Title,
       SUM(CASE WHEN m.year IS NULL THEN 1 ELSE 0 END) AS Null_Count_Year,
       SUM(CASE WHEN m.date_published IS NULL THEN 1 ELSE 0 END) AS Null_Count_Date_Published,
       SUM(CASE WHEN m.duration IS NULL THEN 1 ELSE 0 END) AS Null_Count_Duration,
       SUM(CASE WHEN m.country IS NULL THEN 1 ELSE 0 END) AS Null_Count_Country,
       SUM(CASE WHEN m.worlwide_gross_income IS NULL THEN 1 ELSE 0 END) AS Null_Count_WW_Gross_Income,
       SUM(CASE WHEN m.languages IS NULL THEN 1 ELSE 0 END) AS Null_Count_Languages,
       SUM(CASE WHEN m.production_company IS NULL THEN 1 ELSE 0 END) AS Null_Count_Production_Company
FROM movie AS m;

-- Country, Worldwide Gross Income, Languages, Production Company columns have null values.

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

-- Type your code below:
-- Movie count by year
SELECT year, COUNT(*) AS number_of_movies
FROM movie
GROUP BY year
ORDER BY year;
-- We can observe from the above query output, that the number of movies produced per year has been on a decline year after year.
-- 2017 had the most number of movies produced with 3052 movies.

-- Movie count by month
SELECT month(date_published) AS month, COUNT(*) AS number_of_movies
FROM movie
GROUP BY month(date_published)
ORDER BY month(date_published);

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT year, COUNT(*) AS No_of_movies_produced_in_USA_or_India
FROM movie
WHERE year = 2019 AND (country REGEXP 'USA' OR country REGEXP 'India');

-- Total of 1059 movies were produced in the USA or India in the year 2019

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/


-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre
FROM genre;

-- Total of 13 distinct genres

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */


-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
WITH genre_summary AS
(	SELECT g.genre AS genre, COUNT(m.title) AS movies_count
	FROM movie m INNER JOIN genre g ON m.id=g.movie_id
	GROUP BY g.genre
)
SELECT * 
FROM genre_summary
WHERE movies_count = ( SELECT MAX(movies_count)
					   FROM genre_summary );
                       
-- Drama is the top genre by movie count with 4285 movies.

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/


-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH single_genre_movies AS
(
  SELECT m.id
  FROM movie m INNER JOIN genre g ON m.id = g.movie_id
  GROUP BY m.id
  HAVING COUNT(*) = 1
)
SELECT COUNT(*) AS movie_count
FROM single_genre_movies;

-- There are 3289 movies that belong to only one genre.

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 

-- Type your code below:
SELECT g.genre AS genre, ROUND(AVG(m.duration),1) AS avg_duration
FROM movie m INNER JOIN genre g ON m.id=g.movie_id
GROUP BY g.genre
ORDER BY AVG(m.duration) DESC;

-- Action movies have longest average duration.

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 

-- Type your code below:
WITH genre_rankings AS
(
	SELECT g.genre, COUNT(*) AS movie_count, RANK() OVER (ORDER BY COUNT(*) DESC) AS genre_rank
	FROM movie m INNER JOIN genre g ON m.id = g.movie_id
	GROUP BY g.genre
)
SELECT *
FROM genre_rankings
WHERE genre = 'Thriller';

-- Thriller genre is at rank 3 with 1484 movies.

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?

-- Type your code below:
SELECT MIN(avg_rating) AS min_avg_rating, 
	   MAX(avg_rating) AS max_avg_rating, 
       MIN(total_votes) AS min_total_votes,
       MAX(total_votes) AS max_total_votes,
       MIN(median_rating) AS min_median_rating,
       MAX(median_rating) AS max_median_rating
FROM ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


-- Q11. Which are the top 10 movies based on average rating?

-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
WITH movies_ranked_all AS
(
	SELECT m.title AS title, r.avg_rating AS avg_rating, ROW_NUMBER() OVER (ORDER BY r.avg_rating DESC) AS movie_rank
	FROM movie m INNER JOIN ratings r ON m.id = r.movie_id
)
SELECT *
FROM movies_ranked_all
WHERE movie_rank<=10;

-- 'Kirket' and 'Love in Kilnerry' are the highest rated movies.

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/


-- Q12. Summarise the ratings table based on the movie counts by median ratings.

-- Type your code below:
-- Order by is good to have
SELECT r.median_rating AS median_rating, COUNT(*) AS movie_count
FROM movie m INNER JOIN ratings r ON m.id = r.movie_id
GROUP BY r.median_rating
ORDER BY r.median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??

-- Type your code below:
WITH production_companies_rank AS
(
	SELECT m.production_company AS production_company, COUNT(*) AS movie_count, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS prod_company_rank
	FROM movie m INNER JOIN ratings r ON m.id = r.movie_id
	WHERE r.avg_rating>8 AND m.production_company IS NOT NULL
	GROUP BY m.production_company
)
SELECT *
FROM production_companies_rank
WHERE prod_company_rank=1;

-- Dream Warrior Pictures and National Theatre Live are the top production houses.

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?

-- Type your code below:
SELECT g.genre AS genre, COUNT(*) AS movie_count
FROM movie m INNER JOIN genre g ON m.id = g.movie_id
			 INNER JOIN ratings r ON m.id = r.movie_id
WHERE (m.year=2017 AND MONTH(m.date_published)=3) AND r.total_votes>1000 AND m.country REGEXP 'USA'
GROUP BY g.genre
ORDER BY movie_count DESC;

-- Drama genre had the most number of movies released during March 2017 in the USA that had more than 1,000 votes.


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?

-- Type your code below:
SELECT m.title AS title, r.avg_rating AS avg_rating, g.genre AS genre
FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
			 INNER JOIN genre g ON r.movie_id=g.movie_id
WHERE m.title REGEXP '^The' AND r.avg_rating>8
ORDER BY avg_rating DESC;

-- We can observe that the top 3 highly rated movies that start with the word ‘The’ are from Drama genre.


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
WITH movies_between_april2018_and_april2019 AS
(
	SELECT m.title, m.date_published, r.median_rating
	FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
	WHERE (m.date_published BETWEEN '2018-04-01' AND '2019-04-01') AND (r.median_rating=8)
)
SELECT COUNT(*) FROM movies_between_april2018_and_april2019;

-- We can observe that there are 361 movies released between 1 April 2018 and 1 April 2019, that were given a median rating of 8.


-- Q17. Do German movies get more votes than Italian movies? 

-- Type your code below:
WITH german_language_movies AS
(
	SELECT m.languages AS language, SUM(r.total_votes) AS total_votes_for_german_movies
	FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
	WHERE m.languages REGEXP 'German'
	GROUP BY m.languages
)
SELECT SUM(total_votes_for_german_movies) AS total_votes_for_german_movies
FROM german_language_movies;
-- From above query, we get the total number of votes for German movies as 4421525

WITH italian_language_movies AS
(
	SELECT m.languages AS language, SUM(r.total_votes) AS total_votes_for_italian_movies
	FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
	WHERE m.languages REGEXP 'Italian'
	GROUP BY m.languages
)
SELECT SUM(total_votes_for_italian_movies) AS total_votes_for_italian_movies
FROM italian_language_movies;
-- From above query, we get the total number of votes for German movies as 2559540. So, German movies have received more votes than Italian movies

-- Answer is Yes


-- Q18. Which columns in the names table have null values??

-- Type your code below:
SELECT SUM(CASE WHEN n.id IS NULL THEN 1 ELSE 0 END) AS ID_nulls,
	   SUM(CASE WHEN n.name IS NULL THEN 1 ELSE 0 END) AS name_nulls,
       SUM(CASE WHEN n.height IS NULL THEN 1 ELSE 0 END) AS height_nulls,
       SUM(CASE WHEN n.date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls,
	   SUM(CASE WHEN n.known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names AS n;

-- Except ID and name, all the other columns have null values.

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/


-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

-- Type your code below:

-- First lets find the top 3 genres (which have maximum number of movies with ratings >8)
SELECT g.genre AS genre, COUNT(g.movie_id) AS movies_count
FROM genre g INNER JOIN ratings r USING (movie_id)
WHERE r.avg_rating>8
GROUP BY genre
ORDER BY COUNT(g.movie_id) DESC
LIMIT 3;
-- From the above query, we can get to know that the top 3 genres are Drama > Action > Comedy
-- So, now lets find out the top directors from these 3 genres
        
WITH top_directors_list AS
    (
        SELECT nm.name AS director_name, COUNT(*) AS movie_count,
			   ROW_NUMBER() OVER(ORDER BY COUNT(dm.movie_id) DESC) AS director_rank
        FROM names nm INNER JOIN director_mapping dm ON nm.id=dm.name_id
                      INNER JOIN genre g ON g.movie_id=dm.movie_id
                      INNER JOIN ratings r ON r.movie_id=dm.movie_id
		WHERE r.avg_rating>8 AND g.genre IN ('Drama', 'Action', 'Comedy')
        GROUP BY nm.name
	)
SELECT director_name, movie_count
FROM top_directors_list
WHERE director_rank<=4;       -- 4 has been used in the WHERE clause because there are 3 directors with the same movie count, so all of them can be considered for the movie.

-- James Mangold, Anthony Russo, Joe Russo and Soubin Shahir are the top directors.
    
/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?

-- Type your code below:
WITH top_actors AS
(
	SELECT nm.name AS actor_name, COUNT(*) AS movie_count, DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS actor_rank
	FROM movie m INNER JOIN role_mapping rm ON m.id=rm.movie_id
				 INNER JOIN names nm ON nm.id=rm.name_id
				 INNER JOIN ratings r ON m.id=r.movie_id
	WHERE r.median_rating>=8
	GROUP BY nm.name
)
SELECT actor_name, movie_count
FROM top_actors
WHERE actor_rank<=2;

-- Mammootty and Mohanlal are the top 2 actors whose movies have a median rating >= 8.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?

-- Type your code below:
WITH production_company_rankings AS
(
	SELECT m.production_company, SUM(r.total_votes) AS vote_count, 
		   DENSE_RANK() OVER (ORDER BY SUM(r.total_votes) DESC) AS prod_comp_rank
	FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
	GROUP BY m.production_company
	ORDER BY SUM(r.total_votes) DESC
)
SELECT *
FROM production_company_rankings
WHERE prod_comp_rank<=3;

-- Marvel Studios, Twentieth Century Fox and Warner Bros. are the top 3 production houses based on the number of votes received by their movies.

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 

-- Type your code below:
WITH actor_rankings AS
(
	SELECT nm.name, SUM(r.total_votes) AS total_votes, COUNT(*) AS movie_count, 
		   ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes),2) AS actor_avg_rating  -- Weighted average calculation
	FROM movie m INNER JOIN role_mapping rm ON m.id=rm.movie_id
				 INNER JOIN names nm ON nm.id=rm.name_id
				 INNER JOIN ratings r ON m.id=r.movie_id
	WHERE m.country REGEXP 'India' AND rm.category = 'Actor'
	GROUP BY nm.name
)
SELECT *, DENSE_RANK() OVER (ORDER BY actor_avg_rating DESC) AS actor_rank
FROM actor_rankings
WHERE movie_count>=5;

-- Top actor is Vijay Sethupathi with an average rating of 8.42, followed by Fahadh Faasil and Yogi Babu.

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 

-- Type your code below:
WITH 
	actress_rankings AS
	(
		SELECT nm.name, SUM(r.total_votes) AS total_votes, COUNT(*) AS movie_count, 
			   ROUND(SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes),2) AS actress_avg_rating
		FROM movie m INNER JOIN role_mapping rm ON m.id=rm.movie_id
					 INNER JOIN names nm ON nm.id=rm.name_id
					 INNER JOIN ratings r ON m.id=r.movie_id
		WHERE m.country REGEXP 'India' AND m.languages REGEXP 'Hindi' AND rm.category = 'Actress'
		GROUP BY nm.name
	),
    more_than_3_movies AS
    (
		SELECT *, DENSE_RANK() OVER (ORDER BY actress_avg_rating DESC, total_votes DESC) AS actor_rank
		FROM actress_rankings
		WHERE movie_count>=3
	)
    SELECT *
    FROM more_than_3_movies
    WHERE actor_rank<=5;
    
    -- Taapsee Pannu is the top actress with average rating of 7.74, followed by Kriti Sanon and Divya Dutta, Shraddha Kapoor and Kriti Kharbanda.

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT m.title, r.avg_rating,
       CASE WHEN r.avg_rating > 8 THEN 'Superhit'
            WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
            WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
            ELSE 'Flop movies'
		END AS category
FROM movie m INNER JOIN genre g ON m.id=g.movie_id
			 INNER JOIN ratings r ON m.id=r.movie_id
WHERE g.genre='Thriller';

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:


-- Q25. What is the genre-wise running total and moving average of the average movie duration? 

-- Type your code below:
WITH genre_summary AS
(
	SELECT g.genre AS genre, ROUND(AVG(m.duration),1) AS avg_duration
	FROM movie m INNER JOIN genre g on m.id=g.movie_id
	GROUP BY g.genre
)
SELECT *, 
       SUM(avg_duration) OVER w AS running_total_duration,
       AVG(avg_duration) OVER w AS moving_avg_duration  -- Here moving average has been considered from the starting row, i.e all rows.
FROM genre_summary
WINDOW w AS (ORDER BY genre ROWS UNBOUNDED PRECEDING);

-- Round is good to have and not a must have; Same thing applies to sorting

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

-- Type your code below:

-- Top 3 Genres based on most number of movies

-- First, lets find the top 3 genres by movie count
SELECT g.genre, COUNT(g.movie_id) AS movie_count
FROM movie m INNER JOIN genre g ON m.id=g.movie_id
GROUP BY g.genre
ORDER BY movie_count DESC;

-- After running the above query, we can see that the top 3 genres by movie count are Drama, Comedy and Thriller in that order.
-- Now for these 3 genres, lets find the 5 highest-grossing movies of each year
-- Here, we have 3 records where worldwide_gross_income is in INR. Hence, we are converting these values to USD.
-- USD to INR exchange rate has been considered as $1 = INR 83, based on the latest prevailing exchange rate.
WITH 
	highest_grossing_movies_in_top_3_genres AS
	(
		SELECT g.genre AS genre, m.year AS year, m.title AS movie_name,
			   CASE WHEN m.worlwide_gross_income REGEXP 'INR' 
					THEN CAST(SUBSTRING(worlwide_gross_income, 5) AS DECIMAL)/83 ELSE CAST(SUBSTRING(worlwide_gross_income, 3) AS DECIMAL)
			   END AS worldwide_gross_income
		FROM movie m INNER JOIN genre g ON m.id=g.movie_id
		WHERE g.genre IN ('Drama', 'Comedy', 'Thriller')
	),
    rankings AS
    (
		SELECT *, DENSE_RANK() OVER(PARTITION BY year ORDER BY worldwide_gross_income DESC) AS movie_rank
        FROM highest_grossing_movies_in_top_3_genres
	),
    rankings_formatted_output AS
    (
		SELECT genre, year, movie_name, CONCAT('$', ROUND(worldwide_gross_income)) AS worldwide_gross_income, movie_rank
        FROM rankings
	)    
SELECT *
FROM rankings_formatted_output
WHERE movie_rank<=5;

-- Top 5 highest grossing movies are 'The Fate of the Furious', 'Despicable Me 3', 'Jumanji: Welcome to the Jungle', 'Zhan Lang II' and 'Guardiand of the Galaxy Vol.2' in that order.


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?

-- Type your code below:
WITH production_company_rankings AS
(
	SELECT m.production_company, COUNT(m.id) AS movie_count, DENSE_RANK() OVER(ORDER BY COUNT(m.id) DESC) AS prod_comp_rank
	FROM movie m INNER JOIN ratings r ON m.id=r.movie_id
	WHERE r.median_rating>=8 AND POSITION(',' IN languages)>0 AND m.production_company IS NOT NULL
	GROUP BY m.production_company
)
SELECT *
FROM production_company_rankings
WHERE prod_comp_rank<=2;

-- Star Cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits among multilingual movies.

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?

-- Type your code below:
WITH actress_rankings AS
(
	SELECT nm.name AS actress_name, SUM(r.total_votes) AS total_votes, COUNT(r.movie_id) AS movie_count, 
		   ROUND(SUM(r.avg_rating * r.total_votes)/SUM(r.total_votes),2) AS actress_avg_rating,
		   DENSE_RANK() OVER(ORDER BY COUNT(r.movie_id) DESC, SUM(r.total_votes) DESC) AS actress_rank
	FROM movie m INNER JOIN genre g ON m.id=g.movie_id
				 INNER JOIN ratings r ON m.id=r.movie_id
				 INNER JOIN role_mapping rm ON m.id=rm.movie_id
				 INNER JOIN names nm ON rm.name_id=nm.id
	WHERE r.avg_rating>8 AND g.genre='Drama' AND rm.category='Actress'
	GROUP BY nm.name
)
SELECT *
FROM actress_rankings
WHERE actress_rank<=3;

-- Parvathy Thiruvothu, Susan Brown and Amanda Lawrence are the top 3 actresses based on number of Super Hit movies in drama genre.
-- In the above code, since movie_count is clashing for many top actresses, total_votes has been used as a tie breaker to calculate the rank.


/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations



--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- Getting the list of directors with the required columns
WITH 
	director_list AS
	(
		SELECT nm.id AS director_id, nm.name AS director_name, m.id AS movie_id, m.date_published AS movie_date, r.avg_rating AS avg_rating, 
			   r.total_votes AS total_votes, m.duration AS duration,
			   LEAD(m.date_published,1) OVER(PARTITION BY nm.id ORDER BY m.date_published, m.id) AS next_movie_date
		FROM names nm INNER JOIN director_mapping dm ON nm.id=dm.name_id
					  INNER JOIN movie m ON m.id=dm.movie_id
					  INNER JOIN ratings r ON m.id=r.movie_id
	),
    
    -- Calculating the inter movie time difference in days and adding it to the output table
    director_list_with_inter_movie_days AS
    (
		SELECT *, DATEDIFF(next_movie_date,  movie_date) AS inter_movie_days
		FROM director_list
    )

    -- Aggregating the data by director_id
SELECT director_id, director_name, COUNT(movie_id) AS number_of_movies,
       ROUND(AVG(inter_movie_days)) AS avg_inter_movie_days,
	   ROUND(SUM(avg_rating * total_votes)/SUM(total_votes),2) AS avg_rating,   -- Weighted average is being calculated here
       SUM(total_votes) AS total_votes,
       MIN(avg_rating) AS min_rating,
       MAX(avg_rating) AS max_rating,
       SUM(duration) AS total_duration
FROM director_list_with_inter_movie_days
GROUP BY director_id
ORDER BY COUNT(movie_id) DESC, avg_rating DESC	       -- Average rating is used as tie-breaker for directors with same movie count
LIMIT 9;

-- We can observe that A.L.Vijay has directed the most number of movies (5 movies).