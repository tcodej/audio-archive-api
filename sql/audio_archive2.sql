CREATE TABLE `projects` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `slug` varchar(60) UNIQUE NOT NULL,
  `title` varchar(60) NOT NULL,
  `year_start` year(4) DEFAULT NULL,
  `year_end` year(4) DEFAULT NULL,
  `description` text,
  `media_id` int(11) DEFAULT null,
  `featured` int(11) DEFAULT null
);

CREATE TABLE `songs` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT null,
  `project_id` int(11) NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `date` date DEFAULT null,
  `type` ENUM ('rehearsal', 'live', 'demo', 'alternate', 'release') DEFAULT null,
  `lyrics` text,
  `media_id` int(11) DEFAULT null,
  `peak_data` text,
  `featured` int(11) DEFAULT null,
  `file` varchar(120) DEFAULT null
);

CREATE TABLE `parent_songs` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `slug` varchar(60) UNIQUE NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `primary_id` int(11) DEFAULT null
);

CREATE TABLE `collections` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `slug` varchar(60) UNIQUE NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `date` date DEFAULT null,
  `type` ENUM ('album', 'playlist') DEFAULT null,
  `media_id` int(11) DEFAULT null
);

CREATE TABLE `collections_map` (
  `ordinal` int(11) DEFAULT null,
  `collection_id` int(11) NOT NULL,
  `song_id` int(11) NOT NULL
);

CREATE TABLE `media` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `path` varchar(255) DEFAULT NULL,
  `type` ENUM ('image', 'audio') DEFAULT null
);

CREATE TABLE `tags` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(30) UNIQUE NOT NULL
);

CREATE TABLE `tags_map` (
  `song_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
);

CREATE TABLE `people` (
  `id` int(11) PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(60) UNIQUE NOT NULL,
  `slug` varchar(60) UNIQUE NOT NULL
);

CREATE TABLE `people_map` (
  `project_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `role` varchar(120) DEFAULT null
);

ALTER TABLE `songs` ADD FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`);

ALTER TABLE `collections` ADD FOREIGN KEY (`id`) REFERENCES `collections_map` (`collection_id`);

ALTER TABLE `songs` ADD FOREIGN KEY (`id`) REFERENCES `collections_map` (`song_id`);

ALTER TABLE `projects` ADD FOREIGN KEY (`id`) REFERENCES `collections` (`project_id`);

ALTER TABLE `media` ADD FOREIGN KEY (`id`) REFERENCES `songs` (`media_id`);

ALTER TABLE `media` ADD FOREIGN KEY (`id`) REFERENCES `projects` (`media_id`);

ALTER TABLE `songs` ADD FOREIGN KEY (`id`) REFERENCES `tags_map` (`song_id`);

ALTER TABLE `tags` ADD FOREIGN KEY (`id`) REFERENCES `tags_map` (`tag_id`);

ALTER TABLE `projects` ADD FOREIGN KEY (`id`) REFERENCES `people_map` (`project_id`);

ALTER TABLE `people` ADD FOREIGN KEY (`id`) REFERENCES `people_map` (`person_id`);

ALTER TABLE `songs` ADD FOREIGN KEY (`id`) REFERENCES `parent_songs` (`primary_id`);

ALTER TABLE `parent_songs` ADD FOREIGN KEY (`id`) REFERENCES `songs` (`parent_id`);

ALTER TABLE `media` ADD FOREIGN KEY (`id`) REFERENCES `collections` (`media_id`);
