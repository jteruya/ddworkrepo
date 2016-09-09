-- Create Tables
drop table if exists jt.salesperson
;
create table jt.salesperson (
     id int
   , name varchar     
   , age int
   , salary int)
;

drop table if exists jt.customer
;
create table jt.customer (
     id int
   , name varchar
   , city varchar
   , industry_type char)
;

drop table if exists jt.orders
;
create table jt.orders (
      number int
    , order_date date
    , cust_id int
    , salesperson_id int
    , amount int)
;

-- Populate Tables
insert into jt.salesperson (id, name, age, salary) values (1, 'Abe', 61, 140000);
insert into jt.salesperson (id, name, age, salary) values (2, 'Bob', 34, 44000);
insert into jt.salesperson (id, name, age, salary) values (5, 'Chris', 34, 40000);
insert into jt.salesperson (id, name, age, salary) values (7, 'Dan', 41, 52000);
insert into jt.salesperson (id, name, age, salary) values (8, 'Ken', 57, 115000);
insert into jt.salesperson (id, name, age, salary) values (11, 'Joe', 38, 38000);

insert into jt.customer (id, name, city, industry_type) values (4, 'Samsonic', 'pleasant', 'J');
insert into jt.customer (id, name, city, industry_type) values (6, 'Panasung', 'oaktown', 'J');
insert into jt.customer (id, name, city, industry_type) values (7, 'Samony', 'jackson', 'B');
insert into jt.customer (id, name, city, industry_type) values (9, 'Orange', 'Jackson', 'B');

insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (10, '1996-08-02', 4, 2, 540);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (20, '1999-01-30', 4, 8, 1800);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (30, '1995-07-14', 9, 1, 460);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (40, '1998-01-29', 7, 2, 2400);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (50, '1998-02-03', 6, 7, 600);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (60, '1998-03-02', 6, 7, 720);
insert into jt.orders (number, order_date, cust_id, salesperson_id, amount) values (70, '1998-05-06', 9, 7, 150);

-- Q1: Names of all salespeople that have an order with Samsonic.
SELECT DISTINCT SP.Name
FROM jt.orders ORDERS
INNER JOIN jt.salesperson SP
ON ORDERS.SalesPerson_Id = SP.Id
INNER JOIN jt.customer C
ON ORDERS.Cust_Id = C.Id
WHERE C.Name = 'Samsonic'
;

-- Bob
-- Ken

-- Q2: The names of all salespeople that do not have any order with Samsonic.
SELECT DISTINCT SP.Name
FROM jt.salesperson SP
LEFT JOIN (SELECT *
           FROM jt.orders ORDERS
           INNER JOIN jt.customer C
           ON ORDERS.Cust_Id = C.Id
           WHERE C.Name = 'Samsonic'
           ) ORDERS
ON ORDERS.SalesPerson_Id = SP.Id
WHERE ORDERS.SalesPerson_Id IS NULL
;

--Abe
--Chris
--Joe
--Dan

-- Q3:  The names of salespeople that have 2 or more orders.
SELECT DISTINCT SP.Name
FROM jt.orders ORDERS
INNER JOIN jt.salesperson SP
ON ORDERS.SalesPerson_Id = SP.Id
GROUP BY SP.Name
HAVING COUNT(*) >= 2
;

--Bob
--Dan

-- Q4: Write a SQL statement to insert rows into a table called highAchiever(Name, Age), where a salesperson must have a salary of 100,000 or greater to be included in the table.
