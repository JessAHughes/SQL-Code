#Checking the fuel types are correct

SELECT 
  DISTINCT(fuel_type)
FROM
  GoogleProject1.car_info;


#Checking the length, width, and height of cars is correct according to dataset description

SELECT
  MIN(height)   AS min_height,
  MAX(height)   AS max_height,
  MIN(width)    AS min_width,
  MAX(width)    AS max_width,
  MIN(length)   AS min_length,
  MAX(length)   AS max_length
FROM
	GoogleProject1.car_info;
    
    
#Double checking and fixing number of doors column

SELECT 
  *
FROM
  GoogleProject1.car_info
WHERE
  num_of_doors LIKE "";
  
  
UPDATE
  GoogleProject1.car_info
SET
  num_of_doors = "four"
WHERE
  make = "dodge"
  AND fuel_type = "gas"
  AND body_style = "sedan";
  
  
UPDATE
  GoogleProject1.car_info
SET
  num_of_doors = "four"
WHERE
  make = "mazda"
  AND fuel_type = "diesel"
  AND body_style = "sedan";


#Checking for errors in the number of cylinders column

SELECT
  DISTINCT(num_of_cylinders)
FROM
  GoogleProject1.car_info;
  
#Found a spelling error
UPDATE
  GoogleProject1.car_info
SET
  num_of_cylinders = "two"
WHERE
  num_of_cylinders = "tow";
  
  
#Checking the compression ratio against the dataset description

SELECT
  MIN(compression_ratio) AS min_compression_ratio,
  MAX(compression_ratio) AS max_compression_ratio
FROM
  GoogleProject1.car_info
#Found a 70 that shouldn't be there so checking the other data to make sure it's the only outlier
WHERE
  compression_ratio <> 70;

#Checking how many rows have the '70' value (Only 1)

SELECT
  COUNT(*) AS num_of_rows_to_delete
FROM
  GoogleProject1.car_info
WHERE
  compression_ratio = 70;
  
#Deleting the row as it was entered in error and should be removed

DELETE FROM
  GoogleProject1.car_info
WHERE
  compression_ratio = 70;
  
  
#Making sure the drivetrain values are consistant

SELECT
  DISTINCT(drive_wheels),
#Found a distinct duplicate of 4wd
  LENGTH(drive_wheels)      AS string_length
#Found an extra space, making an extra 4wd value
FROM
 GoogleProject1.car_info;
  
#Correcting the space error in 4wd
UPDATE
  GoogleProject1.car_info
SET
  drive_wheels = TRIM(drive_wheels)
WHERE TRUE;

