
--Package

CREATE OR REPLACE PACKAGE Test_PKG1 IS

	PROCEDURE Out_Screen(TOSC IN VARCHAR2);
	
	FUNCTION Add_Two_Num(A IN NUMBER, B IN NUMBER) RETURN NUMBER;
	
	FUNCTION Min_Two_Num(A IN NUMBER, B IN NUMBER) RETURN NUMBER;

	FUNCTION FACTORIAL(NUM IN NUMBER) RETURN NUMBER;
	
END test_pkg;


create or replace package body Test_PKG1 is
test varchar2(10); 
  
   -- CREATE OR REPLACE 
    PROCEDURE Out_Screen(TOSC IN VARCHAR2)
    IS
    test varchar2(10);
    BEGIN
       DBMS_OUTPUT.enable;
        DBMS_OUTPUT.put_line(TOSC);
    END;

    -- FUNCTION Min_Two_Num -- ****************************************
    FUNCTION Min_Two_Num(A IN NUMBER, B IN NUMBER) RETURN NUMBER
    IS
    test1 number;
    BEGIN
     RETURN (A - B);
    END;

    -- FUNCTION Add_Two_Num -- ****************************************
    FUNCTION Add_Two_Num(A IN NUMBER, B IN NUMBER) RETURN NUMBER
    IS
    BEGIN
     RETURN (A + B);
    END;

    -- FUNCTION FACTORIAL -- ****************************************
    FUNCTION FACTORIAL(NUM IN NUMBER) RETURN NUMBER
    IS
    BEGIN
    IF (NUM <=1) THEN
     RETURN (NUM);
    ELSE
     RETURN (NUM * FACTORIAL(NUM-1));
    END IF;
    END;

end;


