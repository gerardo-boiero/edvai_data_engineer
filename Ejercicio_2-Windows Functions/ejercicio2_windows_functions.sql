select o.customer_id , od.unit_price ,
avg(od.unit_price) over (partition by o.customer_id)
from orders o INNER JOIN order_details od
ON o.order_id = od.order_id;


select o.customer_id , od.unit_price ,
rank() over (partition by o.customer_id order by od.unit_price desc)
from orders o INNER JOIN order_details od
ON o.order_id = od.order_id;


select o.customer_id , od.unit_price ,
row_number () over (partition by o.customer_id order by od.unit_price desc)
from orders o INNER JOIN order_details od
ON o.order_id = od.order_id;


/* 1 - Obtener el promedio de precios por cada categoría de producto. La cláusula
OVER(PARTITION BY CategoryID) específica que se debe calcular el promedio de
precios por cada valor único de CategoryID en la tabla*/
select c.category_name , p.product_name, p.unit_price, avg(p.unit_price) over (partition by c.category_id) as avgpricebycategory
from categories c
inner join products p on p.category_id  = c.category_id;

/*2- Obtener el promedio de venta de cada cliente*/
select avg(od.unit_price*quantity) over (partition by o.customer_id) as avgorderamount,
o.order_id, o.customer_id, o.employee_id, o.order_date , o.required_date, o.shipped_date 
from orders o 
inner join order_details od on o.order_id = od.order_id;


/*3-Obtener el promedio de cantidad de productos vendidos por categoría (product_name,
quantity_per_unit, unit_price, quantity, avgquantity) y ordenarlo por nombre de la
categoría y nombre del producto*/
select * 


