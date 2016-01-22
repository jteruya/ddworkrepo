select created
            , application_id
            , global_user_id
            , binary_version
            , app_type_id
     , metadata
     , jsonb_array_elements(metadata->'metadata'->'beacons')->>'uuid' as uuid
     , jsonb_array_elements(metadata->'metadata'->'beacons')->>'major' as major
     , jsonb_array_elements(metadata->'metadata'->'beacons')->>'minor' as minor
from public.fact_states
where application_id = '95fb910b-8d80-4340-8b5f-5bf8a99b149a'
and identifier = 'beacons'
and created >= '2015-06-03'
and created < '2015-06-06'
and app_type_id in (1,2)
and global_user_id = '0022128d-18a7-4d00-b477-7c5a1891441a'
and metadata->'metadata'->>'beacons' <> '[]';



