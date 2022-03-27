--create Table Documents
CREATE TABLE DOCUMENTS
    ("Document Id" INT GENERATED ALWAYS AS IDENTITY CONSTRAINT doc_pk PRIMARY KEY,
     "Document Name" VARCHAR2(50) CONSTRAINT doc_nam_nn NOT NULL,
     "Document Description" VARCHAR2(4000),
     "Record Timestamp" TIMESTAMP CONSTRAINT doc_rec_tim_nn NOT NULL,
     "Timestamp" TIMESTAMP CONSTRAINT doc_tim_nn NOT NULL,
     "Record User Id" VARCHAR2(50) CONSTRAINT doc_rec_use_nn NOT NULL,
     "User Id" VARCHAR2(50) CONSTRAINT doc_use_nn NOT NULL
    );

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