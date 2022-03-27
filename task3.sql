---Create package load for Task4

CREATE OR REPLACE PACKAGE Load AS

    PROCEDURE load_csv;
    
END Load;

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