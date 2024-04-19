CREATE DATABASE SocialMediaDB02
GO

USE SocialMediaDB02
GO

DBCC CHECKIDENT ('comments', RESEED, 1);

CREATE TABLE users (
    user_id INTEGER IDENTITY(1,1) PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    profile_photo_url VARCHAR(255) DEFAULT 'https://picsum.photos/100',
    bio VARCHAR(255),
    created_at DATETIME2 DEFAULT GETDATE()
);

ALTER TABLE users
ADD email VARCHAR(30) NOT NULL;

CREATE TABLE photos (
    photo_id INTEGER IDENTITY(1,1) PRIMARY KEY,
    photo_url VARCHAR(255) NOT NULL UNIQUE,
    post_id	INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    size FLOAT CHECK (size<5)
);

CREATE TABLE videos (
  video_id INTEGER IDENTITY(1,1) PRIMARY KEY,
  video_url VARCHAR(255) NOT NULL UNIQUE,
  post_id INTEGER NOT NULL,
  created_at DATETIME2 DEFAULT GETDATE(),
  size FLOAT CHECK (size<10)
  
);

CREATE TABLE post (
	post_id INTEGER IDENTITY(1,1) PRIMARY KEY,
    photo_id INTEGER,
    video_id INTEGER,
    user_id INTEGER NOT NULL,
    caption VARCHAR(200), 
    location VARCHAR(50) ,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
	FOREIGN KEY(photo_id) REFERENCES photos(photo_id),
    FOREIGN KEY(video_id) REFERENCES videos(video_id)
);

CREATE TABLE comments (
    comment_id INTEGER IDENTITY(1,1) PRIMARY KEY,
    comment_text VARCHAR(255) NOT NULL,
    post_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id)
);

CREATE TABLE post_likes (
    user_id INTEGER NOT NULL,
    post_id INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    PRIMARY KEY(user_id, post_id)
);

CREATE TABLE comment_likes (
    user_id INTEGER NOT NULL,
    comment_id INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(comment_id) REFERENCES comments(comment_id),
    PRIMARY KEY(user_id, comment_id)
);

CREATE TABLE follows (
    follower_id INTEGER NOT NULL,
    followee_id INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(follower_id) REFERENCES users(user_id),
    FOREIGN KEY(followee_id) REFERENCES users(user_id),
    PRIMARY KEY(follower_id, followee_id)
);

CREATE TABLE hashtags (
  hashtag_id INTEGER IDENTITY(1,1) PRIMARY KEY,
  hashtag_name VARCHAR(255) UNIQUE,
  created_at DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE hashtag_follow (
	user_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(hashtag_id) REFERENCES hashtags(hashtag_id),
    PRIMARY KEY(user_id, hashtag_id)
);

CREATE TABLE post_tags (
    post_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    FOREIGN KEY(post_id) REFERENCES post(post_id),
    FOREIGN KEY(hashtag_id) REFERENCES hashtags(hashtag_id),
    PRIMARY KEY(post_id, hashtag_id)
);

CREATE TABLE bookmarks (
  post_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  created_at DATETIME2 DEFAULT GETDATE(),
  FOREIGN KEY(post_id) REFERENCES post(post_id),
  FOREIGN KEY(user_id) REFERENCES users(user_id),
  PRIMARY KEY(user_id, post_id)
);

CREATE TABLE login (
  login_id INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
  user_id INTEGER NOT NULL,
  ip VARCHAR(50) NOT NULL,
  login_time DATETIME2 NOT NULL DEFAULT GETDATE(),
  FOREIGN KEY(user_id) REFERENCES users(user_id)
);