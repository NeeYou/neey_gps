ALTER TABLE `users` ADD `odznaka` VARCHAR(255) NOT NULL DEFAULT 0;
INSERT INTO `items` (`id`, `name`, `label`, `limit`, `rare`, `can_remove`) VALUES (NULL, 'nadajson', 'GPS', -1, 0, 1);