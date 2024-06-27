use restaurant_db;
describe menu_items;
describe order_details;

-- There is no foreign  key defined in the database tables, so we are altering the table to create the foreign key to link them
alter table order_details
add foreign key (item_id) references menu_items(menu_item_id);

select * from menu_items;
select * from order_details;


-- We will also create a view, as we have to join the two tables to fetch the results, so we don't want to repeat the join again and again.

create view joined_data as
select
order_details.*,
menu_items.*
from
order_details
inner join
menu_items on order_details.item_id = menu_items.menu_item_id;


-- Task 1- How many items are there in the menu?

select count(distinct item_name) as Total_Menu_Items 
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id;

-- Task 2- Total number of orders 

select count(distinct order_id) as Total_Orders 
from joined_data;

-- Task 3- Total Sales of the restaurant

select sum(price) as Total_Sales 
from joined_data;

-- Task 4- What is average order value/ average per cheque (APC) ?

select sum(price)/count(distinct order_id) as Average_Per_Cheque 
from joined_data;

-- Task 5- What are the total number of items ordered during three months ?

select count(item_name) as Total_Items_Ordered 
from joined_data;

-- Task 6- What is average items per order ?

select count(item_name)/count(distinct order_id) as Average_Items_Per_Order
from joined_data;

-- Task 7- What is total sales distribution as per different food categories ?

select mi.category as Food_Category, sum(mi.price) as Category_Sales, 
sum(mi.price)/(select sum(mi.price) from order_details od inner join menu_items mi on od.item_id = mi.menu_item_id)*100 
as Sales_Percent 
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.category;

-- Task 8- What is sales distribution as per quantity ordered ?

select joined_data.category as Food_Category, count(joined_data.item_name) as Quantity_Ordered, 
count(joined_data.item_name)/(select count(joined_data.item_name) from joined_data)*100 
as Percent_Distribution 
from joined_data
group by
joined_data.category;

-- Task 9- Find the Sales distribution of each and every menu item arranging it in descending order

select mi.item_name as Menu_Item, sum(mi.price) as Item_Sales, mi.category as Category_Name  
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.item_name, mi.category
order by sum(mi.price) desc;

-- Task 10- Find the weekly sales for the given months

select week(od.order_date) as Week_Number, sum(mi.price) as Total_Sales 
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
week(od.order_date);

-- Task 11- Find the distribution of sales on the basis of weekdays ?

select dayname(od.order_date) as Day_Of_The_Week, sum(mi.price) as Total_Sales 
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
dayname(od.order_date)
order by Total_Sales desc;

-- Task 12- Find the hourly distribution of sales in order to find the hourly engagement of customers ?

select hour(od.order_time) as Hour_Of_Day, count(*) as Total_Transactions, sum(mi.price) as total_sales_amount
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
hour(od.order_time)
order by Hour_Of_Day;

-- Task 13- Find the top 5 sales generating food items also return the sales values

select mi.item_name as Top_5, sum(mi.price) as Total_Sales_Amount
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.item_name 
order by 
Total_Sales_Amount desc limit 5;

-- Task 14- Find the 5 least sales generating food items along with sales values

select mi.item_name as Bottom_5, sum(mi.price) as Total_Sales_Amount
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.item_name 
order by 
Total_Sales_Amount asc limit 5;

-- Task 15- Find the 5 most ordered food items and also find the number of times they are ordered

select mi.item_name as Top_5_Ordered, count(od.order_id) as Order_Count
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.item_name 
order by 
Order_Count desc limit 5;

-- Task 16- Find the 5 least ordered food items and also their order count

select mi.item_name as Top_5_Ordered, count(od.order_id) as Order_Count
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by
mi.item_name 
order by 
Order_Count asc limit 5;

-- Task 17- What is the total sales percent change month on month (MoM) basis ?

select 
month(od.order_date) as month,
sum(mi.price) as total_sales,
(sum(mi.price) - lag(sum(mi.price)) 
over (order by month(od.order_date))) / lag(sum(mi.price)) 
over (order by month(od.order_date)) * 100 
as percent_change
from order_details od 
inner join 
menu_items mi 
on 
od.item_id = mi.menu_item_id
group by 
month(od.order_date)
order by 
month(od.order_date);
    
    
-- Task 18- Find the sales percent change for each and every food category for month on month (MoM) basis showing sales fluctuations of the respective sales category.

select
month, month_name, category, total_sales, previous_month_sales,
    case
        when previous_month_sales is null then null 
        else ((total_sales - previous_month_sales) / previous_month_sales) * 100
    end as percent_change
from (
    select
        monthname(joined_data.order_date) as month_name,
        month(joined_data.order_date) as month,
        joined_data.category,
        sum(joined_data.price) as total_sales,
        lag(sum(joined_data.price)) 
        over(partition by joined_data.category 
        order by 
        month(joined_data.order_date)) 
        as 
        previous_month_sales
from joined_data
group by
monthname(joined_data.order_date),
month(joined_data.order_date),
joined_data.category
) as sales_data
order by
category,
month;


             ----------------------------------------------- Thank You ----------------------------------------------------