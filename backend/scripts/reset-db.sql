-- Reset database script
-- This will delete all data from all tables
-- Note: Tables will be created automatically when you start the server

USE pollapp;

-- Disable foreign key checks temporarily
SET FOREIGN_KEY_CHECKS = 0;

-- Delete all data from tables (ignore errors if tables don't exist)
-- Votes table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'pollapp' AND table_name = 'votes') > 0,
    'TRUNCATE TABLE votes', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Poll options table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'pollapp' AND table_name = 'poll_options') > 0,
    'TRUNCATE TABLE poll_options', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Polls table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'pollapp' AND table_name = 'polls') > 0,
    'TRUNCATE TABLE polls', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Users table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'pollapp' AND table_name = 'users') > 0,
    'TRUNCATE TABLE users', 'SELECT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- Verify tables are empty (only if they exist)
SELECT 'Database reset complete. Start the server to create/update tables.' as Message;
