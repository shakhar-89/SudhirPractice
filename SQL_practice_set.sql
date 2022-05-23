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

--sol1 
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

--sol2
with cte as (
    select min(period_start) period_start,max(period_end) period_end
     from Sales
     union all
    select dateadd(day,1,period_start),period_end from cte
    where period_start < period_end
) select s.product_id,product_name,cast(year(c.period_start) as varchar) report_year,sum(s.average_daily_sales) total_amount
    from Sales s 
     inner join Product p on s.product_id = p.product_id
     inner join cte c on c.period_start between s.period_start and s.period_end
  group by s.product_id,product_name,year(c.period_start) 
  order by s.product_id,year(c.period_start) 
  option (maxrecursion 0)


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
SELECT America, Asia, Europe
FROM (SELECT name America, ROW_NUMBER() OVER(ORDER BY name) rnk FROM student WHERE continent = 'America') t1
LEFT JOIN (SELECT name Asia, ROW_NUMBER() OVER(ORDER BY name) rnk FROM student WHERE continent = 'Asia') t2
ON t1.rnk = t2.rnk
LEFT JOIN (SELECT name Europe, ROW_NUMBER() OVER(ORDER BY name) rnk FROM student WHERE continent = 'Europe') t3
ON t1.rnk = t3.rnk


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


49.  https://leetcode.com/problems/shortest-distance-in-a-plane/ 
  
  Shortest Distance in a Plane

Table: Point2D

+-------------+------+
| Column Name | Type |
+-------------+------+
| x           | int  |
| y           | int  |
+-------------+------+
(x, y) is the primary key column for this table.
Each row of this table indicates the position of a point on the X-Y plane.
 

The distance between two points p1(x1, y1) and p2(x2, y2) is sqrt((x2 - x1)2 + (y2 - y1)2).

Write an SQL query to report the shortest distance between any two points from the Point2D table. Round the distance to two decimal points.

The query result format is in the following example.

 

Example 1:

Input: 
Point2D table:
+----+----+
| x  | y  |
+----+----+
| -1 | -1 |
| 0  | 0  |
| -1 | -2 |
+----+----+
Output: 
+----------+
| shortest |
+----------+
| 1.00     |
+----------+
Explanation: The shortest distance is 1.00 from point (-1, -1) to (-1, 2).

--solution 
/* Write your PL/SQL query statement below */
select min(round(sqrt(power(p1.x-p2.x,2) + power(p1.y-p2.y,2)),2)) "shortest"
 from Point2D p1, Point2D p2
where p1.x <> p2.x or p1.y <> p2.y

50. https://leetcode.com/problems/second-degree-follower/ 

Second Degree Follower

Table: Follow

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| followee    | varchar |
| follower    | varchar |
+-------------+---------+
(followee, follower) is the primary key column for this table.
Each row of this table indicates that the user follower follows the user followee on a social network.
There will not be a user following themself.
 

A second-degree follower is a user who:

follows at least one user, and
is followed by at least one user.
Write an SQL query to report the second-degree users and the number of their followers.

Return the result table ordered by follower in alphabetical order.

The query result format is in the following example.

 

Example 1:

Input: 
Follow table:
+----------+----------+
| followee | follower |
+----------+----------+
| Alice    | Bob      |
| Bob      | Cena     |
| Bob      | Donald   |
| Donald   | Edward   |
+----------+----------+
Output: 
+----------+-----+
| follower | num |
+----------+-----+
| Bob      | 2   |
| Donald   | 1   |
+----------+-----+
Explanation: 
User Bob has 2 followers. Bob is a second-degree follower because he follows Alice, so we include him in the result table.
User Donald has 1 follower. Donald is a second-degree follower because he follows Bob, so we include him in the result table.
User Alice has 1 follower. Alice is not a second-degree follower because she does not follow anyone, so we don not include her in the result table.

--solution:
/* Write your PL/SQL query statement below */
select followee as "follower",count(distinct follower) as "num"
 from Follow e
where exists (
    select 1 from Follow i where e.followee = i.follower
)
group by followee
having count(distinct follower) >= 1

51. https://leetcode.com/problems/customers-who-bought-all-products/

Customers Who Bought All Products

Table: Customer

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| customer_id | int     |
| product_key | int     |
+-------------+---------+
There is no primary key for this table. It may contain duplicates.
product_key is a foreign key to Product table.
 

Table: Product

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| product_key | int     |
+-------------+---------+
product_key is the primary key column for this table.
 

Write an SQL query to report the customer ids from the Customer table that bought all the products in the Product table.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Customer table:
+-------------+-------------+
| customer_id | product_key |
+-------------+-------------+
| 1           | 5           |
| 2           | 6           |
| 3           | 5           |
| 3           | 6           |
| 1           | 6           |
+-------------+-------------+
Product table:
+-------------+
| product_key |
+-------------+
| 5           |
| 6           |
+-------------+
Output: 
+-------------+
| customer_id |
+-------------+
| 1           |
| 3           |
+-------------+
Explanation: 
The customers who bought all the products (5 and 6) are customers with IDs 1 and 3.

--solution
/* Write your PL/SQL query statement below */
select customer_id 
 from Customer
group by customer_id
having count(distinct product_key) = (select count(distinct product_key) from Product)

52. https://leetcode.com/problems/delete-duplicate-emails/ 

Delete Duplicate Emails

Table: Person

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| email       | varchar |
+-------------+---------+
id is the primary key column for this table.
Each row of this table contains an email. The emails will not contain uppercase letters.
 

Write an SQL query to delete all the duplicate emails, keeping only one unique email with the smallest id. Note that you are supposed to write a DELETE statement and not a SELECT one.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Person table:
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+
Output: 
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+
Explanation: john@example.com is repeated two times. We keep the row with the smallest Id = 1.

--solution:
 delete from Person e 
  where exists (select 1 from Person i where e.email = i.email and e.id > i.id)

53. Find how many products fall into customer_budget along with list of those products
    In case of clash choose the low costly product 

--schema
drop table products;
create table products(product_id varchar(20) ,cost int);
insert into products values ('P1',200),('P2',300),('P3',500),('P4',800);
commit;

drop table customer_budget;
create table customer_budget(customer_id int,budget int);
insert into customer_budget values (100,400),(200,800),(300,1500);
commit;

col products for a40
--solution
with temp as (
  select product_id,cost,
    --this works because of the rule on choosing low costly product in case of clash  
    sum(cost) over(order by cost rows between unbounded preceding and 0 preceding) rsum
   from products
) 
select 
  customer_id,
  budget,
  count(distinct product_id) no_of_products,
  LISTAGG(product_id, ',') WITHIN GROUP (ORDER BY product_id) "products"
from customer_budget cb 
 left join temp p on p.rsum < cb.budget
group by customer_id,budget

--ouput:
CUSTOMER_ID     BUDGET NO_OF_PRODUCTS products
----------- ---------- -------------- ----------------------------------------
        100        400              1 P1
        200        800              2 P1,P2
        300       1500              3 P1,P2,P3

3 rows selected.

SQL>

54. https://leetcode.com/problems/sales-person/ 

Sales Person

Table: SalesPerson

+-----------------+---------+
| Column Name     | Type    |
+-----------------+---------+
| sales_id        | int     |
| name            | varchar |
| salary          | int     |
| commission_rate | int     |
| hire_date       | date    |
+-----------------+---------+
sales_id is the primary key column for this table.
Each row of this table indicates the name and the ID of a salesperson alongside their salary, commission rate, and hire date.
 

Table: Company

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| com_id      | int     |
| name        | varchar |
| city        | varchar |
+-------------+---------+
com_id is the primary key column for this table.
Each row of this table indicates the name and the ID of a company and the city in which the company is located.
 

Table: Orders

+-------------+------+
| Column Name | Type |
+-------------+------+
| order_id    | int  |
| order_date  | date |
| com_id      | int  |
| sales_id    | int  |
| amount      | int  |
+-------------+------+
order_id is the primary key column for this table.
com_id is a foreign key to com_id from the Company table.
sales_id is a foreign key to com_id from the SalesPerson table.
Each row of this table contains information about one order. This includes the ID of the company, the ID of the salesperson, the date of the order, and the amount paid.
 

Write an SQL query to report the names of all the salespersons who did not have any orders related to the company with the name "RED".

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
SalesPerson table:
+----------+------+--------+-----------------+------------+
| sales_id | name | salary | commission_rate | hire_date  |
+----------+------+--------+-----------------+------------+
| 1        | John | 100000 | 6               | 4/1/2006   |
| 2        | Amy  | 12000  | 5               | 5/1/2010   |
| 3        | Mark | 65000  | 12              | 12/25/2008 |
| 4        | Pam  | 25000  | 25              | 1/1/2005   |
| 5        | Alex | 5000   | 10              | 2/3/2007   |
+----------+------+--------+-----------------+------------+
Company table:
+--------+--------+----------+
| com_id | name   | city     |
+--------+--------+----------+
| 1      | RED    | Boston   |
| 2      | ORANGE | New York |
| 3      | YELLOW | Boston   |
| 4      | GREEN  | Austin   |
+--------+--------+----------+
Orders table:
+----------+------------+--------+----------+--------+
| order_id | order_date | com_id | sales_id | amount |
+----------+------------+--------+----------+--------+
| 1        | 1/1/2014   | 3      | 4        | 10000  |
| 2        | 2/1/2014   | 4      | 5        | 5000   |
| 3        | 3/1/2014   | 1      | 1        | 50000  |
| 4        | 4/1/2014   | 1      | 4        | 25000  |
+----------+------------+--------+----------+--------+
Output: 
+------+
| name |
+------+
| Amy  |
| Mark |
| Alex |
+------+
Explanation: 
According to orders 3 and 4 in the Orders table, it is easy to tell that only salesperson John and Pam have sales to company RED, so we report all the other names in the table salesperson.

--solution
select name from 
SalesPerson where sales_id not in (
select distinct sales_id 
 from Orders o
where com_id in ( 
    select com_id from company where name = 'RED'))


55. https://leetcode.com/problems/dynamic-pivoting-of-a-table/ 

Dynamic Pivoting of a Table

Table: Products

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| product_id  | int     |
| store       | varchar |
| price       | int     |
+-------------+---------+
(product_id, store) is the primary key for this table.
Each row of this table indicates the price of product_id in store.
There will be at most 30 different stores in the table.
price is the price of the product at this store.
 

Important note: This problem targets those who have a good experience with SQL. If you are a beginner, we recommend that you skip it for now.

Implement the procedure PivotProducts to reorganize the Products table so that each row has the id of one product and its price in each store. The price should be null if the product is not sold in a store. The columns of the table should contain each store and they should be sorted in lexicographical order.

The procedure should return the table after reorganizing it.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Products table:
+------------+----------+-------+
| product_id | store    | price |
+------------+----------+-------+
| 1          | Shop     | 110   |
| 1          | LC_Store | 100   |
| 2          | Nozama   | 200   |
| 2          | Souq     | 190   |
| 3          | Shop     | 1000  |
| 3          | Souq     | 1900  |
+------------+----------+-------+
Output: 
+------------+----------+--------+------+------+
| product_id | LC_Store | Nozama | Shop | Souq |
+------------+----------+--------+------+------+
| 1          | 100      | null   | 110  | null |
| 2          | null     | 200    | null | 190  |
| 3          | null     | null   | 1000 | 1900 |
+------------+----------+--------+------+------+
Explanation: 
We have 4 stores: Shop, LC_Store, Nozama, and Souq. We first order them lexicographically to be: LC_Store, Nozama, Shop, and Souq.
Now, for product 1, the price in LC_Store is 100 and in Shop is 110. For the other two stores, the product is not sold so we set the price as null.
Similarly, product 2 has a price of 200 in Nozama and 190 in Souq. It is not sold in the other two stores.
For product 3, the price is 1000 in Shop and 1900 in Souq. It is not sold in the other two stores.

--solution1
 CREATE FUNCTION PivotProducts
 RETURN SYS_REFCURSOR IS result SYS_REFCURSOR;
 BEGIN
     /* Write your PL/SQL query statement below */
    open result for select * from (
        select product_id "product_id",store,price
        from Products
    )
    pivot (
        max(price)
     for (store) in (
         'LC_Store' "LC_Store",
         'Nozama' "Nozama",
         'Shop' "Shop",
         'Souq' "Souq")
    );
    
     RETURN result;
END;

56. https://leetcode.com/problems/get-the-second-most-recent-activity/ 

Get the Second Most Recent Activity

Table: UserActivity

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| username      | varchar |
| activity      | varchar |
| startDate     | Date    |
| endDate       | Date    |
+---------------+---------+
There is no primary key for this table. It may contain duplicates.
This table contains information about the activity performed by each user in a period of time.
A person with username performed an activity from startDate to endDate.
 

Write an SQL query to show the second most recent activity of each user.

If the user only has one activity, return that one. A user cannot perform more than one activity at the same time.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
UserActivity table:
+------------+--------------+-------------+-------------+
| username   | activity     | startDate   | endDate     |
+------------+--------------+-------------+-------------+
| Alice      | Travel       | 2020-02-12  | 2020-02-20  |
| Alice      | Dancing      | 2020-02-21  | 2020-02-23  |
| Alice      | Travel       | 2020-02-24  | 2020-02-28  |
| Bob        | Travel       | 2020-02-11  | 2020-02-18  |
+------------+--------------+-------------+-------------+
Output: 
+------------+--------------+-------------+-------------+
| username   | activity     | startDate   | endDate     |
+------------+--------------+-------------+-------------+
| Alice      | Dancing      | 2020-02-21  | 2020-02-23  |
| Bob        | Travel       | 2020-02-11  | 2020-02-18  |
+------------+--------------+-------------+-------------+
Explanation: 
The most recent activity of Alice is Travel from 2020-02-24 to 2020-02-28, before that she was dancing from 2020-02-21 to 2020-02-23.
Bob only has one record, we just take that one.

--solution
/* Write your PL/SQL query statement below */

select username,activity,startdate,enddate from (
select username,activity,
    to_char(startdate,'yyyy-mm-dd') startdate ,
    to_char(enddate,'yyyy-mm-dd') enddate,
    dense_rank() over(partition by username order by endDate desc) rnk,
    count(distinct activity) over(partition by username) cnt
 from UserActivity ) where rnk=2 or cnt =1

 57. https://leetcode.com/problems/number-of-trusted-contacts-of-a-customer/ 
 Number of Trusted Contacts of a Customer

Table: Customers

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| customer_id   | int     |
| customer_name | varchar |
| email         | varchar |
+---------------+---------+
customer_id is the primary key for this table.
Each row of this table contains the name and the email of a customer of an online shop.
 

Table: Contacts

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | id      |
| contact_name  | varchar |
| contact_email | varchar |
+---------------+---------+
(user_id, contact_email) is the primary key for this table.
Each row of this table contains the name and email of one contact of customer with user_id.
This table contains information about people each customer trust. The contact may or may not exist in the Customers table.
 

Table: Invoices

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| invoice_id   | int     |
| price        | int     |
| user_id      | int     |
+--------------+---------+
invoice_id is the primary key for this table.
Each row of this table indicates that user_id has an invoice with invoice_id and a price.
 

Write an SQL query to find the following for each invoice_id:

customer_name: The name of the customer the invoice is related to.
price: The price of the invoice.
contacts_cnt: The number of contacts related to the customer.
trusted_contacts_cnt: The number of contacts related to the customer and at the same time they are customers to the shop. (i.e their email exists in the Customers table.)
Return the result table ordered by invoice_id.

The query result format is in the following example.

 

Example 1:

Input: 
Customers table:
+-------------+---------------+--------------------+
| customer_id | customer_name | email              |
+-------------+---------------+--------------------+
| 1           | Alice         | alice@leetcode.com |
| 2           | Bob           | bob@leetcode.com   |
| 13          | John          | john@leetcode.com  |
| 6           | Alex          | alex@leetcode.com  |
+-------------+---------------+--------------------+
Contacts table:
+-------------+--------------+--------------------+
| user_id     | contact_name | contact_email      |
+-------------+--------------+--------------------+
| 1           | Bob          | bob@leetcode.com   |
| 1           | John         | john@leetcode.com  |
| 1           | Jal          | jal@leetcode.com   |
| 2           | Omar         | omar@leetcode.com  |
| 2           | Meir         | meir@leetcode.com  |
| 6           | Alice        | alice@leetcode.com |
+-------------+--------------+--------------------+
Invoices table:
+------------+-------+---------+
| invoice_id | price | user_id |
+------------+-------+---------+
| 77         | 100   | 1       |
| 88         | 200   | 1       |
| 99         | 300   | 2       |
| 66         | 400   | 2       |
| 55         | 500   | 13      |
| 44         | 60    | 6       |
+------------+-------+---------+
Output: 
+------------+---------------+-------+--------------+----------------------+
| invoice_id | customer_name | price | contacts_cnt | trusted_contacts_cnt |
+------------+---------------+-------+--------------+----------------------+
| 44         | Alex          | 60    | 1            | 1                    |
| 55         | John          | 500   | 0            | 0                    |
| 66         | Bob           | 400   | 2            | 0                    |
| 77         | Alice         | 100   | 3            | 2                    |
| 88         | Alice         | 200   | 3            | 2                    |
| 99         | Bob           | 300   | 2            | 0                    |
+------------+---------------+-------+--------------+----------------------+
Explanation: 
Alice has three contacts, two of them are trusted contacts (Bob and John).
Bob has two contacts, none of them is a trusted contact.
Alex has one contact and it is a trusted contact (Alice).
John doesnot have any contacts.

--solution
select invoice_id,customer_name,price,
   count(contact_name) "contacts_cnt",
    sum(
        case 
            when contact_name in (select customer_name from Customers)
            then 1 else 0
        end) "trusted_contacts_cnt"
 from Invoices i inner join Customers c on i.user_id = c.customer_id
  left join Contacts ct on c.customer_id = ct.user_id
group by invoice_id,customer_name,price
order by invoice_id

58. https://leetcode.com/problems/game-play-analysis-v/ 

Game Play Analysis V

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
 

The install date of a player is the first login day of that player.

We define day one retention of some date x to be the number of players whose install date is x and they logged back in on the day right after x, divided by the number of players whose install date is x, rounded to 2 decimal places.

Write an SQL query to report for each install date, the number of players that installed the game on that day, and the day one retention.

Return the result table in any order.

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
| 3         | 1         | 2016-03-01 | 0            |
| 3         | 4         | 2016-07-03 | 5            |
+-----------+-----------+------------+--------------+
Output: 
+------------+----------+----------------+
| install_dt | installs | Day1_retention |
+------------+----------+----------------+
| 2016-03-01 | 2        | 0.50           |
| 2017-06-25 | 1        | 0.00           |
+------------+----------+----------------+
Explanation: 
Player 1 and 3 installed the game on 2016-03-01 but only player 1 logged back in on 2016-03-02 so the day 1 retention of 2016-03-01 is 1 / 2 = 0.50
Player 2 installed the game on 2017-06-25 but didnot log back in on 2017-06-26 so the day 1 retention of 2017-06-25 is 0 / 1 = 0.00

--solution
/* Write your PL/SQL query statement below */
--calculate install date
-- count number of installs on that date (y)
-- count players login next day to install date (x) 
-- x/y for each install date

with temp1 as ( --calculate install dates
select player_id,min(event_date) install_dt
 from Activity
group by player_id
) select to_char(install_dt,'yyyy-mm-dd') install_dt,count(1) installs,
   round(count(distinct a.player_id) / count(1),2) "Day1_retention"
 from temp1 left join activity a 
   on a.event_date = temp1.install_dt + interval '1' day
    and a.player_id = temp1.player_id
 group by to_char(install_dt,'yyyy-mm-dd')


59. https://leetcode.com/problems/unpopular-books/ 

Unpopular Books

Table: Books

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| book_id        | int     |
| name           | varchar |
| available_from | date    |
+----------------+---------+
book_id is the primary key of this table.
 

Table: Orders

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| order_id       | int     |
| book_id        | int     |
| quantity       | int     |
| dispatch_date  | date    |
+----------------+---------+
order_id is the primary key of this table.
book_id is a foreign key to the Books table.
 

Write an SQL query that reports the books that have sold less than 10 copies in the last year, excluding books that have been available for less than one month from today. Assume today is 2019-06-23.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Books table:
+---------+--------------------+----------------+
| book_id | name               | available_from |
+---------+--------------------+----------------+
| 1       | "Kalila And Demna" | 2010-01-01     |
| 2       | "28 Letters"       | 2012-05-12     |
| 3       | "The Hobbit"       | 2019-06-10     |
| 4       | "13 Reasons Why"   | 2019-06-01     |
| 5       | "The Hunger Games" | 2008-09-21     |
+---------+--------------------+----------------+
Orders table:
+----------+---------+----------+---------------+
| order_id | book_id | quantity | dispatch_date |
+----------+---------+----------+---------------+
| 1        | 1       | 2        | 2018-07-26    |
| 2        | 1       | 1        | 2018-11-05    |
| 3        | 3       | 8        | 2019-06-11    |
| 4        | 4       | 6        | 2019-06-05    |
| 5        | 4       | 5        | 2019-06-20    |
| 6        | 5       | 9        | 2009-02-02    |
| 7        | 5       | 8        | 2010-04-13    |
+----------+---------+----------+---------------+
Output: 
+-----------+--------------------+
| book_id   | name               |
+-----------+--------------------+
| 1         | "Kalila And Demna" |
| 2         | "28 Letters"       |
| 5         | "The Hunger Games" |
+-----------+--------------------+

--solution
/* Write your PL/SQL query statement below */

with temp as (
select b.book_id book_id ,name,o.quantity quantity,o.dispatch_date ,b.available_from
 from Books b 
 left join Orders o on b.book_id = o.book_id 
    ) 
    
-- all the books
select book_id,name from Books 

MINUS 

--books sold 10 copies in last year

select book_id,name 
 from temp 
where dispatch_date 
    between to_date('2019-06-23') - interval '1' year
     and to_date('2019-06-23')
group by book_id,name
having sum(quantity) >=10

MINUS 

--books available only from last month
select book_id,name 
 from temp 
where available_from
    between to_date('2019-06-23') - interval '1' month
     and to_date('2019-06-23')


60. https://leetcode.com/problems/new-users-daily-count/ 

New Users Daily Count

SQL Schema
Table: Traffic

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| activity      | enum    |
| activity_date | date    |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The activity column is an ENUM type of ('login', 'logout', 'jobs', 'groups', 'homepage').
 

Write an SQL query to reports for every date within at most 90 days from today, the number of users that logged in for the first time on that date. Assume today is 2019-06-30.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Traffic table:
+---------+----------+---------------+
| user_id | activity | activity_date |
+---------+----------+---------------+
| 1       | login    | 2019-05-01    |
| 1       | homepage | 2019-05-01    |
| 1       | logout   | 2019-05-01    |
| 2       | login    | 2019-06-21    |
| 2       | logout   | 2019-06-21    |
| 3       | login    | 2019-01-01    |
| 3       | jobs     | 2019-01-01    |
| 3       | logout   | 2019-01-01    |
| 4       | login    | 2019-06-21    |
| 4       | groups   | 2019-06-21    |
| 4       | logout   | 2019-06-21    |
| 5       | login    | 2019-03-01    |
| 5       | logout   | 2019-03-01    |
| 5       | login    | 2019-06-21    |
| 5       | logout   | 2019-06-21    |
+---------+----------+---------------+
Output: 
+------------+-------------+
| login_date | user_count  |
+------------+-------------+
| 2019-05-01 | 1           |
| 2019-06-21 | 2           |
+------------+-------------+
Explanation: 
Note that we only care about dates with non zero user count.
The user with id 5 first logged in on 2019-03-01 so he is not counted on 2019-06-21.

--solution
/* Write your PL/SQL query statement below */

select to_char(fdate,'yyyy-mm-dd') login_date,count(distinct user_id) user_count
 from (
select user_id,min(activity_date) fdate
 from Traffic 
where activity = 'login'
group by user_id
)
where fdate >= to_date('2019-06-30') - interval '90' day
group by to_char(fdate,'yyyy-mm-dd')


61. https://leetcode.com/problems/reported-posts-ii/

Reported Posts II

Table: Actions

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| post_id       | int     |
| action_date   | date    | 
| action        | enum    |
| extra         | varchar |
+---------------+---------+
There is no primary key for this table, it may have duplicate rows.
The action column is an ENUM type of ('view', 'like', 'reaction', 'comment', 'report', 'share').
The extra column has optional information about the action, such as a reason for the report or a type of reaction.
 

Table: Removals

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| post_id       | int     |
| remove_date   | date    | 
+---------------+---------+
post_id is the primary key of this table.
Each row in this table indicates that some post was removed due to being reported or as a result of an admin review.
 

Write an SQL query to find the average daily percentage of posts that got removed after being reported as spam, rounded to 2 decimal places.

The query result format is in the following example.

 

Example 1:

Input: 
Actions table:
+---------+---------+-------------+--------+--------+
| user_id | post_id | action_date | action | extra  |
+---------+---------+-------------+--------+--------+
| 1       | 1       | 2019-07-01  | view   | null   |
| 1       | 1       | 2019-07-01  | like   | null   |
| 1       | 1       | 2019-07-01  | share  | null   |
| 2       | 2       | 2019-07-04  | view   | null   |
| 2       | 2       | 2019-07-04  | report | spam   |
| 3       | 4       | 2019-07-04  | view   | null   |
| 3       | 4       | 2019-07-04  | report | spam   |
| 4       | 3       | 2019-07-02  | view   | null   |
| 4       | 3       | 2019-07-02  | report | spam   |
| 5       | 2       | 2019-07-03  | view   | null   |
| 5       | 2       | 2019-07-03  | report | racism |
| 5       | 5       | 2019-07-03  | view   | null   |
| 5       | 5       | 2019-07-03  | report | racism |
+---------+---------+-------------+--------+--------+
Removals table:
+---------+-------------+
| post_id | remove_date |
+---------+-------------+
| 2       | 2019-07-20  |
| 3       | 2019-07-18  |
+---------+-------------+
Output: 
+-----------------------+
| average_daily_percent |
+-----------------------+
| 75.00                 |
+-----------------------+
Explanation: 
The percentage for 2019-07-04 is 50% because only one post of two spam reported posts were removed.
The percentage for 2019-07-02 is 100% because one post was reported as spam and it was removed.
The other days had no spam reports so the average is (50 + 100) / 2 = 75%
Note that the output is only one number and that we do not care about the remove dates.

--solution
/* Write your PL/SQL query statement below */


with temp as (
select to_char(action_date,'yyyy-mm-dd'),(count(distinct r.post_id) / count(distinct a.post_id)) *100 daily_percentage_removed
from Actions a
  left join Removals r on a.post_id = r.post_id and a.action_date < r.remove_date
 where extra = 'spam' and action = 'report'
group by to_char(action_date,'yyyy-mm-dd')
) 
select round(avg(daily_percentage_removed),2) average_daily_percent from temp

-- select round(avg(daily_percentage_removed),2) average_daily_percent 
-- from temp

-- with daily_spams as (
--     select to_char(action_date,'yyyy-mm-dd'),count(distinct r.post_id) / count(distinct a.post_id) * 100 res
--      from Actions a 
--     left join Removals r on a.post_id = r.post_id and a.action_date < r.remove_date 
--     where extra = 'spam' and action = 'report'
--  group by to_char(action_date,'yyyy-mm-dd')
-- ) select round(avg(res),2) average_daily_percent from daily_spams


62. https://leetcode.com/problems/product-price-at-a-given-date/ 

Product Price at a Given Date

SQL Schema
Table: Products

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| product_id    | int     |
| new_price     | int     |
| change_date   | date    |
+---------------+---------+
(product_id, change_date) is the primary key of this table.
Each row of this table indicates that the price of some product was changed to a new price at some date.
 

Write an SQL query to find the prices of all products on 2019-08-16. Assume the price of all products before any change is 10.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Products table:
+------------+-----------+-------------+
| product_id | new_price | change_date |
+------------+-----------+-------------+
| 1          | 20        | 2019-08-14  |
| 2          | 50        | 2019-08-14  |
| 1          | 30        | 2019-08-15  |
| 1          | 35        | 2019-08-16  |
| 2          | 65        | 2019-08-17  |
| 3          | 20        | 2019-08-18  |
+------------+-----------+-------------+
Output: 
+------------+-------+
| product_id | price |
+------------+-------+
| 2          | 50    |
| 1          | 35    |
| 3          | 10    |
+------------+-------+

--solution
with temp as (
    select product_id,new_price,change_date
     from Products
    union all
    --to make sure all the products have price as 10 as on or before 2019-08-16 if not changed
    select distinct product_id,10,to_date('1900-01-01')
     from Products
 ),
 temp2 as ( select product_id,new_price price,
    dense_rank() over(partition by product_id order by change_date desc) rnk  -- take last price 
   from temp where change_date <= '2019-08-16' )
 select product_id,price 
  from temp2 where rnk=1


63. https://leetcode.com/problems/report-contiguous-dates/ 

Report Contiguous Dates

SQL Schema
Table: Failed

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| fail_date    | date    |
+--------------+---------+
fail_date is the primary key for this table.
This table contains the days of failed tasks.
 

Table: Succeeded

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| success_date | date    |
+--------------+---------+
success_date is the primary key for this table.
This table contains the days of succeeded tasks.
 

A system is running one task every day. Every task is independent of the previous tasks. The tasks can fail or succeed.

Write an SQL query to generate a report of period_state for each continuous interval of days in the period from 2019-01-01 to 2019-12-31.

period_state is 'failed' if tasks in this interval failed or 'succeeded' if tasks in this interval succeeded. Interval of days are retrieved as start_date and end_date.

Return the result table ordered by start_date.

The query result format is in the following example.

 

Example 1:

Input: 
Failed table:
+-------------------+
| fail_date         |
+-------------------+
| 2018-12-28        |
| 2018-12-29        |
| 2019-01-04        |
| 2019-01-05        |
+-------------------+
Succeeded table:
+-------------------+
| success_date      |
+-------------------+
| 2018-12-30        |
| 2018-12-31        |
| 2019-01-01        |
| 2019-01-02        |
| 2019-01-03        |
| 2019-01-06        |
+-------------------+
Output: 
+--------------+--------------+--------------+
| period_state | start_date   | end_date     |
+--------------+--------------+--------------+
| succeeded    | 2019-01-01   | 2019-01-03   |
| failed       | 2019-01-04   | 2019-01-05   |
| succeeded    | 2019-01-06   | 2019-01-06   |
+--------------+--------------+--------------+
Explanation: 
The report ignored the system state in 2018 as we care about the system in the period 2019-01-01 to 2019-12-31.
From 2019-01-01 to 2019-01-03 all tasks succeeded and the system state was "succeeded".
From 2019-01-04 to 2019-01-05 all tasks failed and the system state was "failed".
From 2019-01-06 to 2019-01-06 all tasks succeeded and the system state was "succeeded".

--solution :
/* Write your PL/SQL query statement below */

with temp as (
select 'failed' period_state, fail_date ed
 from failed where fail_date between '2019-01-01' and '2019-12-31'
union 
select 'succeeded' period_state, success_date 
 from succeeded where success_date between '2019-01-01' and '2019-12-31'
),
temp1 as ( select period_state,ed,
    ed - dense_rank() over(partition by period_state order by ed) flag 
  from temp )
select period_state,to_char(min(ed),'yyyy-mm-dd') start_date,
  to_char(max(ed),'yyyy-mm-dd') end_date
 from temp1 
group by period_state,flag
order by start_date
 
64. https://leetcode.com/problems/number-of-transactions-per-visit/ 

Number of Transactions per Visit

SQL Schema
Table: Visits

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user_id       | int     |
| visit_date    | date    |
+---------------+---------+
(user_id, visit_date) is the primary key for this table.
Each row of this table indicates that user_id has visited the bank in visit_date.
 

Table: Transactions

+------------------+---------+
| Column Name      | Type    |
+------------------+---------+
| user_id          | int     |
| transaction_date | date    |
| amount           | int     |
+------------------+---------+
There is no primary key for this table, it may contain duplicates.
Each row of this table indicates that user_id has done a transaction of amount in transaction_date.
It is guaranteed that the user has visited the bank in the transaction_date.(i.e The Visits table contains (user_id, transaction_date) in one row)
 

A bank wants to draw a chart of the number of transactions bank visitors did in one visit to the bank and the corresponding number of visitors who have done this number of transaction in one visit.

Write an SQL query to find how many users visited the bank and didnot do any transactions, how many visited the bank and did one transaction and so on.

The result table will contain two columns:

transactions_count which is the number of transactions done in one visit.
visits_count which is the corresponding number of users who did transactions_count in one visit to the bank.
transactions_count should take all values from 0 to max(transactions_count) done by one or more users.

Return the result table ordered by transactions_count.

The query result format is in the following example.

 

Example 1:


Input: 
Visits table:
+---------+------------+
| user_id | visit_date |
+---------+------------+
| 1       | 2020-01-01 |
| 2       | 2020-01-02 |
| 12      | 2020-01-01 |
| 19      | 2020-01-03 |
| 1       | 2020-01-02 |
| 2       | 2020-01-03 |
| 1       | 2020-01-04 |
| 7       | 2020-01-11 |
| 9       | 2020-01-25 |
| 8       | 2020-01-28 |
+---------+------------+
Transactions table:
+---------+------------------+--------+
| user_id | transaction_date | amount |
+---------+------------------+--------+
| 1       | 2020-01-02       | 120    |
| 2       | 2020-01-03       | 22     |
| 7       | 2020-01-11       | 232    |
| 1       | 2020-01-04       | 7      |
| 9       | 2020-01-25       | 33     |
| 9       | 2020-01-25       | 66     |
| 8       | 2020-01-28       | 1      |
| 9       | 2020-01-25       | 99     |
+---------+------------------+--------+
Output: 
+--------------------+--------------+
| transactions_count | visits_count |
+--------------------+--------------+
| 0                  | 4            |
| 1                  | 5            |
| 2                  | 0            |
| 3                  | 1            |
+--------------------+--------------+
Explanation: The chart drawn for this example is shown above.
* For transactions_count = 0, The visits (1, "2020-01-01"), (2, "2020-01-02"), (12, "2020-01-01") and (19, "2020-01-03") did no transactions so visits_count = 4.
* For transactions_count = 1, The visits (2, "2020-01-03"), (7, "2020-01-11"), (8, "2020-01-28"), (1, "2020-01-02") and (1, "2020-01-04") did one transaction so visits_count = 5.
* For transactions_count = 2, No customers visited the bank and did two transactions so visits_count = 0.
* For transactions_count = 3, The visit (9, "2020-01-25") did three transactions so visits_count = 1.
* For transactions_count >= 4, No customers visited the bank and did more than three transactions so we will stop at transactions_count = 3

--solution
/* Write your PL/SQL query statement below */

with temp1 as (
select transaction_date,user_id,count(1) transactions_count
 from Transactions
group by transaction_date,user_id
),
temp2 as ( select coalesce(transactions_count,0) transactions_count,
          count(visit_date) visits_count
  from Visits v 
   left join temp1 t on v.visit_date = t.transaction_date and v.user_id = t.user_id
  group by coalesce(transactions_count,0))
--this is to get the list of number of transactions (1,2,3,4, etc) until the max number of transactions from the prev cte
, cte_tran_cnt(cnt,max_cnt) as (
select 0 as cnt, max(transactions_count) as max_cnt
from temp2
 union all
 select cnt +1, max_cnt
 from cte_tran_cnt
 where cnt < max_cnt
 ) select cnt transactions_count,coalesce(visits_count,0) visits_count
   from cte_tran_cnt 
    left join temp2 on cte_tran_cnt.cnt = temp2.transactions_count
 order by cnt

 65. https://leetcode.com/problems/find-the-quiet-students-in-all-exams/submissions/
 
 Find the Quiet Students in All Exams

SQL Schema
Table: Student

+---------------------+---------+
| Column Name         | Type    |
+---------------------+---------+
| student_id          | int     |
| student_name        | varchar |
+---------------------+---------+
student_id is the primary key for this table.
student_name is the name of the student.
 

Table: Exam

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| exam_id       | int     |
| student_id    | int     |
| score         | int     |
+---------------+---------+
(exam_id, student_id) is the primary key for this table.
Each row of this table indicates that the student with student_id had a score points in the exam with id exam_id.
 

A quiet student is the one who took at least one exam and did not score the high or the low score.

Write an SQL query to report the students (student_id, student_name) being quiet in all exams. Do not return the student who has never taken any exam.

Return the result table ordered by student_id.

The query result format is in the following example.

 

Example 1:

Input: 
Student table:
+-------------+---------------+
| student_id  | student_name  |
+-------------+---------------+
| 1           | Daniel        |
| 2           | Jade          |
| 3           | Stella        |
| 4           | Jonathan      |
| 5           | Will          |
+-------------+---------------+
Exam table:
+------------+--------------+-----------+
| exam_id    | student_id   | score     |
+------------+--------------+-----------+
| 10         |     1        |    70     |
| 10         |     2        |    80     |
| 10         |     3        |    90     |
| 20         |     1        |    80     |
| 30         |     1        |    70     |
| 30         |     3        |    80     |
| 30         |     4        |    90     |
| 40         |     1        |    60     |
| 40         |     2        |    70     |
| 40         |     4        |    80     |
+------------+--------------+-----------+
Output: 
+-------------+---------------+
| student_id  | student_name  |
+-------------+---------------+
| 2           | Jade          |
+-------------+---------------+
Explanation: 
For exam 1: Student 1 and 3 hold the lowest and high scores respectively.
For exam 2: Student 1 hold both highest and lowest score.
For exam 3 and 4: Studnet 1 and 4 hold the lowest and high scores respectively.
Student 2 and 5 have never got the highest or lowest in any of the exams.
Since student 5 is not taking any exam, he is excluded from the result.
So, we only return the information of Student 2.

--solution
/* Write your PL/SQL query statement below */

with temp as (
    select exam_id,min(score) min_max
     from Exam 
    group by exam_id
    union all
   select exam_id,max(score) min_max
     from Exam 
    group by exam_id
),
temp2 as ( select 
   student_id 
  from Exam
  where (exam_id,score) not in (select exam_id,min_max from temp)
  
  MINUS
  
  select 
   student_id 
  from Exam
  where (exam_id,score) in (select exam_id,min_max from temp)
) select t.student_id,
         s.student_name
    from temp2 t
    inner join student s 
  on t.student_id = s.student_id
 order by 1

 66. https://leetcode.com/problems/sales-by-day-of-the-week/ 

Sales by Day of the Week

Table: Orders

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| order_id      | int     |
| customer_id   | int     |
| order_date    | date    | 
| item_id       | varchar |
| quantity      | int     |
+---------------+---------+
(ordered_id, item_id) is the primary key for this table.
This table contains information on the orders placed.
order_date is the date item_id was ordered by the customer with id customer_id.
 

Table: Items

+---------------------+---------+
| Column Name         | Type    |
+---------------------+---------+
| item_id             | varchar |
| item_name           | varchar |
| item_category       | varchar |
+---------------------+---------+
item_id is the primary key for this table.
item_name is the name of the item.
item_category is the category of the item.
 

You are the business owner and would like to obtain a sales report for category items and the day of the week.

Write an SQL query to report how many units in each category have been ordered on each day of the week.

Return the result table ordered by category.

The query result format is in the following example.

 

Example 1:

Input: 
Orders table:
+------------+--------------+-------------+--------------+-------------+
| order_id   | customer_id  | order_date  | item_id      | quantity    |
+------------+--------------+-------------+--------------+-------------+
| 1          | 1            | 2020-06-01  | 1            | 10          |
| 2          | 1            | 2020-06-08  | 2            | 10          |
| 3          | 2            | 2020-06-02  | 1            | 5           |
| 4          | 3            | 2020-06-03  | 3            | 5           |
| 5          | 4            | 2020-06-04  | 4            | 1           |
| 6          | 4            | 2020-06-05  | 5            | 5           |
| 7          | 5            | 2020-06-05  | 1            | 10          |
| 8          | 5            | 2020-06-14  | 4            | 5           |
| 9          | 5            | 2020-06-21  | 3            | 5           |
+------------+--------------+-------------+--------------+-------------+
Items table:
+------------+----------------+---------------+
| item_id    | item_name      | item_category |
+------------+----------------+---------------+
| 1          | LC Alg. Book   | Book          |
| 2          | LC DB. Book    | Book          |
| 3          | LC SmarthPhone | Phone         |
| 4          | LC Phone 2020  | Phone         |
| 5          | LC SmartGlass  | Glasses       |
| 6          | LC T-Shirt XL  | T-Shirt       |
+------------+----------------+---------------+
Output: 
+------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| Category   | Monday    | Tuesday   | Wednesday | Thursday  | Friday    | Saturday  | Sunday    |
+------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
| Book       | 20        | 5         | 0         | 0         | 10        | 0         | 0         |
| Glasses    | 0         | 0         | 0         | 0         | 5         | 0         | 0         |
| Phone      | 0         | 0         | 5         | 1         | 0         | 0         | 10        |
| T-Shirt    | 0         | 0         | 0         | 0         | 0         | 0         | 0         |
+------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+
Explanation: 
On Monday (2020-06-01, 2020-06-08) were sold a total of 20 units (10 + 10) in the category Book (ids: 1, 2).
On Tuesday (2020-06-02) were sold a total of 5 units in the category Book (ids: 1, 2).
On Wednesday (2020-06-03) were sold a total of 5 units in the category Phone (ids: 3, 4).
On Thursday (2020-06-04) were sold a total of 1 unit in the category Phone (ids: 3, 4).
On Friday (2020-06-05) were sold 10 units in the category Book (ids: 1, 2) and 5 units in Glasses (ids: 5).
On Saturday there are no items sold.
On Sunday (2020-06-14, 2020-06-21) were sold a total of 10 units (5 +5) in the category Phone (ids: 3, 4).
There are no sales of T-shirts.

--solution
/* Write your PL/SQL query statement below */

with temp as (
select o.*,trim(to_char(order_date,'DAY'))  day
 from Orders o
) select 
    i.item_category category,
    SUM(CASE WHEN DAY = 'MONDAY' THEN QUANTITY ELSE 0 END) AS "MONDAY",
    SUM(CASE WHEN DAY = 'TUESDAY' THEN QUANTITY ELSE 0 END) AS "TUESDAY",
    SUM(CASE WHEN DAY = 'WEDNESDAY' THEN QUANTITY ELSE 0 END) AS "WEDNESDAY",
    SUM(CASE WHEN DAY = 'THURSDAY' THEN QUANTITY ELSE 0 END) AS "THURSDAY",
    SUM(CASE WHEN DAY = 'FRIDAY' THEN QUANTITY ELSE 0 END) AS "FRIDAY",
    SUM(CASE WHEN DAY = 'SATURDAY' THEN QUANTITY ELSE 0 END) AS "SATURDAY",
    SUM(CASE WHEN DAY = 'SUNDAY' THEN QUANTITY ELSE 0 END) AS "SUNDAY"
 from 
  Items i left join temp t on i.item_id = t.item_id  
 group by i.item_category
 order by i.item_category

67. https://leetcode.com/problems/hopper-company-queries-i/ 

Hopper Company Queries I

SQL Schema
Table: Drivers

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| driver_id   | int     |
| join_date   | date    |
+-------------+---------+
driver_id is the primary key for this table.
Each row of this table contains the drivers ID and the date they joined the Hopper company.
 

Table: Rides

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| ride_id      | int     |
| user_id      | int     |
| requested_at | date    |
+--------------+---------+
ride_id is the primary key for this table.
Each row of this table contains the ID of a ride, the users ID that requested it, and the day they requested it.
There may be some ride requests in this table that were not accepted.
 

Table: AcceptedRides

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| ride_id       | int     |
| driver_id     | int     |
| ride_distance | int     |
| ride_duration | int     |
+---------------+---------+
ride_id is the primary key for this table.
Each row of this table contains some information about an accepted ride.
It is guaranteed that each accepted ride exists in the Rides table.
 

Write an SQL query to report the following statistics for each month of 2020:

The number of drivers currently with the Hopper company by the end of the month (active_drivers).
The number of accepted rides in that month (accepted_rides).
Return the result table ordered by month in ascending order, where month is the months number (January is 1, February is 2, etc.).

The query result format is in the following example.

 

Example 1:

Input: 
Drivers table:
+-----------+------------+
| driver_id | join_date  |
+-----------+------------+
| 10        | 2019-12-10 |
| 8         | 2020-1-13  |
| 5         | 2020-2-16  |
| 7         | 2020-3-8   |
| 4         | 2020-5-17  |
| 1         | 2020-10-24 |
| 6         | 2021-1-5   |
+-----------+------------+
Rides table:
+---------+---------+--------------+
| ride_id | user_id | requested_at |
+---------+---------+--------------+
| 6       | 75      | 2019-12-9    |
| 1       | 54      | 2020-2-9     |
| 10      | 63      | 2020-3-4     |
| 19      | 39      | 2020-4-6     |
| 3       | 41      | 2020-6-3     |
| 13      | 52      | 2020-6-22    |
| 7       | 69      | 2020-7-16    |
| 17      | 70      | 2020-8-25    |
| 20      | 81      | 2020-11-2    |
| 5       | 57      | 2020-11-9    |
| 2       | 42      | 2020-12-9    |
| 11      | 68      | 2021-1-11    |
| 15      | 32      | 2021-1-17    |
| 12      | 11      | 2021-1-19    |
| 14      | 18      | 2021-1-27    |
+---------+---------+--------------+
AcceptedRides table:
+---------+-----------+---------------+---------------+
| ride_id | driver_id | ride_distance | ride_duration |
+---------+-----------+---------------+---------------+
| 10      | 10        | 63            | 38            |
| 13      | 10        | 73            | 96            |
| 7       | 8         | 100           | 28            |
| 17      | 7         | 119           | 68            |
| 20      | 1         | 121           | 92            |
| 5       | 7         | 42            | 101           |
| 2       | 4         | 6             | 38            |
| 11      | 8         | 37            | 43            |
| 15      | 8         | 108           | 82            |
| 12      | 8         | 38            | 34            |
| 14      | 1         | 90            | 74            |
+---------+-----------+---------------+---------------+
Output: 
+-------+----------------+----------------+
| month | active_drivers | accepted_rides |
+-------+----------------+----------------+
| 1     | 2              | 0              |
| 2     | 3              | 0              |
| 3     | 4              | 1              |
| 4     | 4              | 0              |
| 5     | 5              | 0              |
| 6     | 5              | 1              |
| 7     | 5              | 1              |
| 8     | 5              | 1              |
| 9     | 5              | 0              |
| 10    | 6              | 0              |
| 11    | 6              | 2              |
| 12    | 6              | 1              |
+-------+----------------+----------------+
Explanation: 
By the end of January --> two active drivers (10, 8) and no accepted rides.
By the end of February --> three active drivers (10, 8, 5) and no accepted rides.
By the end of March --> four active drivers (10, 8, 5, 7) and one accepted ride (10).
By the end of April --> four active drivers (10, 8, 5, 7) and no accepted rides.
By the end of May --> five active drivers (10, 8, 5, 7, 4) and no accepted rides.
By the end of June --> five active drivers (10, 8, 5, 7, 4) and one accepted ride (13).
By the end of July --> five active drivers (10, 8, 5, 7, 4) and one accepted ride (7).
By the end of August --> five active drivers (10, 8, 5, 7, 4) and one accepted ride (17).
By the end of September --> five active drivers (10, 8, 5, 7, 4) and no accepted rides.
By the end of October --> six active drivers (10, 8, 5, 7, 4, 1) and no accepted rides.
By the end of November --> six active drivers (10, 8, 5, 7, 4, 1) and two accepted rides (20, 5).
By the end of December --> six active drivers (10, 8, 5, 7, 4, 1) and one accepted ride (2).

--solution1
/* Write your PL/SQL query statement below */
with cte(yr,month) as (
    select 2020,1 from dual 
     union all
    select 2020,month + 1 from cte 
    where month+1 <= 12
) ,
cte2 as (
select 
 coalesce(yr,to_number(to_char(join_date,'yyyy'))) yr,
 coalesce(month,to_number(to_char(join_date,'mm'))) month,
 driver_id
from cte c 
 full outer join Drivers d 
  on to_number(to_char(join_date,'mm')) = c.month
   and to_number(to_char(join_date,'yyyy')) = c.yr
) 
 select month,max(ad) active_drivers,count(distinct ad.ride_id) accepted_rides
  from ( select yr,month,count(driver_id) over(order by yr,month) ad
 from cte2 ) T
  left join Rides r on T.yr = to_number(to_char(requested_at,'yyyy'))
      and T.month = to_number(to_char(requested_at,'mm'))
  left outer join AcceptedRides ad on ad.ride_id = r.ride_id
 where yr = 2020
 group by yr,month
order by yr,month


--solution2 with edge cases missing 
/* Write your T-SQL query statement below */
with cte as (
    select min(join_date) join_date,max(join_date) join_date_max
     from Drivers
     union all
    select dateadd(month,1,join_date),join_date_max from cte
    where join_date < join_date_max
) ,
cte2 as ( select year(c.join_date) yr ,month(c.join_date) mn,driver_id
   from cte c
    left join drivers d 
     on year(c.join_date) = year(d.join_date)
      and month(c.join_date) = month(d.join_date)
) 
 select mn month,max(ad) active_drivers,count(ad.ride_id) accepted_rides
  from ( select yr,mn,count(driver_id) over( order by yr,mn) ad
  from cte2 ) T
  left join Rides r on T.yr = year(requested_at) and T.mn = month(requested_at)
  left outer join AcceptedRides ad on ad.ride_id = r.ride_id
 where T.yr = 2020
 group by yr,mn
  order by mn

68. https://leetcode.com/problems/hopper-company-queries-ii/ 

Hopper Company Queries II

Share
SQL Schema
Table: Drivers

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| driver_id   | int     |
| join_date   | date    |
+-------------+---------+
driver_id is the primary key for this table.
Each row of this table contains the drivers ID and the date they joined the Hopper company.
 

Table: Rides

+--------------+---------+
| Column Name  | Type    |
+--------------+---------+
| ride_id      | int     |
| user_id      | int     |
| requested_at | date    |
+--------------+---------+
ride_id is the primary key for this table.
Each row of this table contains the ID of a ride, the users ID that requested it, and the day they requested it.
There may be some ride requests in this table that were not accepted.
 

Table: AcceptedRides

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| ride_id       | int     |
| driver_id     | int     |
| ride_distance | int     |
| ride_duration | int     |
+---------------+---------+
ride_id is the primary key for this table.
Each row of this table contains some information about an accepted ride.
It is guaranteed that each accepted ride exists in the Rides table.
 

Write an SQL query to report the percentage of working drivers (working_percentage) for each month of 2020 where:


Note that if the number of available drivers during a month is zero, we consider the working_percentage to be 0.

Return the result table ordered by month in ascending order, where month is the months number (January is 1, February is 2, etc.). Round working_percentage to the nearest 2 decimal places.

The query result format is in the following example.

 

Example 1:

Input: 
Drivers table:
+-----------+------------+
| driver_id | join_date  |
+-----------+------------+
| 10        | 2019-12-10 |
| 8         | 2020-1-13  |
| 5         | 2020-2-16  |
| 7         | 2020-3-8   |
| 4         | 2020-5-17  |
| 1         | 2020-10-24 |
| 6         | 2021-1-5   |
+-----------+------------+
Rides table:
+---------+---------+--------------+
| ride_id | user_id | requested_at |
+---------+---------+--------------+
| 6       | 75      | 2019-12-9    |
| 1       | 54      | 2020-2-9     |
| 10      | 63      | 2020-3-4     |
| 19      | 39      | 2020-4-6     |
| 3       | 41      | 2020-6-3     |
| 13      | 52      | 2020-6-22    |
| 7       | 69      | 2020-7-16    |
| 17      | 70      | 2020-8-25    |
| 20      | 81      | 2020-11-2    |
| 5       | 57      | 2020-11-9    |
| 2       | 42      | 2020-12-9    |
| 11      | 68      | 2021-1-11    |
| 15      | 32      | 2021-1-17    |
| 12      | 11      | 2021-1-19    |
| 14      | 18      | 2021-1-27    |
+---------+---------+--------------+
AcceptedRides table:
+---------+-----------+---------------+---------------+
| ride_id | driver_id | ride_distance | ride_duration |
+---------+-----------+---------------+---------------+
| 10      | 10        | 63            | 38            |
| 13      | 10        | 73            | 96            |
| 7       | 8         | 100           | 28            |
| 17      | 7         | 119           | 68            |
| 20      | 1         | 121           | 92            |
| 5       | 7         | 42            | 101           |
| 2       | 4         | 6             | 38            |
| 11      | 8         | 37            | 43            |
| 15      | 8         | 108           | 82            |
| 12      | 8         | 38            | 34            |
| 14      | 1         | 90            | 74            |
+---------+-----------+---------------+---------------+
Output: 
+-------+--------------------+
| month | working_percentage |
+-------+--------------------+
| 1     | 0.00               |
| 2     | 0.00               |
| 3     | 25.00              |
| 4     | 0.00               |
| 5     | 0.00               |
| 6     | 20.00              |
| 7     | 20.00              |
| 8     | 20.00              |
| 9     | 0.00               |
| 10    | 0.00               |
| 11    | 33.33              |
| 12    | 16.67              |
+-------+--------------------+
Explanation: 
By the end of January --> two active drivers (10, 8) and no accepted rides. The percentage is 0%.
By the end of February --> three active drivers (10, 8, 5) and no accepted rides. The percentage is 0%.
By the end of March --> four active drivers (10, 8, 5, 7) and one accepted ride by driver (10). The percentage is (1 / 4) * 100 = 25%.
By the end of April --> four active drivers (10, 8, 5, 7) and no accepted rides. The percentage is 0%.
By the end of May --> five active drivers (10, 8, 5, 7, 4) and no accepted rides. The percentage is 0%.
By the end of June --> five active drivers (10, 8, 5, 7, 4) and one accepted ride by driver (10). The percentage is (1 / 5) * 100 = 20%.
By the end of July --> five active drivers (10, 8, 5, 7, 4) and one accepted ride by driver (8). The percentage is (1 / 5) * 100 = 20%.
By the end of August --> five active drivers (10, 8, 5, 7, 4) and one accepted ride by driver (7). The percentage is (1 / 5) * 100 = 20%.
By the end of September --> five active drivers (10, 8, 5, 7, 4) and no accepted rides. The percentage is 0%.
By the end of October --> six active drivers (10, 8, 5, 7, 4, 1) and no accepted rides. The percentage is 0%.
By the end of November --> six active drivers (10, 8, 5, 7, 4, 1) and two accepted rides by two different drivers (1, 7). The percentage is (2 / 6) * 100 = 33.33%.
By the end of December --> six active drivers (10, 8, 5, 7, 4, 1) and one accepted ride by driver (4). The percentage is (1 / 6) * 100 = 16.67%.

--solution
/* Write your PL/SQL query statement below */

with cte(yr,month) as (
    select 2020,1 from dual 
     union all
    select 2020,month + 1 from cte 
    where month+1 <= 12
) ,
cte2 as (
select 
 coalesce(yr,to_number(to_char(join_date,'yyyy'))) yr,
 coalesce(month,to_number(to_char(join_date,'mm'))) month,
 driver_id
from cte c 
 full outer join Drivers d 
  on to_number(to_char(join_date,'mm')) = c.month
   and to_number(to_char(join_date,'yyyy')) = c.yr
) 
 select month,
  case when max(ad) = 0 then 0 
       else round((count(distinct ad.driver_id)/max(ad) * 100),2) 
   end
   working_percentage
  from ( select yr,month,count(driver_id) over(order by yr,month) ad
 from cte2 ) T
  left join Rides r on T.yr = to_number(to_char(requested_at,'yyyy'))
      and T.month = to_number(to_char(requested_at,'mm'))
  left outer join AcceptedRides ad on ad.ride_id = r.ride_id
 where yr = 2020
 group by yr,month
 order by yr,month

69. https://leetcode.com/problems/find-the-subtasks-that-did-not-execute/ 

Find the Subtasks That Did Not Execute

Hard

Table: Tasks

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| task_id        | int     |
| subtasks_count | int     |
+----------------+---------+
task_id is the primary key for this table.
Each row in this table indicates that task_id was divided into subtasks_count subtasks labeled from 1 to subtasks_count.
It is guaranteed that 2 <= subtasks_count <= 20.
 

Table: Executed

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| task_id       | int     |
| subtask_id    | int     |
+---------------+---------+
(task_id, subtask_id) is the primary key for this table.
Each row in this table indicates that for the task task_id, the subtask with ID subtask_id was executed successfully.
It is guaranteed that subtask_id <= subtasks_count for each task_id.
 

Write an SQL query to report the IDs of the missing subtasks for each task_id.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Tasks table:
+---------+----------------+
| task_id | subtasks_count |
+---------+----------------+
| 1       | 3              |
| 2       | 2              |
| 3       | 4              |
+---------+----------------+
Executed table:
+---------+------------+
| task_id | subtask_id |
+---------+------------+
| 1       | 2          |
| 3       | 1          |
| 3       | 2          |
| 3       | 3          |
| 3       | 4          |
+---------+------------+
Output: 
+---------+------------+
| task_id | subtask_id |
+---------+------------+
| 1       | 1          |
| 1       | 3          |
| 2       | 1          |
| 2       | 2          |
+---------+------------+
Explanation: 
Task 1 was divided into 3 subtasks (1, 2, 3). Only subtask 2 was executed successfully, so we include (1, 1) and (1, 3) in the answer.
Task 2 was divided into 2 subtasks (1, 2). No subtask was executed successfully, so we include (2, 1) and (2, 2) in the answer.
Task 3 was divided into 4 subtasks (1, 2, 3, 4). All of the subtasks were executed successfully.

--solution
/* Write your PL/SQL query statement below */

with cte(tid,stid,max_stid) as (
    select task_id,1,subtasks_count from Tasks
    union all
    select tid,stid + 1,max_stid from cte 
    where stid < max_stid
) select tid task_id ,stid subtask_id from cte c 
  where not exists (
      select 1 from Executed e 
       where e.task_id=c.tid and e.subtask_id=c.stid
  )
order by tid,stid

70. https://leetcode.com/problems/page-recommendations-ii/ 

Page Recommendations II

SQL Schema
Table: Friendship

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| user1_id      | int     |
| user2_id      | int     |
+---------------+---------+
(user1_id, user2_id) is the primary key for this table.
Each row of this table indicates that the users user1_id and user2_id are friends.
 

Table: Likes

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| user_id     | int     |
| page_id     | int     |
+-------------+---------+
(user_id, page_id) is the primary key for this table.
Each row of this table indicates that user_id likes page_id.
 

You are implementing a page recommendation system for a social media website. Your system will recommended a page to user_id if the page is liked by at least one friend of user_id and is not liked by user_id.

Write an SQL query to find all the possible page recommendations for every user. Each recommendation should appear as a row in the result table with these columns:

user_id: The ID of the user that your system is making the recommendation to.
page_id: The ID of the page that will be recommended to user_id.
friends_likes: The number of the friends of user_id that like page_id.
Return result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Friendship table:
+----------+----------+
| user1_id | user2_id |
+----------+----------+
| 1        | 2        |
| 1        | 3        |
| 1        | 4        |
| 2        | 3        |
| 2        | 4        |
| 2        | 5        |
| 6        | 1        |
+----------+----------+
Likes table:
+---------+---------+
| user_id | page_id |
+---------+---------+
| 1       | 88      |
| 2       | 23      |
| 3       | 24      |
| 4       | 56      |
| 5       | 11      |
| 6       | 33      |
| 2       | 77      |
| 3       | 77      |
| 6       | 88      |
+---------+---------+
Output: 
+---------+---------+---------------+
| user_id | page_id | friends_likes |
+---------+---------+---------------+
| 1       | 77      | 2             |
| 1       | 23      | 1             |
| 1       | 24      | 1             |
| 1       | 56      | 1             |
| 1       | 33      | 1             |
| 2       | 24      | 1             |
| 2       | 56      | 1             |
| 2       | 11      | 1             |
| 2       | 88      | 1             |
| 3       | 88      | 1             |
| 3       | 23      | 1             |
| 4       | 88      | 1             |
| 4       | 77      | 1             |
| 4       | 23      | 1             |
| 5       | 77      | 1             |
| 5       | 23      | 1             |
+---------+---------+---------------+
Explanation: 
Take user 1 as an example:
  - User 1 is friends with users 2, 3, 4, and 6.
  - Recommended pages are 23 (user 2 liked it), 24 (user 3 liked it), 56 (user 3 liked it), 33 (user 6 liked it), and 77 (user 2 and user 3 liked it).
  - Note that page 88 is not recommended because user 1 already liked it.

Another example is user 6:
  - User 6 is friends with user 1.
  - User 1 only liked page 88, but user 6 already liked it. Hence, user 6 has no recommendations.

You can recommend pages for users 2, 3, 4, and 5 using a similar process.

--solution
with frnd(f1,f2) as (
    select user1_id,user2_id from Friendship 
    union
    select user2_id,user1_id from Friendship 
) select f1 user_id,page_id,count(page_id) friends_likes
   from frnd f 
    inner join Likes l on f.f2=l.user_id
   where (f1,page_id) not in (select user_id,page_id from Likes)
   group by f1,page_id

71. https://leetcode.com/problems/leetcodify-similar-friends/ 

Leetcodify Similar Friends

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
 

Write an SQL query to report the similar friends of Leetcodify users. A user x and user y are similar friends if:

Users x and y are friends, and
Users x and y listened to the same three or more different songs on the same day.
Return the result table in any order. Note that you must return the similar pairs of friends the same way they were represented in the input (i.e., always user1_id < user2_id).

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
| 2        | 4        |
| 2        | 5        |
+----------+----------+
Output: 
+----------+----------+
| user1_id | user2_id |
+----------+----------+
| 1        | 2        |
+----------+----------+
Explanation: 
Users 1 and 2 are friends, and they listened to songs 10, 11, and 12 on the same day. They are similar friends.
Users 1 and 3 listened to songs 10, 11, and 12 on the same day, but they are not friends.
Users 2 and 4 are friends, but they did not listen to the same three different songs.
Users 2 and 5 are friends and listened to songs 10, 11, and 12, but they did not listen to them on the same day.

--solution
/* Write your PL/SQL query statement below */

select 
 distinct user1_id,user2_id
from Friendship f
 inner join Listens l1 on l1.user_id = f.user1_id
 inner join Listens l2 on l2.user_id = f.user2_id
where l1.song_id = l2.song_id and l1.day=l2.day
group by user1_id,user2_id,l1.day
having count(distinct l1.song_id) >= 3

72. https://leetcode.com/problems/first-and-last-call-on-the-same-day/ 

First and Last Call On the Same Day

SQL Schema
Table: Calls

+--------------+----------+
| Column Name  | Type     |
+--------------+----------+
| caller_id    | int      |
| recipient_id | int      |
| call_time    | datetime |
+--------------+----------+
(caller_id, recipient_id, call_time) is the primary key for this table.
Each row contains information about the time of a phone call between caller_id and recipient_id.
 

Write an SQL query to report the IDs of the users whose first and last calls on any day were with the same person. Calls are counted regardless of being the caller or the recipient.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Calls table:
+-----------+--------------+---------------------+
| caller_id | recipient_id | call_time           |
+-----------+--------------+---------------------+
| 8         | 4            | 2021-08-24 17:46:07 |
| 4         | 8            | 2021-08-24 19:57:13 |
| 5         | 1            | 2021-08-11 05:28:44 |
| 8         | 3            | 2021-08-17 04:04:15 |
| 11        | 3            | 2021-08-17 13:07:00 |
| 8         | 11           | 2021-08-17 22:22:22 |
+-----------+--------------+---------------------+
Output: 
+---------+
| user_id |
+---------+
| 1       |
| 4       |
| 5       |
| 8       |
+---------+
Explanation: 
On 2021-08-24, the first and last call of this day for user 8 was with user 4. User 8 should be included in the answer.
Similarly, user 4 on 2021-08-24 had their first and last call with user 8. User 4 should be included in the answer.
On 2021-08-11, user 1 and 5 had a call. This call was the only call for both of them on this day. Since this call is the first and last call of the day for both of them, they should both be included in the answer.

--solution:
/* Write your PL/SQL query statement below */
with temp as ( -- both caller and recepient as users
    select caller_id,recipient_id,call_time from calls 
     union
    select recipient_id,caller_id,call_time from calls 
),
temp2 as ( --first and last call of all the users call of the day
    select caller_id,min(call_time) ft ,max(call_time) lt
   from temp 
  group by caller_id,to_char(call_time,'yyyy-mm-dd')
) 
,
temp3 as ( --caller and recipient of all the first and last call of the day
    select caller_id,recipient_id,call_time
 from temp 
 where (caller_id,call_time) in (select caller_id,ft from temp2)
 
 union all
 
 select caller_id ,recipient_id,call_time
 from temp 
 where (caller_id,call_time) in (select caller_id,lt from temp2)
  ) --count number of distinct recipeint for one user per day that should be 1(same recipient) because now we have only two calls first and last at this point.
  select distinct caller_id user_id
   from temp3
   group by caller_id,to_char(call_time,'yyyy-mm-dd')
   having count(distinct recipient_id) = 1 


73. https://leetcode.com/problems/the-number-of-seniors-and-juniors-to-join-the-company/ 
The Number of Seniors and Juniors to Join the Company

SQL Schema
Table: Candidates

+-------------+------+
| Column Name | Type |
+-------------+------+
| employee_id | int  |
| experience  | enum |
| salary      | int  |
+-------------+------+
employee_id is the primary key column for this table.
experience is an enum with one of the values ('Senior', 'Junior').
Each row of this table indicates the id of a candidate, their monthly salary, and their experience.
 

A company wants to hire new employees. The budget of the company for the salaries is $70000. The companys criteria for hiring are:

Hiring the largest number of seniors.
After hiring the maximum number of seniors, use the remaining budget to hire the largest number of juniors.
Write an SQL query to find the number of seniors and juniors hired under the mentioned criteria.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 10000  |
| 9           | Junior     | 10000  |
| 2           | Senior     | 20000  |
| 11          | Senior     | 20000  |
| 13          | Senior     | 50000  |
| 4           | Junior     | 40000  |
+-------------+------------+--------+
Output: 
+------------+---------------------+
| experience | accepted_candidates |
+------------+---------------------+
| Senior     | 2                   |
| Junior     | 2                   |
+------------+---------------------+
Explanation: 
We can hire 2 seniors with IDs (2, 11). Since the budget is $70000 and the sum of their salaries is $40000, we still have $30000 but they are not enough to hire the senior candidate with ID 13.
We can hire 2 juniors with IDs (1, 9). Since the remaining budget is $30000 and the sum of their salaries is $20000, we still have $10000 but they are not enough to hire the junior candidate with ID 4.
Example 2:

Input: 
Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 10000  |
| 9           | Junior     | 10000  |
| 2           | Senior     | 80000  |
| 11          | Senior     | 80000  |
| 13          | Senior     | 80000  |
| 4           | Junior     | 40000  |
+-------------+------------+--------+
Output: 
+------------+---------------------+
| experience | accepted_candidates |
+------------+---------------------+
| Senior     | 0                   |
| Junior     | 3                   |
+------------+---------------------+
Explanation: 
We cannot hire any seniors with the current budget as we need at least $80000 to hire one senior.
We can hire all three juniors with the remaining budget.

--solution
/* Write your PL/SQL query statement below */
with S as ( -- adding maximum number of seniors till 70000
select experience,count(employee_id) ac ,max(total_sal) maxSal
from ( 
    select 
        experience,employee_id,sum(salary) over(order by salary,employee_id) total_sal
    from Candidates where experience = 'Senior'
    union all
    select 'Senior',NULL,0 from dual -- in case 0 senior
) where total_sal <=70000
group by experience
),
J as ( -- adding maximum number of juniors till 70000 - sum(of seniors)
select T.experience,count(T.employee_id) accepted_candidates
from ( 
    select 
        experience,employee_id,sum(salary) over(order by salary,employee_id) total_sal
    from Candidates where experience = 'Junior'
        union all
    select 'Junior',NULL,0 from dual -- in case 0 junior
) T full outer join S on 1=1  
where T.total_sal <= 70000 - S.maxSal
group by T.experience )
select experience,ac accepted_candidates from S
union all
select experience,accepted_candidates from J

74. https://leetcode.com/problems/the-number-of-seniors-and-juniors-to-join-the-company-ii/ 

The Number of Seniors and Juniors to Join the Company II

Table: Candidates

+-------------+------+
| Column Name | Type |
+-------------+------+
| employee_id | int  |
| experience  | enum |
| salary      | int  |
+-------------+------+
employee_id is the primary key column for this table.
experience is an enum with one of the values ('Senior', 'Junior').
Each row of this table indicates the id of a candidate, their monthly salary, and their experience.
The salary of each candidate is guaranteed to be unique.
 

A company wants to hire new employees. The budget of the company for the salaries is $70000. The companys criteria for hiring are:

Keep hiring the senior with the smallest salary until you cannot hire any more seniors.
Use the remaining budget to hire the junior with the smallest salary.
Keep hiring the junior with the smallest salary until you cannot hire any more juniors.
Write an SQL query to find the ids of seniors and juniors hired under the mentioned criteria.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input:
Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 10000  |
| 9           | Junior     | 15000  |
| 2           | Senior     | 20000  |
| 11          | Senior     | 16000  |
| 13          | Senior     | 50000  |
| 4           | Junior     | 40000  |
+-------------+------------+--------+
Output: 
+-------------+
| employee_id |
+-------------+
| 11          |
| 2           |
| 1           |
| 9           |
+-------------+
Explanation: 
We can hire 2 seniors with IDs (11, 2). Since the budget is $70000 and the sum of their salaries is $36000, we still have $34000 but they are not enough to hire the senior candidate with ID 13.
We can hire 2 juniors with IDs (1, 9). Since the remaining budget is $34000 and the sum of their salaries is $25000, we still have $9000 but they are not enough to hire the junior candidate with ID 4.
Example 2:

Input:
Candidates table:
+-------------+------------+--------+
| employee_id | experience | salary |
+-------------+------------+--------+
| 1           | Junior     | 25000  |
| 9           | Junior     | 10000  |
| 2           | Senior     | 85000  |
| 11          | Senior     | 80000  |
| 13          | Senior     | 90000  |
| 4           | Junior     | 30000  |
+-------------+------------+--------+
Output: 
+-------------+
| employee_id |
+-------------+
| 9           |
| 1           |
| 4           |
+-------------+
Explanation: 
We cannot hire any seniors with the current budget as we need at least $80000 to hire one senior.
We can hire all three juniors with the remaining budget.

--solution
with S as ( -- adding maximum number of seniors till 70000
select employee_id,total_sal
from ( 
    select 
        employee_id,sum(salary) over(order by salary,employee_id) total_sal
    from Candidates where experience = 'Senior'
) where total_sal <=70000
),
J as ( -- adding maximum number of juniors till 70000 - sum(of seniors)
select T.employee_id 
from ( 
    select 
        employee_id,sum(salary) over(order by salary) total_sal
    from Candidates where experience = 'Junior'

) T 
where T.total_sal <= 70000 - (select coalesce(max(total_sal),0) from S))
 select employee_id from S
 union all
 select employee_id from J

 75. 
--find largest order by value for each person and order details 
-- without subquery , cte , window function , temp table 

drop table int_orders;
CREATE TABLE int_orders(
 order_number number NOT NULL,
 order_date date NOT NULL,
 cust_id number NOT NULL,
 salesperson_id number NOT NULL,
 amount number NOT NULL
);

alter session set NLS_DATE_FORMAT='yyyy-mm-dd';

INSERT INTO int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (30, '1995-07-14', 9, 1, 460);

INSERT into int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (10, '1996-08-02' , 4, 2, 540);

INSERT INTO int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (40, '1998-01-29' , 7, 2, 2400);

INSERT INTO int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (50, '1998-02-03' , 6, 7, 600);

INSERT into int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (60, '1998-03-02' , 6, 7, 720);

INSERT into int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (70, '1998-05-06' , 9, 7, 150);

INSERT into int_orders (order_number, order_date, cust_id, salesperson_id, amount) VALUES (20, '1999-01-30' , 4, 8, 1800);

commit;

--solution
--all largers except smallest 
select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id and a.amount >= b.amount
 MINUS
 --all smallers except largest
 select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id and a.amount < b.amount


ORDER_NUMBER ORDER_DATE    CUST_ID SALESPERSON_ID     AMOUNT
------------ ---------- ---------- -------------- ----------
	  30 1995-07-14 	 9		1	 460
	  20 1999-01-30 	 4		8	1800
	  40 1998-01-29 	 7		2	2400
	  60 1998-03-02 	 6		7	 720

SQL>

--solution2
select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id
 group by a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 having(a.amount >= max(b.amount))

 ORDER_NUMBER ORDER_DATE    CUST_ID SALESPERSON_ID     AMOUNT
------------ ---------- ---------- -------------- ----------
	  30 1995-07-14 	 9		1	 460
	  40 1998-01-29 	 7		2	2400
	  60 1998-03-02 	 6		7	 720
	  20 1999-01-30 	 4		8	1800

--solution3
--full table
select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 MINUS
 --all smallers except largest
 select a.ORDER_NUMBER,a.ORDER_DATE,a.CUST_ID,a.SALESPERSON_ID,a.AMOUNT
 from int_orders a
 inner join int_orders b on a.salesperson_id=b.salesperson_id and a.amount < b.amount


76. https://leetcode.com/problems/monthly-transactions-ii/ 

 Monthly Transactions II

Table: Transactions

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| id             | int     |
| country        | varchar |
| state          | enum    |
| amount         | int     |
| trans_date     | date    |
+----------------+---------+
id is the primary key of this table.
The table has information about incoming transactions.
The state column is an enum of type ["approved", "declined"].
Table: Chargebacks

+----------------+---------+
| Column Name    | Type    |
+----------------+---------+
| trans_id       | int     |
| trans_date     | date    |
+----------------+---------+
Chargebacks contains basic information regarding incoming chargebacks from some transactions placed in Transactions table.
trans_id is a foreign key to the id column of Transactions table.
Each chargeback corresponds to a transaction made previously even if they were not approved.
 

Write an SQL query to find for each month and country: the number of approved transactions and their total amount, the number of chargebacks, and their total amount.

Note: In your query, given the month and country, ignore rows with all zeros.

Return the result table in any order.

The query result format is in the following example.

 

Example 1:

Input: 
Transactions table:
+-----+---------+----------+--------+------------+
| id  | country | state    | amount | trans_date |
+-----+---------+----------+--------+------------+
| 101 | US      | approved | 1000   | 2019-05-18 |
| 102 | US      | declined | 2000   | 2019-05-19 |
| 103 | US      | approved | 3000   | 2019-06-10 |
| 104 | US      | declined | 4000   | 2019-06-13 |
| 105 | US      | approved | 5000   | 2019-06-15 |
+-----+---------+----------+--------+------------+
Chargebacks table:
+----------+------------+
| trans_id | trans_date |
+----------+------------+
| 102      | 2019-05-29 |
| 101      | 2019-06-30 |
| 105      | 2019-09-18 |
+----------+------------+
Output: 
+---------+---------+----------------+-----------------+------------------+-------------------+
| month   | country | approved_count | approved_amount | chargeback_count | chargeback_amount |
+---------+---------+----------------+-----------------+------------------+-------------------+
| 2019-05 | US      | 1              | 1000            | 1                | 2000              |
| 2019-06 | US      | 2              | 8000            | 1                | 1000              |
| 2019-09 | US      | 0              | 0               | 1                | 5000              |
+---------+---------+----------------+-----------------+------------------+-------------------+

--solution
/* Write your PL/SQL query statement below */

with chargeback as (
select to_char(c.trans_date,'yyyy-mm') cmonth,t.country,
  sum(t.amount) c_amount,count(1) chargeback_count
 from Chargebacks c 
 inner join Transactions t on t.id=c.trans_id
group by to_char(c.trans_date,'yyyy-mm'),t.country
),--select * from chargeback
txn as (
    select to_char(t.trans_date,'yyyy-mm') tmonth,t.country,
  sum(t.amount) approved_amount,count(1) approved_count 
 from Transactions t
 where state = 'approved'
group by to_char(t.trans_date,'yyyy-mm'),t.country
) 
select coalesce(t.tmonth,c.cmonth) month,
       coalesce(t.country,c.country) country,
       coalesce(approved_count,0) approved_count,
       coalesce(approved_amount,0) approved_amount,
       coalesce(c.chargeback_count,0) chargeback_count,
       coalesce(c.c_amount,0) chargeback_amount
 from chargeback c 
full outer join  txn t on t.tmonth = c.cmonth and t.country = c.country


77. https://leetcode.com/problems/team-scores-in-football-tournament/ 

Team Scores in Football Tournament

Table: Teams

+---------------+----------+
| Column Name   | Type     |
+---------------+----------+
| team_id       | int      |
| team_name     | varchar  |
+---------------+----------+
team_id is the primary key of this table.
Each row of this table represents a single football team.
 

Table: Matches

+---------------+---------+
| Column Name   | Type    |
+---------------+---------+
| match_id      | int     |
| host_team     | int     |
| guest_team    | int     | 
| host_goals    | int     |
| guest_goals   | int     |
+---------------+---------+
match_id is the primary key of this table.
Each row is a record of a finished match between two different teams. 
Teams host_team and guest_team are represented by their IDs in the Teams table (team_id), and they scored host_goals and guest_goals goals, respectively.
 

You would like to compute the scores of all teams after all matches. Points are awarded as follows:
A team receives three points if they win a match (i.e., Scored more goals than the opponent team).
A team receives one point if they draw a match (i.e., Scored the same number of goals as the opponent team).
A team receives no points if they lose a match (i.e., Scored fewer goals than the opponent team).
Write an SQL query that selects the team_id, team_name and num_points of each team in the tournament after all described matches.

Return the result table ordered by num_points in decreasing order. In case of a tie, order the records by team_id in increasing order.

The query result format is in the following example.

 

Example 1:

Input: 
Teams table:
+-----------+--------------+
| team_id   | team_name    |
+-----------+--------------+
| 10        | Leetcode FC  |
| 20        | NewYork FC   |
| 30        | Atlanta FC   |
| 40        | Chicago FC   |
| 50        | Toronto FC   |
+-----------+--------------+
Matches table:
+------------+--------------+---------------+-------------+--------------+
| match_id   | host_team    | guest_team    | host_goals  | guest_goals  |
+------------+--------------+---------------+-------------+--------------+
| 1          | 10           | 20            | 3           | 0            |
| 2          | 30           | 10            | 2           | 2            |
| 3          | 10           | 50            | 5           | 1            |
| 4          | 20           | 30            | 1           | 0            |
| 5          | 50           | 30            | 1           | 0            |
+------------+--------------+---------------+-------------+--------------+
Output: 
+------------+--------------+---------------+
| team_id    | team_name    | num_points    |
+------------+--------------+---------------+
| 10         | Leetcode FC  | 7             |
| 20         | NewYork FC   | 3             |
| 50         | Toronto FC   | 3             |
| 30         | Atlanta FC   | 1             |
| 40         | Chicago FC   | 0             |
+------------+--------------+---------------+

--solution
with temp as (
select
 host_team team_id,3 pnts
from Matches where host_goals > guest_goals
union all
select
 guest_team,3 pnts
from Matches where host_goals < guest_goals
union all
select
 guest_team,1 pnts
from Matches where host_goals=guest_goals
union all
select
 host_team,1 pnts
from Matches where host_goals=guest_goals
) select Teams.team_id team_id,team_name,sum(coalesce(pnts,0)) num_points
  from Teams left join 
   temp on Teams.team_id = temp.team_id
 group by Teams.team_id,team_name
 order by num_points desc,Teams.team_id

--solution 2
/* Write your PL/SQL query statement below */

with temp as (
select
 host_team team_id,
 case 
    when host_goals > guest_goals then 3
   when host_goals < guest_goals then 0
   else 1
 end as pnts
from Matches
union all
select
 guest_team team_id,
 case 
    when host_goals < guest_goals then 3
    when host_goals > guest_goals then 0
    else 1 
 end as pnts
from Matches
) --select * from temp
select Teams.team_id team_id,team_name,sum(coalesce(pnts,0)) num_points
  from Teams left join 
   temp on Teams.team_id = temp.team_id
 group by Teams.team_id,team_name
 order by num_points desc,Teams.team_id

 
