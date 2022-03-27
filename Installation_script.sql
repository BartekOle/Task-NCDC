SET ECHO OFF
SET VERIFY OFF

---variables

PROMPT 
PROMPT specify password for task as parameter 1:
DEFINE pass = &1
PROMPT specify log path as parameter 2:
DEFINE log_path = &2
PROMPT
PROMPT specify path for CSVTask directory as parameter 3:
DEFINE dir_path = &3
PROMPT

-- log file

DEFINE spool_file = &log_path\task3.log
SPOOL &spool_file

--- cleanup 

alter session set "_ORACLE_SCRIPT"=true; 

DROP USER NCDC CASCADE;

--create user task

CREATE USER NCDC
    IDENTIFIED BY &pass;
    
GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO NCDC;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE, UNLIMITED TABLESPACE TO NCDC;  
GRANT CREATE ANY DIRECTORY TO NCDC;
ALTER USER NCDC GRANT CONNECT THROUGH system;  

CONNECT NCDC/&pass

--create Table Documents
CREATE TABLE DOCUMENTS
    ("Document Id" INT GENERATED ALWAYS AS IDENTITY CONSTRAINT doc_pk PRIMARY KEY,
     "Document Name" VARCHAR2(50) CONSTRAINT doc_nam_nn NOT NULL,
     "Document Description" VARCHAR2(4000),
     "Record Timestamp" TIMESTAMP CONSTRAINT doc_rec_tim_nn NOT NULL,
     "Timestamp" TIMESTAMP CONSTRAINT doc_tim_nn NOT NULL,
     "Record User Id" VARCHAR2(50) CONSTRAINT doc_rec_use_nn NOT NULL,
     "User Id" VARCHAR2(50) CONSTRAINT doc_use_nn NOT NULL
    )
/
--Create trigger for task 1
CREATE OR REPLACE TRIGGER Documents_BeforeInsert
BEFORE INSERT OR UPDATE ON DOCUMENTS
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        :NEW."Record Timestamp" := SYSDATE;
        :NEW."Timestamp" := SYSDATE;
        :NEW."Record User Id" := user;
        :NEW."User Id" := user;
    ELSE
        :NEW."Timestamp" := SYSDATE;
        :NEW."User Id" := user;        
    END IF;
END;
/
---Create package Task for Task2

CREATE OR REPLACE PACKAGE Task AS

    FUNCTION validate_pesel (
      PESEL IN NUMBER
    ) RETURN VARCHAR2;

  PROCEDURE print_documents;
    
END Task;
/    
CREATE OR REPLACE PACKAGE BODY Task AS

    FUNCTION validate_pesel (
      PESEL IN NUMBER
    ) RETURN VARCHAR2 IS
        TYPE Weights_table IS VARRAY(11) OF INTEGER;
        v_boolean VARCHAR2(10);
        v_weights Weights_table := weights_table(1, 3, 7, 9, 1, 3, 7, 9, 1, 3, 1);
        v_sum INTEGER := 0;
        v_pesel INTEGER := PESEL;
    BEGIN
        IF LENGTH(PESEL) != 11 THEN
            v_boolean := 'false';
        ELSE
            FOR i IN REVERSE 1..v_weights.COUNT
                LOOP
                    v_sum := v_sum + (MOD(v_pesel, 10) * v_weights(i));
                    v_pesel := FLOOR(v_pesel/10);
                END LOOP;
            IF MOD(v_sum, 10) = 0 THEN
                v_boolean := 'true';
            ELSE
                v_boolean := 'false';
            END IF;
        END IF;
    
        RETURN v_boolean;

    END validate_pesel;    

  PROCEDURE print_documents IS
  BEGIN
    FOR record IN(SELECT "Document Description", "Document Name" FROM DOCUMENTS)
        LOOP
            IF record."Document Description" IS NOT NULL THEN
                DBMS_OUTPUT.PUT_LINE(record."Document Name");
            ELSE
                DBMS_OUTPUT.PUT_LINE('No Description');
            END IF;
        END LOOP;
  END print_documents;
  

END Task;
/
---Create package load for Task4

CREATE OR REPLACE PACKAGE Load AS

    PROCEDURE load_csv;
    
END Load;
/
CREATE OR REPLACE PACKAGE BODY Load AS

  PROCEDURE load_csv IS
    v_file   utl_file.file_type;
    v_text   VARCHAR2(1024);
  BEGIN
    v_file := utl_file.fopen('CSVTASK', 'file.csv', 'R', 1024);
    LOOP
        utl_file.get_line(v_file, v_text, 1024);
        INSERT INTO DOCUMENTS("Document Name", "Document Description") VALUES
            (REGEXP_SUBSTR(v_text, '[^;]+', 1, 1), REGEXP_SUBSTR(v_text, '[^;]+', 1, 2)); 
    END LOOP;
    utl_file.fclose(v_file);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
         NULL;
  END load_csv;
  

END Load;
/
---Insert test value to table Documents

 INSERT INTO DOCUMENTS("Document Name", "Document Description") VALUES
('Insert', 'test2')
/
 INSERT INTO DOCUMENTS("Document Name", "Document Description") VALUES
('Insert2', 'testInsert')
/
 INSERT INTO DOCUMENTS("Document Name") VALUES
('Insert3')
/
--Update one value to check trigger 

UPDATE DOCUMENTS
    SET "Document Description" = 'UpdateTest2'
    WHERE "Document Name" = 'Insert'
/
---create directory CSVTask

CREATE OR REPLACE DIRECTORY CSVTask as '&dir_path\csvTask\';
--load file

BEGIN
 load.load_csv();
END;
/
COMMIT;

spool off
