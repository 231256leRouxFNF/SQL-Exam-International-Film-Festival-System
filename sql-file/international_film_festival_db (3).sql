-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Aug 21, 2025 at 01:44 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `international_film_festival_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetInternationalFilms` ()   BEGIN
  SELECT
    f.film_id,
    f.title,
    COUNT(fc.country_id) AS country_count
  FROM film f
  JOIN filmcountry fc ON fc.film_id = f.film_id
  GROUP BY f.film_id, f.title
  HAVING COUNT(fc.country_id) > 1
  ORDER BY country_count DESC, f.title;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetNominees` (IN `p_min_avg_score` DECIMAL(4,2))   BEGIN
  SELECT
    f.film_id,
    f.title,
    AVG(js.score) AS avg_score,
    COUNT(js.jury_member_id) AS votes
  FROM juryscore js
  JOIN film f ON f.film_id = js.film_id
  GROUP BY f.film_id, f.title
  HAVING AVG(js.score) >= p_min_avg_score
  ORDER BY avg_score DESC, votes DESC, f.title;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSoldOutScreenings` ()   BEGIN
  SELECT
    s.screening_id,
    f.title,
    v.name AS venue,
    s.starts_at,
    s.ends_at,
    COUNT(t.ticket_id) AS tickets_sold,
    v.capacity
  FROM screening s
  JOIN film f ON f.film_id = s.film_id
  JOIN venue v ON v.venue_id = s.venue_id
  LEFT JOIN ticket t ON t.screening_id = s.screening_id
  GROUP BY s.screening_id, f.title, v.name, s.starts_at, s.ends_at, v.capacity
  HAVING COUNT(t.ticket_id) >= v.capacity;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audience`
--

CREATE TABLE `audience` (
  `audience_id` int(11) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audience`
--

INSERT INTO `audience` (`audience_id`, `full_name`, `email`, `phone`) VALUES
(1, 'Lerato Ndlovu', 'lerato@example.com', '+27 82 000 0001'),
(2, 'Sam Patel', 'sam@example.com', '+27 82 000 0002'),
(3, 'Mia Chen', 'mia@example.com', '+27 82 000 0003'),
(4, 'Alex Brown', 'alex@example.com', '+27 82 000 0004'),
(5, 'Jo Naidoo', 'jo@example.com', '+27 82 000 0005');

-- --------------------------------------------------------

--
-- Table structure for table `award`
--

CREATE TABLE `award` (
  `award_id` int(11) NOT NULL,
  `award_category_id` int(11) NOT NULL,
  `year` year(4) NOT NULL,
  `film_id` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `result` enum('Winner','Nominee') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `awardcategory`
--

CREATE TABLE `awardcategory` (
  `award_category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `awardcategory`
--

INSERT INTO `awardcategory` (`award_category_id`, `name`, `description`, `category_id`) VALUES
(1, 'Best Feature', 'Top narrative feature', 1),
(2, 'Best Documentary', 'Top documentary', 2),
(3, 'Best Short', 'Top short film', 3);

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

CREATE TABLE `category` (
  `category_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`category_id`, `name`, `description`) VALUES
(1, 'Feature Film', 'Narrative feature-length films'),
(2, 'Documentary', 'Non-fiction films'),
(3, 'Short Film', 'Short-format films');

-- --------------------------------------------------------

--
-- Table structure for table `country`
--

CREATE TABLE `country` (
  `country_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `country`
--

INSERT INTO `country` (`country_id`, `name`) VALUES
(2, 'France'),
(4, 'Japan'),
(1, 'South Africa'),
(3, 'USA');

-- --------------------------------------------------------

--
-- Table structure for table `event`
--

CREATE TABLE `event` (
  `event_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `venue_id` int(11) NOT NULL
) ;

--
-- Dumping data for table `event`
--

INSERT INTO `event` (`event_id`, `name`, `description`, `starts_at`, `ends_at`, `venue_id`) VALUES
(1, 'Opening Night', 'Premiere screening', '2025-08-25 18:00:00', '2025-08-25 21:30:00', 1),
(2, 'Docu Focus', 'Documentary block', '2025-08-26 14:00:00', '2025-08-26 17:00:00', 2);

-- --------------------------------------------------------

--
-- Table structure for table `film`
--

CREATE TABLE `film` (
  `film_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `release_year` year(4) DEFAULT NULL,
  `duration_min` int(11) DEFAULT NULL,
  `synopsis` text DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `film`
--

INSERT INTO `film` (`film_id`, `title`, `release_year`, `duration_min`, `synopsis`, `category_id`) VALUES
(1, 'Savannah Skies', '2024', 110, 'A family drama set in the Karoo.', 1),
(2, 'Oceans of Truth', '2023', 95, 'Documentary exploring climate change.', 2),
(3, 'Neon Sparrow', '2025', 18, 'Stylized short about urban isolation.', 3);

-- --------------------------------------------------------

--
-- Table structure for table `filmcountry`
--

CREATE TABLE `filmcountry` (
  `film_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `filmcountry`
--

INSERT INTO `filmcountry` (`film_id`, `country_id`) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 4);

-- --------------------------------------------------------

--
-- Table structure for table `filmperson`
--

CREATE TABLE `filmperson` (
  `film_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `role` enum('Director','Producer','Actor','Writer','Cinematographer','Editor','Composer') NOT NULL,
  `character_name` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `filmperson`
--

INSERT INTO `filmperson` (`film_id`, `person_id`, `role`, `character_name`) VALUES
(1, 1, 'Director', NULL),
(1, 3, 'Actor', NULL),
(2, 2, 'Director', NULL),
(3, 3, 'Actor', NULL),
(3, 4, 'Director', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `jurymember`
--

CREATE TABLE `jurymember` (
  `jury_member_id` int(11) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `affiliation` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jurymember`
--

INSERT INTO `jurymember` (`jury_member_id`, `full_name`, `email`, `affiliation`) VALUES
(1, 'Prof. Nomsa Dlamini', 'nomsa@uni.ac.za', 'UCT'),
(2, 'Diego Fernández', 'diego@fest.org', 'IFF');

-- --------------------------------------------------------

--
-- Table structure for table `juryscore`
--

CREATE TABLE `juryscore` (
  `jury_member_id` int(11) NOT NULL,
  `film_id` int(11) NOT NULL,
  `score` tinyint(4) NOT NULL,
  `comments` text DEFAULT NULL
) ;

--
-- Dumping data for table `juryscore`
--

INSERT INTO `juryscore` (`jury_member_id`, `film_id`, `score`, `comments`) VALUES
(1, 1, 9, 'Stunning photography'),
(1, 2, 7, 'Solid, informative'),
(1, 3, 6, 'Experimental'),
(2, 1, 8, 'Strong performances'),
(2, 2, 8, 'Well researched'),
(2, 3, 7, 'Intriguing');

-- --------------------------------------------------------

--
-- Table structure for table `person`
--

CREATE TABLE `person` (
  `person_id` int(11) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `dob` date DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `person`
--

INSERT INTO `person` (`person_id`, `full_name`, `dob`, `country_id`) VALUES
(1, 'Thandi Mokoena', '1985-06-12', 1),
(2, 'Jean Dupont', '1970-03-21', 2),
(3, 'Ava Johnson', '1990-10-05', 3),
(4, 'Kenji Sato', '1982-01-14', 4);

-- --------------------------------------------------------

--
-- Table structure for table `screening`
--

CREATE TABLE `screening` (
  `screening_id` int(11) NOT NULL,
  `film_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL,
  `starts_at` datetime NOT NULL,
  `ends_at` datetime NOT NULL,
  `capacity` int(11) NOT NULL
) ;

--
-- Dumping data for table `screening`
--

INSERT INTO `screening` (`screening_id`, `film_id`, `venue_id`, `starts_at`, `ends_at`, `capacity`) VALUES
(1, 1, 1, '2025-08-25 19:00:00', '2025-08-25 21:00:00', 0),
(2, 2, 2, '2025-08-26 15:00:00', '2025-08-26 16:45:00', 0),
(3, 1, 2, '2025-08-27 12:00:00', '2025-08-27 14:00:00', 0),
(4, 3, 1, '2025-08-27 15:00:00', '2025-08-27 15:30:00', 0);

--
-- Triggers `screening`
--
DELIMITER $$
CREATE TRIGGER `trg_screening_no_overlap_bi` BEFORE INSERT ON `screening` FOR EACH ROW BEGIN
  IF EXISTS (
    SELECT 1 FROM screening s
     WHERE s.venue_id = NEW.venue_id
       AND NOT (NEW.ends_at <= s.starts_at OR NEW.starts_at >= s.ends_at)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping screening in this venue';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_screening_no_overlap_bu` BEFORE UPDATE ON `screening` FOR EACH ROW BEGIN
  IF EXISTS (
    SELECT 1 FROM screening s
     WHERE s.venue_id = NEW.venue_id
       AND s.screening_id <> OLD.screening_id
       AND NOT (NEW.ends_at <= s.starts_at OR NEW.starts_at >= s.ends_at)
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Overlapping screening in this venue';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `seat`
--

CREATE TABLE `seat` (
  `seat_id` int(11) NOT NULL,
  `venue_id` int(11) NOT NULL,
  `row_label` varchar(10) NOT NULL,
  `seat_number` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `seat`
--

INSERT INTO `seat` (`seat_id`, `venue_id`, `row_label`, `seat_number`) VALUES
(1, 1, 'A', '1'),
(2, 1, 'A', '2'),
(3, 1, 'A', '3'),
(4, 1, 'A', '4'),
(5, 2, 'A', '1'),
(6, 2, 'A', '2'),
(7, 2, 'A', '3');

-- --------------------------------------------------------

--
-- Table structure for table `sponsor`
--

CREATE TABLE `sponsor` (
  `sponsor_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsor`
--

INSERT INTO `sponsor` (`sponsor_id`, `name`, `email`) VALUES
(1, 'CineBank', 'contact@cinebank.com'),
(2, 'GreenOcean', 'hello@greenocean.org');

-- --------------------------------------------------------

--
-- Table structure for table `sponsorship`
--

CREATE TABLE `sponsorship` (
  `sponsorship_id` int(11) NOT NULL,
  `sponsor_id` int(11) NOT NULL,
  `event_id` int(11) DEFAULT NULL,
  `award_category_id` int(11) DEFAULT NULL,
  `amount` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sponsorship`
--

INSERT INTO `sponsorship` (`sponsorship_id`, `sponsor_id`, `event_id`, `award_category_id`, `amount`) VALUES
(1, 1, 1, 1, 50000.00),
(2, 2, 2, 2, 25000.00);

-- --------------------------------------------------------

--
-- Table structure for table `ticket`
--

CREATE TABLE `ticket` (
  `ticket_id` int(11) NOT NULL,
  `screening_id` int(11) NOT NULL,
  `seat_id` int(11) NOT NULL,
  `audience_id` int(11) NOT NULL,
  `purchased_at` datetime DEFAULT current_timestamp(),
  `price` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `ticket`
--

INSERT INTO `ticket` (`ticket_id`, `screening_id`, `seat_id`, `audience_id`, `purchased_at`, `price`) VALUES
(1, 1, 1, 1, '2025-08-21 08:54:42', 120.00),
(2, 1, 2, 2, '2025-08-21 08:54:42', 120.00),
(3, 1, 3, 3, '2025-08-21 08:54:42', 120.00),
(4, 1, 4, 4, '2025-08-21 08:54:42', 120.00),
(5, 2, 5, 1, '2025-08-21 08:54:42', 100.00),
(6, 2, 6, 2, '2025-08-21 08:54:42', 100.00);

--
-- Triggers `ticket`
--
DELIMITER $$
CREATE TRIGGER `trg_ticket_no_double_booking_bi` BEFORE INSERT ON `ticket` FOR EACH ROW BEGIN
  IF EXISTS (
    SELECT 1 FROM ticket
     WHERE screening_id = NEW.screening_id
       AND seat_id = NEW.seat_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat already booked for this screening';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_ticket_no_double_booking_bu` BEFORE UPDATE ON `ticket` FOR EACH ROW BEGIN
  IF (NEW.seat_id <> OLD.seat_id OR NEW.screening_id <> OLD.screening_id) AND
     EXISTS (
       SELECT 1 FROM ticket
        WHERE screening_id = NEW.screening_id
          AND seat_id = NEW.seat_id
          AND ticket_id <> OLD.ticket_id
     ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat already booked for this screening';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_ticket_set_timestamp` BEFORE INSERT ON `ticket` FOR EACH ROW BEGIN
  IF NEW.purchased_at IS NULL THEN
    SET NEW.purchased_at = CURRENT_TIMESTAMP;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `venue`
--

CREATE TABLE `venue` (
  `venue_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `venue`
--

INSERT INTO `venue` (`venue_id`, `name`, `address`, `city`, `capacity`) VALUES
(1, 'Grand Theatre', '123 Main St', 'Cape Town', 4),
(2, 'Art House', '88 Bree St', 'Cape Town', 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `audience`
--
ALTER TABLE `audience`
  ADD PRIMARY KEY (`audience_id`);

--
-- Indexes for table `award`
--
ALTER TABLE `award`
  ADD PRIMARY KEY (`award_id`),
  ADD KEY `fk_award_category` (`award_category_id`),
  ADD KEY `fk_award_film` (`film_id`),
  ADD KEY `fk_award_person` (`person_id`);

--
-- Indexes for table `awardcategory`
--
ALTER TABLE `awardcategory`
  ADD PRIMARY KEY (`award_category_id`),
  ADD KEY `fk_awardcategory_category` (`category_id`);

--
-- Indexes for table `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `country`
--
ALTER TABLE `country`
  ADD PRIMARY KEY (`country_id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `event`
--
ALTER TABLE `event`
  ADD PRIMARY KEY (`event_id`),
  ADD KEY `fk_event_venue` (`venue_id`);

--
-- Indexes for table `film`
--
ALTER TABLE `film`
  ADD PRIMARY KEY (`film_id`),
  ADD KEY `fk_film_category` (`category_id`);

--
-- Indexes for table `filmcountry`
--
ALTER TABLE `filmcountry`
  ADD PRIMARY KEY (`film_id`,`country_id`),
  ADD KEY `fk_filmcountry_country` (`country_id`);

--
-- Indexes for table `filmperson`
--
ALTER TABLE `filmperson`
  ADD PRIMARY KEY (`film_id`,`person_id`,`role`),
  ADD KEY `fk_filmperson_person` (`person_id`);

--
-- Indexes for table `jurymember`
--
ALTER TABLE `jurymember`
  ADD PRIMARY KEY (`jury_member_id`);

--
-- Indexes for table `juryscore`
--
ALTER TABLE `juryscore`
  ADD PRIMARY KEY (`jury_member_id`,`film_id`),
  ADD KEY `fk_juryscore_film` (`film_id`);

--
-- Indexes for table `person`
--
ALTER TABLE `person`
  ADD PRIMARY KEY (`person_id`),
  ADD KEY `fk_person_country` (`country_id`);

--
-- Indexes for table `screening`
--
ALTER TABLE `screening`
  ADD PRIMARY KEY (`screening_id`),
  ADD KEY `idx_screening_film` (`film_id`),
  ADD KEY `idx_screening_venue_time` (`venue_id`,`starts_at`,`ends_at`);

--
-- Indexes for table `seat`
--
ALTER TABLE `seat`
  ADD PRIMARY KEY (`seat_id`),
  ADD UNIQUE KEY `uq_seat` (`venue_id`,`row_label`,`seat_number`);

--
-- Indexes for table `sponsor`
--
ALTER TABLE `sponsor`
  ADD PRIMARY KEY (`sponsor_id`);

--
-- Indexes for table `sponsorship`
--
ALTER TABLE `sponsorship`
  ADD PRIMARY KEY (`sponsorship_id`),
  ADD KEY `fk_sponsorship_sponsor` (`sponsor_id`),
  ADD KEY `fk_sponsorship_event` (`event_id`),
  ADD KEY `fk_sponsorship_awardcategory` (`award_category_id`);

--
-- Indexes for table `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`ticket_id`),
  ADD KEY `fk_ticket_seat` (`seat_id`),
  ADD KEY `fk_ticket_audience` (`audience_id`),
  ADD KEY `idx_ticket_screening` (`screening_id`);

--
-- Indexes for table `venue`
--
ALTER TABLE `venue`
  ADD PRIMARY KEY (`venue_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audience`
--
ALTER TABLE `audience`
  MODIFY `audience_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `award`
--
ALTER TABLE `award`
  MODIFY `award_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `awardcategory`
--
ALTER TABLE `awardcategory`
  MODIFY `award_category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `category`
--
ALTER TABLE `category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `country`
--
ALTER TABLE `country`
  MODIFY `country_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `event`
--
ALTER TABLE `event`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `film`
--
ALTER TABLE `film`
  MODIFY `film_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `jurymember`
--
ALTER TABLE `jurymember`
  MODIFY `jury_member_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `person`
--
ALTER TABLE `person`
  MODIFY `person_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `screening`
--
ALTER TABLE `screening`
  MODIFY `screening_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `seat`
--
ALTER TABLE `seat`
  MODIFY `seat_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `sponsor`
--
ALTER TABLE `sponsor`
  MODIFY `sponsor_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `sponsorship`
--
ALTER TABLE `sponsorship`
  MODIFY `sponsorship_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `ticket`
--
ALTER TABLE `ticket`
  MODIFY `ticket_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `venue`
--
ALTER TABLE `venue`
  MODIFY `venue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `award`
--
ALTER TABLE `award`
  ADD CONSTRAINT `fk_award_category` FOREIGN KEY (`award_category_id`) REFERENCES `awardcategory` (`award_category_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_award_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_award_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `awardcategory`
--
ALTER TABLE `awardcategory`
  ADD CONSTRAINT `fk_awardcategory_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `event`
--
ALTER TABLE `event`
  ADD CONSTRAINT `fk_event_venue` FOREIGN KEY (`venue_id`) REFERENCES `venue` (`venue_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `film`
--
ALTER TABLE `film`
  ADD CONSTRAINT `fk_film_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `filmcountry`
--
ALTER TABLE `filmcountry`
  ADD CONSTRAINT `fk_filmcountry_country` FOREIGN KEY (`country_id`) REFERENCES `country` (`country_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_filmcountry_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `filmperson`
--
ALTER TABLE `filmperson`
  ADD CONSTRAINT `fk_filmperson_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_filmperson_person` FOREIGN KEY (`person_id`) REFERENCES `person` (`person_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `juryscore`
--
ALTER TABLE `juryscore`
  ADD CONSTRAINT `fk_juryscore_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_juryscore_member` FOREIGN KEY (`jury_member_id`) REFERENCES `jurymember` (`jury_member_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `person`
--
ALTER TABLE `person`
  ADD CONSTRAINT `fk_person_country` FOREIGN KEY (`country_id`) REFERENCES `country` (`country_id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `screening`
--
ALTER TABLE `screening`
  ADD CONSTRAINT `fk_screening_film` FOREIGN KEY (`film_id`) REFERENCES `film` (`film_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_screening_venue` FOREIGN KEY (`venue_id`) REFERENCES `venue` (`venue_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `seat`
--
ALTER TABLE `seat`
  ADD CONSTRAINT `fk_seat_venue` FOREIGN KEY (`venue_id`) REFERENCES `venue` (`venue_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sponsorship`
--
ALTER TABLE `sponsorship`
  ADD CONSTRAINT `fk_sponsorship_awardcategory` FOREIGN KEY (`award_category_id`) REFERENCES `awardcategory` (`award_category_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sponsorship_event` FOREIGN KEY (`event_id`) REFERENCES `event` (`event_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_sponsorship_sponsor` FOREIGN KEY (`sponsor_id`) REFERENCES `sponsor` (`sponsor_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `fk_ticket_audience` FOREIGN KEY (`audience_id`) REFERENCES `audience` (`audience_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ticket_screening` FOREIGN KEY (`screening_id`) REFERENCES `screening` (`screening_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ticket_seat` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
