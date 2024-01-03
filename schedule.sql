-- Create a temporary table to store conflicting exercise_id values
CREATE TEMPORARY TABLE temp_conflicting_exercises (
  `conflicting_exercise_id` INT
);

-- Insert conflicting exercise_id values into the temporary table
INSERT INTO temp_conflicting_exercises
SELECT e1.`exercise_id` AS conflicting_exercise_id
FROM `exercise` e1
WHERE EXISTS (
  SELECT 1
  FROM `exercise` e2
  WHERE e1.`patient_id` = e2.`patient_id`
    AND e1.`exercise_id` <> e2.`exercise_id`
    AND (
      (e1.`start_time` >= e2.`start_time` AND e1.`start_time` < DATE_ADD(e2.`start_time`, INTERVAL e2.`duration` MINUTE))
      OR
      (DATE_ADD(e1.`start_time`, INTERVAL e1.`duration` MINUTE) > e2.`start_time` AND DATE_ADD(e1.`start_time`, INTERVAL e1.`duration` MINUTE) <= DATE_ADD(e2.`start_time`, INTERVAL e2.`duration` MINUTE))
    )
);

-- Query the temporary table for the conflicting exercise_id values
SELECT * FROM temp_conflicting_exercises;
-- Delete records from the `exercise` table based on `exercise_id` values in the temporary table
DELETE FROM `exercise`
WHERE `exercise_id` IN (SELECT `conflicting_exercise_id` FROM temp_conflicting_exercises);
