-- Modified: 27-Mar-2020 (Bob Heckel) 

-- MINUS implements the set difference operator. This returns all the rows in the first table not in the second. 
-- MINUS is one of the few operators that consider null values equal.
-- See also intersect.sql, notexist.sql

select toy_name from toys_for_sale 
minus 
select toy_name from bought_toys 
order  by toy_name;

-- same if no NULLs

select toy_name  
from   toys_for_sale tofs 
where  not exists ( 
  --select 1 
  select null 
  from   bought_toys boto 
  where  tofs.toy_name = boto.toy_name 
);

-- same if NULLs
select toy_name
from   toys_for_sale tofs 
where  not exists ( 
  select null 
  from   bought_toys boto 
  where  ( tofs.toy_name = boto.toy_name or ( tofs.toy_name is null and boto.toy_name is null ))
)
order  by toy_name;

-- But if you want to see the price as well as the name of the toys you've not purchased MINUS won't work
select toy_name, price 
from   toys_for_sale tofs 
where  not exists ( 
  select null 
  from   bought_toys boto 
  where  tofs.toy_name = boto.toy_name 
);

---

-- "MINUS ALL" keep duplicates by using analytic function hack (MINUS removes duplicates of the input sets
-- first before doing the subtraction)
select
   product_id
 , product_name
 , row_number() over ( partition by product_id, product_name order by rownum) as rn
from customer_order_products
MINUS
select
   product_id
 , product_name
 , row_number() over ( partition by product_id, product_name order by rownum) as rn
from customer_order_products
order by 1;
