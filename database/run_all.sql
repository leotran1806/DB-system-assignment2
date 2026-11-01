-- Run only after completing the TODO DDL / DML / routine definitions.
-- MySQL CLI usage from this directory:
--   mysql -u root -p < run_all.sql
-- In MySQL Workbench, open and execute each script in order instead of using SOURCE.
SOURCE 01_create_tables.sql;
SOURCE 02_sample_data.sql;
SOURCE 03_triggers.sql;
SOURCE 04_procedures.sql;
SOURCE 05_functions.sql;
