select *
from authdb_applications
where lower(name) like '%doubledutch%16%';

-- applicationId: 9923FE97-48CB-45D7-B42C-DEAEB2EB53B6

-- User Id: 45888635
-- Pulled from CMS.

select *
from authdb_is_users
where userid = 45888635;

-- globalUserId: 31800539-3E0C-4247-A8FE-3CFBC5E5D78E

select *
from fact_actions_live
where application_id = '9923fe97-48cb-45d7-b42c-deaeb2eb53b6'
and global_user_id = '31800539-3e0c-4247-a8fe-3cfbc5e5d78e'
and created >= '2016-01-01';

-- submitListSearch exists.


select *
from authdb_applications
where lower(name) like '%fi%europe%';

-- applicationId: E7DBE508-1E84-4EF9-BF3D-577C789C4DE5

-- User Id: 45969064
-- Pulled from CMS.

select *
from authdb_is_users
where userid = 45969064;

-- globalUserId: CCE7F1C9-34C1-4351-849C-41ACF1BC0F0A

select *
from fact_actions_live
where application_id = 'e7dbe508-1e84-4ef9-bf3d-577c789c4de5'
and global_user_id = 'cce7f1c9-34c1-4351-849c-41acf1bc0f0a'
and created >= '2016-01-01';

-- submitListSearch does not exist.