-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.1.28-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win32
-- HeidiSQL Version:             10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Dumping database structure for archive_audio
CREATE DATABASE IF NOT EXISTS `archive_audio` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `archive_audio`;

-- Dumping structure for table archive_audio.collections
DROP TABLE IF EXISTS `collections`;
CREATE TABLE IF NOT EXISTS `collections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `project_id` int(11) NOT NULL,
  `slug` varchar(60) NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `date` date DEFAULT NULL,
  `type` enum('album','playlist') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.collections: ~0 rows (approximately)
/*!40000 ALTER TABLE `collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `collections` ENABLE KEYS */;

-- Dumping structure for table archive_audio.collection_map
DROP TABLE IF EXISTS `collection_map`;
CREATE TABLE IF NOT EXISTS `collection_map` (
  `ordinal` int(11) DEFAULT NULL,
  `collection_id` int(11) NOT NULL,
  `song_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.collection_map: ~0 rows (approximately)
/*!40000 ALTER TABLE `collection_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `collection_map` ENABLE KEYS */;

-- Dumping structure for table archive_audio.media
DROP TABLE IF EXISTS `media`;
CREATE TABLE IF NOT EXISTS `media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `path` varchar(255) DEFAULT NULL,
  `type` enum('image','audio') DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.media: ~3 rows (approximately)
/*!40000 ALTER TABLE `media` DISABLE KEYS */;
REPLACE INTO `media` (`id`, `path`, `type`) VALUES
	(1, 'main-echo-no-echo.jpg', 'image'),
	(2, 'main-squish.jpg', 'image'),
	(3, 'square.jpg', 'image');
/*!40000 ALTER TABLE `media` ENABLE KEYS */;

-- Dumping structure for table archive_audio.parent_songs
DROP TABLE IF EXISTS `parent_songs`;
CREATE TABLE IF NOT EXISTS `parent_songs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(60) NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `primary_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.parent_songs: ~0 rows (approximately)
/*!40000 ALTER TABLE `parent_songs` DISABLE KEYS */;
/*!40000 ALTER TABLE `parent_songs` ENABLE KEYS */;

-- Dumping structure for table archive_audio.people
DROP TABLE IF EXISTS `people`;
CREATE TABLE IF NOT EXISTS `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(60) NOT NULL,
  `slug` varchar(60) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.people: ~0 rows (approximately)
/*!40000 ALTER TABLE `people` DISABLE KEYS */;
/*!40000 ALTER TABLE `people` ENABLE KEYS */;

-- Dumping structure for table archive_audio.people_map
DROP TABLE IF EXISTS `people_map`;
CREATE TABLE IF NOT EXISTS `people_map` (
  `project_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `role` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.people_map: ~0 rows (approximately)
/*!40000 ALTER TABLE `people_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `people_map` ENABLE KEYS */;

-- Dumping structure for table archive_audio.projects
DROP TABLE IF EXISTS `projects`;
CREATE TABLE IF NOT EXISTS `projects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `slug` varchar(60) NOT NULL,
  `title` varchar(60) NOT NULL,
  `year_start` year(4) DEFAULT NULL,
  `year_end` year(4) DEFAULT NULL,
  `description` text,
  `media_id` int(11) DEFAULT NULL,
  `featured` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.projects: ~2 rows (approximately)
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
REPLACE INTO `projects` (`id`, `slug`, `title`, `year_start`, `year_end`, `description`, `media_id`, `featured`) VALUES
	(1, 'squish', 'Squish', '1993', '1994', 'My first band', 2, 1),
	(2, 'echo-no-echo', 'Echo No Echo', '2006', '2008', 'Lorum ipsum', 1, NULL);
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;

-- Dumping structure for table archive_audio.songs
DROP TABLE IF EXISTS `songs`;
CREATE TABLE IF NOT EXISTS `songs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_id` int(11) DEFAULT NULL,
  `project_id` int(11) NOT NULL,
  `slug` varchar(60) NOT NULL,
  `title` varchar(120) NOT NULL,
  `description` text,
  `date` date DEFAULT NULL,
  `type` enum('rehearsal','live','demo','alternate','release') DEFAULT NULL,
  `lyrics` text,
  `media_id` int(11) DEFAULT NULL,
  `peak_data` text,
  `featured` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `songs_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.songs: ~2 rows (approximately)
/*!40000 ALTER TABLE `songs` DISABLE KEYS */;
REPLACE INTO `songs` (`id`, `parent_id`, `project_id`, `slug`, `title`, `description`, `date`, `type`, `lyrics`, `media_id`, `peak_data`, `featured`) VALUES
	(1, NULL, 1, 'song-a', 'Song A', 'A song called A', '2020-05-25', NULL, 'None', 3, NULL, 1),
	(2, NULL, 2, 'out-of-place', 'Out Of Place', 'Started out as ...', '2020-05-25', 'release', 'Feel like I\'m alonge', NULL, NULL, NULL);
/*!40000 ALTER TABLE `songs` ENABLE KEYS */;

-- Dumping structure for table archive_audio.tags
DROP TABLE IF EXISTS `tags`;
CREATE TABLE IF NOT EXISTS `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.tags: ~0 rows (approximately)
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;

-- Dumping structure for table archive_audio.tag_map
DROP TABLE IF EXISTS `tag_map`;
CREATE TABLE IF NOT EXISTS `tag_map` (
  `song_id` int(11) NOT NULL,
  `tag_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table archive_audio.tag_map: ~0 rows (approximately)
/*!40000 ALTER TABLE `tag_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `tag_map` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
