

# AA Clearing main database
DROP TABLE IF EXISTS attachment;
DROP TABLE IF EXISTS attachment_type;
DROP TABLE IF EXISTS audit;
DROP TABLE IF EXISTS channel;
DROP TABLE IF EXISTS channel_email_option;
DROP TABLE IF EXISTS channel_message;
DROP TABLE IF EXISTS channel_message_status;
DROP TABLE IF EXISTS channel_processor;
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS example_data;
DROP TABLE IF EXISTS favorite;
DROP TABLE IF EXISTS group_user;
DROP TABLE IF EXISTS inbox;
DROP TABLE IF EXISTS inbox_message;
DROP TABLE IF EXISTS lookup;
DROP TABLE IF EXISTS object_history;
DROP TABLE IF EXISTS object_history_entry;
DROP TABLE IF EXISTS object_index;
DROP TABLE IF EXISTS object_modification;
DROP TABLE IF EXISTS patch_testmodule_food_has_name;
DROP TABLE IF EXISTS patch_testmodule_food_has_title;
DROP TABLE IF EXISTS printer;
DROP TABLE IF EXISTS report;
DROP TABLE IF EXISTS report_connection;
DROP TABLE IF EXISTS report_feed;
DROP TABLE IF EXISTS report_member;
DROP TABLE IF EXISTS report_template;
DROP TABLE IF EXISTS rest_session;
DROP TABLE IF EXISTS sessions;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS task;
DROP TABLE IF EXISTS task_data;
DROP TABLE IF EXISTS task_group;
DROP TABLE IF EXISTS task_group_member;
DROP TABLE IF EXISTS task_group_notify;
DROP TABLE IF EXISTS task_group_user_notify;
DROP TABLE IF EXISTS task_object;
DROP TABLE IF EXISTS task_time;
DROP TABLE IF EXISTS task_user_notify;
DROP TABLE IF EXISTS template;
DROP TABLE IF EXISTS testmodule_data;
DROP TABLE IF EXISTS testmodule_food_no_label;
DROP TABLE IF EXISTS timelog;
DROP TABLE IF EXISTS user;
DROP TABLE IF EXISTS user_role;
DROP TABLE IF EXISTS widget_config;


# Installing main database SQL
--
-- Database: `cmfive`
--
-- CREATE DATABASE IF NOT EXISTS `cmfive` DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
-- USE `cmfive`;

-- --------------------------------------------------------

--
-- Table structure for table `attachment`
--

CREATE TABLE IF NOT EXISTS `attachment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `parent_table` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `parent_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `modifier_user_id` bigint(20) DEFAULT NULL,
  `filename` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `mimetype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `fullpath` text COLLATE utf8_unicode_ci NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `type_code` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `attachment_type`
--

CREATE TABLE IF NOT EXISTS `attachment_type` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `audit`
--

CREATE TABLE IF NOT EXISTS `audit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dt_created` datetime DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `submodule` text COLLATE utf8_unicode_ci,
  `message` text COLLATE utf8_unicode_ci,
  `module` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `action` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `path` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `ip` varchar(15) COLLATE utf8_unicode_ci NOT NULL,
  `db_class` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_action` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=77 ;

-- --------------------------------------------------------

--
-- Table structure for table `channel`
--

CREATE TABLE IF NOT EXISTS `channel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notify_user_email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notify_user_id` bigint(20) DEFAULT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `do_processing` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `channel_email_option`
--

CREATE TABLE IF NOT EXISTS `channel_email_option` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `channel_id` bigint(20) NOT NULL,
  `server` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `s_username` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `s_password` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `use_auth` tinyint(4) NOT NULL DEFAULT '1',
  `folder` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL,
  `protocol` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_filter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_filter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subject_filter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `cc_filter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body_filter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `post_read_action` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `post_read_parameter` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `channel_message`
--

CREATE TABLE IF NOT EXISTS `channel_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `channel_id` bigint(20) NOT NULL,
  `message_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_processed` tinyint(1) NOT NULL DEFAULT '0',
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `channel_message_status`
--

CREATE TABLE IF NOT EXISTS `channel_message_status` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) NOT NULL,
  `processor_id` bigint(20) NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `is_successful` tinyint(1) NOT NULL DEFAULT '0',
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `channel_processor`
--

CREATE TABLE IF NOT EXISTS `channel_processor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `class` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `module` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `channel_id` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `processor_settings` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `settings` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `comment`
--

CREATE TABLE IF NOT EXISTS `comment` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `obj_table` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `obj_id` bigint(20) DEFAULT NULL,
  `comment` text COLLATE utf8_unicode_ci,
  `is_internal` tinyint(4) NOT NULL DEFAULT '0',
  `is_system` tinyint(4) NOT NULL DEFAULT '0',
  `creator_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `contact`
--

CREATE TABLE IF NOT EXISTS `contact` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `othername` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `homephone` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `workphone` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `mobile` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `priv_mobile` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fax` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `notes` text COLLATE utf8_unicode_ci,
  `dt_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `private_to_user_id` bigint(20) DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `group_user`
--

CREATE TABLE IF NOT EXISTS `group_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `dt_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `inbox`
--

CREATE TABLE IF NOT EXISTS `inbox` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `sender_id` bigint(20) DEFAULT NULL,
  `subject` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `message_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_read` datetime DEFAULT NULL,
  `is_new` tinyint(1) NOT NULL DEFAULT '1',
  `dt_archived` datetime DEFAULT NULL,
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `parent_message_id` int(11) DEFAULT NULL,
  `has_parent` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `del_forever` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `inbox_message`
--

CREATE TABLE IF NOT EXISTS `inbox_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message` text COLLATE utf8_unicode_ci NOT NULL,
  `digest` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `lookup`
--

CREATE TABLE IF NOT EXISTS `lookup` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `weight` int(11) DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `code` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `object_history`
--

CREATE TABLE IF NOT EXISTS `object_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `class_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `object_history_entry`
--

CREATE TABLE IF NOT EXISTS `object_history_entry` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `history_id` bigint(20) NOT NULL,
  `attr_name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `attr_value` longtext COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `object_index`
--

CREATE TABLE IF NOT EXISTS `object_index` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `dt_created` datetime DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `class_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `content` longtext COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  FULLTEXT KEY `object_index_content` (`content`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Table structure for table `object_modification`
--

CREATE TABLE IF NOT EXISTS `object_modification` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `table_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `dt_created` datetime DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `printer`
--

CREATE TABLE IF NOT EXISTS `printer` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(512) NOT NULL,
  `server` varchar(512) NOT NULL,
  `port` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `report`
--

CREATE TABLE IF NOT EXISTS `report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_connection_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `module` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `report_code` text COLLATE utf8_unicode_ci NOT NULL,
  `is_approved` tinyint(1) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci,
  `sqltype` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `report_connection`
--

CREATE TABLE IF NOT EXISTS `report_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `db_driver` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `db_host` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_port` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_database` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `db_file` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `s_db_user` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `s_db_password` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `report_feed`
--

CREATE TABLE IF NOT EXISTS `report_feed` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `report_key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `url` varchar(1024) COLLATE utf8_unicode_ci NOT NULL,
  `dt_created` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `report_member`
--

CREATE TABLE IF NOT EXISTS `report_member` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `report_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;

-- --------------------------------------------------------

--
-- Table structure for table `report_template`
--

CREATE TABLE IF NOT EXISTS `report_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `report_id` bigint(20) NOT NULL,
  `template_id` bigint(20) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `dt_updated` datetime DEFAULT NULL,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `rest_session`
--

CREATE TABLE IF NOT EXISTS `rest_session` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` varchar(100) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `session_data` text COLLATE utf8_unicode_ci NOT NULL,
  `expires` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task`
--

CREATE TABLE IF NOT EXISTS `task` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `is_closed` tinyint(1) NOT NULL DEFAULT '0',
  `parent_id` int(11) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_group_id` int(11) NOT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `priority` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `assignee_id` int(11) NOT NULL,
  `dt_assigned` datetime NOT NULL,
  `dt_first_assigned` datetime NOT NULL,
  `first_assignee_id` int(11) NOT NULL,
  `dt_completed` datetime DEFAULT NULL,
  `dt_planned` datetime DEFAULT NULL,
  `dt_due` datetime DEFAULT NULL,
  `estimate_hours` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `latitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `longitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_data`
--

CREATE TABLE IF NOT EXISTS `task_data` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `data_key` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group`
--

CREATE TABLE IF NOT EXISTS `task_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_assign` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_view` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_create` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `task_group_type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `default_assignee_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_member`
--

CREATE TABLE IF NOT EXISTS `task_group_member` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_group_id` int(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `priority` int(11) NOT NULL,
  `is_active` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_notify`
--

CREATE TABLE IF NOT EXISTS `task_group_notify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_group_id` int(11) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_user_notify`
--

CREATE TABLE IF NOT EXISTS `task_group_user_notify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `task_group_id` int(11) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` tinyint(1) DEFAULT '0',
  `task_creation` tinyint(1) NOT NULL DEFAULT '0',
  `task_details` tinyint(1) NOT NULL DEFAULT '0',
  `task_comments` tinyint(1) NOT NULL DEFAULT '0',
  `time_log` tinyint(1) NOT NULL DEFAULT '0',
  `task_documents` tinyint(1) NOT NULL DEFAULT '0',
  `task_pages` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_object`
--

CREATE TABLE IF NOT EXISTS `task_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `table_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_time`
--

CREATE TABLE IF NOT EXISTS `task_time` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` int(11) NOT NULL,
  `creator_id` int(11) NOT NULL,
  `dt_created` datetime NOT NULL,
  `user_id` int(11) NOT NULL,
  `dt_start` datetime NOT NULL,
  `dt_end` datetime NOT NULL,
  `comment_id` int(11) NOT NULL,
  `is_suspect` tinyint(4) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `time_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_user_notify`
--

CREATE TABLE IF NOT EXISTS `task_user_notify` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `task_creation` tinyint(1) NOT NULL DEFAULT '0',
  `task_details` tinyint(1) NOT NULL DEFAULT '0',
  `task_comments` tinyint(1) NOT NULL DEFAULT '0',
  `time_log` tinyint(1) NOT NULL DEFAULT '0',
  `task_documents` tinyint(1) NOT NULL DEFAULT '0',
  `task_pages` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `template`
--

CREATE TABLE IF NOT EXISTS `template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `module` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `template_title` text COLLATE utf8_unicode_ci,
  `template_body` longtext COLLATE utf8_unicode_ci,
  `test_title_json` text COLLATE utf8_unicode_ci,
  `test_body_json` text COLLATE utf8_unicode_ci,
  `is_active` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `dt_created` datetime DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE IF NOT EXISTS `user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `login` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `password_salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `contact_id` bigint(20) DEFAULT NULL,
  `password_reset_token` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `dt_password_reset_at` timestamp NULL DEFAULT NULL,
  `redirect_url` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'main/index',
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `is_group` tinyint(4) NOT NULL DEFAULT '0',
  `dt_created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dt_lastlogin` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `login` (`login`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `user_role`
--

CREATE TABLE IF NOT EXISTS `user_role` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_per_user` (`user_id`,`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `widget_config`
--

CREATE TABLE IF NOT EXISTS `widget_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `destination_module` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `source_module` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `widget_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `custom_config` text COLLATE utf8_unicode_ci,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

--
-- Table structure for table `tag`
--

CREATE TABLE IF NOT EXISTS `tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `obj_class` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `obj_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `tag` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `tag_color` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX deleted_tag_id(`is_deleted`, `tag`, `obj_class`, `obj_id`, `user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

--
-- Table structure for table `favorite`
--

CREATE TABLE IF NOT EXISTS `favorite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `object_class` varchar(255) NOT NULL,
  `object_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `dt_created` datetime NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `dt_modified` datetime NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;



#Installing updates
CREATE TABLE IF NOT EXISTS `report_connection` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `db_driver` varchar(255) NOT NULL,
  `db_host` varchar(255) NULL,
  `db_port` varchar(255) NULL,
  `db_database` varchar(255) NULL,
  `db_file` varchar(255) NULL,
  `s_db_user` varchar(255) NULL,
  `s_db_password` varchar(255) NULL,  
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;
CREATE TABLE IF NOT EXISTS `channel_message_status` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `message_id` bigint(20) NOT NULL,
  `processor_id` bigint(20) NOT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `is_successful` tinyint(1) NOT NULL DEFAULT '0',
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;
ALTER TABLE `user` CHANGE `is_group` `is_group` TINYINT(4) NULL;
ALTER TABLE `task` CHANGE `priority` `priority` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL;

ALTER TABLE `task` CHANGE `task_type` `task_type` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL;
ALTER TABLE `user` CHANGE `is_group` `is_group` TINYINT(4) NOT NULL DEFAULT '0';
CREATE TABLE IF NOT EXISTS `report_template` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `report_id` bigint(20) NOT NULL,
  `template_id` bigint(20) NOT NULL,
  `type` varchar(255) DEFAULT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `dt_updated` datetime DEFAULT NULL,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;
ALTER TABLE `object_index` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `dt_modified` `dt_modified` DATETIME NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `modifier_id` `modifier_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `audit` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `audit` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_completed` `dt_completed` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `obj_id` `obj_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `comment` `comment` TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `modifier_id` `modifier_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `dt_modified` `dt_modified` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `is_deleted` `is_deleted` TINYINT(1) NOT NULL DEFAULT '0';

ALTER TABLE `task` CHANGE `title` `title` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_planned` `dt_planned` DATETIME NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_due` `dt_due` DATETIME NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `estimate_hours` `estimate_hours` INT(11) NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `description` `description` TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `latitude` `latitude` VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `longitude` `longitude` VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;
ALTER TABLE `comment` CHANGE `is_deleted` `is_deleted` tinyint(1) NOT NULL DEFAULT '0';

ALTER TABLE `task_group` CHANGE `is_deleted` `is_deleted` tinyint(1) NOT NULL DEFAULT '0';

ALTER TABLE `report_member` CHANGE `is_deleted` `is_deleted` tinyint(1) NOT NULL DEFAULT '0';
ALTER TABLE `task` ADD `creator_id` BIGINT NULL AFTER `longitude`, 
                   ADD `modifier_id` BIGINT NULL AFTER `creator_id`, 
                   ADD `dt_created` DATETIME NULL AFTER `modifier_id`, 
                   ADD `dt_modified` DATETIME NULL AFTER `dt_created`;
ALTER TABLE `object_index` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `dt_modified` `dt_modified` DATETIME NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `object_index` CHANGE `modifier_id` `modifier_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `audit` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `audit` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_completed` `dt_completed` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `obj_id` `obj_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `comment` `comment` TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `creator_id` `creator_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `dt_created` `dt_created` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `modifier_id` `modifier_id` BIGINT(20) NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `dt_modified` `dt_modified` DATETIME NULL DEFAULT NULL;

ALTER TABLE `comment` CHANGE `is_deleted` `is_deleted` TINYINT(1) NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `title` `title` VARCHAR(255) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_planned` `dt_planned` DATETIME NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `dt_due` `dt_due` DATETIME NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `estimate_hours` `estimate_hours` INT(11) NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `description` `description` TEXT CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `latitude` `latitude` VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;

ALTER TABLE `task` CHANGE `longitude` `longitude` VARCHAR(20) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL DEFAULT NULL;
ALTER TABLE `user` CHANGE `password_reset_token` `password_reset_token` VARCHAR(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NOT NULL;
ALTER TABLE `user` CHANGE `password_reset_token` `password_reset_token` VARCHAR(40) CHARACTER SET utf8 COLLATE utf8_unicode_ci NULL;
CREATE TABLE IF NOT EXISTS `tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `obj_class` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `obj_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `tag` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `tag_color` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX deleted_tag_id(`is_deleted`, `tag`, `obj_class`, `obj_id`, `user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;


#Installing seed data
/*INSERT INTO `contact` (`id`, `firstname`, `lastname`, `othername`, `title`, `homephone`, `workphone`, `mobile`, `priv_mobile`, `fax`, `email`, `notes`, `dt_created`, `dt_modified`, `is_deleted`, `private_to_user_id`, `creator_id`) VALUES
(1, 'Administrator', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'admin@tripleacs.com', NULL, '2012-04-27 06:31:52', '0000-00-00 00:00:00', 0, NULL, NULL);

INSERT INTO `user` (`id`, `login`, `password`, `password_salt`, `contact_id`, `is_admin`, `is_active`, `is_deleted`, `is_group`, `dt_created`, `dt_lastlogin`) VALUES
(1, 'admin', 'ca1e51f19afbe6e0fb51dde5bcf01ab73e52c7cd', '9b618fbc7f9509fc28ebea98becfdd58', 1, 1, 1, 0, 0, '2012-04-27 06:31:07', '2012-04-27 17:23:54');
*/

INSERT INTO `report` (`id`, `title`, `module`, `category`, `report_code`, `is_approved`, `is_deleted`, `description`, `sqltype`) VALUES
(1, 'Audit', 'admin', '', '[[dt_from||date||Date From]]\r\n\r\n[[dt_to||date||Date To]]\r\n\r\n[[user_id||select||User||select u.id as value, concat(c.firstname,'' '',c.lastname) as title from user u, contact c where u.contact_id = c.id order by title]]\r\n\r\n[[module||select||Module||select distinct module as value, module as title from audit order by module asc]]\r\n\r\n[[action||select||Action||select distinct action as value, concat(module,''/'',action) as title from audit order by title]]\r\n\r\n@@Audit Report||\r\n\r\nselect \r\na.dt_created as Date, \r\nconcat(c.firstname,'' '',c.lastname) as User,  \r\na.module as Module,\r\na.path as Url,\r\na.db_class as ''Class'',\r\na.db_action as ''Action'',\r\na.db_id as ''DB Id''\r\n\r\nfrom audit a\r\n\r\nleft join user u on u.id = a.creator_id\r\nleft join contact c on c.id = u.contact_id\r\n\r\nwhere \r\na.dt_created >= ''{{dt_from}} 00:00:00'' \r\nand a.dt_created <= ''{{dt_to}} 23:59:59'' \r\nand (''{{module}}'' = '''' or a.module = ''{{module}}'')\r\nand (''{{action}}'' = '''' or a.action = ''{{action}}'') \r\nand (''{{user_id}}'' = '''' or a.creator_id = ''{{user_id}}'')\r\n\r\n@@\r\n', 1, 0, 'Show Audit Information', 'select'),
(2, 'Contacts', 'admin', '', '@@Contacts||\r\nselect * from contact\r\n@@', 0, 0, '', 'select');


INSERT INTO `report_member` (`id`, `report_id`, `user_id`, `role`, `is_deleted`) VALUES
(1, 1, 1, 'OWNER', 0),
(2, 2, 1, 'OWNER', 0);





#Installing system modules


#Installing system/modules/admin module


#Installing system/modules/auth module


#Installing system/modules/channels module
CREATE TABLE IF NOT EXISTS `channel` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `name` varchar(255) DEFAULT NULL,
  `notify_user_email` varchar(255) DEFAULT NULL,
  `notify_user_id` bigint(20) DEFAULT NULL,
  `do_processing` tinyint(1) NOT NULL DEFAULT '1',
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=24 ;


CREATE TABLE IF NOT EXISTS `channel_email_option` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `channel_id` bigint(20) NOT NULL,
  `server` varchar(1024) NOT NULL,
  `s_username` varchar(512) DEFAULT NULL,
  `s_password` varchar(512) DEFAULT NULL,
  `port` int(11) DEFAULT NULL,
  `use_auth` tinyint(4) NOT NULL DEFAULT '1',
  `folder` varchar(256) DEFAULT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;


CREATE TABLE IF NOT EXISTS `channel_processor` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `class` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `module` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `channel_id` bigint(20) NOT NULL,
  `name` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `settings` varchar(1024) COLLATE utf8_unicode_ci DEFAULT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=3 ;


CREATE TABLE IF NOT EXISTS `channel_message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `channel_id` bigint(20) NOT NULL,
  `channel_type` varchar(255) NOT NULL,
  `is_processed` tinyint(1) NOT NULL DEFAULT '0',
  `creator_id` bigint(20) DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;



#Installing system/modules/favorite module


#Installing system/modules/file module


#Installing system/modules/help module


#Installing system/modules/inbox module


#Installing system/modules/install module


#Installing system/modules/main module


#Installing system/modules/report module


#Installing system/modules/rest module


#Installing system/modules/search module


#Installing system/modules/systestmodule module


#Installing system/modules/tag module
--
-- Table structure for table `tag`
--

CREATE TABLE IF NOT EXISTS `tag` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `obj_class` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `obj_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `tag` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `tag_color` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `creator_id` bigint(20) DEFAULT NULL,
  `dt_created` datetime DEFAULT NULL,
  `modifier_id` bigint(20) DEFAULT NULL,
  `dt_modified` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  INDEX deleted_tag_id(`is_deleted`, `tag`, `obj_class`, `obj_id`, `user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------


#Installing system/modules/task module

--
-- Table structure for table `task`
--

CREATE TABLE IF NOT EXISTS `task` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `is_closed` tinyint(1) NOT NULL DEFAULT '0',
  `parent_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_group_id` bigint(20) NOT NULL,
  `status` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `priority` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `task_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `assignee_id` bigint(20) NOT NULL,
  `dt_assigned` datetime NOT NULL,
  `dt_first_assigned` datetime NOT NULL,
  `first_assignee_id` bigint(20) NOT NULL,
  `dt_completed` datetime DEFAULT NULL,
  `dt_planned` datetime DEFAULT NULL,
  `dt_due` datetime DEFAULT NULL,
  `estimate_hours` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `latitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `longitude` varchar(20) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_data`
--

CREATE TABLE IF NOT EXISTS `task_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL,
  `data_key` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `value` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group`
--

CREATE TABLE IF NOT EXISTS `task_group` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_assign` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_view` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `can_create` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_active` tinyint(4) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `task_group_type` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `default_assignee_id` bigint(20) NOT NULL,
  `default_task_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_priority` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_member`
--

CREATE TABLE IF NOT EXISTS `task_group_member` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_group_id` int(50) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `role` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `priority` int(11) NOT NULL,
  `is_active` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_notify`
--

CREATE TABLE IF NOT EXISTS `task_group_notify` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_group_id` bigint(20) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_group_user_notify`
--

CREATE TABLE IF NOT EXISTS `task_group_user_notify` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `task_group_id` bigint(20) NOT NULL,
  `role` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value` tinyint(1) DEFAULT '0',
  `task_creation` tinyint(1) NOT NULL DEFAULT '0',
  `task_details` tinyint(1) NOT NULL DEFAULT '0',
  `task_comments` tinyint(1) NOT NULL DEFAULT '0',
  `time_log` tinyint(1) NOT NULL DEFAULT '0',
  `task_documents` tinyint(1) NOT NULL DEFAULT '0',
  `task_pages` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_object`
--

CREATE TABLE IF NOT EXISTS `task_object` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `task_id` bigint(20) NOT NULL,
  `key` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `table_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `object_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_time`
--

-- CREATE TABLE IF NOT EXISTS `task_time` (
--   `id` bigint(20) NOT NULL AUTO_INCREMENT,
--   `object_table` varchar(255) NOT NULL,
--   `object_id` bigint(20) NOT NULL,
--   `creator_id` bigint(20) NOT NULL,
--   `dt_created` datetime NOT NULL,
--   `user_id` bigint(20) NOT NULL,
--   `dt_start` datetime NOT NULL,
--   `dt_end` datetime NOT NULL,
--   `comment_id` bigint(20) NOT NULL,
--   `is_suspect` tinyint(4) NOT NULL DEFAULT '0',
--   `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
--   `time_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
--   PRIMARY KEY (`id`)
-- ) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

--
-- Table structure for table `task_user_notify`
--

CREATE TABLE IF NOT EXISTS `task_user_notify` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `task_id` bigint(20) NOT NULL,
  `task_creation` tinyint(1) NOT NULL DEFAULT '0',
  `task_details` tinyint(1) NOT NULL DEFAULT '0',
  `task_comments` tinyint(1) NOT NULL DEFAULT '0',
  `time_log` tinyint(1) NOT NULL DEFAULT '0',
  `task_documents` tinyint(1) NOT NULL DEFAULT '0',
  `task_pages` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;




#Installing system/modules/task module updates
ALTER TABLE `task` ADD `effort` FLOAT NULL DEFAULT NULL AFTER `priority`;

ALTER TABLE `task` CHANGE `estimate_hours` `estimate_hours` FLOAT(11) NULL DEFAULT NULL;
-- The following changes were made to db.sql
ALTER TABLE `task_group` ADD `default_task_type` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL;

ALTER TABLE `task_group` ADD `default_priority` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL;


#Installing system/modules/timelog module


--
-- If you want to migrate to Timelog and REMOVE TaskTime
--

-- -- Update structure and rename
-- ALTER TABLE task_time
--     ADD COLUMN `object_table` VARCHAR(255) NOT NULL AFTER `id`,
--     CHANGE COLUMN `task_id` `object_id` BIGINT(20) NULL,
--     DROP COLUMN `comment_id`, 
--     ADD COLUMN `dt_modified` DATETIME NOT NULL AFTER `dt_created`, 
--     ADD COLUMN `modifier_id` BIGINT(20) NOT NULL AFTER `creator_id`, 
--     RENAME TO  `timelog`;
-- 
-- -- Change layout
-- ALTER TABLE timelog
--     CHANGE COLUMN `user_id` `user_id` BIGINT(20) NOT NULL AFTER `id`, 
--     CHANGE COLUMN `time_type` `time_type` VARCHAR(255) CHARACTER SET 'utf8' COLLATE 'utf8_unicode_ci' NULL AFTER `dt_end`, 
--     CHANGE COLUMN `dt_created` `dt_created` DATETIME NOT NULL AFTER `is_suspect`, 
--     CHANGE COLUMN `dt_modified` `dt_modified` DATETIME NOT NULL AFTER `dt_created`, 
--     CHANGE COLUMN `creator_id` `creator_id` BIGINT(20) NOT NULL AFTER `dt_modified`, 
--     CHANGE COLUMN `modifier_id` `modifier_id` BIGINT(20) NOT NULL AFTER `creator_id`, 
--     CHANGE COLUMN `id` `id` BIGINT(20) NOT NULL AUTO_INCREMENT,
--     CHANGE COLUMN `dt_end` `dt_end` DATETIME NULL;
-- 
-- -- Migrate data (All time logs were previously attached to Tasks)
-- UPDATE timelog SET object_class = "Task" WHERE 1;

--
-- If you want to migrate to Timelog and KEEP TaskTime
--

-- Table structure for table `timelog`
--

DROP TABLE IF EXISTS `timelog`;
CREATE TABLE `timelog` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `object_class` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `object_id` bigint(20) DEFAULT NULL,
  `dt_start` datetime NOT NULL,
  `dt_end` datetime NULL,
  `time_type` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `is_suspect` tinyint(4) NOT NULL DEFAULT '0',
  `dt_created` datetime NOT NULL,
  `dt_modified` datetime NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;



#Installing modules/example module
--
-- Table structure for table `example_data`
--

CREATE TABLE IF NOT EXISTS `example_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `data` varchar(1024) NOT NULL,
  `example_checkbox` tinyint(1) NOT NULL DEFAULT '0',
  `select_field` varchar(255) NOT NULL,
  `autocomplete_field` varchar(255) NOT NULL,
  `multiselect_field` varchar(255) NOT NULL,
  `radio_field` varchar(255) NOT NULL,
  `password_field` varchar(255) NOT NULL,
  `email_field` varchar(255) NOT NULL,
  `hidden_field` varchar(255) NOT NULL,
  `d_date_field`  date NOT NULL,
  `dt_datetime_field`  datetime NOT NULL,
  `t_time_field` time NOT NULL,
  `rte_field` varchar(255) NOT NULL,
  `file_field` varchar(255) NOT NULL,
  `multifile_field` varchar(255) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `dt_created` datetime NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `dt_modified` datetime NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;



#Installing modules/frontend module


#Installing modules/testmodule module
CREATE TABLE IF NOT EXISTS `testmodule_data` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `data` varchar(255) NOT NULL,
  `s_data` varchar(255) NOT NULL,
  `d_last_known`  date NOT NULL,
  `t_killed`  time NOT NULL,
  `dt_born`  datetime NOT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `dt_created` datetime NOT NULL,
  `creator_id` bigint(20) NOT NULL,
  `dt_modified` datetime NOT NULL,
  `modifier_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;


CREATE TABLE IF NOT EXISTS `patch_testmodule_food_has_title` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `patch_testmodule_food_has_name` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;
CREATE TABLE IF NOT EXISTS `testmodule_food_no_label` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `data` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

INSERT INTO `contact` (`id`, `firstname`, `lastname`, `othername`, `title`, `homephone`, `workphone`, `mobile`, `priv_mobile`, `fax`, `email`, `notes`, `dt_created`, `dt_modified`, `is_deleted`, `private_to_user_id`, `creator_id`) VALUES
(1, 'Administrator', '', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'admin@tripleacs.com', NULL, '2012-04-27 06:31:52', '2012-04-27 06:31:0', 0, NULL, NULL);
INSERT INTO `user` (`id`, `login`, `password`, `password_salt`, `contact_id`, `is_admin`, `is_active`, `is_deleted`, `is_group`, `dt_created`, `dt_lastlogin`) VALUES
(1, 'admin', 'ca1e51f19afbe6e0fb51dde5bcf01ab73e52c7cd', '9b618fbc7f9509fc28ebea98becfdd58', 1, 1, 1, 0, 0, '2012-04-27 06:31:07', '2012-04-27 17:23:54');
INSERT INTO user_role (`id`, `user_id`, `role`) VALUES (NULL, 1, 'user');
