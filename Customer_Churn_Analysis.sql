create database customer_churn_analysis;
use customer_churn_analysis;
select * from c_churn;

#1. How many customers are in the dataset?
select COUNT(*) as total_customers from c_churn;

#2. How many customers are there in each contract type?
select contract,count(*)as customers 
from c_churn 
group by contract 
order by customers desc;

#3. Do churned customers have higher monthly charges?
select churn,round(avg(monthlycharges),2) as avg_monthly_charges 
from c_churn 
group by churn;

#4. How does total customer value differ by churn status?
select churn,round(avg(totalcharges),2) as avg_total_charges 
from c_churn 
group by churn;

#5. Who are the top 10 highest-paying customers who churned?
select customerid,contract,monthlycharges,totalcharges 
from c_churn 
where churn = 'yes' 
order by monthlycharges 
limit 10;

#6.Which contract type has the highest churn rate?
select contract,count(*) as customers,
sum(churn='yes') as churned,
round(sum(churn='yes')*100/count(*),2) as churn_rate 
from c_churn
group by contract
order by churn_rate;

#7.Which internet service has the highest churn rate?
select internetservice,count(*) as customers,
sum(churn='yes') as churned,
round(sum(churn='yes')*100/count(*),2) as churn_rate 
from c_churn 
group by internetservice 
order by churn_rate;

#8.Which payment method has the highest churn rate?
select paymentmethod,count(*) as customers,
sum(churn='yes') as churned,
round(sum(churn='yes')*100/count(*),2) as churn_rate 
from c_churn 
group by paymentmethod 
order by churn_rate;

#9.Rank contract types by churn rate
select contract,
round(sum(churn='yes') * 100/count(*), 2) as churn_rate,
rank() over(order by sum(churn='yes') * 100/count(*) desc )as churn_rank
from c_churn 
group by contract; 

#10.Rank internet services by churn rate
select internetservice,round(sum(churn='yes')*100/count(*),2) as churn_rate,
rank() over(order by sum(churn='yes')*100/count(*) desc) as churn_rank
from c_churn
group by internetservice;

#11.Which customers have both a partner and dependents?
select customerid,gender,tenure,contract,churn 
from c_churn 
where partner = 'yes' and dependents = 'yes';

#12.Which contract has more than 1,000 customers?
select contract,count(*) as customers 
from c_churn 
group by contract 
having count(*) >1000;

#Create customers,services and bills table 

create table customers as
select customerid,gender,seniorcitizen,partner,dependents,tenure from c_churn;

create table services as
select customerid,phoneservice,multiplelines,internetservice,onlinesecurity,onlinebackup,deviceprotection,techsupport,streamingtv,streamingmovies from c_churn;

create table billing as
select customerid,contract,paperlessbilling,paymentmethod,monthlycharges,totalcharges,churn from c_churn;

#13.Combine customer and service information
select c.customerid,c.gender,c.tenure,s.internetservice,s.onlinesecurity 
from customers c 
join services s
on c.customerid = s.customerid;

#14.Combine customer and billing information
select c.customerid,c.gender,c.tenure,b.contract,b.monthlycharges,b.churn
from customers c
join billing b
on c.customerid = b.customerid;

#15.Which internet service has the highest churn rate using JOIN?
select s.internetservice,count(*) as customers,
sum(b.churn='yes') as churned,
round(sum(b.churn='yes')*100/count(*),2) as churn_rate
from services s
join billing b
on s.customerid=b.customerid
group by s.internetservice
order by churn_rate desc;

#16.Analyze churn by contract using JOIN
select b.contract,count(*) as customers,
round(sum(b.churn='yes')*100/count(*),2) as churn_rate
from customers c
join billing b
on c.customerid=b.customerid
group by b.contract
order by churn_rate desc;

#17.Final business query with customer + service + billing
select c.gender,s.internetservice,b.contract,
count(*) as customers,
round(sum(b.churn='yes')*100/count(*),2) as churn_rate
from customers c
join services s on c.customerid = s.customerid
join billing b on c.customerid = b.customerid
group by c.gender,s.internetservice,b.contract
order by churn_rate desc; 
