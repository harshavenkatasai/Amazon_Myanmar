Create database Amazon;
Use amazon;
#Added CSV to table using import wizard option
RENAME TABLE `data-table` TO data_table;

#To Verify the Table
select * from data_table;

#analyze the Product line which is performing more
SELECT 
    product_line, 
    SUM(Total) AS total_sales, 
    SUM(gross_income) AS total_profit, 
    SUM(Quantity) AS total_quantity
FROM data_table
GROUP BY product_line
ORDER BY total_sales DESC;

#Selecting Columns which has null values
SELECT Invoice_ID, Branch,City,Customer_type,Gender,Product_line,Unit_price,Quantity,Tax_5,
Total,D_ate,T_ime,Payment,cogs,gross_margin_percentage,gross_income,Rating
FROM data_table
WHERE Invoice_ID IS NULL
   OR Branch IS NULL
   OR City IS NULL
   OR Customer_type IS NULL
   OR Gender IS NULL
   OR Product_line IS NULL
   OR Unit_price IS NULL
   OR Quantity IS NULL
   OR Tax_5 IS NULL
   OR Total IS NULL
   OR D_ate IS NULL
   OR T_ime IS NULL
   OR Payment IS NULL
   OR cogs IS NULL
   OR gross_margin_percentage IS NULL
   OR gross_income IS NULL
   OR Rating IS NULL;

#no null vales were found

-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening
#adding a new column
ALTER TABLE data_table
ADD COLUMN time_of_day VARCHAR(60) NOT NULL;

#disabling safe mode
SET SQL_SAFE_UPDATES = 0;

# adding and filtering 00am to 12pm 'morning',13pm to 18pm 'afternoon',19pm t 23pm as 'evening'
UPDATE data_table
SET time_of_day = 'Afternoon'
WHERE T_ime between '13:00:00' and '18:00:00' ;

UPDATE data_table
SET time_of_day = 'Evening'
WHERE T_ime between '19:00:00' and '23:00:00' ;

UPDATE data_table
SET time_of_day = 'Morning'
WHERE T_ime between '00:00:00' and '12:00:00' ;

# To check wether the values are apropriate
select T_ime,time_of_day from data_table;

#Verifying the created column has null defined already as not null
select T_ime,time_of_day from data_table where time_of_day is null;


-- Changeing Date fromet from text to Date type
ALTER TABLE data_table
ADD COLUMN dayname VARCHAR(60) NOT NULL;
#to see datatype of all colums in table
describe data_table;

#updated the format from irreguler to reguler format
UPDATE data_table
SET D_ate = STR_TO_DATE(D_ate, '%d-%m-%Y');

#changeing the datatype from text to date
ALTER TABLE data_table
CHANGE COLUMN D_ate D_ate DATE;

# adding Day names to new column dayname
UPDATE data_table
SET dayname = DATE_FORMAT(d_ate, '%a');
Select D_ate,dayname from data_table;

-- Add a new column named monthname that contains the extracted months of the year
#Creating column with monthname as name
ALTER TABLE data_table
ADD COLUMN monthname VARCHAR(60) NOT NULL;

#added month name from date column data to monthname
UPDATE data_table
SET monthname = DATE_FORMAT(d_ate, '%b');
Select D_ate,monthname from data_table;


--  ___________________________________Qustions Starts from here _______________________________

#1.What is the count of distinct cities in the dataset?

Select COUNT(DISTINCT City) AS count_of_distinct From data_table; #--3

#2.For each branch, what is the corresponding city?

Select DISTINCT branch,city from data_table;

#3.What is the count of distinct product lines in the dataset?

Select COUNT(DISTINCT Product_line) AS count_of_Product_line From data_table;

#4.Which payment method occurs most frequently?

Select Payment,count(Payment) as paycount from data_table
group by payment
order by paycount desc limit 1;

#5.Which product line has the highest sales?

Select Product_line,sum(total) as total_sales from data_table
group by product_line
order by total_sales desc ;

#6.How much revenue is generated each month?

Select monthname, sum(total) as total_sales from data_table
group by monthname
order by total_sales;

#7.In which month did the cost of goods sold reach its peak?

Select monthname, sum(cogs) as total_cogs from data_table
group by monthname
order by total_cogs desc limit 1;

#8.Which product line generated the highest revenue?

Select product_line, sum(total) as revenue from data_table
group by product_line
order by revenue desc limit 1;

#9.In which city was the highest revenue recorded?

Select City, sum(total) as revenue from data_table
group by City
order by revenue desc limit 1;

#10.Which product line incurred the highest Value Added Tax?

Select Product_line, sum(Tax_5) as total_vat from data_table
group by Product_line
order by total_vat DESC Limit 1;

#11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

Select Product_line, sum(Total) as total_sales,
Case
	when sum(Total) > (select avg(total) from data_table) then 'Good'
    Else 'Bad'
End as Perfomamce
from data_table
group by Product_line;

#12.Identify the branch that exceeded the average number of products sold.

Select Branch , sum(Quantity*Unit_price) as total_product_Sold from data_table
group by branch
having sum(total)>(Select avg(Quantity*Unit_price) from data_table);

#13.Which product line is most frequently associated with each gender?

With Frequent_product_line  as(
	Select  gender, product_line, count(gender) as frequency,
    row_number() over (partition by gender order by count(*) DESC) AS r_ank
    from data_table
    group by gender, product_line)
Select gender, product_line, frequency from Frequent_product_line
where r_ank = 1;

#14.Calculate the average rating for each product line.

Select product_line, round(avg(rating),2) as avg_rating  from data_table
group by product_line;

#15.Count the sales occurrences for each time of day on every weekday.

Select dayname,time_of_day,count(d_ate) as sales_count from data_table
group by dayname,time_of_day
having dayname !='Sun'
order by dayname desc;

#16.Identify the customer type contributing the highest revenue.

Select Customer_type, sum(total) as highest_revenue from data_table
group by Customer_type
order by highest_revenue desc limit 1;

#17.Determine the city with the highest VAT percentage.

Select City,max(Tax_5) as highest_vat_Percentage from data_table
group by City
order by Max(tax_5);

#18.Identify the customer type with the highest VAT payments.

Select Customer_type,max(Tax_5) as highest_vat_Percentage from data_table
group by Customer_type
order by Max(tax_5) desc limit 1;

#19. What is the count of distinct customer types in the dataset?

Select count(distinct(customer_type)) as count_of_distinct_customer from data_table;

#20.What is the count of distinct payment methods in the dataset?

Select count(distinct payment) as count_of_distinct_payment from data_table;

#21.Which customer type occurs most frequently?

Select Customer_type,count(*) as frequency_occurs from data_table
group by Customer_type
order by count(customer_type) desc limit 1;

#22.Identify the customer type with the highest purchase frequency.

Select Customer_type,count(invoice_ID) as frequency from data_table
group by Customer_type
order by count(invoice_ID);

#23.Determine the predominant gender among customers.

Select gender, count(gender) AS frequency from data_table
group by gender
order by frequency desc limit 1;

#24.Examine the distribution of genders within each branch.

Select Branch,gender,count(gender) AS gender_count from data_table
group by branch,gender
order by branch,gender;

#25.Identify the time of day when customers provide the most ratings

Select time_of_day, count(rating) as rating_count from data_table
group by time_of_day
order by rating_count desc limit 1;

#26.Determine the time of day with the highest customer ratings for each branch.

WITH average_ratings AS (
    SELECT branch, time_of_day, AVG(rating) AS avg_rating
    FROM data_table
    GROUP BY branch, time_of_day
),
highest_ratings AS (
    SELECT branch, time_of_day, avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS r_ank
    FROM average_ratings
)
SELECT branch, time_of_day, avg_rating FROM highest_ratings
 WHERE r_ank = 1;



#27.Identify the day of the week with the highest average ratings.

Select dayname, avg(rating) as rating_avarage from data_table
group by dayname
order by rating_avarage desc limit 1;

#28.Determine the day of the week with the highest average ratings for each branch.


WITH average_ratings AS (
    SELECT branch, dayname, AVG(rating) AS avg_rating FROM data_table
    GROUP BY branch, dayname
),
highest_ratings AS (
    SELECT branch, dayname, avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS r_ank
    FROM average_ratings
)
SELECT branch, dayname, avg_rating FROM highest_ratings
WHERE r_ank = 1;

    














