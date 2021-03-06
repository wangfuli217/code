-- Created: Mon 01 Feb 2019 10:45:15 (Bob Heckel) 
-- Modified: 24-Apr-2020 (Bob Heckel)

CREATE OR REPLACE PACKAGE ztestbob AS
  
  PROCEDURE test(in_x number);

END ztestbob;
/


CREATE OR REPLACE PACKAGE BODY ztestbob AS

  PROCEDURE test(in_x number)
  IS
    l_now DATE := sysdate;

  BEGIN
    dbms_output.put_line('ok1 ' || l_now);
  END;

END ztestbob;
/

exec ztestbob.test(42);

drop package ztestbob;

---

CREATE OR REPLACE PACKAGE ztestbob AS
  
  PROCEDURE delay_buffer_test;

END ztestbob;
/
CREATE OR REPLACE PACKAGE BODY ztestbob AS

  PROCEDURE delay_buffer_test
  IS
    l_now DATE;

  BEGIN
    dbms_output.put_line('ok1');
    SELECT sysdate INTO l_now FROM DUAL; LOOP EXIT WHEN l_now +(10 * (1 / 86400)) = sysdate; END LOOP;
    dbms_output.put_line('ok2');
  END;

END ztestbob;

---

CREATE OR REPLACE PACKAGE manage_students AS

  PROCEDURE find_sname(i_student_id IN student.student_id%TYPE,
                       o_first_name OUT student.first_name%TYPE,
                       o_last_name OUT student.last_name%TYPE);

  FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN;

END manage_students;
/

CREATE OR REPLACE PACKAGE BODY manage_students AS

  PROCEDURE find_sname (i_student_id IN student.student_id%TYPE,
                        o_first_name OUT student.first_name%TYPE,
                        o_last_name OUT student.last_name%TYPE)
  IS

    v_student_id student.student_id%TYPE;

  BEGIN
    SELECT first_name, last_name
    INTO o_first_name, o_last_name
    FROM student
    WHERE student_id = i_student_id;

    EXCEPTION
			WHEN OTHERS THEN
			DBMS_OUTPUT.PUT_LINE ('Error in finding student_id: '||v_student_id);
  END find_sname;


   FUNCTION id_is_good(i_student_id IN student.student_id%TYPE) RETURN BOOLEAN
   IS

	 v_id_cnt number;

	 BEGIN
		 SELECT COUNT(*)
		 INTO v_id_cnt
		 FROM student
		 WHERE student_id = i_student_id;
		 RETURN 1 = v_id_cnt;

		 EXCEPTION
	 WHEN OTHERS THEN
		 RETURN FALSE;
 END id_is_good;

END manage_students;

---

create or replace package ORION_ERRORS_TEST is

  procedure proc_a;
  procedure proc_b;
  procedure proc_c;
  
  procedure force_err(in_status VARCHAR2);

end ORION_ERRORS_TEST;
/
create or replace package body ORION_ERRORS_TEST is

  procedure proc_c is
    begin
     dbms_output.put_line('Inside procedure c');
     orion_errors.raise_error(orion_errors.MY_USER_DEFINED_ERROR);
  end proc_c;

  procedure proc_b is
    begin
     dbms_output.put_line('Inside procedure b');
     proc_c;
  end proc_b;

  procedure proc_a is
    begin
      dbms_output.put_line('Inside procedure a');
      proc_b;
  end proc_a;

  procedure force_err(in_status VARCHAR2) is
    begin
      dbms_output.put_line('ok ' || in_status);
  end;
end ORION_ERRORS_TEST;

---

-- Overloading:

CREATE OR REPLACE PACKAGE p
IS
   PROCEDURE l(bool IN BOOLEAN);

   /* Display a string */
   PROCEDURE l(stg IN VARCHAR2);

   /* Display a string and then a Boolean value */
   PROCEDURE l(
      stg    IN   VARCHAR2,
      bool   IN   BOOLEAN
   );
END;
-- ...

-- Call one of them
DECLARE
   v_is_valid BOOLEAN := book_info.is_valid_isbn('5-88888-66');
BEGIN
   p.l(v_is_valid);
END;


DECLARE
   PROCEDURE proc1(n IN PLS_INTEGER) IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE('pls_integer version');
   END;

   PROCEDURE proc1(n IN NUMBER) IS
   BEGIN
      DBMS_OUTPUT.PUT_LINE('number version');
   END;
BEGIN
   proc1(1.1);
   proc1(1);
END;
