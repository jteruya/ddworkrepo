--======================================================================================================
--Create the schema
CREATE SCHEMA julia;

--Create the read-only user for the views
CREATE USER julia LOGIN PASSWORD 'julia1234';

-- Reset Password
--ALTER USER rterry PASSWORD 'terry123';

--Grant the access permissions to all Views in the "report" schema
GRANT CONNECT ON DATABASE analytics TO julia;
GRANT USAGE ON SCHEMA PUBLIC TO julia;
GRANT USAGE ON SCHEMA eventcube TO julia;
GRANT USAGE ON SCHEMA cs TO julia;
GRANT USAGE ON SCHEMA report TO julia;
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO julia;
GRANT SELECT ON ALL TABLES IN SCHEMA eventcube TO julia;
GRANT SELECT ON ALL TABLES IN SCHEMA report TO julia;
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC GRANT SELECT ON TABLES TO julia;
ALTER DEFAULT PRIVILEGES IN SCHEMA eventcube GRANT SELECT ON TABLES TO julia;
ALTER DEFAULT PRIVILEGES IN SCHEMA report GRANT SELECT ON TABLES TO julia;
GRANT ALL ON SCHEMA julia to julia;
COMMIT;
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC GRANT SELECT ON TABLES TO julia;