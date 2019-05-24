-- Modified: Wed 22 May 2019 11:58:13 (Bob Heckel)

-- If you need to retrieve a single row and you know that at most one row
-- should be retrieved, you should use a SELECT INTO statement:
--
-- The implicit SELECT INTO offers the most-efficient means of returning that
-- single row of information to your PL/SQL program. In addition, the use of SELECT INTO states 
-- very clearly that you expect at most one row, and the statement will raise exceptions 
-- (NO_DATA_FOUND or TOO_MANY_ROWS) if your expectations are not met.

--  Use the cursor-less constructs SELECT... INTO when embedded SQL is possible, or
-- EXECUTE IMMEDIATE... INTO when dynamic SQL is needed

PROCEDURE process_employee (id_in IN employees.employee_id%TYPE)
IS
   l_last_name employees.last_name%TYPE;

BEGIN
   SELECT e.last_name
     INTO l_last_name
     FROM employees e
    WHERE e.employee_id = process_employee.id_in;
   ...
END process_employee;

---

DECLARE
  TYPE RecordTyp IS RECORD (
    last hr.employees.last_name%TYPE,
    id   hr.employees.employee_id%TYPE
  );
  rec1 RecordTyp;

BEGIN
  SELECT last_name, employee_id INTO rec1
  FROM hr.employees
  WHERE job_id = 'King';  -- we can hold only a single record

  DBMS_OUTPUT.PUT_LINE('Employee #' || rec1.id || ' = ' || rec1.last);
END;
/

---

-- If you need to retrieve multiple rows
DECLARE
  --TYPE sals_t IS TABLE OF scott.emp.sal%TYPE;
  TYPE sals_t IS TABLE OF scott.emp%ROWTYPE;

  sals sals_t;

BEGIN
  --SELECT sal BULK COLLECT INTO sals FROM scott.emp WHERE ROWNUM <= 50;
  SELECT * BULK COLLECT INTO sals FROM scott.emp FETCH FIRST 50 ROWS ONLY;
  
  FOR i IN 1..sals.COUNT LOOP
    --dbms_output.put_line(sals(i));
    dbms_output.put_line(sals(i).sal);
  END LOOP;
END;
