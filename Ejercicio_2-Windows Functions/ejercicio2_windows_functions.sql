-- AVG 
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
select p.product_name, c.category_name,  p.quantity_per_unit, p.unit_price, od.quantity, 
avg(od.quantity) over (partition by c.category_id) as avgquantity
from orders o 
inner join order_details od on o.order_id = od.order_id
inner join products p ON p.product_id = od.product_id
inner join categories c on c.category_id  = p.category_id
order by p.product_name, c.category_name ;

-- MIN
/*4. Selecciona el ID del cliente, la fecha de la orden y la fecha más antigua de la
orden para cada cliente de la tabla 'Orders'.*/
select o.customer_id, o.order_date,
min(o.order_date) over (partition by o.customer_id) as earliestoorderdate
from orders o;

-- MAX
/*5. Seleccione el id de producto, el nombre de producto, el precio unitario, el id de
categoría y el precio unitario máximo para cada categoría de la tabla Products.*/
select p.product_id, p.product_name, p.unit_price, p.category_id, 
max(p.unit_price) over (partition by p.category_id) as maxunitprice
from products p;

-- Row_number
/*6. Obtener el ranking de los productos más vendidos*/
select row_number() over (order by sum(od.quantity) desc) as ranking, p.product_name,
sum(od.quantity) as totalquantity
from products p
inner join order_details od on  od.product_id  = p.product_id
group by p.product_name;

/*7. Asignar numeros de fila para cada cliente, ordenados por customer_id */
select  row_number() over (order by c.customer_id) as rownumber, c.customer_id, c.company_name, c.contact_name, c.contact_title, c.address  from customers c 

/*8. Obtener el ranking de los empleados más jóvenes () ranking, nombre y apellido del
empleado, fecha de nacimiento)*/
select row_number() over (order by birth_date desc) as ranking, first_name || ' ' || last_name as employeename, birth_date from employees;


--SUM
/*9. Obtener la suma de venta de cada cliente */
select sum(od.unit_price*quantity) over (partition by o.customer_id) as sumorderamount,
o.order_id, o.customer_id, o.employee_id, o.order_date , o.required_date 
from orders o 
inner join order_details od on o.order_id = od.order_id;

/*10.Obtener la suma total de ventas por categoría de producto*/
select c.category_name , p.product_name, od.unit_price, od.quantity, 
sum(od.unit_price*quantity) over (partition by c.category_id) as totalsales
from orders o 
inner join order_details od on o.order_id = od.order_id
inner join products p on p.product_id  = od.product_id 
inner join categories c on c.category_id  = p.category_id
order by c.category_name , p.product_id, od.unit_price ;

/*11. Calcular la suma total de gastos de envío por país de destino, luego ordenarlo por país
y por orden de manera ascendente*/
/*Muestra otro monto pero no identifico la razon*/
select o.ship_country, o.order_id, o.shipped_date, o.freight, sum(o.freight) over (partition by o.ship_country) as totalshippingcosts
from orders o 
order by o.ship_country, o.order_id;

--RANK 
/*12.Ranking de ventas por cliente*/
select  s.customer_id, s.company_name, s.total as "Total Sales", rank() over (order by s.total desc) as "Rank"
from 
(select c.customer_id, c.company_name, sum(od.unit_price*od.quantity) as total
from orders o 
inner join order_details od on o.order_id = od.order_id
inner join customers c on c.customer_id  = o.customer_id
group by c.customer_id, c.company_name) as s;

/*13.Ranking de empleados por fecha de contratacion*/
select e.employee_id, e.first_name, e.last_name, e.hire_date, rank() over (order by hire_date asc) as "Rank" from employees e;

/*14.Ranking de productos por precio unitario*/
select p.product_id, p.product_name, p.unit_price, rank() over (order by unit_price desc) as "Rank" from products p 

--LAG
/*15.Mostrar por cada producto de una orden, la cantidad vendida y la cantidad
vendida del producto previo.*/
select o.order_id, od.product_id, od.quantity, lag(od.quantity, 1) over (order by o.order_id, od.product_id) as prevquantity
from orders o 
inner join order_details od on o.order_id = od.order_id;

/*16.Obtener un listado de ordenes mostrando el id de la orden, fecha de orden, id del cliente
y última fecha de orden.*/
select o.order_id, o.order_date, o.customer_id, lag(o.order_date, 1) over (partition by o.customer_id order by o.order_id) as lastorderdate
from orders o;

/*17.Obtener un listado de productos que contengan: id de producto, nombre del producto,
precio unitario, precio del producto anterior, diferencia entre el precio del producto y
precio del producto anterior.*/
select product_id, product_name, unit_price, lastunitprice, (unit_price - lastunitprice) as pricedifference
from 
	(select p.product_id, p.product_name, p.unit_price, lag(p.unit_price,1) over (order by p.product_id) as lastunitprice 
	from products p) as l;

--LEAD
/*18.Obtener un listado que muestra el precio de un producto junto con el precio del producto
siguiente:*/
select p.product_name, p.unit_price, lead(p.unit_price,1) over (order by p.product_id) as nextprice 
from products p;

/*19.Obtener un listado que muestra el total de ventas por categoría de producto junto con el
total de ventas de la categoría siguiente*/
select l.category_name, l.totalsales, lead(l.totalsales) over (order by l.category_name) as nexttotalsales
from
	(select c.category_name, sum(od.unit_price*od.quantity) as totalsales
	from orders o 
	inner join order_details od on o.order_id = od.order_id
	inner join products p on p.product_id  = od.product_id 
	inner join categories c on c.category_id  = p.category_id
	group by c.category_name
	order by c.category_name) as l;


