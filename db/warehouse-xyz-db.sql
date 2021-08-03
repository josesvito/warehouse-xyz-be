-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema warehouse_xyz_db
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `warehouse_xyz_db` ;

-- -----------------------------------------------------
-- Schema warehouse_xyz_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `warehouse_xyz_db` DEFAULT CHARACTER SET utf8 ;
USE `warehouse_xyz_db` ;

-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`master_role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`master_role` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`user` (
  `id` INT UNSIGNED NOT NULL,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `token` VARCHAR(1000) NULL,
  `name` VARCHAR(255) NOT NULL,
  `master_role_id` INT UNSIGNED NOT NULL,
  `id_npwp` VARCHAR(16) NULL,
  `last_login` TIMESTAMP NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  INDEX `fk_user_master_role_idx` (`master_role_id` ASC),
  UNIQUE INDEX `id_npwp_UNIQUE` (`id_npwp` ASC),
  UNIQUE INDEX `username_UNIQUE` (`username` ASC),
  CONSTRAINT `fk_user_master_role`
    FOREIGN KEY (`master_role_id`)
    REFERENCES `warehouse_xyz_db`.`master_role` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`master_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`master_category` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`master_unit`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`master_unit` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`item` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `date_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `name` VARCHAR(255) NOT NULL,
  `vendor` VARCHAR(255) NULL,
  `master_category_id` INT UNSIGNED NOT NULL,
  `master_unit_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_item_master_category1_idx` (`master_category_id` ASC),
  INDEX `fk_item_master_unit21_idx` (`master_unit_id` ASC),
  CONSTRAINT `fk_item_master_category1`
    FOREIGN KEY (`master_category_id`)
    REFERENCES `warehouse_xyz_db`.`master_category` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_item_master_unit21`
    FOREIGN KEY (`master_unit_id`)
    REFERENCES `warehouse_xyz_db`.`master_unit` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`procurement`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`procurement` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `generated_id` VARCHAR(255) NULL,
  `quantity` FLOAT NOT NULL,
  `date_proposal` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_accepted` TIMESTAMP NULL,
  `date_rejected` TIMESTAMP NULL,
  `reason` VARCHAR(255) NULL,
  `date_ordered` TIMESTAMP NULL,
  `date_procured` TIMESTAMP NULL,
  `date_exp` TIMESTAMP NULL,
  `is_dismissed` TINYINT(1) NOT NULL DEFAULT 0,
  `procured_by` INT UNSIGNED NULL,
  `note` VARCHAR(255) NULL,
  `requested_by` INT UNSIGNED NOT NULL,
  `item_id` INT UNSIGNED NOT NULL,
  `quantity_out` FLOAT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `fk_procurement_user1_idx` (`requested_by` ASC),
  INDEX `fk_procurement_item1_idx` (`item_id` ASC),
  INDEX `fk_procurement_user2_idx` (`procured_by` ASC),
  CONSTRAINT `fk_procurement_user1`
    FOREIGN KEY (`requested_by`)
    REFERENCES `warehouse_xyz_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_procurement_item1`
    FOREIGN KEY (`item_id`)
    REFERENCES `warehouse_xyz_db`.`item` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_procurement_user2`
    FOREIGN KEY (`procured_by`)
    REFERENCES `warehouse_xyz_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`log_history`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`log_history` (
  `user_id` INT UNSIGNED NOT NULL,
  `action` VARCHAR(255) NOT NULL,
  `time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `fk_log_history_user1_idx` (`user_id` ASC),
  CONSTRAINT `fk_log_history_user1`
    FOREIGN KEY (`user_id`)
    REFERENCES `warehouse_xyz_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`purchase`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`purchase` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `item_id` INT UNSIGNED NOT NULL,
  `date_purchase` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `quantity` FLOAT NOT NULL,
  `note` VARCHAR(255) NULL,
  `handler_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_purchase_item1_idx` (`item_id` ASC),
  INDEX `fk_purchase_user1_idx` (`handler_id` ASC),
  CONSTRAINT `fk_purchase_item1`
    FOREIGN KEY (`item_id`)
    REFERENCES `warehouse_xyz_db`.`item` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_purchase_user1`
    FOREIGN KEY (`handler_id`)
    REFERENCES `warehouse_xyz_db`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`returned`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`returned` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `procurement_id` INT UNSIGNED NOT NULL,
  `quantity` FLOAT UNSIGNED NOT NULL,
  `note` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_returned_procurement1_idx` (`procurement_id` ASC),
  CONSTRAINT `fk_returned_procurement1`
    FOREIGN KEY (`procurement_id`)
    REFERENCES `warehouse_xyz_db`.`procurement` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`master_role`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`master_role` (`id`, `name`) VALUES (1, 'Admin');
INSERT INTO `warehouse_xyz_db`.`master_role` (`id`, `name`) VALUES (2, 'Accountant');
INSERT INTO `warehouse_xyz_db`.`master_role` (`id`, `name`) VALUES (3, 'Staff');

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`user`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`, `is_active`) VALUES (1, 'admin', '$2y$10$cMyENZ8jzm5xW0LJgbr2nO0gJVfBB1V6Q40SOZ6T.AhJUiVgQSShy', NULL, 'John Doe', 1, NULL, NULL, 1);
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`, `is_active`) VALUES (2, 'accountant', '$2y$10$cMyENZ8jzm5xW0LJgbr2nO0gJVfBB1V6Q40SOZ6T.AhJUiVgQSShy', NULL, 'Mary Doe', 2, '3334441100004411', NULL, 1);
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`, `is_active`) VALUES (3, 'staff', '$2y$10$cMyENZ8jzm5xW0LJgbr2nO0gJVfBB1V6Q40SOZ6T.AhJUiVgQSShy', NULL, 'Staff Kun', 3, '3334441100004412', NULL, 1);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`master_category`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (1, 'Essentials');
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (2, 'Coffee');
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (3, 'Dessert');
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (4, 'Etc.');

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`master_unit`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`master_unit` (`id`, `name`) VALUES (1, 'kg');
INSERT INTO `warehouse_xyz_db`.`master_unit` (`id`, `name`) VALUES (2, 'Sachet');
INSERT INTO `warehouse_xyz_db`.`master_unit` (`id`, `name`) VALUES (3, 'ml');
INSERT INTO `warehouse_xyz_db`.`master_unit` (`id`, `name`) VALUES (4, 'pcs');

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`item`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (1, '2021-05-25', 'Gula', 'Nuxtcafe', 1, 1);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (2, '2021-05-25', 'Gula', 'Nuxtcafe', 1, 2);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (3, '2021-05-25', 'Kopi Espresso', NULL, 2, 1);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (4, '2021-05-25', 'Borboun', 'Nestel', 4, 1);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (5, '2021-05-25', 'Milk Grade A', 'Nestel', 1, 3);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `vendor`, `master_category_id`, `master_unit_id`) VALUES (6, '2021-06-15', 'Cheese Cake', 'Chaddar', 3, 4);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`procurement`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (1, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, 'Tolong restock item ini', 2, 1, 1);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (2, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, 'Untuk tourist', 2, 2, NULL);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (3, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, NULL, 2, 3, NULL);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (4, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, NULL, 2, 4, NULL);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (5, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, NULL, 2, 5, NULL);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`, `quantity_out`) VALUES (6, NULL, 10, '2021-07-10', '2021-07-10', NULL, NULL, '2021-07-10', '2021-07-10', '2021-07-31', 0, 3, NULL, 2, 6, NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`purchase`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`purchase` (`id`, `item_id`, `date_purchase`, `quantity`, `note`, `handler_id`) VALUES (1, 1, '2021-07-10', 1, 'AN Ibu Em Yeu Anh', 1);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`returned`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`returned` (`id`, `procurement_id`, `quantity`, `note`) VALUES (1, 1, 1, 'Cacat');

COMMIT;

