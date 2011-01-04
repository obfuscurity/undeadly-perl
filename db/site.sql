PRAGMA foreign_keys = ON;
CREATE TABLE users(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   role_id INTEGER NOT NULL,
   username VARCHAR(255) NOT NULL,
   password VARCHAR(255) NOT NULL,
   firstname VARCHAR(255) NOT NULL,
   lastname VARCHAR(255) NOT NULL,
   email VARCHAR(255) NOT NULL,
   url TEXT NOT NULL,
   tz VARCHAR(255) NOT NULL,
   reputation INTEGER NOT NULL DEFAULT 0,
   FOREIGN KEY(role_id) REFERENCES roles(id)
);
CREATE TABLE roles(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   name TEXT NOT NULL,
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
   read_comments BOOLEAN NOT NULL DEFAULT 1
);
CREATE UNIQUE INDEX index_roles_on_name ON roles(name);
INSERT INTO roles VALUES (1, 'superuser', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (2, 'admin', 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (3, 'editor', 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1);
INSERT INTO roles VALUES (4, 'normal', 0, 0, 0, 0, 0, 1, 1, 0, 0, 1, 1);
INSERT INTO roles VALUES (5, 'readonly', 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1);
CREATE TABLE articles(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   revision_id INTEGER NOT NULL,
   topic_id INTEGER NOT NULL,
   status VARCHAR(255) NOT NULL,
   FOREIGN KEY(revision_id) REFERENCES revisions(id),
   FOREIGN KEY(topic_id) REFERENCES topics(id)
);
CREATE TABLE revisions(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   article_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   epoch INTEGER NOT NULL,
   title TEXT NOT NULL,
   dept TEXT NOT NULL,
   content TEXT NOT NULL,
   description TEXT NOT NULL,
   format VARCHAR(255) NOT NULL,
   old_sid INTEGER,
   FOREIGN KEY(article_id) REFERENCES articles(id),
   FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE topics(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   name TEXT NOT NULL,
   description TEXT NOT NULL,
   image_url TEXT
);
CREATE UNIQUE INDEX index_topics_on_name ON topics(name);
INSERT INTO topics VALUES (1, 'unknown', 'placeholder topic', NULL);
CREATE TABLE comments(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   article_id INTEGER NOT NULL,
   user_id INTEGER NOT NULL,
   epoch INTEGER NOT NULL,
   title TEXT NOT NULL,
   content TEXT NOT NULL,
   score INTEGER NOT NULL DEFAULT 0,
   FOREIGN KEY(article_id) REFERENCES articles(id),
   FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE TABLE events(
   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   type VARCHAR(255) NOT NULL,
   message TEXT NOT NULL
);
