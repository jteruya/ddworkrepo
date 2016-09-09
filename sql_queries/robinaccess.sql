--======================================================================================================
--Create the schema
CREATE SCHEMA rterry;

--Create the read-only user for the views
CREATE USER rterry LOGIN PASSWORD 'rterry1234';

-- Reset Password
--ALTER USER rterry PASSWORD 'terry123';

--Grant the access permissions to all Views in the "report" schema
--GRANT CONNECT ON DATABASE analytics TO rterry;
GRANT CONNECT ON DATABASE etl TO rterry;
GRANT USAGE ON SCHEMA PUBLIC TO rterry;
GRANT USAGE ON SCHEMA eventcube TO rterry;
GRANT USAGE ON SCHEMA channels TO rterry;
--GRANT USAGE ON SCHEMA cs TO julia;
GRANT USAGE ON SCHEMA report TO rterry;
GRANT SELECT ON ALL TABLES IN SCHEMA PUBLIC TO rterry;
GRANT SELECT ON ALL TABLES IN SCHEMA eventcube TO rterry;
GRANT SELECT ON ALL TABLES IN SCHEMA report TO rterry;
GRANT SELECT ON ALL TABLES IN SCHEMA channels TO rterry;
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC GRANT SELECT ON TABLES TO rterry;
ALTER DEFAULT PRIVILEGES IN SCHEMA eventcube GRANT SELECT ON TABLES TO rterry;
ALTER DEFAULT PRIVILEGES IN SCHEMA report GRANT SELECT ON TABLES TO rterry;
ALTER DEFAULT PRIVILEGES IN SCHEMA channels GRANT SELECT ON TABLES TO rterry;
GRANT ALL ON SCHEMA rterry to rterry;
COMMIT;
ALTER DEFAULT PRIVILEGES IN SCHEMA PUBLIC GRANT SELECT ON TABLES TO rterry;