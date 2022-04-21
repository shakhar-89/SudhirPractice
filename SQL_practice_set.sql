1. Popularity Percentage
Find the popularity percentage for each user on Facebook. The popularity percentage is defined as the total number of friends the user has divided by the total number of users on the platform, then converted into a percentage by multiplying by 100.
Output each user along with their popularity percentage. Order records in ascending order by user id.
The 'user1' and 'user2' column are pairs of friends.

Tab : facebook_friends
user1 int
user2 int

Solution :
c3 as (
select user1,user2 from facebook_friends
union 
select user2,user1 from facebook_friends ),
c4 as (select count(distinct user1) from c3)
select user1,(sum(c3.count)/c4.count ::float) * 100
 from c3 join c4 on 1=1 
 group by user1,c4.count order by 1;

2. https://platform.stratascratch.com/coding/10352-users-by-avg-session-time?python= 
    
Users By Avg Session time
Calculate each users average session time. A session is defined as the time difference between a page_load and page_exit. For simplicity, assume an user has only 1 session per day and if there are multiple of the same events in that day, consider only the latest page_load and earliest page_exit. Output the user_id and their average session time.

Tab:  facebook_web_log
user_id      int 
timestamp    datetime
action       varchar

Solution :
--select * from facebook_web_log;
--calculate page_load 
--calculate page_exist
--user_id,page_exit(timestamp) - page_load(timestamp)

with page_load as (
 select * from (
   select user_id,timestamp,row_number() over(partition by user_id,timestamp::date order by timestamp desc) rank
   from facebook_web_log 
   where action='page_load' ) t where rank=1
 ) ,
 page_exit as (
 select * from (
   select user_id,timestamp,row_number() over(partition by user_id,timestamp::date order by timestamp) rank
   from facebook_web_log 
   where action='page_exit' ) t where rank=1
 ) 
  select pl.user_id,avg(pe.timestamp-pl.timestamp) avg
   from page_load pl 
    inner join page_exit pe on pl.user_id=pe.user_id 
   and pl.timestamp::date=pe.timestamp::date
    group by pl.user_id
    order by pl.user_id;


3. https://platform.stratascratch.com/coding/9782-customer-revenue-in-march?python= 

Customer Revenue In March
Calculate the total revenue from each customer in March 2019. 

Output the revenue along with the customer id and sort the results based on the revenue in descending order.

Table: orders
id     int
cust_id. int
order_date datetime
order_details varchar
total_order_cost int

Solution : 
--parition data by march 2019,customer id
--sum(totol_order_cost)
select cust_id,sum(total_order_cost) 
 from orders
 where to_char(order_date,'YYYY-MM')='2019-03'
 group by cust_id
 order by sum(total_order_cost) desc;

4. https://platform.stratascratch.com/coding/10060-top-cool-votes?python=  Top Cool Votes
       Find the review_text that received the highest number of  'cool' votes.
       Output the business name along with the review text with the highest numbef of 'cool' votes.
 Table: yelp_reviews
business_name    varchar
review_id               varchar
user_id                  varchar
stars                      varchar
review_date          datetime
review_text           varchar
funny                     int
useful                    int
cool                       int

Solution : 
with cool_vote as (
select review_text 
 from (
   select review_text,rank() over(order by no_of_cool desc) rank 
    from (
      select review_text,sum(cool) no_of_cool
      from yelp_reviews
      group by review_text) t1
  ) t where rank=1
) select business_name,review_text 
 from yelp_reviews 
 where review_text in (select * from cool_vote);

5. https://platform.stratascratch.com/coding/9726-classify-business-type?python= 
Classify Business Type
Classify each business as either a restaurant, cafe, school, or other. A restaurant should have the word 'restaurant' in the business name. For cafes, either 'cafe', 'café', or 'coffee' can be in the business name. 'School' should be in the business name for schools. All other businesses should be classified as 'other'.

Solution : 
select distinct
   business_name,
    case 
     when lower(business_name) like '%restaurant%' then 'restaurant'
     when (lower(business_name) like '%cafe%' or lower(business_name) like '%café%' or lower(business_name) like '%coffee%') then 'cafe'
     when lower(business_name) like '%school%' then 'school'
     else 'other'
    end business_type
  from sf_restaurant_health_violations;

6. https://platform.stratascratch.com/coding/9913-order-details?python= 
Order Details
Find order details made by Jill and Eva.
Consider the Jill and Eva as first names of customers.
Output the order date, details and cost along with the first name.
Order records based on the customer id in ascending order.


7. https://platform.stratascratch.com/coding/10049-reviews-of-categories?python= 
Reviews of Categories
Find the top business categories based on the total number of reviews. Output the category along with the total number of reviews. Order by total reviews in descending order.

Solution:
with cat as (
 select business_id,
  unnest(string_to_array(categories,';')) as category,
  review_count
  from yelp_business
) select category,sum(review_count) 
 from cat
 group by category 
 order by sum(review_count) desc;


8 . https://platform.stratascratch.com/coding/9897-highest-salary-in-department?python= 

Highest Salary In Department
Find the employee with the highest salary per department.
Output the department name, employees first name along with the corresponding salary.


select department,first_name,salary 
 from employee
 where (department,salary) IN
 ( 
   select department,max(salary) 
    from employee
    group by department
 );

9. https://platform.stratascratch.com/coding/9915-highest-cost-orders?python= 

Highest Cost Orders
Find the customer with the highest total order cost between 2019-02-01 to 2019-05-01. 
If customer had more than one order on a certain day, sum the order costs on daily basis. 
Output their first name, total cost of their items, and the date.
 
 For simplicity, you can assume that every first name in the dataset is unique.

Tables: customers, orders

customers

id int
first_name  varchar
last_name varchar
city varchar
address varchar
phone_number varchar

orders

id  int
cust_id  int
order_date  datetime
order_details  varchar
total_order_cost  int

Solution :
with temp as (
 select first_name,order_date,sum,rank() over(order by sum desc) rank
 from (
   select first_name,order_date,sum(total_order_cost) sum
    from customers c 
     left join orders o on c.id=o.cust_id
    where order_date between '2019-02-01' and '2019-05-01'
   group by first_name,order_date
 ) t ) select first_name,sum,order_date from temp where rank=1;

10. https://platform.stratascratch.com/coding/514-marketing-campaign-success-advanced?python= 

Marketing Campaign Success [Advanced]
You have a table of in-app purchases by user. Users that make their first in-app purchase are placed in a marketing campaign where they see call-to-actions for more in-app purchases. Find the number of users that made additional in-app purchases due to the success of the marketing campaign.

The marketing campaign doesnt start until one day after the initial in-app purchase so users that make multiple purchases on the same day do not count, nor do we count users that make only the same purchases over time.

Table: marketing_campaign
user_id         int
created_at   datetime
product_id   int
quantity        int
price             int

Solution :
--Users made first purchage
with fp as (
  select * from marketing_campaign 
   where (user_id,created_at) in (
    select user_id,min(created_at)
     from marketing_campaign
      group by user_id
   )
 ) select count(distinct user_id) from  // users made subsequent purchages
   marketing_campaign mc 
   where not exists (select user_id,created_at,product_id 
                      from fp
                       where fp.user_id=mc.user_id
                       and fp.product_id=mc.product_id
                       and mc.created_at >= fp.created_at);



11. https://platform.stratascratch.com/coding/9728-inspections-that-resulted-in-violations?python= 
Inspections That Resulted In Violations
Youre given a dataset of health inspections. Count the number of inspections that resulted in a violation for 'Roxanne Cafe' for each year. If an inspection resulted in a violation, there will be a value in the 'violation_id' column. Output the number of inspections by year in ascending order.

Solution :
select to_char(inspection_date,'YYYY'),count(violation_id)
from sf_restaurant_health_violations
where business_name='Roxanne Cafe'
group by to_char(inspection_date,'YYYY')
order by 2 desc;

12. https://platform.stratascratch.com/coding/9905-highest-target-under-manager?python= 
Highest Target Under Manager
Find the highest target achieved by the employee or employees who works under the manager id 13. Output the first name of the employee and target achieved. The solution should show the highest target achieved under manager_id=13 and which employee(s) achieved it.

Solution :
With temp as (
select first_name,target,rank() over( order by target desc) rank
 from (
   select first_name,sum(target) target
     from salesforce_employees
    where manager_id=13
    group by first_name
 ) t ) select first_name,target from temp where rank=1;


13. https://platform.stratascratch.com/coding/9632-host-popularity-rental-prices?python= 

Host Popularity Rental Prices
You’re given a table of rental property searches by users.
 The table consists of search results and outputs host information for searchers.
  Find the minimum, average, maximum rental prices for each host’s popularity rating. 
  The host’s popularity rating is defined as below:
    0 reviews: New
    1 to 5 reviews: Rising
    6 to 15 reviews: Trending Up
    16 to 40 reviews: Popular
    more than 40 reviews: Hot

Tip: The `id` column in the table refers to the search ID. Youll need to create your own host_id by concating price, room_type, host_since, zipcode, and number_of_reviews.

Table: airbnb_host_searches
id int
price float
property_type varchar
room_type varchar
amenities varchar
accommodates int
bathrooms int
bed_type varchar
cancellation_policy varchar
cleaning_fee bool
city varchar
host_identity_verified varchar
host_response_rate varchar
host_since datetime
neighbourhood varchar
number_of_reviews int
review_scores_rating float
zipcode int
bedrooms int
beds int

Solution:

with temp as (
select host_id,price,sum(number_of_reviews) number_of_reviews
 from (
   select 
    price||room_type||host_since||zipcode||number_of_reviews host_id,
    number_of_reviews,
    price
  from airbnb_host_searches
 ) t group by host_id,price
 ) ,
 temp2 as ( select 
     price,
     case 
      when  number_of_reviews > 40 then 'Hot'
      when  number_of_reviews > 15 then 'Popular'
      when  number_of_reviews > 5 then 'Trending Up'
      when  number_of_reviews > 0 then 'Rising'
      else  'New'
     end popularity_rating
  from temp ) 
  select popularity_rating,avg(price),min(price),max(price)
   from temp2
  group by popularity_rating
  order by popularity_rating;


14. https://platform.stratascratch.com/coding/10300-premium-vs-freemium?python= 

Premium vs Freemium
Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying customers have more downloads than paying customers. The output should be sorted by earliest date first and contain 3 columns date, non-paying downloads, paying downloads.
Tables: ms_user_dimension, ms_acc_dimension, ms_download_facts

ms_user_dimension
user_id int
acc_id int

ms_acc_dimension 
acc_id  int
paying_customer  varchar

ms_download_facts
date datetime
user_id int
downloads int

Solution :
with idata as (
select date,downloads,paying_customer pc
 from ms_user_dimension u
 left join ms_acc_dimension a on u.acc_id=a.acc_id
 left join ms_download_facts d on u.user_id=d.user_id
),
paying as ( 
  select date,sum(downloads) downloads 
   from idata 
   where pc='yes' 
   group by date),
non_paying as ( 
 select date,sum(downloads) downloads 
  from idata 
   where pc='no' 
   group by date) 
select p.date,p.downloads,np.downloads
 from paying p join non_paying np on p.date=np.date
 where np.downloads > p.downloads
 order by p.date;

15. https://platform.stratascratch.com/coding/10319-monthly-percentage-difference?python= 

Monthly Percentage Difference
Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the beginning of the year to the end of the year.
The percentage change column will be populated from the 2nd month forward and can be calculated as ((this months revenue - last months revenue) / last months revenue)*100.
Table: sf_transactions

id int
created_at datetime
value int
purchase_id int

Solution : 
select mnth,
  cast(((mon_rev - lag(mon_rev) over(order by mnth))
   / lag(mon_rev) over(order by mnth) :: decimal) * 100 as decimal(18,2))
   
 from ( 
   select to_char(created_at,'YYYY-MM') mnth,sum(value) mon_rev
    from sf_transactions
   group by to_char(created_at,'YYYY-MM')
) t;


16.  
Risky Projects
Identify projects that are at risk for going overbudget. A project is considered to be overbudget if the cost of all employees assigned to the project is greater than the budget of the project. 
You will need to prorate the cost of the employees to the duration of the project. For example, if the budget for a project that takes half a year to complete is $10K, then the total half-year salary of all employees assigned to the project should not exceed $10K. Salary is defined on a yearly basis, so be careful how to calculate salaries for the projects that last less or more than one year.
Output a list of projects that are overbudget with their project name, project budget, and prorated total employee expense (rounded to the next dollar amount).
Tables: linkedin_projects, linkedin_emp_projects, linkedin_employees
All required columns and the first 5 rows of the solution are shown

linkedin_projects
id int
title varchar
budget int
start_date datetime
end_date datetime

linkedin_emp_projects
emp_id int
project_id int

linkedin_employees
id int
first_name varchar
last_name varchar
salary int

solution :

With temp as (
    select 
    lp.id,lp.title,lp.budget,sum((abs(lp.start_date - lp.end_date) / 365 :: float) * le.salary) total_emp_expenses
    from linkedin_projects lp 
        left join linkedin_emp_projects lep on lp.id=lep.project_id 
        left join linkedin_employees le on lep.emp_id=le.id
    group by lp.id,lp.title,lp.budget
) select title,budget,total_emp_expenses from temp 
    where budget < coalesce(total_emp_expenses,0)
    order by title;


17. 

Gender With Generous Reviews
Write a query to find which gender gives a higher average review score when writing reviews as guests. 
Use the `from_type` column to identify guest reviews. Output the gender and their average review score.

Tables: airbnb_reviews, airbnb_guests

airbnb_reviews
from_user int
to_user int
from_type varchar
to_type varchar
review_score int

airbnb_guests
guest_id int
nationality varchar
gender varchar
age int

select gender,avg(review_score) :: float
 from airbnb_reviews ar
  left join airbnb_guests ag on ar.from_user=ag.guest_id
 where from_type='guest'
 group by gender;

 18.
 https://platform.stratascratch.com/coding/9627-3-bed-minimum?python= 

 3 Bed Minimum
Find the average number of beds in each neighborhood that has at least 3 beds in total.

Output results along with the neighborhood name and sort the results based on the number of average beds in descending order.
Table: airbnb_search_details

airbnb_search_details
id int
price float
property_type varchar
room_type varchar
amenities varchar
accommodates int
bathrooms int
bed_type varchar
cancellation_policy varchar
cleaning_fee bool
cityvar char
host_identity_verified varchar
host_response_rate varchar
host_since datetime
neighbourhood varchar
number_of_reviews int
review_scores_rating float
zipcode int
bedrooms int
beds int

select neighbourhood,avg(bedrooms) from airbnb_search_details group by neighbourhood
 having count(bedrooms) >= 3 order by avg(bedrooms) desc;

19. https://leetcode.com/problems/trips-and-users/submissions/

Table: Trips

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| id          | int      |
| client_id   | int      |
| driver_id   | int      |
| city_id     | int      |
| status      | enum     |
| request_at  | date     |     
+-------------+----------+
id is the primary key for this table.
The table holds all taxi trips. Each trip has a unique id, while client_id and driver_id are foreign keys to the users_id at the Users table.
Status is an ENUM type of ('completed', 'cancelled_by_driver', 'cancelled_by_client').
 

Table: Users

+-------------+----------+
| Column Name | Type     |
+-------------+----------+
| users_id    | int      |
| banned      | enum     |
| role        | enum     |
+-------------+----------+
users_id is the primary key for this table.
The table holds all users. Each user has a unique users_id, and role is an ENUM type of ('client', 'driver', 'partner').
banned is an ENUM type of ('Yes', 'No').
 

The cancellation rate is computed by dividing the number of canceled (by client or driver) requests with unbanned users by the total number of requests with unbanned users on that day.

Write a SQL query to find the cancellation rate of requests with unbanned users (both client and driver must not be banned) each day between "2013-10-01" and "2013-10-03". Round Cancellation Rate to two decimal points.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Trips table:
+----+-----------+-----------+---------+---------------------+------------+
| id | client_id | driver_id | city_id | status              | request_at |
+----+-----------+-----------+---------+---------------------+------------+
| 1  | 1         | 10        | 1       | completed           | 2013-10-01 |
| 2  | 2         | 11        | 1       | cancelled_by_driver | 2013-10-01 |
| 3  | 3         | 12        | 6       | completed           | 2013-10-01 |
| 4  | 4         | 13        | 6       | cancelled_by_client | 2013-10-01 |
| 5  | 1         | 10        | 1       | completed           | 2013-10-02 |
| 6  | 2         | 11        | 6       | completed           | 2013-10-02 |
| 7  | 3         | 12        | 6       | completed           | 2013-10-02 |
| 8  | 2         | 12        | 12      | completed           | 2013-10-03 |
| 9  | 3         | 10        | 12      | completed           | 2013-10-03 |
| 10 | 4         | 13        | 12      | cancelled_by_driver | 2013-10-03 |
+----+-----------+-----------+---------+---------------------+------------+
Users table:
+----------+--------+--------+
| users_id | banned | role   |
+----------+--------+--------+
| 1        | No     | client |
| 2        | Yes    | client |
| 3        | No     | client |
| 4        | No     | client |
| 10       | No     | driver |
| 11       | No     | driver |
| 12       | No     | driver |
| 13       | No     | driver |
+----------+--------+--------+
Output: 
+------------+-------------------+
| Day        | Cancellation Rate |
+------------+-------------------+
| 2013-10-01 | 0.33              |
| 2013-10-02 | 0.00              |
| 2013-10-03 | 0.50              |
+------------+-------------------+
Explanation: 
On 2013-10-01:
  - There were 4 requests in total, 2 of which were canceled.
  - However, the request with Id=2 was made by a banned client (User_Id=2), so it is ignored in the calculation.
  - Hence there are 3 unbanned requests in total, 1 of which was canceled.
  - The Cancellation Rate is (1 / 3) = 0.33
On 2013-10-02:
  - There were 3 requests in total, 0 of which were canceled.
  - The request with Id=6 was made by a banned client, so it is ignored.
  - Hence there are 2 unbanned requests in total, 0 of which were canceled.
  - The Cancellation Rate is (0 / 2) = 0.00
On 2013-10-03:
  - There were 3 requests in total, 1 of which was canceled.
  - The request with Id=8 was made by a banned client, so it is ignored.
  - Hence there are 2 unbanned request in total, 1 of which were canceled.
  - The Cancellation Rate is (1 / 2) = 0.50

Solution : 
/* Write your PL/SQL query statement below */
with client as (
     select * from users where role='client' and banned='No'
),
driver as (
    select * from users where role='driver' and banned='No'
),
temp as (
select request_at,status 
 from Trips t inner join client c on t.client_id = c.users_id
  inner join driver d on t.driver_id = d.users_id
) select request_at "Day" ,
    round(cast(sum( case when status in ('cancelled_by_driver','cancelled_by_client') 
              then 1 
              else 0
         end ) as decimal(5,2))/cast (count(*) as decimal(5,2)),2)
    "Cancellation Rate"
 from temp where request_at between '2013-10-01' and '2013-10-03'
 group by request_at


 sol2:
 select 
 T.request_at as "Day",
 round(sum(case when status in ('cancelled_by_driver','cancelled_by_client') then 1 else 0 end)/count(1),2) as "Cancellation Rate" 
from Trips T
where exists (select 1 from Users cu where T.client_id=cu.users_id and cu.banned ='No')  
and exists (select 1 from Users du where T.driver_id=du.users_id and du.banned ='No')
and request_at between '2013-10-01' and '2013-10-03'
group by request_at

--select 1/2 from dual

20. https://leetcode.com/problems/consecutive-numbers/ 

Write an SQL query to find all numbers that appear at least three times consecutively.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Logs table:
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
Output: 
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+
Explanation: 1 is the only number that appears consecutively for at least three times.

solution:
/* Write your PL/SQL query statement below */
--num should be equal to its lead and lag
with temp as (
    select num,
  lag(num) over(order by id) prev,
  lead(num) over(order by id) nxt
 from logs
) select distinct num "ConsecutiveNums"
    from temp 
  where prev=nxt and prev=num and nxt=num

--little faster 

/* Write your PL/SQL query statement below */
--num should be equal to its lead and lag
with temp as (
 select num "ConsecutiveNums"
    from (
    select num,
  lag(num) over(order by id) prev,
  lead(num) over(order by id) nxt
 from logs
) where prev=nxt and prev=num 
) select distinct "ConsecutiveNums" from temp

21. https://leetcode.com/problems/exchange-seats/ 

Table: Seat

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
+-------------+---------+
id is the primary key column for this table.
Each row of this table indicates the name and the ID of a student.
id is a continuous increment.
 

Write an SQL query to swap the seat id of every two consecutive students. If the number of students is odd, the id of the last student is not swapped.

Return the result table ordered by id in ascending order.

The query result format is in the following example.

 

Example 1:

Input: 
Seat table:
+----+---------+
| id | student |
+----+---------+
| 1  | Abbot   |
| 2  | Doris   |
| 3  | Emerson |
| 4  | Green   |
| 5  | Jeames  |
+----+---------+
Output: 
+----+---------+
| id | student |
+----+---------+
| 1  | Doris   |
| 2  | Abbot   |
| 3  | Green   |
| 4  | Emerson |
| 5  | Jeames  |
+----+---------+
Explanation: 
Note that if the number of students is odd, there is no need to change the last one''s seat.

solution : 
/* Write your PL/SQL query statement below */
with total as (
    select count(*) cnt from Seat  
), 
temp as (
     select 
        case
            when (mod(total.cnt,2) <> 0 and id = total.cnt) then id --last id should be intact
            when mod(id,2) = 0 then id -1 
            when mod(id,2) <> 0 then id +1
        end as "id", student as "student"
    from Seat,total
 ) select * from temp order by 1


22. https://leetcode.com/problems/customers-who-never-order/ 

Table: Customers

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| name        | varchar |
+-------------+---------+
id is the primary key column for this table.
Each row of this table indicates the ID and name of a customer.
 

Table: Orders

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| customerId  | int  |
+-------------+------+
id is the primary key column for this table.
customerId is a foreign key of the ID from the Customers table.
Each row of this table indicates the ID of an order and the ID of the customer who ordered it.
 

Write an SQL query to report all customers who never order anything.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Customers table:
+----+-------+
| id | name  |
+----+-------+
| 1  | Joe   |
| 2  | Henry |
| 3  | Sam   |
| 4  | Max   |
+----+-------+
Orders table:
+----+------------+
| id | customerId |
+----+------------+
| 1  | 3          |
| 2  | 1          |
+----+------------+
Output: 
+-----------+
| Customers |
+-----------+
| Henry     |
| Max       |
+-----------+

solution :
/* Write your PL/SQL query statement below */
-- select name as "Customers"
--  from customers c left join orders o
--   on c.id = o.customerid 
--  where o.customerid is null

select name as "Customers"
 from customers c
where not exists (select 1 from orders o where c.id = o.customerid);

23. https://leetcode.com/problems/rising-temperature/ 

Table: Weather

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| recordDate    | date    |
| temperature   | int     |
+---------------+---------+
id is the primary key for this table.
This table contains information about the temperature on a certain day.
 

Write an SQL query to find all dates Id with higher temperatures compared to its previous dates (yesterday).

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Weather table:
+----+------------+-------------+
| id | recordDate | temperature |
+----+------------+-------------+
| 1  | 2015-01-01 | 10          |
| 2  | 2015-01-02 | 25          |
| 3  | 2015-01-03 | 20          |
| 4  | 2015-01-04 | 30          |
+----+------------+-------------+
Output: 
+----+
| id |
+----+
| 2  |
| 4  |
+----+
Explanation: 
In 2015-01-02, the temperature was higher than the previous day (10 -> 25).
In 2015-01-04, the temperature was higher than the previous day (20 -> 30).

/* Write your PL/SQL query statement below */

-- select "id"
-- from (
--     select id as "id" ,
--         temperature cur ,
--         lag(temperature) over(order by recordDate) prev,
--         recordDate - 
--         lag(recordDate) over(order by id) "dif"
--     from Weather ) t 
-- where t.cur > t.prev and "dif" = 1

-- select "id"
-- from (
--     select id as "id" ,
--         temperature cur ,
--         lag(temperature,1) over(order by recordDate) prev
--     from Weather ) t 
-- where t.cur > t.prev

select b.id
 from weather a 
  inner join weather b on b.recordDate - a.recordDate = 1
where b.temperature > a.temperature
--where b.id is not null


24.  https://leetcode.com/problems/human-traffic-of-stadium/ 

Table: Stadium

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| id            | int     |
| visit_date    | date    |
| people        | int     |
+---------------+---------+
visit_date is the primary key for this table.
Each row of this table contains the visit date and visit id to the stadium with the number of people during the visit.
No two rows will have the same visit_date, and as the id increases, the dates increase as well.
 

Write an SQL query to display the records with three or more rows with consecutive ids, and the number of people is greater than or equal to 100 for each.

Return the result table ordered by visit_date in ascending order.

The query result format is in the following example.

 

Example 1:

Input: 
Stadium table:
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 1    | 2017-01-01 | 10        |
| 2    | 2017-01-02 | 109       |
| 3    | 2017-01-03 | 150       |
| 4    | 2017-01-04 | 99        |
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-09 | 188       |
+------+------------+-----------+
Output: 
+------+------------+-----------+
| id   | visit_date | people    |
+------+------------+-----------+
| 5    | 2017-01-05 | 145       |
| 6    | 2017-01-06 | 1455      |
| 7    | 2017-01-07 | 199       |
| 8    | 2017-01-09 | 188       |
+------+------------+-----------+
Explanation: 
The four rows with ids 5, 6, 7, and 8 have consecutive ids and each of them has >= 100 people attended. Note that row 8 was included even though the visit_date was not the next day after row 7.
The rows with ids 2 and 3 are not included because we need at least three consecutive ids.

/* Write your PL/SQL query statement below */

-- lag ID = cur ID -1 ,lead ID = cur ID + 1

with temp1 as (
    select 
        lag(id) over(order by visit_date) prvId,
        id,
        lead(id) over(order by visit_date) nextId
    from Stadium where people >= 100
) ,
temp as ( -- select only qualifying rows with all the three ids
    select * from temp1 where prvId + 1=id and id = nextId -1
) -- select records for all those three ids
select s.id "id",to_char(s.visit_date,'YYYY-MM-DD') "visit_date",people "people" 
    from temp t inner join stadium s on t.prvid=s.id
   union all
  select s.id "id",to_char(s.visit_date,'YYYY-MM-DD') "visit_date",people "people" 
    from temp t inner join stadium s on t.id=s.id
  union 
 select s.id "id",to_char(s.visit_date,'YYYY-MM-DD') "visit_date",people "people" 
    from temp t inner join stadium s on t.nextId=s.id
 order by 2

 ----

 with temp1 as (
    select 
        lag(id) over(order by visit_date) prvId,
        id,
        lead(id) over(order by visit_date) nextId
    from Stadium where people >= 100
) ,
temp as ( -- select only qualifying rows with all the three ids
    select * from temp1 where prvId + 1=id and id = nextId -1
) -- select records for all those three ids
select distinct s.id "id",to_char(s.visit_date,'YYYY-MM-DD') "visit_date",people "people" 
    from temp t inner join stadium s on t.prvid=s.id or t.id=s.id or t.nextId=s.id
 order by 2

 25. 
 --input 
create table input(team1 varchar2(20),team2 varchar2(20),winner varchar2(20));

insert into input values('India','SL','India');

insert into input values('SL','Aus','Aus');

insert into input values('SA','Eng','Eng');

insert into input values('Eng','NZ','NZ');

insert into input values('Aus','India','India');
commit;

--write a query to print , team, number_of_matches_played,number_of_wins,number_of_losses
with temp as (
    select team1,winner from input 
     union all
    select team2,winner from input
) select team1,
         count(*) no_of_matches_played,
         sum(case when winner = team1 then 1 else 0 end) wins,
         sum(case when winner <> team1 then 1 else 0 end) losses 
   from temp
  group by team1

  --output:
  TEAM1		     NO_OF_MATCHES_PLAYED	WINS	 LOSSES
-------------------- -------------------- ---------- ----------
India					2	   2	      0
SL					2	   0	      2
SA					1	   0	      1
Eng					2	   1	      1
Aus					2	   1	      1
NZ					1	   1	      0


26.
--input
drop table customer_orders;
create table customer_orders(order_id number,customer_id number,order_date date);

insert into customer_orders values(1,100,to_date('01-JAN-22'));
insert into customer_orders values(2,200,to_date('01-JAN-22'));
insert into customer_orders values(3,300,to_date('01-JAN-22'));


insert into customer_orders values(4,100,to_date('02-JAN-22'));
insert into customer_orders values(5,400,to_date('02-JAN-22'));
insert into customer_orders values(6,500,to_date('02-JAN-22'));
insert into customer_orders values(7,100,to_date('03-JAN-22'));
insert into customer_orders values(8,400,to_date('03-JAN-22'));
insert into customer_orders values(9,600,to_date('03-JAN-22'));

commit;

--write a query to print order_date,new_customer_count per order date , old_customer_count per order date
--output
order_date,new_customer_count,old_customer_count
01-JAN-22,3,0
02-JAN-22,2,1
03-JAN-22,1,2

with all_cust_per_day as (
  select order_date od ,count(1) cust_per_day
   from customer_orders
  group by order_date
), 
new_cust_per_day
  as ( select frst_dat od ,count(1) newcust_per_day
        from ( select customer_id,min(order_date) frst_dat
          from customer_orders
        group by customer_id ) temp
       group by frst_dat
) select a.od,n.newcust_per_day new_customer_count,(a.cust_per_day-n.newcust_per_day) old_customer_count
  from all_cust_per_day a
    inner join new_cust_per_day n on a.od=n.od

27.
--input
drop table input;
create table input(name varchar2(20),address varchar2(20),email varchar2(30),floor number,resources varchar2(20));

insert into input values('A','Bangalore','A@gmail.com',1,'CPU');
insert into input values('A','Bangalore','A1@gmail.com',1,'CPU');
insert into input values('A','Bangalore','A2@gmail.com',2,'DESKTOP');
insert into input values('B','Bangalore','B@gmail.com',2,'DESKTOP');
insert into input values('B','Bangalore','B1@gmail.com',2,'DESKTOP');
insert into input values('B','Bangalore','B2@gmail.com',1,'MONITOR');
commit;

--Write a query to display name , total_visits , most_visited_floor_each_employee,resoueces_used
--output
name , total_visits , most_visited_floor_each_employee,resoueces_used
A,3,1,CPU,DESKTOP
B,3,2,DESKTOP,MONITOR

select name,
  count(1) over(partition by name) visits_count,
  count(1) over(partition by name,floor) visits_count_per_emp_per_floor,
  listagg(resources,',')
 from input
 group by name

with temp as (
 select name,
  count(floor) over(partition by name) vis_cnt,
  floor,
  count(floor) over(partition by name,floor) vis_cnt_per_emp_per_flr,
  resources,
  listagg(distinct resources,',') over(partition by name) resoueces_used
  from input
),
temp1 as (
    select name,
      vis_cnt,
      floor,
      dense_rank() over(partition by name order by vis_cnt_per_emp_per_flr desc) rnk ,
      resoueces_used
      from temp
) select name,vis_cnt,floor,resoueces_used
  from temp1 where rnk=1;


with top_flr as (
select name,floor tf from (
    select name,floor,count(1),dense_rank() over(order by count(1) desc) rnk
     from input group by name,floor )
  where rnk=1
),
temp as (
  select name,
    count(floor) vis_cnt,
    listagg(distinct resources,',') resoueces_used
  from input group by name
) select temp.name,vis_cnt,tf,resoueces_used
   from temp inner join top_flr on temp.name=top_flr.name

28. 

--person 
create table person(PersonID number,Name varchar2(20),email varchar2(50),score number);
insert into person values(1,'Alice','alice2018@hotmail.com',88);
insert into person values(2,'Bob','Bob2018@hotmail.com',11);
insert into person values(3,'Davis','Davis2018@hotmail.com',27);
insert into person values(4,'Tara','Tara2018@hotmail.com',45);
insert into person values(5,'John','John2018@hotmail.com',63);
commit;

--friend
create table friend(PersonID number,FriendID number);
insert into friend values(1,2);
insert into friend values(1,3);
insert into friend values(2,1);
insert into friend values(2,3);
insert into friend values(3,5);
insert into friend values(4,2);
insert into friend values(4,3);
insert into friend values(4,5);
commit;

--Write a query to find out personID,name,number_of_friends,sum of marks of a person 
-- who have friends with total score greater than 100

 with t_friends as (
   select PersonID,FriendID from friend
    union 
   select FriendID,PersonID from friend
 ),
 temp as ( 
    select tf.PersonID pid ,p1.name pname,
            count(tf.FriendID) no_of_friends,
            sum(p2.score) fmarks
      from t_friends tf
     inner join person p1 on tf.PersonID = p1.PersonID
     inner join person p2 on tf.FriendID = p2.PersonID
    group by tf.PersonID,p1.name
 ) select pid,pname,no_of_friends,fmarks from temp where fmarks > 100

--if there's only one way friendship
with temp as ( 
    select tf.PersonID pid ,p1.name pname,
            count(tf.FriendID) no_of_friends,
            sum(p2.score) fmarks
      from friend tf
     inner join person p1 on tf.PersonID = p1.PersonID
     inner join person p2 on tf.FriendID = p2.PersonID
    group by tf.PersonID,p1.name
 ) select pid,pname,no_of_friends,fmarks from temp where fmarks > 100

29.
--MARKET ANALYSIS : Write a SQL query to find for each seller , 
--whether the brand of the second item (by date) they sold is their favorite brand. 
-- If a seller sold less than two items , report the answer for that seller as no. 

--ouput
seller_id , 2nd_item_fav_brand
2,no
3,yes
4,no

create table users (
 user_id         number,
 join_date       date,
 favorite_brand  varchar2(50));

 create table orders (
 order_id       number     ,
 order_date     date    ,
 item_id        number     ,
 buyer_id       number     ,
 seller_id      number 
 );

 create table items
 (
 item_id        number     ,
 item_brand     varchar2(50)
 );

alter session set NLS_DATE_FORMAT='YYYY-MM-DD'; 

 insert into users values (1,'2019-01-01','Lenovo'),(2,'2019-02-09','Samsung'),(3,'2019-01-19','LG'),(4,'2019-05-21','HP');

 insert into items values (1,'Samsung'),(2,'Lenovo'),(3,'LG'),(4,'HP');

 insert into orders values (1,'2019-08-01',4,1,2),(2,'2019-08-02',2,1,3),(3,'2019-08-03',3,2,3),(4,'2019-08-04',1,4,2)
 ,(5,'2019-08-04',1,3,4),(6,'2019-08-05',2,2,4);

commit;

--solution
with temp1 as (
select seller_id,
  item_id,
  dense_rank() over(partition by seller_id order by order_date) rnk
from orders )
select u.user_id seller_id, 
  case when u.favorite_brand=i.item_brand 
       then 'yes' 
       else 'no' 
  end as "2nd_item_fav_brand"
 from users u  
  left outer join temp1 on temp1.seller_id=u.user_id and temp1.rnk=2
  left outer join items i on temp1.item_id = i.item_id 

30.

drop table tasks;
create table tasks (
date_value date,
state varchar2(10)
);

insert into tasks  values ('2019-01-01','success'),('2019-01-02','success'),('2019-01-03','success'),('2019-01-04','fail')
,('2019-01-05','fail'),('2019-01-06','success');
commit;

--input
date_value,state
2019-01-01,success
2019-01-02,success
2019-01-03,success
2019-01-04,fail
2019-01-05,fail
2019-01-06,success

--output
start_date,end_date,state
2019-01-01,2019-01-03,success
2019-01-04,2019-01-05,fail
2019-01-06,2019-01-06,success

--solution
with temp as ( --calculate current and previous state
select date_value,state,coalesce(lag(state) over(order by date_value),'XX') prev_state
 from tasks 
), 
temp1 as ( select date_value,state,prev_state,
    case when state <> prev_state then 1 else 0 end flag -- set flag to 1 when state changes and 0 if state doesn't change
  from temp ),
temp2 as (
select date_value,state,
  sum(flag) over( order by date_value rows between unbounded preceding and 0 preceding) flag1 -- every change in state will get new number
 from temp1 order by date_value
) select min(date_value),max(date_value),state
    from temp2 
  group by state,flag1 

--better solution
with temp as (
  select date_value,state,
    row_number() over(partition by state order by date_value) rnk_state,
    row_number() over(order by date_value) rnk
  from tasks 
) select min(date_value),max(date_value),state
   from temp
  group by state,(rnk-rnk_state)


31. 
create table spending 
(
user_id int,
spend_date date,
platform varchar(10),
amount int
);

insert into spending values(1,'2019-07-01','mobile',100),(1,'2019-07-01','desktop',100),(2,'2019-07-01','mobile',100)
,(2,'2019-07-02','mobile',100),(3,'2019-07-01','desktop',100),(3,'2019-07-02','desktop',100);
commit;


/* User purchase platform.
-- The table logs the spendings history of users that make purchases from an online shopping website which has a desktop 
and a mobile application.
-- Write an SQL query to find the total number of users and the total amount spent using mobile only, desktop only 
and both mobile and desktop together for each date.
*/

with temp as (
select user_id,spend_date,platform,amount,count(1) over(partition by spend_date,user_id) cnt
 from spending
 ),
temp1 as ( select spend_date,case when cnt = 2 then 'both' else platform end as platform,amount,user_id
            from temp 
              union all
            select distinct spend_date,'both' as platform,0,null from temp
)
select spend_date,platform,sum(amount),count(distinct user_id)
   from temp1
group by spend_date,platform

32.
--recursive cte
with cte(num) as 
  (
    select 1 from dual --anchor query
    union all
    select num + 1  --recursive query
    from cte 
    where num < 10 --filter to stop the recursion
  )
select num from cte;

create table sales (
product_id int,
period_start date,
period_end date,
average_daily_sales int
);

insert into sales values(1,'2019-01-25','2019-02-28',100),(2,'2018-12-01','2020-01-01',10),(3,'2019-12-01','2020-01-31',1);

--input
PRODUCT_ID    PERIOD_START  PERIOD_END  AVERAGE_DAILY_SALES
----------    ----------    ----------  -------------------
	 1          2019-01-25    2019-02-28		 100
	 2          2018-12-01    2020-01-01		  10
	 3          2019-12-01    2020-01-31		   1

--Write a query to find total sales by year
--output
product_id,report_year,total_amount
1,2019,3500
2,2018,310
2,2019,3650
2,2020,10
3,2019,31
3,2020,31


with cte(product_id,period_start,period_end,avg) as 
  (
    select product_id,period_start,period_end,average_daily_sales from sales --anchor query
    union all
    select product_id,period_start + interval '1' day,period_end,avg  --recursive query
    from cte 
    where period_start < period_end --filter to stop the recursion
  )
select product_id,to_char(period_start,'YYYY'),sum(avg) 
 from cte --where product_id=3
group by product_id,to_char(period_start,'YYYY')
order by product_id;

33. --Recommendation system based on - product pairs most commonly purchased together.

drop table orders;
create table orders
(
order_id int,
customer_id int,
product_id int
);

insert into orders VALUES 
(1, 1, 1),
(1, 1, 2),
(1, 1, 3),
(2, 2, 1),
(2, 2, 2),
(2, 2, 4),
(3, 1, 5);

drop table products;
create table products (id int,name varchar(10));

insert into products VALUES 
(1, 'A'),
(2, 'B'),
(3, 'C'),
(4, 'D'),
(5, 'E');

commit;


--output:
pair, purchage_freq
AB , 2
AC , 1
BC , 1
AD , 1
BD , 1

--solution
--self join on (a.order_id = b.order_id and a.product_id < b.product_id)  
with data1 as (
  select o.* , p.name 
   from orders o left join products p on o.product_id=p.id 
),
data2 as ( select a.order_id a_order_id,a.name a_name,b.order_id b_order_id,b.name b_name
            from data1 a 
              inner join data1 b on a.order_id = b.order_id --we are looking into same order
              and a.product_id < b.product_id -- we are lookin into different products of the same order
            --where a.order_id=1
) , 
data3 as ( select a_order_id,a_name || b_name grp from data2 )
select grp,count(1) 
  from data3 group by grp

--output:
GRP		       COUNT(1)
-------------------- ----------
AB			      2
AC			      1
BC			      1
AD			      1
BD			      1

34. 

/* Prime subscription rate by product action
  Given the following two tables , return the fraction of users , rounded to two decimal places 
  who accessed Amazon music and upgraded to prime membership within the first 30 days of signing up
*/

drop table users;
create table users
(
user_id integer,
name varchar(20),
join_date date
);
insert into users
values (1, 'Jon', CAST('02-14-2020' AS date)), 
(2, 'Jane', CAST('02-14-2020' AS date)), 
(3, 'Jill', CAST('02-15-2020' AS date)), 
(4, 'Josh', CAST('02-15-2020' AS date)), 
(5, 'Jean', CAST('02-16-2020' AS date)), 
(6, 'Justin', CAST('02-17-2020' AS date)),
(7, 'Jeremy', CAST('02-18-2020' AS date));

drop table events;
create table events
(
user_id integer,
type varchar(10),
access_date date);

insert into events values
(1, 'Pay', CAST('03-01-2020' AS date)), 
(2, 'Music', CAST('03-02-2020' AS date)), 
(2, 'P', CAST('03-12-2020' AS date)),
(3, 'Music', CAST('03-15-2020' AS date)), 
(4, 'Music', CAST('03-15-2020' AS date)), 
(1, 'P', CAST('03-16-2020' AS date)), 
(3, 'P', CAST('03-22-2020' AS date));


--users accessed Music
with total_users_m as (
  select count( distinct user_id) total_cnt 
   from events where type='Music'
), --break type into to two columns
 data1 as (
   select a.user_id,
    a.type firstAccesss,
    b.type secondAccesss,
    a.access_date firstAccesssDate,
    b.access_date secondAccesssDate
  from events a left join events b 
   on a.user_id = b.user_id and a.type <> b.type 
   and a.access_date < b.access_date   
),
data2 as ( select count(*) upg_cnt
    from data1
    inner join users on  data1.user_id = users.user_id
  where secondAccesss is not null 
   and firstAccesss = 'Music' and secondAccesss='P' --upgraded from Music to Premium
   and data1.secondAccesssDate <= join_date + interval '30' day -- 2nd access should be within 30 days from join date
)select round(upg_cnt/total_cnt,2)
    from total_users_m
  join data2 on 1=1

--ouput:
ROUND(UPG_CNT/TOTAL_CNT,2)
--------------------------
		       .33

35. 

/* Write a query to print number of customer retained each month
*/ 

--ouput 
Jan,0
Feb,3

create table transactions(
order_id int,
cust_id int,
order_date date,
amount int
);

delete from transactions;

insert into transactions values 
(1,1,'2020-01-15',150)
,(2,1,'2020-02-10',150)
,(3,2,'2020-01-16',150)
,(4,2,'2020-02-25',150)
,(5,3,'2020-01-10',150)
,(6,3,'2020-02-20',150)
,(7,4,'2020-01-20',150)
,(8,5,'2020-02-20',150)
;

commit;

--solution
with data1 as ( 
   select order_id,
      cust_id,order_date,
      to_char(order_date,'YYYY-MM') ym,
      dense_rank() over(partition by cust_id order by order_date) rnk
 from transactions ),
new_cust as ( --new customers per month 
  select ym,cust_id 
    from data1 where rnk=1
)
select data1.ym,
  ( count( distinct data1.cust_id)-count(distinct new_cust.cust_id)) retained
from new_cust inner join data1 on new_cust.ym=data1.ym 
group by data1.ym

--ouput
YM	  RETAINED
------- ----------
2020-01 	 0
2020-02 	 3

36. 
/*
 find change in employee status
*/

drop table emp_2020;
create table emp_2020
(
emp_id int,
designation varchar(20)
);

drop table emp_2021;
create table emp_2021
(
emp_id int,
designation varchar(20)
);

insert into emp_2020 values (1,'Trainee'), (2,'Developer'),(3,'Senior Developer'),(4,'Manager');
insert into emp_2021 values (1,'Developer'), (2,'Developer'),(3,'Manager'),(5,'Trainee');
commit;

with data1 as (
select emp_2020.emp_id emp1 ,emp_2020.designation desg1,
        emp_2021.emp_id emp2 ,emp_2021.designation desg2
from emp_2020 full outer join emp_2021
 on emp_2020.emp_id = emp_2021.emp_id 
where coalesce(emp_2020.designation,'XXX') != coalesce(emp_2021.designation,'YYY')
 ) 
select coalesce(emp1,emp2) emp_id,
    case when desg1 = 'Trainee' and desg2='Developer' then 'promoted' 
         when desg1 = 'Developer' and desg2='Senior Developer' then 'promoted' 
         when desg1 = 'Senior Developer' and desg2='Manager' then 'promoted'
         when desg1 is null then 'new'
         else 'resigned'
    end as "comment"
   from data1 
order by emp_id

37. Print type of each node for given binary Tree

Drop table T;
Create table T(N number,P number);

Insert into T values(1,4);
Insert into T values(2,5);
Insert into T values(3,5);
Insert into T values(4,6);
Insert into T values(5,6);
Insert into T values(6,NULL);

commit;

--input
SQL> select * from T;

	 N	    P
---------- ----------
	 1	    4
	 2	    5
	 3	    5
	 4	    6
	 5	    6
	 6

6 rows selected.

SQL>


--output:
Node,Type
6,root
5,inner
4,inner
1,leaf
2,leaf
3,leaf

--solution1:

select N as "Node",
  case 
    when P is null then 'root'
    when N not in (select P from T where p is not null) then 'leaf'
    else 'inner'
  end as "Type"
 from T


--solution2:
With temp as ( 
select N.N "l" ,N.P "i",P.P "r"
 from T N 
  inner join T P 
on N.P=P.N 
where P.P is not null
) select "l" , 'leaf' as "type" from temp 
 minus 
  select "i", 'leaf' as "type" from temp 
union all
 select "i",'inner' as "type" from temp 
union all
 select "r",'root' as "type" from temp 
 minus 
 select "i",'root' as "type" from temp 


38. https://leetcode.com/problems/capital-gainloss/ 

Table: Stocks

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| stock_name    | varchar |
| operation     | enum    |
| operation_day | int     |
| price         | int     |
+---------------+---------+
(stock_name, operation_day) is the primary key for this table.
The operation column is an ENUM of type ('Sell', 'Buy')
Each row of this table indicates that the stock which has stock_name had an operation on the day operation_day with the price.
It is guaranteed that each 'Sell' operation for a stock has a corresponding 'Buy' operation in a previous day. It is also guaranteed that each 'Buy' operation for a stock has a corresponding 'Sell' operation in an upcoming day.
 

Write an SQL query to report the Capital gain/loss for each stock.

The Capital gain/loss of a stock is the total gain or loss after buying and selling the stock one or many times.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Stocks table:
+---------------+-----------+---------------+--------+
| stock_name    | operation | operation_day | price  |
+---------------+-----------+---------------+--------+
| Leetcode      | Buy       | 1             | 1000   |
| Corona Masks  | Buy       | 2             | 10     |
| Leetcode      | Sell      | 5             | 9000   |
| Handbags      | Buy       | 17            | 30000  |
| Corona Masks  | Sell      | 3             | 1010   |
| Corona Masks  | Buy       | 4             | 1000   |
| Corona Masks  | Sell      | 5             | 500    |
| Corona Masks  | Buy       | 6             | 1000   |
| Handbags      | Sell      | 29            | 7000   |
| Corona Masks  | Sell      | 10            | 10000  |
+---------------+-----------+---------------+--------+
Output: 
+---------------+-------------------+
| stock_name    | capital_gain_loss |
+---------------+-------------------+
| Corona Masks  | 9500              |
| Leetcode      | 8000              |
| Handbags      | -23000            |
+---------------+-------------------+
Explanation: 
Leetcode stock was bought at day 1 for 1000$ and was sold at day 5 for 9000$. Capital gain = 9000 - 1000 = 8000$.
Handbags stock was bought at day 17 for 30000$ and was sold at day 29 for 7000$. Capital loss = 7000 - 30000 = -23000$.
Corona Masks stock was bought at day 1 for 10$ and was sold at day 3 for 1010$. It was bought again at day 4 for 1000$ and was sold at day 5 for 500$. At last, it was bought at day 6 for 1000$ and was sold at day 10 for 10000$. Capital gain/loss is the sum of capital gains/losses for each ('Buy' --> 'Sell') operation = (1010 - 10) + (500 - 1000) + (10000 - 1000) = 1000 - 500 + 9000 = 9500$.

solution :
select stock_name,
   sum(case when operation = 'Buy' then -1*price 
        else price 
   end) as capital_gain_loss
 from Stocks 
group by stock_name

38.  
Counting Instances in Text
Find the number of times the words 'bull' and 'bear' occur in the contents. We are counting the number of times the words occur so words like 'bullish' should not be included in our count.
Output the word 'bull' and 'bear' along with the corresponding number of occurrences.

--input 
filename,contents
draft1.txt,The stock exchange predicts a bull market which would make many investors happy.
draft2.txt,The stock exchange predicts a bull market which would make many investors happy, but analysts warn of possibility of too much optimism and that in fact we are awaiting a bear market.
final.txt,The stock exchange predicts a bull market which would make many investors happy, but analysts warn of possibility of too much optimism and that in fact we are awaiting a bear market. As always predicting the future market is an uncertain game and all investors should follow their instincts and best practices.

--solution 
with temp as ( 
 select unnest(string_to_array(contents,' ')) as word from google_file_store
 ) select word,count(1) from temp 
  where word in ('bull','bear')
 group by word;

 --output:
word	count
bull	3
bear	2


--solution2
SELECT 
    word,nentry                                       
FROM  
    ts_stat('SELECT to_tsvector(contents) FROM google_file_store') 
WHERE
    word ILIKE 'bull' or word ILIKE 'bear'

39. https://platform.stratascratch.com/coding/10182-number-of-streets-per-zip-code?python= 

Number of Streets Per Zip Code
Find the number of different street names for each postal code, for the given business dataset. For simplicity, just count the first part of the name if the street name has multiple words. 

For example, East Broadway can be counted as East. East Main and East Broadly may be counted both as East, which is fine for this question. 

Counting street names should also be case insensitive, meaning FOLSOM should be counted the same as Folsom. Lastly, consider that some street names have different structures. For example, Pier 39 is the same street as 39 Pier,  your solution should count both situations as Pier street.

Output the result along with the corresponding postal code. Order the result based on the number of streets in descending order and based on the postal code in ascending order.
Table: sf_restaurant_health_violations
sf_restaurant_health_violations
business_idint
business_namevarchar
business_addressvarchar
business_cityvarchar
business_statevarchar
business_postal_codefloat
business_latitudefloat
business_longitudefloat
business_locationvarchar
business_phone_numberfloat
inspection_idvarchar
inspection_datedatetime
inspection_scorefloat
inspection_typevarchar
violation_idvarchar
violation_descriptionvarchar
risk_categoryvarchar


solution:
select business_postal_code,count( distinct case when LEFT(business_address, 1) ~ '[0-9]'
       then split_part(lower(business_address),' ',2)
       else split_part(lower(business_address),' ',1)
  end)
from sf_restaurant_health_violations 
where business_postal_code is not null
group by business_postal_code
order by 2 desc , 1 asc

40. https://leetcode.com/problems/median-employee-salary/ 

Table: Employee

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| id           | int     |
| company      | varchar |
| salary       | int     |
+--------------+---------+
id is the primary key column for this table.
Each row of this table indicates the company and the salary of one employee.
 

Write an SQL query to find the median salary of each company.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Employee table:
+----+---------+--------+
| id | company | salary |
+----+---------+--------+
| 1  | A       | 2341   |
| 2  | A       | 341    |
| 3  | A       | 15     |
| 4  | A       | 15314  |
| 5  | A       | 451    |
| 6  | A       | 513    |
| 7  | B       | 15     |
| 8  | B       | 13     |
| 9  | B       | 1154   |
| 10 | B       | 1345   |
| 11 | B       | 1221   |
| 12 | B       | 234    |
| 13 | C       | 2345   |
| 14 | C       | 2645   |
| 15 | C       | 2645   |
| 16 | C       | 2652   |
| 17 | C       | 65     |
+----+---------+--------+
Output: 
+----+---------+--------+
| id | company | salary |
+----+---------+--------+
| 5  | A       | 451    |
| 6  | A       | 513    |
| 12 | B       | 234    |
| 9  | B       | 1154   |
| 14 | C       | 2645   |
+----+---------+--------+

--solution:
with temp1 as (
select id,company,salary,
 row_number() over(partition by company order by salary,id) rnk,
 count(salary)  over(partition by company) cnt
from employee),
temp2 as (
select id,company,salary,rnk,cnt,
 (case when mod(cnt,2)=1 then 1 else 0 end) isodd
 from temp1)
select id,company,salary
from temp2 
where isodd=0 and rnk between floor(cnt/2) and floor(cnt/2 + 1) 
or (isodd=1 and rnk = floor(cnt/2 + 1))


41. https://leetcode.com/problems/find-median-given-frequency-of-numbers/ 

SQL Schema
Table: Numbers

+-------------+------+
| Column Name | Type |
+-------------+------+
| num         | int  |
| frequency   | int  |
+-------------+------+
num is the primary key for this table.
Each row of this table shows the frequency of a number in the database.
 

The median is the value separating the higher half from the lower half of a data sample.

Write an SQL query to report the median of all the numbers in the database after decompressing the Numbers table. Round the median to one decimal point.

The query result format is in the following example.

 

Example 1:

Input: 
Numbers table:
+-----+-----------+
| num | frequency |
+-----+-----------+
| 0   | 7         |
| 1   | 1         |
| 2   | 3         |
| 3   | 1         |
+-----+-----------+
Output: 
+--------+
| median |
+--------+
| 0.0    |
+--------+
Explanation: 
If we decompress the Numbers table, we will get [0, 0, 0, 0, 0, 0, 0, 1, 2, 2, 2, 3], so the median is (0 + 0) / 2 = 0.

--solution:
with cte1(n,f,frequency) as
(
    select num,1,frequency from numbers 
    union all
    select n,f+1,frequency from cte1
    where f<frequency
),cte2 as (select n,
    row_number() over(order by n) rn,
    count(1) over() cnt
 from cte1)
,cte3 as ( select n,rn,cnt,
    (case when mod(cnt,2)=1 then 1 else 0 end) isodd
 from cte2 )
select 
  case 
    when count(1) = 2 
    then sum(n)/2
    else sum(n)
  end as "median" 
 from cte3 where (isodd=1 and rn = floor(cnt/2) + 1 )
 or (isodd=0 and rn between floor(cnt/2) and floor(cnt/2) + 1 )


 42. https://leetcode.com/problems/find-cumulative-salary-of-an-employee/

 Find Cumulative Salary of an Employee

Share
SQL Schema
Table: Employee

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| month       | int  |
| salary      | int  |
+-------------+------+
(id, month) is the primary key for this table.
Each row in the table indicates the salary of an employee in one month during the year 2020.
 

Write an SQL query to calculate the cumulative salary summary for every employee in a single unified table.

The cumulative salary summary for an employee can be calculated as follows:

For each month that the employee worked, sum up the salaries in that month and the previous two months. This is their 3-month sum for that month. If an employee did not work for the company in previous months, their effective salary for those months is 0.
Do not include the 3-month sum for the most recent month that the employee worked for in the summary.
Do not include the 3-month sum for any month the employee did not work.
Return the result table ordered by id in ascending order. In case of a tie, order it by month in descending order.

The query result format is in the following example.

 

Example 1:

Input: 
Employee table:
+----+-------+--------+
| id | month | salary |
+----+-------+--------+
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 1  | 2     | 30     |
| 2  | 2     | 30     |
| 3  | 2     | 40     |
| 1  | 3     | 40     |
| 3  | 3     | 60     |
| 1  | 4     | 60     |
| 3  | 4     | 70     |
| 1  | 7     | 90     |
| 1  | 8     | 90     |
+----+-------+--------+
Output: 
+----+-------+--------+
| id | month | Salary |
+----+-------+--------+
| 1  | 7     | 90     |
| 1  | 4     | 130    |
| 1  | 3     | 90     |
| 1  | 2     | 50     |
| 1  | 1     | 20     |
| 2  | 1     | 20     |
| 3  | 3     | 100    |
| 3  | 2     | 40     |
+----+-------+--------+
Explanation: 
Employee '1' has five salary records excluding their most recent month '8':
- 90 for month '7'.
- 60 for month '4'.
- 40 for month '3'.
- 30 for month '2'.
- 20 for month '1'.
So the cumulative salary summary for this employee is:
+----+-------+--------+
| id | month | salary |
+----+-------+--------+
| 1  | 7     | 90     |  (90 + 0 + 0)
| 1  | 4     | 130    |  (60 + 40 + 30)
| 1  | 3     | 90     |  (40 + 30 + 20)
| 1  | 2     | 50     |  (30 + 20 + 0)
| 1  | 1     | 20     |  (20 + 0 + 0)
+----+-------+--------+
Note that the 3-month sum for month '7' is 90 because they did not work during month '6' or month '5'.

Employee '2' only has one salary record (month '1') excluding their most recent month '2'.
+----+-------+--------+
| id | month | salary |
+----+-------+--------+
| 2  | 1     | 20     |  (20 + 0 + 0)
+----+-------+--------+

Employee '3' has two salary records excluding their most recent month '4':
- 60 for month '3'.
- 40 for month '2'.
So the cumulative salary summary for this employee is:
+----+-------+--------+
| id | month | salary |
+----+-------+--------+
| 3  | 3     | 100    |  (60 + 40 + 0)
| 3  | 2     | 40     |  (40 + 0 + 0)
+----+-------+--------+

--solution:
with cte1(id,min_m,max_m) as ( 
 /* all the months between min and mx month per emp */
    select id,min(month),max(month) from Employee group by id
    union all
    select id,min_m + 1,max_m from cte1 
    where min_m < max_m
), 
cte2 as ( 
    /*store 0 as salary for didn't work months*/
    select cte1.id as id ,
            cte1.min_m as month,coalesce(e.salary,0) as salary
         from cte1 
 left join employee e on cte1.id=e.id and cte1.min_m=e.month ),
cte3 as ( 
    /*calculate current,last and 2nd last salary*/
    select id,month,salary curr_month_sal,salary + 
    coalesce(lag(salary,1) over(partition by id order by month),0) +
    coalesce(lag(salary,2) over(partition by id order by month),0) csalary,
         max(month) over(partition by id) recent
from cte2)
select id,month,csalary as salary from cte3 
 where curr_month_sal > 0 --exclude didnot work month 
     and recent <> month --exclude recent month
order by id,month desc

43. https://leetcode.com/problems/students-report-by-geography/

 Students Report By Geography

 SQL Schema
Table: Student

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| name        | varchar |
| continent   | varchar |
+-------------+---------+
There is no primary key for this table. It may contain duplicate rows.
Each row of this table indicates the name of a student and the continent they came from.
 

A school has students from Asia, Europe, and America.

Write an SQL query to pivot the continent column in the Student table so that each name is sorted alphabetically and displayed underneath its corresponding continent. The output headers should be America, Asia, and Europe, respectively.

The test cases are generated so that the student number from America is not less than either Asia or Europe.

The query result format is in the following example.

 

Example 1:

Input: 
Student table:
+--------+-----------+
| name   | continent |
+--------+-----------+
| Jane   | America   |
| Pascal | Europe    |
| Xi     | Asia      |
| Jack   | America   |
+--------+-----------+
Output: 
+---------+------+--------+
| America | Asia | Europe |
+---------+------+--------+
| Jack    | Xi   | Pascal |
| Jane    | null | null   |
+---------+------+--------+
 

Follow up: If it is unknown which continent has the most students, could you write a query to generate the student report?

--solution :
Select
 distinct 
 min(case when continent = 'America' then name else null end) as "America",
 min(case when continent = 'Asia' then name else null end) as "Asia",
 min(case when continent = 'Europe' then name else null end) as "Europe"
from ( 
      select dense_rank() over(partition by continent order by name) rnk,
             name,
             continent
       from student 
    ) T
group by rnk
order by 1,2,3


44. https://leetcode.com/problems/leetcodify-friends-recommendations/

Leetcodify Friends Recommendations

SQL Schema
Table: Listens

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| song_id     | int     |
| day         | date    |
+-------------+---------+
There is no primary key for this table. It may contain duplicates.
Each row of this table indicates that the user user_id listened to the song song_id on the day day.
 

Table: Friendship

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user1_id      | int     |
| user2_id      | int     |
+---------------+---------+
(user1_id, user2_id) is the primary key for this table.
Each row of this table indicates that the users user1_id and user2_id are friends.
Note that user1_id < user2_id.
 

Write an SQL query to recommend friends to Leetcodify users. We recommend user x to user y if:

Users x and y are not friends, and
Users x and y listened to the same three or more different songs on the same day.
Note that friend recommendations are unidirectional, meaning if user x and user y should be recommended to each other, the result table should have both user x recommended to user y and user y recommended to user x. Also, note that the result table should not contain duplicates (i.e., user y should not be recommended to user x multiple times.).

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Listens table:
+---------+---------+------------+
| user_id | song_id | day        |
+---------+---------+------------+
| 1       | 10      | 2021-03-15 |
| 1       | 11      | 2021-03-15 |
| 1       | 12      | 2021-03-15 |
| 2       | 10      | 2021-03-15 |
| 2       | 11      | 2021-03-15 |
| 2       | 12      | 2021-03-15 |
| 3       | 10      | 2021-03-15 |
| 3       | 11      | 2021-03-15 |
| 3       | 12      | 2021-03-15 |
| 4       | 10      | 2021-03-15 |
| 4       | 11      | 2021-03-15 |
| 4       | 13      | 2021-03-15 |
| 5       | 10      | 2021-03-16 |
| 5       | 11      | 2021-03-16 |
| 5       | 12      | 2021-03-16 |
+---------+---------+------------+
Friendship table:
+----------+----------+
| user1_id | user2_id |
+----------+----------+
| 1        | 2        |
+----------+----------+
Output: 
+---------+----------------+
| user_id | recommended_id |
+---------+----------------+
| 1       | 3              |
| 2       | 3              |
| 3       | 1              |
| 3       | 2              |
+---------+----------------+
Explanation: 
Users 1 and 2 listened to songs 10, 11, and 12 on the same day, but they are already friends.
Users 1 and 3 listened to songs 10, 11, and 12 on the same day. Since they are not friends, we recommend them to each other.
Users 1 and 4 did not listen to the same three songs.
Users 1 and 5 listened to songs 10, 11, and 12, but on different days.

Similarly, we can see that users 2 and 3 listened to songs 10, 11, and 12 on the same day and are not friends, so we recommend them to each other.

--solution:
--deduplicate listens into temp1
--self join temp1 on (day and song) and filter pair of different ids
-- number of distinct songs listened by above pair on same day should be >=3
-- filter out pair that are already friends.

with temp1 as (
    select distinct user_id user_id,song_id song_id ,to_char(day,'yyyy-mm-dd') day 
    from listens),
temp2 as (
select f.user_id "user_id",s.user_id "recommended_id"
 from temp1 f 
  inner join temp1 s on f.song_id = s.song_id and f.day = s.day
 where f.user_id <> s.user_id
group by f.user_id,s.user_id,f.day
having count( distinct f.song_id ) >= 3
)
select distinct "user_id","recommended_id" 
 from temp2 
-- filter out pair that are already friends.
left join friendship f on ( ("user_id" = user1_id and "recommended_id" = user2_id)
                          or ("user_id" = user2_id and "recommended_id" = user1_id))                          
where f.user1_id is null or f.user2_id is null

45. https://leetcode.com/problems/game-play-analysis-iii/ 
Game Play Analysis III
Table: Activity

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some games.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on someday using some device.
 

Write an SQL query to report for each player and date, how many games played so far by the player. That is, the total number of games played by the player until that date. Check the example for clarity.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-05-02 | 6            |
| 1         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+
Output: 
+-----------+------------+---------------------+
| player_id | event_date | games_played_so_far |
+-----------+------------+---------------------+
| 1         | 2016-03-01 | 5                   |
| 1         | 2016-05-02 | 11                  |
| 1         | 2017-06-25 | 12                  |
| 3         | 2016-03-02 | 0                   |
| 3         | 2018-07-03 | 5                   |
+-----------+------------+---------------------+
Explanation: 
For the player with id 1, 5 + 6 = 11 games played by 2016-05-02, and 5 + 6 + 1 = 12 games played by 2017-06-25.
For the player with id 3, 0 + 5 = 5 games played by 2018-07-03.
Note that for each player we only care about the days when the player logged in.

--solution : 
select player_id "player_id",to_char(event_date,'yyyy-mm-dd') "event_date",
sum(games_played) over( partition by player_id order by event_date rows between unbounded preceding and 0 preceding) "games_played_so_far"
from Activity 
order by player_id,event_date

46. https://leetcode.com/problems/game-play-analysis-iv/ 

Game Play Analysis IV
Table: Activity

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| player_id    | int     |
| device_id    | int     |
| event_date   | date    |
| games_played | int     |
+--------------+---------+
(player_id, event_date) is the primary key of this table.
This table shows the activity of players of some games.
Each row is a record of a player who logged in and played a number of games (possibly 0) before logging out on someday using some device.
 

Write an SQL query to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date, then divide that number by the total number of players.

The query result format is in the following example.

 

Example 1:

Input: 
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+
Output: 
+-----------+
| fraction  |
+-----------+
| 0.33      |
+-----------+
Explanation: 
Only the player with id 1 logged back in after the first day he had logged in so the answer is 1/3 = 0.33

--solution
/* Write your PL/SQL query statement below */
with temp as (select count(distinct player_id) tp from Activity)
select 
round(count(a.player_id) / max(tp),2) as "fraction"
 from 
 --day of first login is important
  ( select player_id player_id , min(event_date) event_date from Activity group by player_id) a 
  inner join Activity b on a.player_id = b.player_id
   and a.event_date = b.event_date - interval '1' day
inner join temp on 1=1


47. https://leetcode.com/problems/get-highest-answer-rate-question/ 
 Get Highest Answer Rate Question
Table: SurveyLog

+-------------+------+
| Column Name | Type |
+-------------+------+
| id          | int  |
| action      | ENUM |
| question_id | int  |
| answer_id   | int  |
| q_num       | int  |
| timestamp   | int  |
+-------------+------+
There is no primary key for this table. It may contain duplicates.
action is an ENUM of the type: "show", "answer", or "skip".
Each row of this table indicates the user with ID = id has taken an action with the question question_id at time timestamp.
If the action taken by the user is "answer", answer_id will contain the id of that answer, otherwise, it will be null.
q_num is the numeral order of the question in the current session.
 

The answer rate for a question is the number of times a user answered the question by the number of times a user showed the question.

Write an SQL query to report the question that has the highest answer rate. If multiple questions have the same maximum answer rate, report the question with the smallest question_id.

The query result format is in the following example.

 

Example 1:

Input: 
SurveyLog table:
+----+--------+-------------+-----------+-------+-----------+
| id | action | question_id | answer_id | q_num | timestamp |
+----+--------+-------------+-----------+-------+-----------+
| 5  | show   | 285         | null      | 1     | 123       |
| 5  | answer | 285         | 124124    | 1     | 124       |
| 5  | show   | 369         | null      | 2     | 125       |
| 5  | skip   | 369         | null      | 2     | 126       |
+----+--------+-------------+-----------+-------+-----------+
Output: 
+------------+
| survey_log |
+------------+
| 285        |
+------------+
Explanation: 
Question 285 was showed 1 time and answered 1 time. The answer rate of question 285 is 1.0
Question 369 was showed 1 time and was not answered. The answer rate of question 369 is 0.0
Question 285 has the highest answer rate.

--solution:
with temp as (
select 
 question_id,
 sum(case when action = 'answer' then 1 else 0 end) /
 sum(case when action = 'show' then 1 else 0 end) answer_rate
from SurveyLog
group by question_id),
temp2 as ( 
select question_id , dense_rank() over (order by answer_rate desc,question_id) rnk 
from temp )
select question_id survey_log from temp2 where rnk=1


48. https://leetcode.com/problems/investments-in-2016/ 

Investments in 2016

Table: Insurance

+-------------+-------+
| Column Name | Type  |
+-------------+-------+
| pid         | int   |
| tiv_2015    | float |
| tiv_2016    | float |
| lat         | float |
| lon         | float |
+-------------+-------+
pid is the primary key column for this table.
Each row of this table contains information about one policy where:
pid is the policyholders policy ID.
tiv_2015 is the total investment value in 2015 and tiv_2016 is the total investment value in 2016.
lat is the latitude of the policy holders city.
lon is the longitude of the policy holders city.
 

Write an SQL query to report the sum of all total investment values in 2016 tiv_2016, for all policyholders who:

have the same tiv_2015 value as one or more other policyholders, and
are not located in the same city like any other policyholder (i.e., the (lat, lon) attribute pairs must be unique).
Round tiv_2016 to two decimal places.

The query result format is in the following example.

 

Example 1:

Input: 
Insurance table:
+-----+----------+----------+-----+-----+
| pid | tiv_2015 | tiv_2016 | lat | lon |
+-----+----------+----------+-----+-----+
| 1   | 10       | 5        | 10  | 10  |
| 2   | 20       | 20       | 20  | 20  |
| 3   | 10       | 30       | 20  | 20  |
| 4   | 10       | 40       | 40  | 40  |
+-----+----------+----------+-----+-----+
Output: 
+----------+
| tiv_2016 |
+----------+
| 45.00    |
+----------+
Explanation: 
The first record in the table, like the last record, meets both of the two criteria.
The tiv_2015 value 10 is the same as the third and fourth records, and its location is unique.

The second record does not meet any of the two criteria. Its tiv_2015 is not like any other policyholders and its location is the same as the third record, which makes the third record fail, too.
So, the result is the sum of tiv_2016 of the first and last record, which is 45.

--solution
/* Write your PL/SQL query statement below */
select round(sum(e.tiv_2016),2) "tiv_2016"
 from Insurance e 
where exists ( /* unique location*/
     select 1 
 from Insurance i where e.lon = i.lon and e.lat = i.lat
group by lat,lon
having count(1) = 1)
and exists ( 
     select 1 /* same tiv_2015 value as one or more other policyholders*/ 
  from Insurance i where e.tiv_2015 = i.tiv_2015 and e.pid <> i.pid)


