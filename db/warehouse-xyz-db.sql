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
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `token` VARCHAR(1000) NULL,
  `name` VARCHAR(255) NOT NULL,
  `master_role_id` INT UNSIGNED NOT NULL,
  `id_npwp` VARCHAR(16) NULL,
  `last_login` TIMESTAMP NULL,
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
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
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
  `master_category_id` INT NOT NULL,
  `vendor` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `name_UNIQUE` (`name` ASC),
  INDEX `fk_item_master_category1_idx` (`master_category_id` ASC),
  CONSTRAINT `fk_item_master_category1`
    FOREIGN KEY (`master_category_id`)
    REFERENCES `warehouse_xyz_db`.`master_category` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `warehouse_xyz_db`.`procurement`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `warehouse_xyz_db`.`procurement` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `generated_id` VARCHAR(255) NULL,
  `quantity` INT NOT NULL,
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
  `quantity` INT NOT NULL,
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
  `quantity` INT UNSIGNED NOT NULL,
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
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`) VALUES (1, 'admin', '$2a$10$lfofFha7vBsyaCJ.fwUV5.TlOqf8FbWeU5LwQJFsJpY8.ForXE6Dy', '', 'John Doe', 1, '', NULL);
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`) VALUES (2, 'marydoe1', '$2a$10$lfofFha7vBsyaCJ.fwUV5.TlOqf8FbWeU5LwQJFsJpY8.ForXE6Dy', '', 'Mary Doe', 2, '3334441100004411', NULL);
INSERT INTO `warehouse_xyz_db`.`user` (`id`, `username`, `password`, `token`, `name`, `master_role_id`, `id_npwp`, `last_login`) VALUES (3, 'staffsan', '$2a$10$lfofFha7vBsyaCJ.fwUV5.TlOqf8FbWeU5LwQJFsJpY8.ForXE6Dy', '', 'Staff Kun', 3, '3334441100004412', NULL);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`master_category`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (1, 'Coffee');
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (2, 'Dessert');
INSERT INTO `warehouse_xyz_db`.`master_category` (`id`, `name`) VALUES (3, 'Etc.');

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`item`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `master_category_id`, `vendor`) VALUES (1, '2021-05-25', 'Luwak', 1, 'Nescoffee');
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `master_category_id`, `vendor`) VALUES (2, '2021-05-25', 'Vietnam Drip', 1, 'Nescoffee');
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `master_category_id`, `vendor`) VALUES (3, '2021-05-25', 'Doughnutello', 2, NULL);
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `master_category_id`, `vendor`) VALUES (4, '2021-05-25', 'Ice block 10 kg', 3, 'Atlas');
INSERT INTO `warehouse_xyz_db`.`item` (`id`, `date_created`, `name`, `master_category_id`, `vendor`) VALUES (5, '2021-05-25', 'Soy Salted Ice Cream', 2, 'IKE');

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`procurement`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`) VALUES (1, NULL, 10, '2021-05-27', '2021-05-27', NULL, NULL, '2021-05-27', '2021-05-27', '2022-05-26', 0, 3, 'Tolong restock item ini', 2, 1);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`) VALUES (2, NULL, 9, '2021-05-28', '2021-05-28', NULL, NULL, '2021-05-28', '2021-05-28', '2022-05-27', 0, 3, 'Untuk tourist', 2, 2);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`) VALUES (3, NULL, 3, '2021-05-28', '2021-05-28', NULL, NULL, '2021-05-28', '2021-05-28', '2022-05-27', 0, 3, NULL, 2, 4);
INSERT INTO `warehouse_xyz_db`.`procurement` (`id`, `generated_id`, `quantity`, `date_proposal`, `date_accepted`, `date_rejected`, `reason`, `date_ordered`, `date_procured`, `date_exp`, `is_dismissed`, `procured_by`, `note`, `requested_by`, `item_id`) VALUES (4, NULL, 7, '2021-05-28', '2021-05-28', NULL, NULL, '2021-05-28', '2021-05-28', '2021-06-18', 0, 3, NULL, 2, 3);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`purchase`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`purchase` (`id`, `item_id`, `date_purchase`, `quantity`, `note`, `handler_id`) VALUES (1, 1, '2021-05-28', 1, 'AN Tn. Ading', 1);
INSERT INTO `warehouse_xyz_db`.`purchase` (`id`, `item_id`, `date_purchase`, `quantity`, `note`, `handler_id`) VALUES (2, 2, '2021-05-28', 2, 'AN Ibu Em Yeu Anh', 1);
INSERT INTO `warehouse_xyz_db`.`purchase` (`id`, `item_id`, `date_purchase`, `quantity`, `note`, `handler_id`) VALUES (3, 4, '2021-05-28', 1, 'Neighbor', 1);
INSERT INTO `warehouse_xyz_db`.`purchase` (`id`, `item_id`, `date_purchase`, `quantity`, `note`, `handler_id`) VALUES (4, 3, '2021-05-28', 2, 'AN Ms. Elly', 1);

COMMIT;


-- -----------------------------------------------------
-- Data for table `warehouse_xyz_db`.`returned`
-- -----------------------------------------------------
START TRANSACTION;
USE `warehouse_xyz_db`;
INSERT INTO `warehouse_xyz_db`.`returned` (`id`, `procurement_id`, `quantity`, `note`) VALUES (1, 1, 1, 'Cacat');

COMMIT;

