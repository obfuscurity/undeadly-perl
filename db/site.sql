PRAGMA foreign_keys = ON;
CREATE TABLE users(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   role_id INTEGER NOT NULL,
   username VARCHAR(255) NOT NULL,
   password VARCHAR(255) NOT NULL,
   firstname VARCHAR(255) NOT NULL,
   lastname VARCHAR(255) NOT NULL,
   email VARCHAR(255) NOT NULL,
   url VARCHAR(255) NOT NULL,
   tz VARCHAR(255) NOT NULL,
   reputation INTEGER NOT NULL DEFAULT 0,
   api_token VARCHAR(40) NOT NULL,
   confirm_token VARCHAR(40) NOT NULL,
   confirmed_on TEXT,
   registered_on TEXT NOT NULL,
   last_login_on TEXT,
   FOREIGN KEY(role_id) REFERENCES roles(id)
);
CREATE TABLE roles(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   name VARCHAR(255) NOT NULL,
   manage_admins BOOLEAN NOT NULL DEFAULT 0,
   manage_editors BOOLEAN NOT NULL DEFAULT 0,
   manage_users BOOLEAN NOT NULL DEFAULT 0,
   edit_articles BOOLEAN NOT NULL DEFAULT 0,
   delete_articles BOOLEAN NOT NULL DEFAULT 0,
   create_articles BOOLEAN NOT NULL DEFAULT 0,
   read_articles BOOLEAN NOT NULL DEFAULT 1,
   edit_comments BOOLEAN NOT NULL DEFAULT 0,
   delete_comments BOOLEAN NOT NULL DEFAULT 0,
   create_comments BOOLEAN NOT NULL DEFAULT 0,
   read_comments BOOLEAN NOT NULL DEFAULT 1,
   can_login BOOLEAN NOT NULL DEFAULT 0
);
CREATE UNIQUE INDEX index_roles_on_name ON roles(name);
INSERT INTO roles VALUES (1, 'superuser', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (2, 'admin', 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (3, 'editor', 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (4, 'normal', 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1, 1);
INSERT INTO roles VALUES (5, 'readonly', 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 1);
INSERT INTO users VALUES (1, 5, 'anonymous', '', 'Anonymous', 'User', '', 'http://undeadly.org/', 'UTC', 0, '', '', '', '', '');
CREATE TABLE articles(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   revision_id INTEGER NOT NULL,
   topic_id INTEGER NOT NULL,
   status VARCHAR(255) NOT NULL,
   published_on TEXT,
   FOREIGN KEY(revision_id) REFERENCES revisions(id),
   FOREIGN KEY(topic_id) REFERENCES topics(id)
);
CREATE TABLE revisions(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   article_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   timestamp TEXT NOT NULL,
   title VARCHAR(255) NOT NULL,
   dept VARCHAR(255) NOT NULL,
   content TEXT NOT NULL,
   description TEXT NOT NULL,
   format VARCHAR(255) NOT NULL,
   old_sid INTEGER,
   FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE INDEX index_revisions_on_article_id ON revisions(article_id);
CREATE TABLE topics(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   name VARCHAR(255) NOT NULL,
   description TEXT NOT NULL,
   image_url VARCHAR(255)
);
CREATE UNIQUE INDEX index_topics_on_name ON topics(name);
INSERT INTO topics VALUES (1, 'unknown', 'placeholder topic', NULL);
INSERT INTO revisions VALUES (1, 1, 1, '2011-01-01 00:00:00', 'Title', 'Dept', 'Hello World', 'initial submission', 'html', NULL);
INSERT INTO articles VALUES (1, 1, 1, 'submitted', NULL);
CREATE TABLE comments(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   parent_id INTEGER NOT NULL DEFAULT 0,
   article_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   timestamp TEXT NOT NULL,
   title VARCHAR(255) NOT NULL,
   content TEXT NOT NULL,
   score INTEGER NOT NULL DEFAULT 0,
   FOREIGN KEY(article_id) REFERENCES articles(id),
   FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE events(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   timestamp TEXT NOT NULL,
   type VARCHAR(255) NOT NULL,
   message TEXT NOT NULL
);
