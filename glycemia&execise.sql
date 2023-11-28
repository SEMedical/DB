-- MySQL Script generated by MySQL Workbench
-- Mon Nov 27 13:32:06 2023
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema glucose_monitoring
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `glycemia` ;

-- -----------------------------------------------------
-- Schema glucose_monitoring
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `glycemia` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `glycemia` ;

-- -----------------------------------------------------
-- Table `user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user` ;

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `age` INT NULL,
  `name` VARCHAR(45) NULL,
  `contact` VARCHAR(11) NULL,
  `password` VARCHAR(64) NULL COMMENT '\'Encrypted by SHA256\'',
  `role` VARCHAR(10) NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `contact_UNIQUE` (`contact` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `doctor`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `doctor` ;

CREATE TABLE IF NOT EXISTS `doctor` (
  `doctor_id` INT NOT NULL,
  `department` VARCHAR(45) NULL,
  `title` VARCHAR(45) NULL,
  PRIMARY KEY (`doctor_id`),
  CONSTRAINT `doctor_id`
    FOREIGN KEY (`doctor_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `profile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `profile` ;

CREATE TABLE IF NOT EXISTS `profile` (
  `patient_id` INT NOT NULL,
  `gender` ENUM('Female', 'Male') NULL DEFAULT 'Male',
  `address` GEOMETRY NULL,
  `type` ENUM('I', 'II', 'gestational') NULL,
  `family_history` TEXT(200) NULL,
  `diagnosed_year` YEAR(4) NULL,
  `anamnesis` TEXT(200) NULL,
  `medication_pattern` ENUM('oral', 'insulin', 'both') NULL,
  `allergy` TEXT(200) NULL,
  `medication_history` TEXT(200) NULL,
  `height` INT NULL,
  `dietary_therapy` TINYINT NULL,
  `exercise_therapy` TINYINT NULL,
  `oral_therapy` TINYINT NULL,
  `insulin_therapy` TINYINT NULL,
  PRIMARY KEY (`patient_id`),
  CONSTRAINT `patient_id0`
    FOREIGN KEY (`patient_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `exercise`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `exercise` ;

CREATE TABLE IF NOT EXISTS `exercise` (
  `patient_id` INT NULL,
  `start_time` DATETIME(6) NULL,
  `duration` INT NULL COMMENT 'unit:min',
  `category` VARCHAR(45) NULL COMMENT '\'jogging,yoga,swimming,running\'',
  `exercise_id` INT NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`exercise_id`),
  CONSTRAINT `patient_id1`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `glycemia`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `glycemia` ;

CREATE TABLE IF NOT EXISTS `glycemia` (
  `patient_id` INT NOT NULL,
  `glycemia` INT NULL,
  `record_time` DATETIME(6) NOT NULL,
  PRIMARY KEY (`record_time`, `patient_id`),
  CONSTRAINT `patient_id`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `insulin`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `insulin` ;

CREATE TABLE IF NOT EXISTS `insulin` (
  `patient_id` INT NOT NULL,
  `dose` DECIMAL NULL,
  `time` TIMESTAMP(6) NOT NULL,
  PRIMARY KEY (`patient_id`, `time`),
  CONSTRAINT `patient_id2`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `treatment`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `treatment` ;

CREATE TABLE IF NOT EXISTS `treatment` (
  `doctor_id` INT NOT NULL,
  `patient_id` INT NOT NULL,
  `treat_time` TIMESTAMP(6) NOT NULL,
  `prescription` TEXT(200) NULL,
  `effect` VARCHAR(45) NULL,
  PRIMARY KEY (`doctor_id`, `patient_id`, `treat_time`),
  INDEX `patient_id_idx` (`patient_id` ASC) VISIBLE,
  CONSTRAINT `patient_id3`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `doctor_id2`
    FOREIGN KEY (`doctor_id`)
    REFERENCES `doctor` (`doctor_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
-- -----------------------------------------------------
-- Table `subscription`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `subscription`;
CREATE TABLE IF NOT EXISTS `subscription` (
  `follower_id` INT NOT NULL,
  `doctor_id` INT NOT NULL,
  PRIMARY KEY (`follower_id`, `doctor_id`),
  CONSTRAINT `fk_subscription_user`
    FOREIGN KEY (`follower_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_subscription_doctor`
    FOREIGN KEY (`doctor_id`)
    REFERENCES `user` (`user_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
) ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `working_hours`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `working_hours` ;

CREATE TABLE IF NOT EXISTS `working_hours` (
  `doctor_id` INT NOT NULL,
  `duration_mark` INT NOT NULL,
  `start_time` TIME NULL,
  `start_day` VARCHAR(15) NULL COMMENT '\'From Monday to Friday\'',
  `end_time` TIME NULL COMMENT 'unit:hour',
  PRIMARY KEY (`doctor_id`, `duration_mark`),
  CONSTRAINT `doctor_id3`
    FOREIGN KEY (`doctor_id`)
    REFERENCES `doctor` (`doctor_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `examine`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `examine` ;

CREATE TABLE IF NOT EXISTS `examine` (
  `examination_id` INT NOT NULL AUTO_INCREMENT,
  `patient_id` INT NULL,
  `weight` DECIMAL NULL,
  `health_state` ENUM('severe', 'unhealthy', 'well', 'healthy') NULL,
  `high_blood_pressure` INT NULL COMMENT 'mmHg',
  `sleep_quality` ENUM('terrible', 'well', 'good') NULL,
  `examine_time` DATETIME(6) NULL,
  `low_blood_pressure` INT NULL COMMENT 'unit:mmHg',
  `hyperglycemia` ENUM('limosis', 'after meal', 'euglycemia') NULL,
  `trend` ENUM('fluctuate', 'steady', 'often hyperglycemia', 'often hypoglycemia') NULL,
  `exercise_dose` ENUM('Seldom(sleep/sedentary/in hospital)', 'Medium', 'High', 'Low') NULL,
  PRIMARY KEY (`examination_id`),
  INDEX `patient_id_idx` (`patient_id` ASC) VISIBLE,
  CONSTRAINT `patient_id4`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `comlication`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `complication` ;

CREATE TABLE IF NOT EXISTS `complication` (
  `patient_id` INT NOT NULL,
  `symptom` ENUM('diabetic foot', 'diabetic eye', 'diabetic kidney', 'diabetic cardiovascular disease', ' diabetic neuropathy', 'diabetic skin disease', 'hypertension', 'hyperlipidemia', 'others') NOT NULL,
  PRIMARY KEY (`patient_id`, `symptom`),
  CONSTRAINT `patient_id5`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `heart_rate`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `heart_rate` ;

CREATE TABLE IF NOT EXISTS `heart_rate` (
  `exercise_id` INT NOT NULL,
  `interval_seq` INT NOT NULL COMMENT 'per 3 minutes',
  `avg_interval_heart_rate` INT NULL,
  PRIMARY KEY (`exercise_id`, `interval_seq`),
  CONSTRAINT `exercise_id`
    FOREIGN KEY (`exercise_id`)
    REFERENCES `exercise` (`exercise_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
