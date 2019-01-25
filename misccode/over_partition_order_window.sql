/* Analytic functions compute an aggregate value based on a group of rows. They
 * differ from aggregate functions in that they RETURN MULTIPLE ROWS FOR EACH
 * GROUP. The group of rows is called a window and is defined by the
 * analytic_clause. For each row, a sliding window of rows is defined. The
 * window determines the range of rows used to perform the calculations for the
 * current row. Window sizes can be based on either a physical number of rows
 * or a logical interval such as time.
 *
 * Analytic functions are the last set of operations performed in a query
 * except for the final ORDER BY clause. All joins and all WHERE, GROUP BY, and
 * HAVING clauses are completed *before* the analytic functions are processed.
 * Therefore, analytic functions can appear only in the SELECT list or ORDER BY
 * clause not in a predicate.  They can often be used to eliminate potentially 
 * expensive subqueries.
 *
 * P  partition
 * O  order
 * W  window
 *
 */

select empno, ename, job, sal,
       -- 1,2,3,4,5... ties are indeterminant
       row_number() OVER (order by sal) as sal_row_number
       -- 1,2,3,4,5... with tie-breaker being empno
       row_number() OVER (order by sal, empno) as sal_row_number2
       -- RANK will skip the next number if there are ties "Olympic" 
       -- 1,2,2,4,5... no #3 
       rank() OVER (order by sal) as sal_rank,
       rank() OVER (order by sal DESC NULLS LAST ) as hi_sal_rank_with_nulls
       -- 1,2,2,3,4... two 2s then normal seq resumes
       dense_rank() OVER (order by sal) as sal_dense_rank,
from emp


select name, gross_sales,
       100*cume_dist() OVER ( order by gross_sales ) as cumedist
       100*percent_rank() OVER ( order by gross_sales ) as pctrank
       ntile(4) OVER ( order by gross_sales DESC ) as quartile
from movies

---

-- Employees in department 10 are ranked by their salary within their department (rank of highest salary is 1).
-- The rank for each employee not in department 10 is 0. 
select e.*,
       rank() over ( order by e.sal desc )
from emp e
where deptno = 10
union all
select e.*, 0
from emp e
where deptno != 10;

---

/* Analytic SQL windowing function.  See also greater_than_average.sql outliers.sql */

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02', 11 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-03', 30 from dual
union all select date '2000-01-04', 10 from dual
union all select date '2000-01-05', 14 from dual
)
select d
      ,amt
      ,row_number() OVER (order by d) row_seq_in_dt_order  -- 1,2,3,4,5,6
      ,rank() OVER (order by d) orderbydt -- 1,2,3,3,5,6 Olympic
      ,dense_rank() OVER (order by d) orderbydt_dense -- 1,2,3,3,4,5,6
      ,row_number() OVER (partition by d order by d) rownumbyday  -- 1,1,1,2,1,1
      ,rank() OVER (partition by d order by amt) rank_by_day -- 1,1,1,1,1,1 can be Top N by day if used as a subquery
      -- Want only first date in a contiguous series otherwise leave blank
      ,case when nvl(lag(d) over (order by d), d) != d-1 then d end lowval_of_range  -- 01jan, , , 03jan, , 
      ,first_value(amt) OVER (order by d) firstdot  -- 10,10,10,10,10,10
      -- Good for cols where only the first appearance holds empno and rest are blank and need to be padded out (like a report for human consumption)
      ,last_value(amt IGNORE NULLS) OVER (order by d)  lastdot_fillin_the_blank  -- 10,11,30,30,10,14
      ,nvl(amt, lag(amt IGNORE NULLS) OVER (partition by d order by d)) fillin_the_blank_handle_nulls  -- 10,11,30,30,10,14
      -- The NTH_VALUE clause lets us identify boundary values that are not necessarily the minima and maxima which could be identified by FIRST_VALUE() and LAST_VALUE()
      ,nth_value(amt,2) OVER (order by d) second_highest_skip_outliers  -- , 11, 11, 11, 11, 11
      ,round(amt/nth_value(amt,2) over (order by d),2)*100 percent_diff  -- , 100, 273, 273, 91, 127
      ,sum(amt) OVER (order by d) as running_tot_fail  -- default 'unbounded preceding and following' is effectively the same as a SUM on the entire set (by each ticker) and hence would not give a running total here
      ,sum(amt) OVER (order by d rows between unbounded preceding and current row) running_total2  -- 10,21,51,81,91,105
      ,avg(amt) OVER (order by d rows between 1 preceding and 1 following) moving_average  -- 10.5,17,23.6666666,23.333333,18,12
--      ,sum(amt) OVER (order by d rows between MYFUNC(foo) preceding and 0 following) running_total3
--      ,sum(amt) OVER (order by d rows between myseq-mytrailing_seq preceding and 0 following) running_total4
      -- Use time RANGE not physical ROWS to avoid missing data
      ,sum(amt) OVER (order by d range between interval '2' day preceding and current row) running_total_2day  -- 10,21,81,81,81,84
      ,avg(amt) OVER (order by d range between interval '2' day preceding and current row) moving_average_2day  -- 10,10.5,20.25,20.25,20.25,21
      -- Always need a sorting clause for LAG()
      ,lag(amt) OVER (order by d) amt_before  -- ,10,11,30,30,10
      ,lead(amt) OVER (partition by d order by d) amt_after  -- , , 30, , ,  good for finding a change in status when you have daily data
      --_______________________________________ <--still just another aggregation function like count() or sum()
      ,listagg(d,', ' within group(ordery by d) OVER ( partition by amt ) csv
      ,sum(amt) OVER () grand_sum
      ,avg(amt) OVER () grand_avg
FROM v;

---

-- Want department number and name of the employee that has the highest salary
-- in that department.  In the event of a tied salary, choose the employee with
-- the first name in alphabetic sequence

-- Self join version:
select deptno, ename top_emp
from emp e
where not exists ( 
  select 1
  from   emp
  where  deptno = e.deptno
    and  (sal > e.sal) or (sal = e.sal and ename < e.ename)
  )
order by 1;

-- Compare fetch first version:
select distinct deptno, 
       ( select ename
         from   emp
         where  deptno = e.deptno
         order by sal desc, ename 
         fetch first row only
       ) top_emp
from emp e
order by 1;

-- Compare Analytic Functions version:
select distinct deptno, 
       first_value(ename) over ( partition by deptno order by sal desc, ename ) as top_emp
from emp
order by 1;

---

/* 
DEPTNO	EMPNO	ENAME	JOB	SAL	RUNNING_TOTAL
10	7782	CLARK	MANAGER	2450	2450
10	7839	KING	PRESIDENT	5000	7450
10	7934	MILLER	CLERK	1300	8750
20	7876	ADAMS	CLERK	1100	1100
20	7902	FORD	ANALYST	3000	4100
20	7566	JONES	MANAGER	2975	7075
20	7788	SCOTT	ANALYST	3000	10075
20	7369	SMITH	CLERK	800	10875
30	7499	ALLEN	SALESMAN	1600	1600
30	7698	BLAKE	MANAGER	2850	4450
30	7900	JAMES	CLERK	950	5400
30	7654	MARTIN	SALESMAN	1250	6650
30	7844	TURNER	SALESMAN	1500	8150
30	7521	WARD	SALESMAN	1250	9400
*/
select deptno, empno, ename, job, sal,
       sum(sal) OVER (
         partition by deptno
         order by ename
         ) as running_total
from emp
order by deptno, ename