-- Pull Rudo's Data
SELECT a.BundleId as "BundleId"
     , du.ApplicationId as "ApplicationId"
     , a.Name as "Name"
     , igu.UserName as "UserName"
     , du.Created AS "Timestamp for CMS Access Granted"
-- Dashboard (CMS) Event Users
FROM ratings_dashboardusers du
-- Rudo provided 54 applicationIds
JOIN (select * from authdb_applications 
      where applicationid in ('2F6916C5-FB3B-47D5-BD75-756F252FE2BF'
                             ,'60CEDA2A-09E8-4245-AB3B-7AA7C5345F9B'
                             ,'CDA15FB6-51A2-4DED-8BBF-D56D4934868A'
                             ,'3543216E-B5E1-4ADA-88CF-9B74AC871CF3'
                             ,'5BC7BC5A-1828-4E90-AA60-A2BD661715A6'
                             ,'71F78EA4-B343-464F-ADCF-157A505FBEE3'
                             ,'30C7C650-25DA-42A4-879A-5C4A7D7E677C'
                             ,'F780B233-1CE4-4FC6-9373-557346A022A4'
                             ,'3BAF0651-83DE-45A9-96BA-982623EB10CA'
                             ,'669887A7-884B-4E9F-85B1-870F837FFCA2'
                             ,'FF19DF38-A300-4EF4-BBEB-ABD911B5D330'
                             ,'0BDF9AD3-F558-40E5-A434-10196DBE679F'
                             ,'B2CFB2AA-0952-4A09-BE6A-51F483EC411C'
                             ,'C8D05B26-B343-408A-9D77-473F63594312'
                             ,'F20C46E3-9A5B-4707-A95B-04C4F3EA318C'
                             ,'F769FFDF-4D89-4023-BBCE-D0CACD3DFB44'
                             ,'CC180B5B-DD02-4674-849C-0CAEF3E98A3A'
                             ,'61ACA6FD-3A88-4427-8A2F-7D4F3B6E26B1'
                             ,'EC870B97-9C08-4C5A-B994-0B587BC97511'
                             ,'2F0C0E8A-2CDD-4626-B7D2-325A9E4DE15B'
                             ,'63757B69-0C12-41DD-921C-C0F60E3AC75B'
                             ,'E9CFCD8C-DEF8-4F80-8617-8FFD317F3930'
                             ,'AD8728AF-7D2E-49EC-9FF6-6C54031EDB06'
                             ,'F2C8BA8C-DCF9-40D2-B5DF-16C6E100EFB2'
                             ,'76A3A07F-FF24-4255-8324-763C38B599B3'
                             ,'147599CC-EB4C-47CB-94BF-0B6E0EBB9C80'
                             ,'255592ED-1EC8-431D-BC92-56CAA969FA46'
                             ,'B0C452B6-099B-420B-8A38-B016F7C314F8'
                             ,'397A38DA-37BD-4BDE-893A-A506A52AE9CF'
                             ,'7320867A-6688-4858-A515-88AA9FDE6654'
                             ,'428E1A6A-3D3B-4ED7-9368-C2CCF59B0CE3'
                             ,'ABDB28B7-4160-452C-B109-1DF60984BAF5'
                             ,'CF931628-07B6-4A07-AEDD-7976DD336223'
                             ,'F38D86CB-866B-4972-A967-98B0BE5F6B19'
                             ,'59FC2C08-44EC-4324-A236-EF9FF9F83BA1'
                             ,'B8C7C86C-AF46-4AAC-AA7B-C112D81781CE'
                             ,'DBAD4D38-A711-480F-AD29-DB1E3C52EEB7'
                             ,'9D1A1AA1-896D-4DB7-9E19-4BBBBCFD0223'
                             ,'9145B9D3-560F-42AB-AEAD-F1E9CF87C631'
                             ,'85672B96-3D37-4FEC-8087-13E8154107F7'
                             ,'F9DF0297-3E24-4462-A48E-D5113300E7F1'
                             ,'35BB658E-18A5-4A1D-BE5A-F79721A42CB2'
                             ,'2288A0E6-9CB0-4BB0-9DD1-B0A4DF7B4325'
                             ,'30773394-2148-4EF1-860C-8A2592DF22AC'
                             ,'582AE26B-FF7B-47B4-97AE-8E07F131E52B'
                             ,'4F102FC4-721C-4444-ADA7-2219BC84104B'
                             ,'3A54F30A-E1C9-4C89-AF6D-E99D5FB9770F'
                             ,'32683E81-9E23-4B48-9844-0A2567CEC52B'
                             ,'03D12DF1-7A86-411C-9589-AE30CC76F899'
                             ,'B4FF6018-AFE9-4BDF-9515-369405BD547C'
                             ,'C222A709-8006-42B0-81FB-31DC544616E5'
                             ,'69212268-D188-455A-94BB-1B783A0D709D'
                             ,'1E2DB3E5-E997-4640-8442-777E55385FC0'
                             ,'CACB31E7-3297-4677-B6E7-20B81645B34E')) a
on du.applicationid = a.applicationid
-- Get the Global User ID for Dashboard Event Users
JOIN authdb_is_users iu ON du.UserId = iu.UserId
-- Custom GlobalUsers table pulled using adhoc db_etl command (hashed username)
JOIN jt.authdb_is_global_users igu ON iu.GlobalUserId = igu.GlobalUserId
ORDER BY 1,2,5;

-- Check the Number of Events from the Data Pull (51)
SELECT count(distinct du.applicationid)
FROM ratings_dashboardusers du
JOIN (select * from authdb_applications 
      where applicationid in ('2F6916C5-FB3B-47D5-BD75-756F252FE2BF'
                             ,'60CEDA2A-09E8-4245-AB3B-7AA7C5345F9B'
                             ,'CDA15FB6-51A2-4DED-8BBF-D56D4934868A'
                             ,'3543216E-B5E1-4ADA-88CF-9B74AC871CF3'
                             ,'5BC7BC5A-1828-4E90-AA60-A2BD661715A6'
                             ,'71F78EA4-B343-464F-ADCF-157A505FBEE3'
                             ,'30C7C650-25DA-42A4-879A-5C4A7D7E677C'
                             ,'F780B233-1CE4-4FC6-9373-557346A022A4'
                             ,'3BAF0651-83DE-45A9-96BA-982623EB10CA'
                             ,'669887A7-884B-4E9F-85B1-870F837FFCA2'
                             ,'FF19DF38-A300-4EF4-BBEB-ABD911B5D330'
                             ,'0BDF9AD3-F558-40E5-A434-10196DBE679F'
                             ,'B2CFB2AA-0952-4A09-BE6A-51F483EC411C'
                             ,'C8D05B26-B343-408A-9D77-473F63594312'
                             ,'F20C46E3-9A5B-4707-A95B-04C4F3EA318C'
                             ,'F769FFDF-4D89-4023-BBCE-D0CACD3DFB44'
                             ,'CC180B5B-DD02-4674-849C-0CAEF3E98A3A'
                             ,'61ACA6FD-3A88-4427-8A2F-7D4F3B6E26B1'
                             ,'EC870B97-9C08-4C5A-B994-0B587BC97511'
                             ,'2F0C0E8A-2CDD-4626-B7D2-325A9E4DE15B'
                             ,'63757B69-0C12-41DD-921C-C0F60E3AC75B'
                             ,'E9CFCD8C-DEF8-4F80-8617-8FFD317F3930'
                             ,'AD8728AF-7D2E-49EC-9FF6-6C54031EDB06'
                             ,'F2C8BA8C-DCF9-40D2-B5DF-16C6E100EFB2'
                             ,'76A3A07F-FF24-4255-8324-763C38B599B3'
                             ,'147599CC-EB4C-47CB-94BF-0B6E0EBB9C80'
                             ,'255592ED-1EC8-431D-BC92-56CAA969FA46'
                             ,'B0C452B6-099B-420B-8A38-B016F7C314F8'
                             ,'397A38DA-37BD-4BDE-893A-A506A52AE9CF'
                             ,'7320867A-6688-4858-A515-88AA9FDE6654'
                             ,'428E1A6A-3D3B-4ED7-9368-C2CCF59B0CE3'
                             ,'ABDB28B7-4160-452C-B109-1DF60984BAF5'
                             ,'CF931628-07B6-4A07-AEDD-7976DD336223'
                             ,'F38D86CB-866B-4972-A967-98B0BE5F6B19'
                             ,'59FC2C08-44EC-4324-A236-EF9FF9F83BA1'
                             ,'B8C7C86C-AF46-4AAC-AA7B-C112D81781CE'
                             ,'DBAD4D38-A711-480F-AD29-DB1E3C52EEB7'
                             ,'9D1A1AA1-896D-4DB7-9E19-4BBBBCFD0223'
                             ,'9145B9D3-560F-42AB-AEAD-F1E9CF87C631'
                             ,'85672B96-3D37-4FEC-8087-13E8154107F7'
                             ,'F9DF0297-3E24-4462-A48E-D5113300E7F1'
                             ,'35BB658E-18A5-4A1D-BE5A-F79721A42CB2'
                             ,'2288A0E6-9CB0-4BB0-9DD1-B0A4DF7B4325'
                             ,'30773394-2148-4EF1-860C-8A2592DF22AC'
                             ,'582AE26B-FF7B-47B4-97AE-8E07F131E52B'
                             ,'4F102FC4-721C-4444-ADA7-2219BC84104B'
                             ,'3A54F30A-E1C9-4C89-AF6D-E99D5FB9770F'
                             ,'32683E81-9E23-4B48-9844-0A2567CEC52B'
                             ,'03D12DF1-7A86-411C-9589-AE30CC76F899'
                             ,'B4FF6018-AFE9-4BDF-9515-369405BD547C'
                             ,'C222A709-8006-42B0-81FB-31DC544616E5'
                             ,'69212268-D188-455A-94BB-1B783A0D709D'
                             ,'1E2DB3E5-E997-4640-8442-777E55385FC0'
                             ,'CACB31E7-3297-4677-B6E7-20B81645B34E')) a
      on du.applicationid = a.applicationid
JOIN authdb_is_users iu ON du.UserId = iu.UserId
JOIN jt.authdb_is_global_users igu ON iu.GlobalUserId = igu.GlobalUserId;


-- Double Check the 3 Events Don't have Dashboard Users (They Don't)
SELECT *
FROM ratings_dashboardusers
WHERE LOWER(applicationid) IN ('1e2db3e5-e997-4640-8442-777e55385fc0', 'cacb31e7-3297-4677-b6e7-20b81645b34e', '2f0c0e8a-2cdd-4626-b7d2-325a9e4de15b')