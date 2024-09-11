## Social Media Analytics
![separator1](https://i.imgur.com/ZUWYTii.png)
### Tổng quan Dự án
Dự án này tập trung vào việc phân tích dữ liệu từ các nền tảng mạng xã hội để tạo ra một cấu trúc cơ bản của cơ sở dữ liệu dễ dàng kết nối với giao diện frontend. Chúng tôi quản lý dữ liệu từ nhiều người dùng, bao gồm cả thông tin về người theo dõi, sở thích và các hoạt động công khai như lượt thích bài viết, bình luận và các hashtag mà họ theo dõi.

Các phân tích khác nhau đã được thực hiện để cung cấp những thông tin giá trị cho việc quản lý và phát triển kinh doanh, bao gồm:
- Thống kê Người dùng: Liệt kê chi tiết thông tin người dùng, đếm số người đăng ký mỗi năm, sắp xếp người dùng theo thời gian đăng ký và liệt kê những người dùng có email nhưng chưa thiết lập hồ sơ cá nhân.
- Thống kê Bài viết: Liệt kê các bài viết và số lượng bình luận của chúng, đếm số bài viết được xuất bản mỗi tháng, sắp xếp bài viết theo thời gian tạo, và tính tổng số lượt thích cho mỗi bài viết.
- Thống kê Bình luận và Lượt thích: Đếm số lượng bình luận và lượt thích cho mỗi bài viết, tính tổng số lượt thích mà mỗi người dùng đã gửi, và liệt kê các bình luận và lượt thích gần đây.
- Thống kê Hashtag: Đếm số lượng bài viết cho mỗi hashtag, liệt kê các hashtag phổ biến và tính tổng số lượt thích cho các bài viết chứa các hashtag cụ thể.
- Thống kê Kết nối: Đếm số người theo dõi cho mỗi người dùng, tính tổng số người theo dõi và người mà mỗi người dùng theo dõi, và liệt kê những người dùng có số lượng người theo dõi lớn nhất.

Ngoài ra, dự án còn bao gồm các phân tích nâng cao như xếp hạng người dùng dựa trên số lượng bài viết đã tạo, trung bình số bài viết được tạo mỗi ngày trong tuần, và liệt kê người dùng với tổng số lượt thích và bình luận cho tất cả các bài viết của họ.
### ERD 
![separator](https://github.com/Bang1710/Social-Media-Analytics/blob/main/ERD.png)
### Analysis Highlights
### A. User statistics
#### 1. List all information about the user.
```sql
SELECT * FROM users;
```

#### 2. Count the number of registered users in each year.
```sql
SELECT YEAR(created_at) AS registration_year, COUNT(*) AS user_count
FROM users
GROUP BY YEAR(created_at);
```

#### 3. Sort users by registration time from new to old.
```sql
SELECT *
FROM users
ORDER BY created_at DESC;
```

#### 4. List users who have emails but have not set up a profile.
```sql
SELECT *
FROM users
WHERE email IS NOT NULL AND bio IS NULL;
```

#### 5. Calculate the total number of logged in users this month.
```sql
SELECT COUNT(DISTINCT user_id) AS number_user_login_in_month
FROM login
WHERE MONTH(login_time) = MONTH(GETDATE()) AND YEAR(login_time) = YEAR(GETDATE());
```
### B. Statistics post

#### 1. Lists posts and the number of comments for each post.
```sql
SELECT p.post_id, p.caption, COUNT(c.comment_id) as number_of_comment_in_post 
FROM post as p 
JOIN comments as c ON p.post_id = c.post_id
GROUP BY p.post_id, p.caption
```
#### 2. Count the number of posts published each month.
```sql
SELECT YEAR(created_at) AS post_of_the_year, MONTH(created_at) AS post_of_the_month, COUNT(*) AS number_of_post_in_month
FROM post
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY YEAR(created_at);
```
#### 3. Sort posts by creation time from newest to oldest.
```sql
SELECT p.post_id, p.caption, p.[location], p.created_at
FROM post as p
ORDER BY p.created_at DESC
```
#### 4. Calculate the total number of likes for each post.
```sql
SELECT pl.post_id, p.caption, COUNT(*) AS number_like_of_each_post
FROM post_likes as pl
JOIN post as p on pl.post_id = p.post_id
GROUP BY pl.post_id, p.caption
ORDER BY COUNT(*) DESC
```
#### 5. Lists posts that have not been starred (bookmarked) by any user.
```sql
SELECT p.post_id, p.caption
FROM post as p
WHERE p.post_id NOT IN (
	SELECT p.post_id FROM post as p
	JOIN bookmarks as b ON p.post_id = b.post_id
	JOIN users as u on b.user_id = u.user_id
)
```
### C. Statistics of comments and likes

#### 1. Count the number of comments and likes per post.
```sql
SELECT p.post_id, COUNT(DISTINCT c.comment_id) AS avg_comment_count, COUNT(DISTINCT pl.user_id) AS avg_like_count
FROM post p
LEFT JOIN comments c ON p.post_id = c.post_id
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY p.post_id;
```

#### 2. Calculate the total number of likes each user liked.
```sql
SELECT user_id, COUNT(*) AS given_likes_count
FROM post_likes
GROUP BY user_id;
```
#### 3. List your most recent comments and likes.
```sql
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
```

### D. Statistics by hashtag

#### 1. Count the number of posts for each hashtag.
```sql
SELECT ht.hashtag_id, ht.hashtag_name, COUNT(pt.post_id) AS post_count
FROM hashtags ht
LEFT JOIN post_tags pt ON ht.hashtag_id = pt.hashtag_id
GROUP BY ht.hashtag_id, ht.hashtag_name;
```

#### 2. Lists the most popular hashtags.
```sql
SELECT TOP 10 ht.hashtag_id, ht.hashtag_name, COUNT(pt.post_id) AS post_count
FROM hashtags ht
LEFT JOIN post_tags pt ON ht.hashtag_id = pt.hashtag_id
GROUP BY ht.hashtag_id, ht.hashtag_name
ORDER BY post_count DESC;
```

#### 3. Calculate the total number of likes for posts containing a specific hashtag.
```sql
SELECT pt.hashtag_id, COUNT(pl.user_id) AS like_count
FROM post_tags pt
INNER JOIN post_likes pl ON pt.post_id = pl.post_id
GROUP BY pt.hashtag_id;
```

#### 4. Sort hashtags alphabetically.
```sql
SELECT *
FROM hashtags
ORDER BY hashtag_name ASC;
```


### E. Connection statistics
#### 1. Count the number of followers for each user.
```sql
SELECT follower_id, COUNT(*) AS followee_count
FROM follows
GROUP BY follower_id;
```

#### 2. Calculate the total number of followers and followings for each user.
```sql
SELECT follower_id, COUNT(DISTINCT followee_id) AS followee_count, 
       (SELECT COUNT(DISTINCT follower_id) FROM follows WHERE followee_id = f.follower_id) AS follower_count
FROM follows f
GROUP BY follower_id;
```

#### 3. List the users with the largest number of followers.
```sql
SELECT TOP 10 follower_id, COUNT(DISTINCT followee_id) AS followee_count
FROM follows
GROUP BY follower_id
ORDER BY followee_count DESC;
```
### F. Advanced statistics

#### 1. List users and rank them based on the number of posts created.
```sql
SELECT user_id, COUNT(*) AS like_count,
       RANK() OVER (ORDER BY COUNT(*) DESC) AS user_rank
FROM post_likes
GROUP BY user_id;
```

#### 2. Calculate the average number of posts created each day of the week.
```sql
SELECT DATEPART(WEEKDAY, created_at) AS day_of_week,
       AVG(COUNT(*)) OVER (PARTITION BY DATEPART(WEEKDAY, created_at)) AS avg_post_count
FROM post
GROUP BY DATEPART(WEEKDAY, created_at);
```

#### 3. Lists users and the total number of likes and comments for all their posts.
```sql
SELECT p.user_id, COUNT(DISTINCT pl.user_id) AS total_likes,
       COUNT(DISTINCT c.user_id) AS total_comments
FROM post p
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.user_id;
```

#### 4. Lists the latest posts and number of comments for each post.
```sql
SELECT p.post_id, p.caption, pc.latest_comment_count
FROM post p
LEFT JOIN (
    SELECT post_id, COUNT(*) AS latest_comment_count,
           ROW_NUMBER() OVER (PARTITION BY post_id ORDER BY created_at DESC) AS row_num
    FROM comments
    GROUP BY post_id
) AS pc ON p.post_id = pc.post_id AND pc.row_num = 1;
```

#### 5. Calculate the average like rate for each post per user.
```sql
SELECT user_id, AVG(like_count) AS avg_like_count
FROM (
    SELECT user_id, post_id, COUNT(*) AS like_count
    FROM post_likes
    GROUP BY user_id, post_id
) AS UserPostLikes
GROUP BY user_id;
```

#### 6. Lists hashtags and the total number of likes and comments for all posts containing that hashtag.
```sql
SELECT h.hashtag_name, COUNT(DISTINCT pl.user_id) AS total_likes,
       COUNT(DISTINCT c.user_id) AS total_comments
FROM hashtags h
INNER JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
LEFT JOIN post_likes pl ON pt.post_id = pl.post_id
LEFT JOIN comments c ON pt.post_id = c.post_id
GROUP BY h.hashtag_name;
```

#### 7. Lists users with their total number of followers.
```sql
SELECT follower_id, COUNT(DISTINCT followee_id) AS total_followers
FROM follows
GROUP BY follower_id;
```

#### 8. List the users and the number of hashtags they created in their posts.
```sql
SELECT user_id, MAX(hashtag_count) AS max_hashtags
FROM (
    SELECT p.user_id, COUNT(*) AS hashtag_count
    FROM post p
    INNER JOIN post_tags pt ON p.post_id = pt.post_id
    GROUP BY p.user_id
) AS UserHashtags;
``` 
