--Inspecting Data
select * from [dbo].[Sales_datasets]
--Checking uniqye values
select distinct status from [dbo].[Sales_datasets] --Nice to plot
select distinct year_id from [dbo].[Sales_datasets]
select distinct PRODUCTLINE from [dbo].[Sales_datasets] --nice to plot
select distinct COUNTRY from [dbo].[Sales_datasets] --nice to plot
select distinct DEALSIZE from [dbo].[Sales_datasets] --nice to plot
select distinct TERRITORY from [dbo].[Sales_datasets]  --nice to plot

select distinct MONTH_ID from [dbo].[Sales_datasets]
where year_id = 2003

--ANALYSIS
--Lets start by grouping the sales by productline
select PRODUCTLINE,sum(sales) Revenue
from [DVAproject].[dbo].[Sales_datasets]
group by PRODUCTLINE
order by 2 desc

select YEAR_ID,sum(sales) Revenue
from [DVAproject].[dbo].[Sales_datasets]
group by YEAR_ID
order by 2 desc

select DEALSIZE,sum(sales) Revenue
from [DVAproject].[dbo].[Sales_datasets]
group by DEALSIZE
order by 2 desc

--what was the best month for sales in specific year? how much was earned that month?
select MONTH_ID, sum(sales) Revenue, count(ORDERNUMBER) frequency
from [DVAproject].[dbo].[Sales_datasets]
where YEAR_ID = 2003
group by MONTH_ID
order by 2 desc

--November seems to be the month, what product do they sell in november, Classic I believe
select MONTH_ID,PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER)
from [DVAproject].[dbo].[Sales_datasets]
where YEAR_ID = 2003 and MONTH_ID = 11
group by MONTH_ID, PRODUCTLINE
order by 3 desc

--Who is our best customer .
;with rfm as
(
select 
    CUSTOMERNAME,
sum(sales) MonetaryValue,
avg (sales) AvgMonetaryValue,
count (ORDERNUMBER) frequency,
max (ORDERDATE) last_order_date,
(select max(ORDERDATE) from [dbo].[Sales_datasets]) max_order_date,
DATEDIFF (DD, max (ORDERDATE), (select max(ORDERDATE) from [dbo].[Sales_datasets])) Recency
from [DVAproject].[dbo].[Sales_datasets]
group by CUSTOMERNAME
),

rfm_calc as
(
select r.*,
NTILE(4) OVER (order by Recency) rfm_recency,
NTILE(4) OVER (order by Frequency) rfm_frequency,
NTILE(4) OVER (order by AvgMonetaryValue) rfm_monetary
from rfm r
)
--order by 4 desc
select c.*
from rfm_calc c

--what produucts are often sold togerther
--select*from [dbo].[Sales_datasets] where ORDERNUMBER = 10411
select distinct ORDERNUMBER, stuff(

(select ','+ PRODUCTCODE
from [dbo].[Sales_datasets] p
where ORDERNUMBER in 
(
select ORDERNUMBER
from(

select ORDERNUMBER, count(*)rn
from [DVAproject].[dbo].[Sales_datasets]
where STATUS = 'shipped'
group by ORDERNUMBER
)m
where rn = 2 
)
and p.ORDERNUMBER=S.ORDERNUMBER
for xml path(''))
, 1, 1, '') Productcodes
from [dbo].[Sales_datasets] s
order by 2 desc