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
DROP SCHEMA IF EXISTS `wegs` ;

-- -----------------------------------------------------
-- Schema glucose_monitoring
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `wegs` DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ;
USE `wegs` ;

-- -----------------------------------------------------
-- Table `user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `user` ;

CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `height` INT NULL CHECK (height BETWEEN 120 AND 220),
  `address` VARCHAR(100) NULL,
  `name` VARCHAR(45) NULL,
  `contact` VARCHAR(11) NULL,
  `password` VARCHAR(64) NULL COMMENT '\'Encrypted by SHA256\'',
  `role` VARCHAR(10) NULL CHECK (role IN ('patient', 'admin')),
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `contact_UNIQUE` (`contact` ASC),
  CHECK (REGEXP_LIKE(contact, '^1[3456789]\d{9}$')))
ENGINE = InnoDB;



-- -----------------------------------------------------
-- Table `profile`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `profile` ;

CREATE TABLE IF NOT EXISTS `profile` (
  `patient_id` INT NOT NULL,
  `gender` ENUM('Female', 'Male') NULL DEFAULT 'Male',
  `type` ENUM('I', 'II', 'gestational') NULL,
  `age` INT NULL,
  `family_history` TEXT(200) NULL,
  `diagnosed_year` YEAR(4) NULL,
  `anamnesis` TEXT(200) NULL,
  `medication_pattern` ENUM('oral', 'insulin', 'both') NULL,
  `allergy` TEXT(200) NULL,
  `medication_history` TEXT(200) NULL,
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
  `category` VARCHAR(45) NULL CHECK (category IN ('jogging', 'yoga', 'swimming', 'running', 'cycling', 'weightlifting', 'tennis')),
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
  `glycemia` DECIMAL(3,1) NULL COMMENT 'unit:mmol/L',
  `record_time` DATETIME(6) NOT NULL,
  PRIMARY KEY (`record_time`, `patient_id`),
  CONSTRAINT `patient_id`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
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
  INDEX `patient_id_idx` (`patient_id` ASC),
  CONSTRAINT `patient_id4`
    FOREIGN KEY (`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `blood_pressure_check`
    CHECK (`low_blood_pressure` < `high_blood_pressure`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `scenario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `scenario`;
CREATE TABLE IF NOT EXISTS `scenario`(
  `patient_id` INT NOT NULL,
  `start_day` DATE,
  `end_day` DATE,
  `frequency` INT COMMENT 'the interval of exercise in the phase',
  `category` VARCHAR(30) COMMENT 'swim,jog,run,climb',
  `intensity` ENUM('Low','Medium','High'),
  `timing` TIME,
  `duration` INT COMMENT 'unit:minute',
  PRIMARY KEY (`patient_id`),
  INDEX `scenario_patient_idx` (`patient_id` ASC),
  CONSTRAINT `scenario_patient_id`
    FOREIGN KEY(`patient_id`)
    REFERENCES `profile` (`patient_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `date_check`
    CHECK (`start_day` < `end_day`),
  CONSTRAINT `interval_check`
    CHECK (DATEDIFF(`end_day`, `start_day`) >= `frequency`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `complication`
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
-- Create a view to calculate daily highest and lowest blood glucose levels
CREATE VIEW `daily_glycemia_summary` AS
SELECT
  `patient_id`,
  DATE(`record_time`) AS `record_date`,
  MAX(`glycemia`) AS `max_glycemia`,
  MIN(`glycemia`) AS `min_glycemia`
FROM
  `glycemia`
GROUP BY
  `patient_id`,
  `record_date`;
-- Create a view to calculate weekly highest and lowest blood glucose levels
CREATE VIEW `weekly_glycemia_summary` AS
SELECT
  `patient_id`,
  YEARWEEK(`record_time`, 0) AS `week_number`,
  DAYOFWEEK(`record_time`) AS `day_of_week`,
  MAX(`glycemia`) AS `max_glycemia`,
  MIN(`glycemia`) AS `min_glycemia`
FROM
  `glycemia`
GROUP BY
  `patient_id`,
  `week_number`,
  `day_of_week`;

DELIMITER //

CREATE EVENT IF NOT EXISTS daily_cleanup
ON SCHEDULE
    EVERY 1 DAY
    STARTS TIMESTAMP(CURDATE(), '04:00:00')
DO
BEGIN
    -- 删除除最大值、最小值和最接近平均值的记录
    DELETE FROM glycemia
    WHERE (record_time, patient_id) NOT IN (
        SELECT record_time, patient_id
        FROM glycemia
        WHERE DATE(record_time) = CURDATE() - INTERVAL 7 DAY
        ORDER BY glycemia ASC
        LIMIT 1

        UNION

        SELECT record_time, patient_id
        FROM glycemia
        WHERE DATE(record_time) = CURDATE() - INTERVAL 7 DAY
        ORDER BY glycemia DESC
        LIMIT 1

        UNION

        SELECT record_time, patient_id
        FROM glycemia
        WHERE DATE(record_time) = CURDATE() - INTERVAL 7 DAY
        ORDER BY ABS(glycemia - (SELECT AVG(glycemia) FROM glycemia WHERE DATE(record_time) = CURDATE() - INTERVAL 7 DAY)) ASC
        LIMIT 1
    );
END //

DELIMITER ;


CREATE OR REPLACE VIEW schedule AS
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION
    SELECT n + 1 FROM numbers WHERE n < 100 -- Adjust the limit based on your needs
)
SELECT
    s.patient_id,
    s.start_day + INTERVAL (n-1) * s.frequency DAY AS exercise_date,
    s.category,
    s.intensity,
    s.timing
FROM
    scenario s
JOIN
    numbers n
ON
    s.start_day + INTERVAL (n-1) * s.frequency DAY BETWEEN s.start_day AND s.end_day;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
