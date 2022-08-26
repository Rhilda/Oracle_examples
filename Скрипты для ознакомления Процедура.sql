
--Процедура

CREATE PROCEDURE TESTPRG
AS
BEGIN	
	NULL;
END TESTPRG;

SELECT *
FROM USER_OBJECTS
WHERE OBJECT_TYPE = 'PROCEDURE'


CREATE OR REPLACE PROCEDURE TESTPRG
IS
BEGIN
	DBMS_OUTPUT.enable;
	DBMS_OUTPUT.put_line('HELLO, WORLD 2!!!');
END TESTPRG;


CREATE OR REPLACE PROCEDURE TESTOUT(NUM IN NUMBER, DT OUT VARCHAR2)
IS
BEGIN
	SELECT email INTO DT FROM employees
	WHERE employees.employee_id = NUM;
END TESTOUT;


DECLARE 

FRDT VARCHAR2(100);

BEGIN

	FRDT := 'HELLO';
	TESTOUT(2103, FRDT);
	DBMS_OUTPUT.enable;
    DBMS_OUTPUT.put_line('EMPLOYEE '||FRDT);

END


CREATE OR REPLACE PROCEDURE TEST_POZ(
	PR_A IN NUMBER, 
	PR_B IN NUMBER,
	PR_C IN VARCHAR2, 
	PR_D IN VARCHAR2                     
    )
IS
BEGIN
NULL;
END TEST_POZ;


DECLARE
PR_1 NUMBER;
PR_2 NUMBER;
PR_3 VARCHAR2(100);
PR_4 VARCHAR2(100);                     
BEGIN
TEST_POZ(PR_B => PR_2, PR_C => PR_3, PR_D => PR_4, PR_A => PR_1);
END;


CREATE OR REPLACE PROCEDURE TEST_POZ(
   PR_A IN NUMBER, 
   PR_B IN NUMBER,
   PR_C IN VARCHAR2 := 'HELLO', 
   PR_D IN VARCHAR2 DEFAULT 'WORLD!!!')
IS

BEGIN

NULL;

END TEST_POZ;




-- Исключения
CREATE OR REPLACE PROCEDURE add_new_order
   (order_id_in IN NUMBER, prod_id in NUMBER, sales_in IN NUMBER)
IS
   no_sales EXCEPTION;
BEGIN
   IF sales_in = 0 THEN RAISE no_sales;
   ELSE
      INSERT INTO orders (id, productid, customerid, createdat, productcount, price) 
      VALUES   ( order_id_in, prod_id, 101,to_date('06.04.2021','DD.MM.YYYY'),sales_in, 100);
      COMMIT;
   END IF;
EXCEPTION
   WHEN no_sales THEN
      raise_application_error (-20001,'You should have Order to close position');
   WHEN OTHERS THEN
      raise_application_error (-20002,'Some error happed!!!');
END;


--ПРИМЕР ПРОЦЕДУРЫ ДЛЯ ЗАГРУЗКИ ВИТРИНЫ
CREATE OR REPLACE PROCEDURE CLIENTS ()
IS
BEGIN
   execute immediate 'truncate table CLIENTS';
   --delete from CLIENTS; commit;
   insert into CLIENTS (id, productname, manufacturer, productcount, price )
   select .......
   from employees e
   join departments d on d.department_id = e.department_id;............
   commit;
   
   dbms_stats.gather_table_stats('<Schema_name>','<Table_name>',cascade => true,degree => 1);
   
EXCEPTION
   WHEN OTHERS THEN
      raise_application_error (SQLCODE,SQLERRM);   
END;

    