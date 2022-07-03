#Setup

#Creating database and column
#Then we import values fromm csv files

create database if not exists Business;
use Business;
CREATE table if not exists ease(
country_code VARCHAR(10),
YR2015 float,
YR2016 float,
YR2017 float,
YR2018 float,
YR2019 float,
average_ease float);
CREATE table if not exists cost(
country_code VARCHAR(10),
YR2015 float,
YR2016 float,
YR2017 float,
YR2018 float,
YR2019 float,
average_cost float);
CREATE table if not exists density(
country_code VARCHAR(10),
YR2015 float,
YR2016 float,
YR2017 float,
YR2018 float,
YR2019 float,
average_density float);
CREATE table if not exists time(
country_code VARCHAR(10),
YR2015 float,
YR2016 float,
YR2017 float,
YR2018 float,
YR2019 float,
average_time float);
CREATE table if not exists countries(
country_code VARCHAR(10),
country_name VARCHAR(20),
country_region VARCHAR(10));

--
--
--

#Queries
#We want to know the country where it is the fastest to create a business while displaying the cost
select time.country_code, time.average_time, cost.average_cost from business.time
join business.cost on time.country_code = cost.country_code
order by time.average_time;

#Which countries has the highest creation of businesses per thousand of ppl with the shortestt time to create in 2017
SELECT
    countries.country_name,
    density.YR2017 as density_per_region,
    cost.average_cost as average_cost_per_creation
FROM density
INNER JOIN cost
    ON density.country_code = cost.country_code
INNER JOIN countries
    ON cost.country_code = countries.country_code
    where country_name = 'Rwanda'
ORDER BY cost.average_cost;

#We want to know the relation between the cost of launching a business and the ease score of launching a business
select ease.country_code, ease.average_ease, cost.average_cost from business.ease
join business.cost on ease.country_code = cost.country_code
order by ease.average_ease desc;

#We want to see the evolution of the time needed to create a business over the year
select * from time
order by average_time;

#
SELECT
    countries.country_region,
	round(avg(cost.YR2015),2) AVG_COST_2015,  round(avg(cost.YR2016),2) AVG_COST_2016,  round(avg(cost.YR2017),2) AVG_COST_2017,
    round(avg(cost.YR2018),2) AVG_COST_2018, round(avg(cost.YR2019),2) AVG_COST_2019,
    ease.average_ease
FROM cost
INNER JOIN countries
ON cost.country_code = countries.country_code
INNER JOIN ease
ON ease.country_code = countries.country_code
    Group by country_region
ORDER BY ease.average_ease desc;


#Creating the normalized tables
select max(time.average_time), min(time.average_time) from time;
create table if not exists normalized_time as
select time.country_code, time.average_time, round((time.average_time - 2.4)/(57.54-2.4),2) as norm_time_average from time;

select max(cost.average_cost), min(cost.average_cost) from cost;
create table if not exists normalized_cost as
select cost.country_code, cost.average_cost, round((cost.average_cost - 0.7)/(34.56-0.7),2) as norm_cost_average from cost;

select max(ease.average_ease), min(ease.average_ease) from ease;
create table if not exists normalized_ease as
select ease.country_code, ease.average_ease, round((ease.average_ease - 51.8314)/(83.6686-51.8314),2) as norm_ease_average from ease;

select max(density.average_density), min(density.average_density) from density;
create table if not exists normalized_density as
select density.country_code, density.average_density, round((density.average_density - 0)/(14.8079-0),2) as norm_density_average from density;


#Joining the normalized tables
create table if not exists normalized_final as
SELECT
    normalized_density.country_code,
    normalized_density.norm_density_average,
	normalized_cost.norm_cost_average,
    normalized_ease.norm_ease_average,
    normalized_time.norm_time_average
FROM normalized_density
INNER JOIN normalized_cost
ON normalized_density.country_code = normalized_cost.country_code
INNER JOIN normalized_ease
ON normalized_cost.country_code = normalized_ease.country_code
INNER JOIN normalized_time
ON normalized_ease.country_code = normalized_time.country_code;


#Final output

select normalized_final.country_code, round(normalized_final.norm_ease_average - normalized_final.norm_time_average + normalized_final.norm_density_average - normalized_final.norm_cost_average,2) as NT
from normalized_final
order by NT desc;