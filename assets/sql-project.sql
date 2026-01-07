-- SQL Project - Data Cleaning

-- https://www.kaggle.com/datasets/ikramshah512/amazon-products-sales-dataset-42k-items-2025


SELECT * FROM amazon_product_sales_dataset.amazon_products_sales_data_uncleaned;

-- Use a staging table to import raw data before cleaning.
CREATE TABLE data_stagging
LIKE amazon_products_sales_data_uncleaned;

INSERT	data_stagging
SELECT * from amazon_products_sales_data_uncleaned;

-- 1. Finding Duplicates

SELECT *
FROM (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY title, rating, number_of_reviews, bought_in_last_month, current_discounted_price, price_on_variant, 
            listed_price, is_best_seller, is_sponsored, is_couponed , buy_box_availability, delivery_details, sustainability_badges,
            image_url,product_url,  collected_at
			) AS row_num
	FROM data_stagging
		
) duplicates
WHERE 
	row_num > 1;
    
-- Adding 'id' column to identify and remove duplicates safely
 ALTER TABLE data_stagging
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY;

-- Dlete the duplicates
 WITH duplicate_cte AS (
	SELECT *,
		ROW_NUMBER() OVER (
			PARTITION BY title, rating, number_of_reviews, bought_in_last_month, 
            current_discounted_price, price_on_variant, listed_price, 
            is_best_seller, is_sponsored, is_couponed, buy_box_availability, 
            delivery_details, sustainability_badges, image_url, product_url,
            collected_at
		) AS row_num
	FROM data_stagging
)
DELETE FROM data_stagging
WHERE id IN (
	SELECT id
	FROM duplicate_cte
	WHERE row_num > 1
);

-- Now removing this extra column 'id'
Alter table data_stagging
drop column Id;    

-- 2. Removing the columns which we didn't need
Alter table data_stagging
drop column sustainability_badges;

-- 3. Standardize text

-- Trim the columns
UPDATE amazon_product_sales_stagging
SET 
    title = TRIM(title),
    rating = TRIM(rating),
    number_of_reviews = TRIM(number_of_reviews),
    bought_in_last_month = TRIM(bought_in_last_month),
    current_discounted_price = TRIM(current_discounted_price),
    price_on_variant = TRIM(price_on_variant),
    listed_price = TRIM(listed_price),
    is_best_seller = TRIM(is_best_seller),
    is_sponsored = TRIM(is_sponsored),
    is_couponed = TRIM(is_couponed),
    buy_box_availability = TRIM(buy_box_availability),
    delivery_details = TRIM(delivery_details),
    image_url = TRIM(image_url),
    product_url = TRIM(product_url),
    collected_at = TRIM(collected_at);
    
-- Replacing empty Buy Box Availability values with 'Not Available'
    SELECT *
FROM data_stagging
WHERE buy_box_availability= ''
   OR buy_box_availability IS NULL;
   
UPDATE data_stagging
SET buy_box_availability = 'Not Available'
WHERE buy_box_availability = ''
   OR buy_box_availability IS NULL;
   
-- remove the "out of 5 stars" and just keep the numeric values
UPDATE data_stagging
SET 
  rating = REGEXP_SUBSTR(rating, '^[0-9]+\\.?[0-9]*');
  
-- Removing commas from the 'number_of_reviews' column to standardize numeric format
UPDATE data_stagging
  SET number_of_reviews = REPLACE(number_of_reviews, ',','');
  
-- Fill the empty cells in reviews column with null
UPDATE data_stagging
   SET number_of_reviews = Null
     WHERE	number_of_reviews ='';
     
-- keep the numeric format in 'bought_in_last_month' column
UPDATE data_stagging
SET bought_in_last_month = TRIM(
    REGEXP_REPLACE(bought_in_last_month, '[^0-9kK\+]', '')
);
UPDATE data_stagging
SET bought_in_last_month = 
    CASE
        WHEN bought_in_last_month REGEXP '^[0-9]+$' THEN bought_in_last_month
        WHEN bought_in_last_month REGEXP '^[0-9]+\\+$' THEN bought_in_last_month
        WHEN bought_in_last_month REGEXP '^[0-9]+[kK]\\+?$' THEN bought_in_last_month
        ELSE NULL
    END;
    
-- Remove the 'basic variant price' in  price_on_variant column
UPDATE data_stagging
  SET price_on_variant = REPLACE(price_on_variant, 'basic variant price','');
UPDATE data_stagging
  SET price_on_variant = REPLACE(price_on_variant, ':','');

-- Set the empty cells with no details avialable
UPDATE data_stagging
   SET delivery_details = 'no details avialable'
     WHERE	delivery_details ='';
     
-- Set the empty cells with null
UPDATE data_stagging
   SET product_url = null
     WHERE	product_url =''; 
     
-- change the date format
UPDATE data_stagging
SET collected_at = STR_TO_DATE(collected_at, '%m/%d/%Y %H:%i');  

-- converting numeric text column into number format
ALTER TABLE data_stagging
MODIFY COLUMN rating DECIMAL(3,2),
MODIFY COLUMN number_of_reviews INT,
MODIFY COLUMN current_discounted_price DECIMAL(10,2);

-- Count total rows after cleaning
SELECT 
  COUNT(*) AS total_rows
FROM data_stagging;

select * From data_stagging;

     
     





  











