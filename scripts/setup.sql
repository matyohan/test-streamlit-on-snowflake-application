-- ==========================================
-- This script runs when the app is installed 
-- ==========================================

-- Create Application Role 
create application role if not exists app_instance_role;


--Creation du shcema app_instance_schema
create or alter versioned schema app_instance_schema;
grant usage on schema app_instance_schema to application role app_instance_role;


--La procedure sotckée UPDATE_REFERENCE : création et droits 
create or replace procedure app_instance_schema.update_reference(ref_name string, operation string, ref_or_alias string)
returns string
language sql
as $$
begin
  case (operation)
    when 'ADD' then
       select system$set_reference(:ref_name, :ref_or_alias);
    when 'REMOVE' then
       select system$remove_reference(:ref_name, :ref_or_alias);
    when 'CLEAR' then
       select system$remove_all_references();
    else
       return 'Unknown operation: ' || operation;
  end case;
  return 'Success';
end;
$$;

--grant usage
grant usage on procedure app_instance_schema.update_reference(string, string, string) to application role app_instance_role;



--Les procédures stockées  GET_DICTIONNARY_SOURCE

CREATE OR REPLACE PROCEDURE app_instance_schema.GET_DICTIONNARY_SOURCE(table_list string, information_schema_columns string)
RETURNS TABLE ()
LANGUAGE SQL
EXECUTE AS OWNER
AS 'DECLARE
        res RESULTSET DEFAULT (
        with 
        t1 as (
          select * from IDENTIFIER(:table_list)
        )
        ,t2 as (
          select TABLE_CATALOG,TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME ,IS_NULLABLE ,DATA_TYPE from IDENTIFIER(:information_schema_columns)
          
        )
       select t2.*,t1.min_date,t1.max_date, t1.date_scope from t1
        inner join t2
        on t1.TABLE_NAME=t2.TABLE_NAME and 
        t1.schema_source=t2.TABLE_SCHEMA);
        
    BEGIN
        return table(res);
END';


-- grant usage
grant usage on procedure app_instance_schema.GET_DICTIONNARY_SOURCE(string) to application role app_instance_role;



-- TABLE DE PARAMETRAGE : Creer le schema INPUT puis la table table_list 

CREATE or replace TABLE app_instance_schema.TABLE_LIST (
  table_name VARCHAR(100) DEFAULT NULL,
  database_source VARCHAR(100) DEFAULT NULL,
    schema_source VARCHAR(100) DEFAULT NULL,
    database_cible VARCHAR(100) DEFAULT NULL,
    schema_cible VARCHAR(100) DEFAULT NULL,
    date_scope VARCHAR(100) DEFAULT NULL,
    min_date DATE DEFAULT NULL,
    max_date DATE DEFAULT NULL
);

INSERT INTO app_instance_schema.TABLE_LIST
  VALUES
  ('Hypermarche_Achats','PC_ALTERYX_DB','HYPERMARCHE_DEV','PC_ALTERYX_DB','HYPERMARCHE','Date de commande','2019-01-01','2022-12-31');

GRANT SELECT ON TABLE app_instance_schema.TABLE_LIST TO APPLICATION ROLE app_instance_role;


-- CREATION DE L'APPLICATION STEAMLIT
create or replace streamlit app_instance_schema.streamlit from '/libraries' main_file='streamlit.py';

grant usage on streamlit app_instance_schema.streamlit to application role app_instance_role;
