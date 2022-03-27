BEGIN
task.print_documents();
END;

BEGIN
DBMS_OUTPUT.PUT_LINE(task.validate_pesel(41061488831));
DBMS_OUTPUT.PUT_LINE(task.validate_pesel(61061488831));
END;