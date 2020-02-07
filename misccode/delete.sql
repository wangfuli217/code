
delete target_bricks tb 
where  exists ( 
  select * from source_bricks sb 
  where  sb.brick_id = tb.brick_id 
  and    sb.colour = 'red' 
);

---

-- Remove all records
delete from foo

delete foo

---

-- Oracle - remove one of two duplicates - first find unique identifier:
select ROWID
from pks_extraction_control
where meth_spec_nm='AM0735CUHPLC' and meth_var_nm='PEAKINFO';

-- then remove one of them
delete
from pks_extraction_control
where rowid='AAB5QNACDAAARalAAo';

COMMIT;

---

-- Find the newest record in a duplicated pair
with v as (        
	select /*+PARALLEL(4)*/ opportunity_employee_id, opportunity_id, employee_id, actual_updated
		from opportunity_employee_base
	 where (opportunity_id, employee_id) in( select oe.opportunity_id, oe.employee_id
																						 from opportunity_employee_base oe
																						where oe.owner_type = 'S' and actual_updated > '01JAN20'
																						group by opportunity_id, employee_id
																					 having count(1) > 1 )
)
select *
  from v
 where exists ( select 1
                  from v v2
                 where v.opportunity_id = v2.opportunity_id
                   and v.actual_updated > v2.actual_updated)
;

-- or delete the oldest record in a duplicated pair
delete
from opportunity_employee_base 
where opportunity_employee_id in (
  with v as (        
        select /*+PARALLEL(4)*/ opportunity_employee_id, opportunity_id, employee_id, actual_updated
          from opportunity_employee_base
         where (opportunity_id, employee_id) in(
                 select oe.opportunity_id, oe.employee_id
                   from opportunity_employee_base oe
                  where oe.owner_type = 'S' and actual_updated > '01JAN20'
                  group by opportunity_id, employee_id
                 having count(1) > 1
        )
  )
  select opportunity_employee_id
  from v
    where exists ( select 1
                   from v v2
                   where v.opportunity_id = v2.opportunity_id
                   and v.actual_updated < v2.actual_updated)
);
