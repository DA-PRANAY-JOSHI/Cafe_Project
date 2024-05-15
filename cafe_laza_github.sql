USE CAFE_LAZA;

#Following is the problem statement?

/*The café owner, Mr. Ayush, is dissatisfied with his café business because he feels
he puts too much effort and time but doesn't receive good amount of orders
however, he is not incurring losses and wants to open his café only when
he is getting a good amount of orders also he want to know the best timestamp*/ 
  

#FOLLOWING ARE THE APPROACHES TO SOLVE THIS PROBLEM.
/*what were the top 5 revenue dates?
what are the top 5 dates by orders_quantity?
average time of top 10 order quantities?
average time of bottom 10 order quantities?
At which week did the cafe have the most sales?
At which week did the cafe have the most order quantities?
what was the average time of the week with the maximum sales?
at what time does the cafe usually have orders more than average?*/   


use cafe_laza;
select * from orders;
select * from amounts;


#removing redendcies from orders_table
create view orders_view as(
select `invoice no.`,`date`from orders);

#removing redendencies from amounts
create view amounts_view as(
select `Invoice no.`,my_amount from amounts);

#checking the null values orders table
select count(case when date is null then `invoice no.` end)as date_nulls from orders_view;

#checking the null values in amounts table
select count(my_amount)as my_amount_null from amounts_view
where my_amount is null;


#what were the top 10 revenue dates?

select sum(my_amount) total_revenue,date(date) as date,dense_rank()over(order by sum(my_amount)desc) as ranks
from orders_view
inner join amounts_view on orders_view.`invoice no.`=amounts_view.`invoice no.`
group by date
limit 10;




#what are the top 5 dates by orders_quantity?
select date(date) as date,
count(date(date)) as day_wise_quantity,dense_rank()over(order by count(date(date)) desc) as ranks
from orders_view
group by date(date)
limit 5;


#average time_hour of top 10 order quantities?
with common_table as(
select *, date_format(date,"%Y %M %d") dt,date(date) as Dates,hour(time(date)) as hours
from orders_view)
,common_2 as(
select dates,count(dates) quantity,round(avg(hours)) as Avg_Time_Hour
from common_table
group by Dates
order by count(dates) desc
limit 10)
select round(avg(Avg_time_hour)) as Avg_Time
from common_2;

#average time of bottom 10 order quantities?
with common_table as(
select *, date_format(date,"%Y %M %d") dt,date(date) as Dates,hour(time(date)) as hours
from orders_view)
,common_2 as(
select dates,count(dates) quantity,round(avg(hours)) as Avg_Time_Hour
from common_table
group by Dates
order by count(dates) asc
limit 10)
select round(avg(Avg_time_hour)) as Avg_Time
from common_2;


#At which week did the cafe have the most sales?
with common as(
  select 
    amounts_view.`invoice no.`, 
    my_amount, 
    date, 
    day(date) as days 
  from 
    orders_view 
    inner join amounts_view on orders_view.`Invoice No.` = amounts_view.`invoice no.` 
  order by 
    orders_view.`invoice no.`
), 
common_2 as(
  select 
    *, 
    case when days between 1 
    and 7 then 1 when days between 8 
    and 14 then 2 when days between 15 
    and 21 then 3 when days between 21 
    and 28 then 4 else 5 end as weeks 
  from 
    common
) 
select 
  sum(my_amount) as week_total, 
  weeks 
from 
  common_2 
group by 
  weeks 
order by 
  week_total desc 
limit 
  1;

    
 #At which week did the cafe have the most order quantities?   
with common as(
  select 
    date(date) as dates, 
    my_amount, 
    case when day(date) between 1 
    and 7 then 1 when day(date) between 8 
    and 14 then 2 when day(date) between 15 
    and 21 then 3 when day(date) between 22 
    and 28 then 4 when day(date) between 28 
    and 31 then 5 else null end as weeks 
  from 
    orders_view 
    join amounts_view on orders_view.`invoice no.` = amounts_view.`invoice no.`
) 
select 
  count(*) as quantity, 
  weeks as week 
from 
  common 
group by 
  weeks 
order by 
  count(*) desc 
limit 
  1;

#what was the average time of the week with the maximum sales?
with common as(
  select 
    sum(my_amount) totals, 
    avg(
      hour(
        time(date)
      )
    ) as avg_time_hour, 
    day(
      date(date)
    ) day 
  from 
    amounts_view 
    join orders_view on amounts_view.`invoice no.` = orders_view.`invoice no.` 
  group by 
    day(
      date(date)
    )
), 
common_2 as(
  select 
    *, 
    case when day between 1 
    and 7 then 1 when day between 8 
    and 14 then 
    2 when day between 15 
    and 21 then 3 when day between 22 
    and 28 then 4 when day between 29 
    and 31 then 5 else null end as weeks 
  from 
    common
) 
select 
  sum(totals) as max_totals, 
  weeks, 
  avg(avg_time_hour) avg_time_hour 
from 
  common_2 
group by 
  weeks 
order by 
  sum(totals) desc 
limit 
  1;
  
  
#hOW DOES THE TREND of order_quantity and total of each day LOOK LIKE IN WHOLE MONTH.

SELECT 
    DATE(date) date,
    COUNT(DISTINCT `invoice no.`) AS Trend_eachday_quantity,
    SUM(my_amount) AS total_trend
FROM
    orders_view
        INNER JOIN
    amounts_view USING (`invoice no.`)
GROUP BY DATE(date)
ORDER BY DATE(date);

#Date of minimum total_amount AND TOTAL_AMOUNT from every week ..
with common as(
select date(date) as date, sum(my_amount) as total
from amounts_view inner join orders_view using(`invoice no.`)
group by date(date)
order by date(date))
, common_2 as(
select *,ceil(day(date)/7) as weeks  from common)
,common_3 as(
select * from common_2
where total in (select min(total) from common_2
group by weeks))
,common_4 as(
select *, dayname(date)as days
from common_3)

select TOTAL,ifnull(date,0)as date from common_4
WHERE TOTAL != 10;
 
