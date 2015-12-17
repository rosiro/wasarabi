-- phpMyAdmin SQL Dump
-- version 4.1.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: 2015 年 12 月 17 日 13:16
-- サーバのバージョン： 5.6.15
-- PHP Version: 5.4.45

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `wasarabi`
--

-- --------------------------------------------------------

--
-- テーブルの構造 `page`
--

CREATE TABLE IF NOT EXISTS `page` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pagename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `revision_id` int(11) NOT NULL,
  `lastupdate_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pagename` (`pagename`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- テーブルの構造 `revision`
--

CREATE TABLE IF NOT EXISTS `revision` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pagetext` text COLLATE utf8_unicode_ci NOT NULL,
  `user_id` int(11) NOT NULL,
  `lastupdate_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- テーブルの構造 `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mailaddress` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `display_name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `lastlogin_datetime` datetime NOT NULL,
  `register_datetime` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
