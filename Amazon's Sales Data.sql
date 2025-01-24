select *from amazondb.amazon;

/* Welcome to Amazon E-Commerce SQL project */ 

-- Creating a column nameed timeofday to find where it is morning , afternoon or evening ? 
alter table amazon 
add column timeofday varchar (20) after Time;

set sql_safe_updates = 0;

update amazondb.amazon 
set timeofday = 
  CASE 
  WHEN time(OrdTime) >= '00:00;00' and time(OrdTime) <= '12:00;00' then 'Morning' 
  WHEN time(OrdTime) >= '12:00;00' and time(OrdTime) <= '18:00;00' then 'Afternoon'
  ELSE 'Evening'
  END;
  

-- changing the format of date 
ALTER TABLE amazondb.amazon
modify COLUMN OrdDate DATE;

UPDATE amazondb.amazon
SET OrdDate = STR_TO_DATE(OrdDate, '%Y-%m-%D')
WHERE STR_TO_DATE(OrdDate, '%d-%m-%Y') IS NOT NULL;


-- finding the day based on date
alter table amazondb.amazon
add column dayname varchar(20) after OrdDate;

update amazondb.amazon
 set dayname = 
   case dayofweek(OrdDate)
      when 1 then 'Sunday'
      when 2 then 'Monday'
      when 3 then 'Tuesday'
      when 4 then 'Wednesday'
      when 5 then 'Thursday'
      when 6 then 'Friday'
      when 7 then 'Saturday'
	end;

-- month based on the date 


alter table amazon
add column Monthname VARCHAR(50) after dayname

set Monthname = 
    CASE month(OrdDate) 
    when 1 then 'Jan'
    when 2 then 'Feb'
    when 3 then 'Mar'
    when 4 then 'Apr'
    when 5 then 'May'
    when 6 then 'June'
    when 7 then 'July'
    when 8 then 'Aug'
    when 9 then 'Sept'
    when 10 then 'Oct'
    when 11 then 'Nov'
    when 12 then 'Dec'
    END;
    
-- here Some bussiness Related questions to be answered : 

-- 1. What is the count of distinct cities in the dataset?
select count(distinct(city)) as count_of_cities  from amazondb.amazon;

-- 2. For each branch, what is the corresponding city?
select distinct branch,city  from amazondb.amazon

-- 3.What is the count of distinct product lines in the dataset? 
SELECT COUNT(DISTINCT `Product line`) AS DistinctProductLines
FROM amazondb.amazon;

-- 4. Which payment method occurs most frequently?
SELECT Payment, COUNT(payment) AS MethodCount
FROM amazondb.amazon
GROUP BY Payment
LIMIT 1;

-- 5.Which product line has the highest sales?
select `product line`, sum(`unit price` * Quantity) as total_sales from amazondb.amazon
group by `product line`
order by total_sales ASC 
limit 1;

-- 6.How much revenue is generated each month?
select Monthname, sum(total) as Revenue from amazondb.amazon
group by Monthname 
order by Revenue
desc;

-- 7.In which month did the cost of goods sold reach its peak?
select Monthname, SUM(cogs) as peak_goods_sold from amazondb.amazon
group by Monthname
order by peak_goods_sold desc;

-- 8.Which product line generated the highest revenue?
Select `product line`, sum(total) as Revenue from amazondb.amazon
group by `Product line`
order by Revenue desc;


-- 9.In which city was the highest revenue recorded?
select city, sum(total) as Revenue from amazondb.amazon
group by City 
order by Revenue
desc;

-- 10.Which product line incurred the highest Value Added Tax?
select `product line`, sum(`tax 5%`) as Highest_VAT from amazondb.amazon
group by `Product line`
order by Highest_VAT
DESC;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select `product line`, sum(`unit price` * Quantity) as total_sales,
 case 
   when sum(`unit price` * Quantity) > (
    select avg(total_sales)
    from (
     select `product line`, sum(`unit price` * Quantity) as total_sales
     from amazondb.amazon
     group by `product line`
     ) as subquery 
     ) then 'Good'
      else 'bad'
     end as salesPerformance
     from amazondb.amazon
     group by `product line`
     order by total_sales
     desc;
     
-- 12.Identify the branch that exceeded the average number of products sold.
select Branch, sum(Quantity) as total_quality
from amazondb.amazon
group by Branch
having sum(Quantity) > (select avg(Quantity) from amazondb.amazon);

-- 13.Which product line is most frequently associated with each gender?
select `product line`, Gender,count(`product line`) as no_of_Productline from amazondb.amazon
group by gender,`product line`
order by no_of_Productline;

-- 14.Calculate the average rating for each product line.
select `product line`, avg(rating) as Average_Rating from amazondb.amazon
group by `product line`
order by Average_Rating;

-- 15. Count the sales occurrences for each time of day on every weekday.
SELECT timeofday, dayname, COUNT(*) AS sales_occurrence FROM amazondb.amazon
where dayname in ('Monday','Tuesday', 'Wednesday', 'Thursday', 'Friday')
GROUP BY timeofday, dayname
ORDER BY dayname, timeofday;

-- 16. Identify the customer type contributing the highest revenue.
select `Customer type` , sum(total) as Revenue from amazondb.amazon
group by `customer type`
order by Revenue Desc 
Limit 1;

-- 17.Determine the city with the highest VAT percentage.
select city , sum(`tax 5%`) as Highest_Vat, sum(total) as total_sales ,(sum(`Tax 5%`) / sum(Total)) * 100 as Vat_percentage  from amazondb.amazon
group by city 
order by Vat_percentage desc;

-- 18.Identify the customer type with the highest VAT payments.
select `customer type` , sum(`tax 5%`) as Highest_Vat  from amazondb.amazon
group by `customer type`
order by Highest_Vat desc;

--  19. What is the count of distinct customer types in the dataset?
select count(distinct (`customer type`)) as distinct_customers
from amazondb.amazon;

-- 20 What is the count of distinct payment methods in the dataset?
select count(distinct(payment)) as distinct_payment
from amazondb.amazon;

-- 21 Which customer type occurs most frequently?
select `customer type`, count(`customer type`) as frequency 
from amazondb.amazon
group by `customer type`
order by frequency 
desc;

-- 22.Identify the customer type with the highest purchase frequency.
select `customer type`, count(*) as highest_purchase
from amazondb.amazon
group by `customer type`
order by highest_purchase 
desc limit 1;

-- 23 Determine the predominant gender among customers.
select Gender, count(*) as predominant_gender
from amazondb.amazon
group by Gender
order by predominant_gender 
desc limit 1;

-- 24 Examine the distribution of genders within each branch.
select Gender, count(*) as gender_count
from amazondb.amazon
group by Gender, Branch
order by gender_count 
desc;

-- 25.Identify the time of day when customers provide the most ratings.
select timeofday, count(Rating) as rating_count
from amazondb.amazon
group by timeofday
order by rating_count 
desc limit 1;

-- 26.Determine the time of day with the highest customer ratings for each branch.
select Branch, timeofday, avg(rating) as average_rating
from amazondb.amazon
group by Branch, timeofday
order by average_rating 
desc;

-- 27.Identify the day of the week with the highest average ratings.
select dayname, avg(Rating) as highest_rating
from amazondb.amazon
group by dayname 
order by highest_rating 
desc limit 1;

-- 28 Determine the day of the week with the highest average ratings for each branch.
select Branch, dayname, avg(Rating) as avg_rating
from amazondb.amazon
group by Branch, dayname 
order by avg_rating
desc;

