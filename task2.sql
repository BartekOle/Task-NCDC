---Create package Task for Task2

CREATE OR REPLACE PACKAGE Task AS

    FUNCTION validate_pesel (
      PESEL IN NUMBER
    ) RETURN VARCHAR2;

  PROCEDURE print_documents;
    
END Task;
   
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