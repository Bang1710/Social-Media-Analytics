--A. User statistics

--1. List all information about the user.
SELECT * FROM users;

--2. Count the number of registered users in each year.
SELECT YEAR(created_at) AS registration_year, COUNT(*) AS user_count
FROM users
GROUP BY YEAR(created_at);

--3. Sort users by registration time from new to old.
SELECT *
FROM users
ORDER BY created_at DESC;

--4. List users who have emails but have not set up a profile.
SELECT *
FROM users
WHERE email IS NOT NULL AND bio IS NULL;

--5. Calculate the total number of logged in users this month.
SELECT COUNT(DISTINCT user_id) AS number_user_login_in_month
FROM login
WHERE MONTH(login_time) = MONTH(GETDATE()) AND YEAR(login_time) = YEAR(GETDATE());


--B. Statistics post

--1. Lists posts and the number of comments for each post.
SELECT p.post_id, p.caption, COUNT(c.comment_id) as number_of_comment_in_post 
FROM post as p 
JOIN comments as c ON p.post_id = c.post_id
GROUP BY p.post_id, p.caption

--2. Count the number of posts published each month.
SELECT YEAR(created_at) AS post_of_the_year, MONTH(created_at) AS post_of_the_month, COUNT(*) AS number_of_post_in_month
FROM post
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY YEAR(created_at);

--3. Sort posts by creation time from newest to oldest.
SELECT p.post_id, p.caption, p.[location], p.created_at
FROM post as p
ORDER BY p.created_at DESC

--4. Calculate the total number of likes for each post.
SELECT pl.post_id, p.caption, COUNT(*) AS number_like_of_each_post
FROM post_likes as pl
JOIN post as p on pl.post_id = p.post_id
GROUP BY pl.post_id, p.caption
ORDER BY COUNT(*) DESC

--5. Lists posts that have not been starred (bookmarked) by any user.
SELECT p.post_id, p.caption
FROM post as p
WHERE p.post_id NOT IN (
	SELECT p.post_id FROM post as p
	JOIN bookmarks as b ON p.post_id = b.post_id
	JOIN users as u on b.user_id = u.user_id
)

--C. Statistics of comments and likes

--1. Count the number of comments and likes per post.
SELECT p.post_id, COUNT(DISTINCT c.comment_id) AS avg_comment_count, COUNT(DISTINCT pl.user_id) AS avg_like_count
FROM post p
LEFT JOIN comments c ON p.post_id = c.post_id
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY p.post_id;

--2. Calculate the total number of likes each user liked.
SELECT user_id, COUNT(*) AS given_likes_count
FROM post_likes
GROUP BY user_id;


--3. List your most recent comments and likes.
WITH RecentActivity AS (
    SELECT 'Comment' AS activity_type, comment_id, user_id, post_id, created_at
    FROM comments
    UNION ALL
    SELECT 'Like' AS activity_type, NULL AS comment_id, user_id, post_id, created_at
    FROM post_likes
)

SELECT TOP 10 *
FROM RecentActivity
ORDER BY created_at DESC;

--D. Statistics by hashtag

--1. Count the number of posts for each hashtag.
SELECT ht.hashtag_id, ht.hashtag_name, COUNT(pt.post_id) AS post_count
FROM hashtags ht
LEFT JOIN post_tags pt ON ht.hashtag_id = pt.hashtag_id
GROUP BY ht.hashtag_id, ht.hashtag_name;

--2. Lists the most popular hashtags.
SELECT TOP 10 ht.hashtag_id, ht.hashtag_name, COUNT(pt.post_id) AS post_count
FROM hashtags ht
LEFT JOIN post_tags pt ON ht.hashtag_id = pt.hashtag_id
GROUP BY ht.hashtag_id, ht.hashtag_name
ORDER BY post_count DESC;

--3. Calculate the total number of likes for posts containing a specific hashtag.
SELECT pt.hashtag_id, COUNT(pl.user_id) AS like_count
FROM post_tags pt
INNER JOIN post_likes pl ON pt.post_id = pl.post_id
GROUP BY pt.hashtag_id;

--4. Sort hashtags alphabetically.
SELECT *
FROM hashtags
ORDER BY hashtag_name ASC;


--E. Connection statistics
--1. Count the number of followers for each user.
SELECT follower_id, COUNT(*) AS followee_count
FROM follows
GROUP BY follower_id;

--2. Calculate the total number of followers and followings for each user.
SELECT follower_id, COUNT(DISTINCT followee_id) AS followee_count, 
       (SELECT COUNT(DISTINCT follower_id) FROM follows WHERE followee_id = f.follower_id) AS follower_count
FROM follows f
GROUP BY follower_id;

--3. List the users with the largest number of followers.
SELECT TOP 10 follower_id, COUNT(DISTINCT followee_id) AS followee_count
FROM follows
GROUP BY follower_id
ORDER BY followee_count DESC;

--F. Advanced statistics

--1. List users and rank them based on the number of posts created.
SELECT user_id, COUNT(*) AS like_count,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS user_rank
FROM post_likes
GROUP BY user_id;

--2. Calculate the average number of posts created each day of the week.
SELECT DATEPART(WEEKDAY, created_at) AS day_of_week,
       AVG(COUNT(*)) OVER (PARTITION BY DATEPART(WEEKDAY, created_at)) AS avg_post_count
FROM post
GROUP BY DATEPART(WEEKDAY, created_at);

--3. Lists users and the total number of likes and comments for all their posts.
SELECT p.user_id, COUNT(DISTINCT pl.user_id) AS total_likes,
       COUNT(DISTINCT c.user_id) AS total_comments
FROM post p
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.user_id;

--4. Lists the latest posts and number of comments for each post.
SELECT p.post_id, p.caption, pc.latest_comment_count
FROM post p
LEFT JOIN (
    SELECT post_id, COUNT(*) AS latest_comment_count,
           ROW_NUMBER() OVER (PARTITION BY post_id ORDER BY created_at DESC) AS row_num
    FROM comments
    GROUP BY post_id
) AS pc ON p.post_id = pc.post_id AND pc.row_num = 1;

--5. Calculate the average like rate for each post per user.
SELECT user_id, AVG(like_count) AS avg_like_count
FROM (
    SELECT user_id, post_id, COUNT(*) AS like_count
    FROM post_likes
    GROUP BY user_id, post_id
) AS UserPostLikes
GROUP BY user_id;

--6. Lists hashtags and the total number of likes and comments for all posts containing that hashtag.
SELECT h.hashtag_name, COUNT(DISTINCT pl.user_id) AS total_likes,
       COUNT(DISTINCT c.user_id) AS total_comments
FROM hashtags h
INNER JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
LEFT JOIN post_likes pl ON pt.post_id = pl.post_id
LEFT JOIN comments c ON pt.post_id = c.post_id
GROUP BY h.hashtag_name;

--7. Lists users with their total number of followers.
SELECT follower_id, COUNT(DISTINCT followee_id) AS total_followers
FROM follows
GROUP BY follower_id;

--8. List the users and the number of hashtags they created in their posts.
SELECT user_id, MAX(hashtag_count) AS max_hashtags
FROM (
    SELECT p.user_id, COUNT(*) AS hashtag_count
    FROM post p
    INNER JOIN post_tags pt ON p.post_id = pt.post_id
    GROUP BY p.user_id
) AS UserHashtags;

-- G. More statistics

-- 1. Location of User 
SELECT * FROM post
WHERE location IN ('agra' ,'maharashtra','west bengal');


-- 2. Most Followed Hashtag
SELECT TOP 5
	    hashtag_name AS 'Hashtags', COUNT(hashtag_follow.hashtag_id) AS 'Total Follows' 
FROM hashtag_follow, hashtags 
WHERE hashtags.hashtag_id = hashtag_follow.hashtag_id
GROUP BY hashtag_follow.hashtag_id
ORDER BY COUNT(hashtag_follow.hashtag_id) DESC

-- 3. Most Used Hashtags
SELECT TOP 10
	hashtag_name AS 'Trending Hashtags', 
    COUNT(post_tags.hashtag_id) AS 'Times Used'
FROM hashtags,post_tags
WHERE hashtags.hashtag_id = post_tags.hashtag_id
GROUP BY post_tags.hashtag_id
ORDER BY COUNT(post_tags.hashtag_id) DESC;


-- 4. Most Inactive User
SELECT user_id, username AS 'Most Inactive User'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM post);

 
-- 5. Most Likes Posts
SELECT post_likes.user_id, post_likes.post_id, COUNT(post_likes.post_id) 
FROM post_likes, post
WHERE post.post_id = post_likes.post_id 
GROUP BY post_likes.post_id
ORDER BY COUNT(post_likes.post_id) DESC ;

-- 6. Average post per user
SELECT ROUND((COUNT(post_id) / COUNT(DISTINCT user_id) ),2) AS 'Average Post per User' 
FROM post;

-- 7. no. of login by per user
SELECT u.user_id, u.email, u.username, COUNT(l.login_id) AS login_number
FROM users u
INNER JOIN login l ON u.user_id = l.user_id
GROUP BY u.user_id, u.email, u.username;


-- 8. User who liked every single post (CHECK FOR BOT)
SELECT u.username, COUNT(*) AS num_likes 
FROM users u
INNER JOIN post_likes pl ON u.user_id = pl.user_id 
GROUP BY u.user_id, u.username 
HAVING COUNT(*) = (SELECT COUNT(*) FROM post);


-- 9. User Never Comment 
SELECT user_id, username AS 'User Never Comment'
FROM users
WHERE user_id NOT IN (SELECT user_id FROM comments);

-- 10. User who commented on every post (CHECK FOR BOT)
SELECT username, Count(*) AS num_comment 
FROM users 
INNER JOIN comments ON users.user_id = comments.user_id 
GROUP  BY comments.user_id 
HAVING Count(*) = (SELECT Count(*) FROM comments); 


-- 11. User Not Followed by anyone
SELECT user_id, username AS 'User Not Followed by anyone'
FROM users
WHERE user_id NOT IN (SELECT followee_id FROM follows);

-- 12. User Not Following Anyone
SELECT user_id, username AS 'User Not Following Anyone'
FROM users
WHERE user_id NOT IN (SELECT follower_id FROM follows);

-- 13. Posted more than 5 times
SELECT user_id, COUNT(user_id) AS post_count FROM post
GROUP BY user_id
HAVING COUNT(user_id) > 5
ORDER BY COUNT(user_id) DESC;

-- 14. Followers > 40
SELECT followee_id, COUNT(follower_id) AS follower_count FROM follows
GROUP BY followee_id
HAVING COUNT(follower_id) > 40
ORDER BY COUNT(follower_id) DESC;

-- 15. Longest captions in post
SELECT TOP 5 user_id, caption, LEN(post.caption) AS caption_length 
FROM post 
ORDER BY LEN(post.caption) DESC;

