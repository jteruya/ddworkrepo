drop table if exists jt.nonseamless_delivered;
drop table if exists jt.nonseamless_delivered_once;
drop table if exists jt.nonseamless_delivered_more_than_once;
drop table if exists jt.nonseamless_events_lvl_2;
drop table if exists jt.nonseamless_events_lvl_3;
drop table if exists jt.nonseamless_events_lvl_4;
drop table if exists jt.nonseamless_events_spine;
drop table if exists jt.nonseamless_events_summary;
drop table if exists jt.nonseamless_strange_paths;
drop table if exists jt.nonseamless_fact_analysis;
drop table if exists jt.nonseamless_login_funnel;

/* Table: seamless_delivered
   Desciption: Email Delivery Staging Table */

select a.applicationid
     , b.name
     , b.eventtype
     , a.messageid
     , a.subject
     , case
         when a.subject like 'Password Reset%' or a.subject like 'Restablecer la contraseña%' then 'passwordresetemail'
         when a.subject like '%sent you a message%' then 'messagealertemail'
         when a.subject like 'Welcome to %' or a.subject like 'Bienvenido %' then 'welcomeemail'
         when a.subject like 'Today at %' or a.subject like 'Today @ %'then 'dailydigestemail'
         when a.subject like 'Your Session Notes' then 'sessionnotealertemail'
         when a.subject like 'Your Beacon Message Info' then 'beaconmessageinfoemail'
         when a.subject like 'Exhibitor Opportunity %' then 'exhibitoropportunityemail'
         when a.subject like 'Your Leads Report %' then 'leadsreportemailemail'
         when a.subject like 'Set Up Lead Scanning For %' then 'setupleadscanningcalltoactionemail'
         when a.subject like 'Activity Flagged %' then 'activityflaggedemail'
         when a.subject like '% has requested a meeting' then 'meetingrequestemail'
         when a.subject is null then 'nullsubjectemail'
         else 'unknownemail'
       end as emailsubjectcatg
     , a.recipientemail
     , a.senderemail
     , a.eventstatus
     , a.clickurl
     , a.id
     , a.eventtimestamp
into jt.nonseamless_delivered
from mailgun_events a
join jt.tm_eventcubesummary b
on a.applicationid = b.applicationid
where a.eventstatus = 'delivered'
and a.subject like 'Welcome to %'
and (a.applicationid = '1C87DF2E-4D34-446A-80E2-013E3BAC7170'
or a.applicationid = 'F1F5DF7D-E81C-4201-9B94-089163B7EF0F'
or a.applicationid = 'DC12CD48-BB7F-4955-917A-0F0182683E4F'
or a.applicationid = 'FBAA081E-596E-47E4-9F46-4089A836CF71'
or a.applicationid = '61035230-5FCC-44F0-ADD8-594393C96895'
or a.applicationid = '9894EBB9-D345-4753-8DC3-64E50790B293'
or a.applicationid = '3E943526-AFE6-417F-BB1A-6E992B37A7BA'
or a.applicationid = '5D376E05-A8C2-4F14-9CE2-70A2DFECE85E'
or a.applicationid = '22279E2D-212D-41B7-9854-776FE915720E'
or a.applicationid = '0020571D-FD4D-49BB-8B28-A2D3800FF318'
or a.applicationid = '5B6CF6E5-D5FB-4AB0-8BA4-AA962BB3AD3D'
or a.applicationid = '1748F562-9027-485D-92C4-B01F59498E38'
or a.applicationid = 'C800ED62-8B9B-48B3-B918-D05A21A00984'
or a.applicationid = 'B4B30CC1-4389-4C8C-8943-DE27EFDD9EB2'
or a.applicationid = '34ABBE07-7264-4CA2-AA26-DFF8EEB108E6'
or a.applicationid = 'C4291322-B9D5-4584-8A07-1DCCDFA28DF5'
or a.applicationid = '41C1F41E-B4BE-4257-86F9-22C47C655793'
or a.applicationid = '30E710D1-E90F-46CC-8C26-4A97C019EEBC'
or a.applicationid = 'F713DC57-029E-43C2-B819-65A1EA525595'
or a.applicationid = '81D2E11F-1B0F-4275-A0D9-6A42B4F9E1AD'
or a.applicationid = '14C308B3-0B97-42DC-916A-81EFE86A2B9A'
or a.applicationid = 'F125BF81-621C-4762-B8D8-858DE2B5A470'
or a.applicationid = '6DCB03A0-FDA4-4F34-9DCC-A69C6985CAA3'
or a.applicationid = 'D1C3C46E-42F0-4CE8-A2CC-D25683F2575B'
or a.applicationid = '9881260B-79B8-4CFC-BC9B-D674AC367BBC'
or a.applicationid = '5C41B176-9B34-4C9A-85A1-DCDFF2309473'
or a.applicationid = '267E5070-4188-4C11-B027-F2431240161D'
or a.applicationid = '295BB4E3-53C1-45A7-BCE3-011B93A3EFE5'
or a.applicationid = 'C1BEDD2C-E106-4B0D-9F75-084BE645D221'
or a.applicationid = 'C268B100-C6CC-493C-8057-0A07EFB94F2A'
or a.applicationid = '79EB81B7-264D-44E4-AC96-273322BB6DCD'
or a.applicationid = '60EACA1B-FD27-4892-8B33-3D2CD54F6D1E'
or a.applicationid = '4B4FE5BD-1623-49FE-A334-7505EC18C99F'
or a.applicationid = '24A1B125-25F8-4C57-89F2-8298603E5278'
or a.applicationid = '49A81F2B-28B0-42F2-A4DF-878E7F4AE184'
or a.applicationid = '98056656-C959-4295-95AD-CAD151F5D2A8'
or a.applicationid = '5507AAC3-C433-4759-9FCF-D8AA5FD1CCBD'
or a.applicationid = 'BF461C07-1F2A-409B-A81F-0688213CF6FF'
or a.applicationid = 'B9B9B941-F899-45C8-8CAF-18B0CAE05D8B'
or a.applicationid = '05A697B9-D60E-49D1-933B-1BF92EF35D71'
or a.applicationid = '20840C72-788B-4C9E-9D91-2820A81A79A5'
or a.applicationid = 'A9980DC7-E857-4F97-9039-5038957AD769'
or a.applicationid = 'D3952526-E615-46F9-A5BE-6A8BA9880A1F'
or a.applicationid = '0CC5F95F-7AF7-4F62-8FC6-733BD6792829'
or a.applicationid = 'D5C2B3C6-2BB2-4968-8DB6-8CCFB6FA7AC8'
or a.applicationid = '0759561E-172A-41F6-92DC-948054D60E7D'
or a.applicationid = '2E3E340E-C3CF-4784-93E8-A1898E7C9AB6'
or a.applicationid = '397A38DA-37BD-4BDE-893A-A506A52AE9CF'
or a.applicationid = '72693855-1406-4690-BBE5-B625AA6DE5C0'
or a.applicationid = '46101742-D739-4465-97A8-D0E4B645465F'
or a.applicationid = '618439CC-6833-45E5-94FE-E93B70A2A0E0'
or a.applicationid = 'AF668F70-403C-403B-8F86-1480D77E66D0'
or a.applicationid = '8CE79357-4829-428C-A57C-246B286503B7'
or a.applicationid = '4568A817-5191-4002-A6BC-2B65FA0E756C'
or a.applicationid = '5F70274F-3C50-4CDE-8389-2B88F17E8031'
or a.applicationid = '6B6BB985-1D7C-4572-898E-80955D05E12C'
or a.applicationid = '15E85CF6-B7EC-4031-ADBE-84EDDFFCF6A4'
or a.applicationid = 'E4DA1784-40AE-4BF4-9806-AE558C9E3C73'
or a.applicationid = '6CA83DB6-86F3-4AB1-AC4A-E9C1FD46FF2D'
or a.applicationid = '5555825B-F5FA-4BE3-B083-24443BFE01AA'
or a.applicationid = 'FF5DD039-D43B-46C1-ADDB-63E0EB6227BE'
or a.applicationid = '2CA10389-EDE6-469C-BA7C-822A7DD52E67'
or a.applicationid = '10BB5DCB-D514-47F4-B2E1-9F3A67269529'
or a.applicationid = 'A4377274-04E9-4579-9D12-B0040A587C7A'
or a.applicationid = '628AE2DB-EB57-48C8-952E-255AF4C3E22A'
or a.applicationid = '4F0826EF-D346-4277-A85B-327B008E6132'
or a.applicationid = '8623B169-A61C-40AF-9849-33839A22ED70'
or a.applicationid = '90B38C50-8F86-441A-BBF7-382966EEFC70'
or a.applicationid = '9E8E55CD-6B38-41A3-82F7-521A56EFBA43'
or a.applicationid = 'E1DDC2D0-DD8D-4650-B91F-65C9B93C728F'
or a.applicationid = '1B6CB721-6F58-493F-A7BC-724AA276BB0E'
or a.applicationid = 'B18B18F6-CB0C-4289-9DC5-7F4A12261DC0'
or a.applicationid = 'B4ECAC21-91D4-4666-8A8A-89EAFEF321D1'
or a.applicationid = '047D92E3-EBFD-4EB6-BF05-AB14533BA112'
or a.applicationid = 'E539125E-A725-4DDF-899E-F5B6ABAB41AB'
or a.applicationid = '5C7CF891-6288-46E3-A353-09DEDAFBEB7C'
or a.applicationid = '03E5B58A-1A9E-43AF-83D7-B8EE58BD0BF4'
or a.applicationid = '68803BAF-CFA5-4E86-8318-858529008049'
or a.applicationid = '59C409AF-9383-4E8B-9044-8C0742822A98'
or a.applicationid = '6411727D-9E91-47AE-8732-9912444CF27C'
or a.applicationid = '8ABDA130-2D08-4909-965C-A67766D85D0D'
or a.applicationid = 'F2DF3932-1CAC-4D27-9B09-A6C26D85AB4A'
or a.applicationid = 'AE55D8B5-21C4-4B1C-B797-A95C882533D9'
or a.applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or a.applicationid = 'AFC442D8-9F95-4EE2-827B-C38AB45D929B'
or a.applicationid = '915DB044-EBCC-4442-8520-D91AE4478283'
or a.applicationid = '5BBC996B-7672-4BF0-9DCD-F531EABEA919'
or a.applicationid = '840BF386-EAE0-420C-94FF-37D4FEFF8B3B'
or a.applicationid = 'CF33F5ED-ED4D-430E-8FBC-53C2160A3F2B'
or a.applicationid = '36D5119E-D91A-4B4E-83BF-79884FA0113A'
or a.applicationid = '80F8BC6E-E35E-4097-84A0-85CA83EE3C10'
or a.applicationid = '7585ED89-9D5A-43C5-AFF7-C4D4207E846B'
or a.applicationid = '551F457D-1A63-47F3-9DDB-13CE37C11F93'
or a.applicationid = '69212268-D188-455A-94BB-1B783A0D709D'
or a.applicationid = 'BDC2D475-A1B3-4156-AF72-2ACDEC3DD6D4'
or a.applicationid = '499958F3-95C8-4B87-92BA-40C6CCE872D7'
or a.applicationid = '2C94CC37-ABAA-419B-AAEF-4FC922F820E8'
or a.applicationid = '004165AE-BA1B-4A7D-A107-5BDB46751430'
or a.applicationid = '445D91A6-3D72-4085-9DE0-74A9754E663D'
or a.applicationid = '91880A90-4383-4C57-BD3C-8F9E13EEB65B'
or a.applicationid = '89BCEC73-DEE2-48C5-B576-9E0A52D75956'
or a.applicationid = '7325E7C8-134F-407C-92F4-A646CACD2C99'
or a.applicationid = '407D88F0-DE75-48BB-839F-AB539EA58A5D'
or a.applicationid = '3128084D-EE77-4224-A368-B56EF844DCCB'
or a.applicationid = '3C89569C-A85C-492A-B9A6-F14D9FC35438'
or a.applicationid = 'A1CBECE2-D30C-47CD-AE5A-02E38E39021D'
or a.applicationid = 'C55FCED8-23F8-4D45-8880-03DBBB2718F1'
or a.applicationid = 'EC870B97-9C08-4C5A-B994-0B587BC97511'
or a.applicationid = 'EF061CAD-5058-4E80-8668-283B47C91334'
or a.applicationid = '35EB0C3E-EFD4-41E9-B68B-382289BB6025'
or a.applicationid = '57585F78-B5B8-485E-ABA8-3F034A8E01C7'
or a.applicationid = '27E55832-B293-4078-81A8-457085B8CAC8'
or a.applicationid = 'E5727682-4CA3-4F8C-B834-4757532EFB71'
or a.applicationid = 'AC9805E4-0D3B-45CF-86B5-5014222EF502'
or a.applicationid = 'E26D633B-9A95-408B-871B-51F8FDE9CB5A'
or a.applicationid = '6C0C3BEF-65D1-4AE9-A722-715A947A68BF'
or a.applicationid = '9F648D07-780F-4B5E-B0FB-754EFFD0DEA2'
or a.applicationid = '75EE75C1-914B-403A-ADD5-7CC3AD37B0B9'
or a.applicationid = '21B69912-BF05-4455-B04D-86E65E368B8F'
or a.applicationid = '83063347-BD87-4128-B0CB-BEF9D7D58E84'
or a.applicationid = '6A4AFBF8-EBD5-4447-9F26-C13FA4F6ED63'
or a.applicationid = '30CC5B5E-5EBD-49BB-80FB-CB308A3A33EC'
or a.applicationid = 'A27B69FC-1507-4F3E-8156-D93D8AE2E952'
or a.applicationid = '60C5959A-389C-446A-8F75-1FF9E0CA3EBF'
or a.applicationid = 'C9A38227-BEEE-4156-B427-38EB46ACB9B0'
or a.applicationid = '8DDFC805-7F99-47A6-A086-46CB3CCD4D3B'
or a.applicationid = 'CC105B77-8363-4BC4-AA63-51DAFF556898'
or a.applicationid = 'BE86E144-CEA0-4556-B11D-63FFC7A0B6F3'
or a.applicationid = 'CF931628-07B6-4A07-AEDD-7976DD336223'
or a.applicationid = 'D08B4C8C-A696-4CE0-8A1C-7AE4C590EA01'
or a.applicationid = '98209457-C8F4-4BBB-B124-A301B1A93C72'
or a.applicationid = '19732564-506D-4C42-B37F-D617B523F371'
or a.applicationid = 'D5E94CC0-A1ED-4E3C-BD06-E0BE702C911A'
or a.applicationid = '21CB044C-C9D5-402D-82A2-F21D097F65C1'
or a.applicationid = 'CF1D7257-AD44-4E91-9B4C-F5BBB60A5665'
or a.applicationid = '158DFBA5-2FFE-42F7-85C9-4EBB3896DB6A'
or a.applicationid = '72103917-FF18-4468-BD84-71C290442D71'
or a.applicationid = 'AE11769E-E76E-4723-BE12-90DFC5B33F2D'
or a.applicationid = '14A71E48-3864-4B1F-8553-A9A0214322B9'
or a.applicationid = '12384B4C-1FEB-4ABE-9EDE-B2FF5C1C7AA9'
or a.applicationid = '2B071D94-2E5F-4FA0-B9E7-B8C2B3D29CA0'
or a.applicationid = 'A56A3D12-9E7A-4BB0-B735-D4189EAA453A'
or a.applicationid = 'C9BAEF19-5D80-4176-B711-F104D18608B7'
or a.applicationid = '9F07CB63-2016-44E1-86E9-F138AEAA2CF5'
or a.applicationid = 'E64D961F-A9ED-4A1C-90CD-2479ECB6BC54'
or a.applicationid = '158077FB-878D-44D5-94C3-34062B8EE559'
or a.applicationid = '2927C51E-AE58-49DB-B116-3416A8E2BE23'
or a.applicationid = 'F5A78B81-CA56-42A6-B297-3AE3E5188181'
or a.applicationid = 'BB36EE30-C3ED-49EF-A99B-3B1D6E0700EF'
or a.applicationid = '22171396-AF8B-4D75-B969-47CC9ABE6069'
or a.applicationid = '5D24F1D6-7053-4E85-8226-4BF049ED74C6'
or a.applicationid = 'DC8C8137-D49C-4132-85B9-4E9EE0B6FBA6'
or a.applicationid = '464D5101-0C2E-46EB-9D69-873C9E01DBA9'
or a.applicationid = '34ABF1E0-1DCA-4B84-BB54-92090C0E5128'
or a.applicationid = '49CD9291-A4DE-40B1-B578-A0C019A5150D'
or a.applicationid = 'FB081147-9320-48E2-BE47-C24DD7451E84'
or a.applicationid = 'A261297C-403C-45D0-B5CE-CE08BDB635A6'
or a.applicationid = 'A1B78705-EDBA-4B55-B2B6-CEF2D0D84229'
or a.applicationid = '502D27D6-AE1B-461F-82C3-E55B4F44C796'
or a.applicationid = '0BBF438D-195B-4E70-AFD5-FDA0845793A3'
or a.applicationid = 'BD874883-0E1C-4EC2-883F-09F3685D04AF'
or a.applicationid = '61C55F7D-E75A-4563-9E0D-0A719ADABCB0'
or a.applicationid = '98B3331B-AEBC-47AB-8BB8-10F8D8C51602'
or a.applicationid = '0A99856E-DFC0-46F2-8116-4B014F4DD175'
or a.applicationid = 'BF21690A-B394-4EA2-AD50-4F3CDBA21017'
or a.applicationid = '3C9561CB-B2E1-481D-9B42-6FEA976DBA1F'
or a.applicationid = '36234724-7532-467E-A7DE-7A1F2A32BFE2'
or a.applicationid = 'E34E75DB-5845-4655-BD33-B1D7B931CFD4'
or a.applicationid = 'C74AA76A-F1C3-4BE1-9848-C962841A0FC8'
or a.applicationid = 'C5345CF0-17BB-4360-8E0D-E3DC8A69B6A4'
or a.applicationid = 'DCAC79D2-2765-45A0-B3C8-E8180B8EFAAD'
or a.applicationid = '076EC55B-3EEF-451F-9165-EB240B6A00AB'
or a.applicationid = '92A9D6AC-1011-4D78-ADD0-EFEA6458A484'
or a.applicationid = 'CD4EE7BB-90EA-465F-B42A-09FF920DA68D'
or a.applicationid = '83C4B886-A51F-40E0-9796-1C8C9CE77A9E'
or a.applicationid = '24041366-69B2-4E48-9A00-21D5634B08AA'
or a.applicationid = '31577CBA-2521-45C4-A81D-2A88AD1A4327'
or a.applicationid = 'A94CBC3F-E422-4E4F-9C8E-2AD52318F244'
or a.applicationid = '6CB13100-92D1-40F6-8B93-4AB3D9B05A9A'
or a.applicationid = '8947DCC6-FD51-47E1-A5EC-5AC2D3A54300'
or a.applicationid = 'FF2CE048-D431-4F34-97DC-6FAB0111BEB7'
or a.applicationid = 'F78AB4AC-653C-4420-99E1-9059C0011EC1'
or a.applicationid = '775E10E8-924A-4148-B134-9FCAD3304883'
or a.applicationid = '0317001C-A76E-4F48-A743-E99F4F294ED2'
or a.applicationid = '3036320D-80DE-4003-B4C4-12C6D93CCF9A'
or a.applicationid = '8EC1B49B-E55A-4D44-B381-3FAF22769444'
or a.applicationid = '4471573B-4F5E-472B-AC5C-5609E1613B86'
or a.applicationid = '69C2C5EF-F115-4016-8C2C-57626D279BB3'
or a.applicationid = 'C6510A51-675F-411C-B86C-7F03DBA7BE53'
or a.applicationid = 'F7F2FB30-796B-4574-B7E3-9EEBC2AA2D52'
or a.applicationid = '2192130E-A4AA-421F-898C-B7FEF832061E'
or a.applicationid = '5E2969E7-892A-4C2B-B0B9-CE26FBAD5D05'
or a.applicationid = '13F31EEB-D6D8-411C-B718-D9973888695A'
or a.applicationid = '853A78B0-8C03-43BB-8E68-E3C0EA18F77B'
or a.applicationid = '7DEB845E-32A6-4690-93C2-547D24793AAB'
or a.applicationid = '376D080F-D513-4CAB-937B-5A5D0A9FC909'
or a.applicationid = '7424ECE2-EF48-4A5E-BDD9-7FE0C4B407FD'
or a.applicationid = '03488131-6A0B-4D1E-9E1C-8D271C43AD46'
or a.applicationid = '90523B50-5487-4122-9055-9EFA1AFB03D6'
or a.applicationid = 'CD8252E7-59F2-4333-9FD9-A1784F857A79'
or a.applicationid = '2B5793ED-7EE9-489F-ACC7-B22AC2249473'
or a.applicationid = '3EDD4327-8005-4BDC-8D56-195D7EEA9571'
or a.applicationid = '55FF0FA7-EC70-46FF-BE3A-1F85DB13E0F9'
or a.applicationid = 'F37795AE-86CC-4C23-9DB4-607172331C94'
or a.applicationid = 'E7ABB189-7125-482D-B765-765E3E478C7B'
or a.applicationid = 'C340B9C8-12C2-460D-80C3-77C311AAADDC'
or a.applicationid = '4A2C9560-35B2-4902-B277-A3A1C2E092EC'
or a.applicationid = 'C0561536-A8F6-41A2-8E61-B18006EA94B5'
or a.applicationid = '32652123-AB63-4952-8582-B3BA45A8DE30'
or a.applicationid = 'FC59A38D-B59F-4F37-95B6-CA8EE546F786'
or a.applicationid = 'F359AB49-D080-4077-940F-D7AF76FF100B'
or a.applicationid = '32D100CE-E774-4C78-99CA-19AE7ADC02F7'
or a.applicationid = '6C914223-6063-4B1F-989F-2EEBC490FD15'
or a.applicationid = '50F47B9C-BE0A-4EF0-84A4-3681E640C9F8'
or a.applicationid = '2A6F46A7-E223-4088-BE7A-3B04AA249DEC'
or a.applicationid = '87AE73B0-2C59-4FE4-9308-5201CC69AD31'
or a.applicationid = '4CCB7DF4-2DF3-46AC-89A1-5ADC5E18F30F'
or a.applicationid = 'FE70FD32-5225-451F-B404-614C49879771'
or a.applicationid = 'BFA57F38-F885-45D5-B912-8413F09EF7B9'
or a.applicationid = '98E022CE-2568-4546-9E26-99316E9509A7'
or a.applicationid = '724D7D18-97DE-4E31-B472-9EC51FA7C743'
or a.applicationid = 'AAC351D1-7510-42D6-988D-9F25831D1CD5'
or a.applicationid = '548984B0-3F02-4D6F-B593-D39F093265B2'
or a.applicationid = '8DEC92AC-9A40-4C42-9265-ED71B0EF0569'
or a.applicationid = 'ED8768E2-ED06-43B2-AE02-18296C0D3B5A'
or a.applicationid = '5DA8D944-178E-4E81-ADAB-42A71A17C7DC'
or a.applicationid = '741E45D7-8861-4561-B4A2-4A09A4C30899'
or a.applicationid = '0B80C244-7A66-4FA1-8EEA-A9C09E6221C6'
or a.applicationid = 'B9DAAC7C-84B0-4C96-8EE5-B7CAADC0F0D7'
or a.applicationid = 'C8660149-BA10-4681-9C49-C451878D8DE8'
or a.applicationid = '9033D8CC-2C02-4BF4-BD37-D6509EE0D5CA'
or a.applicationid = '0668893E-7234-451B-AF10-E9B4E198721F'
or a.applicationid = 'B1A5AE3C-A761-4F9C-B0B8-EBDA06D9FC84'
or a.applicationid = '5C3F4F7E-4621-4676-98B8-1514DF937761'
or a.applicationid = '09A40898-0D05-434D-9E7F-1F2C569DED4B'
or a.applicationid = 'ED6770D8-C409-4E56-A745-2AC02DE1CEF2'
or a.applicationid = '6C172B62-3628-4AAB-8A28-3F3B7B004884'
or a.applicationid = 'AE7702DA-DE93-4DC0-9852-4411AB0E8581'
or a.applicationid = '7129A38D-7BB1-4682-B9D3-5A38C873E6D4'
or a.applicationid = '82270BB7-4492-4485-BEEF-7607DCA88870'
or a.applicationid = '7B9C1F9A-5437-41AF-9028-7A5A69B243B4'
or a.applicationid = 'EE9F1AFA-315C-49C2-A944-84339C1FC4BA'
or a.applicationid = '47EE4849-67C9-414D-9655-84A8CD3138D3'
or a.applicationid = 'BADEA36A-EB07-41AF-B02E-8D8D7A8B4CEE'
or a.applicationid = '06CB614E-5A1F-4912-9385-D1F80136273B'
or a.applicationid = 'D36EB7C2-3D86-4F52-9D11-D907595B5CB0'
or a.applicationid = 'ED8F2044-7982-42D7-B18B-FBED992BF4E1'
or a.applicationid = 'D25F4719-BEF8-4FF7-A8FC-1BDDCB4D3569'
or a.applicationid = '208FDD6E-94FB-42CC-B46D-2739C79397B4'
or a.applicationid = 'C222A709-8006-42B0-81FB-31DC544616E5'
or a.applicationid = 'FD3458D9-C62F-408D-9831-4925F36D523A'
or a.applicationid = 'B6C8F258-D3F0-4C94-854D-57F9F8A77B22'
or a.applicationid = '7F9D075A-0A50-4A21-98C6-790AF25EA083'
or a.applicationid = 'BD7245E4-D798-4C37-874A-A0301F09BAC4'
or a.applicationid = '3BB2E2C1-E58A-49E1-84B7-AA3BD23D52A5'
or a.applicationid = '694046DE-223A-4E32-B401-FB654A95EC1E'
or a.applicationid = '284BB2A0-516D-4022-B4F3-FC1F5BFB9425'
or a.applicationid = 'BB1B07C6-9A2D-4102-A3B0-2790BF44C079'
or a.applicationid = '5BD23FA4-D45B-4A4A-AFBB-3013FC6A54A8'
or a.applicationid = '49AEEA59-61DF-40E9-8621-43469A7AAD7F'
or a.applicationid = '9866A4B3-FDFA-4F96-81A6-4DBF3181A25E'
or a.applicationid = '4424521C-58D2-4800-83CD-578272616125'
or a.applicationid = '9E235184-B24B-4633-812D-90F94ED00DB0'
or a.applicationid = 'F6F545E7-F039-49A6-8F5C-9A7C03C36D98');

/* Table: seamless_delivered_once
   Description: This contains emails that were only delivered once. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.nonseamless_delivered_once
from jt.nonseamless_delivered
group by 1,2,3,4,5,6,7
having count(*) = 1;

/* Table: seamless_delivered_more_than_once
   Description: This contains emails that were delivered more than once - anomaly. */

select applicationid
     , name
     , eventtype
     , recipientemail
     , senderemail
     , messageid
     , emailsubjectcatg
into jt.nonseamless_delivered_more_than_once
from jt.nonseamless_delivered
group by 1,2,3,4,5,6,7
having count(*) > 1;


/* Table: seamless_events_lvl_2
   Description: This contains all emails with 'delivered' and/or 'failed' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
into jt.nonseamless_events_lvl_2
from mailgun_events
where (eventstatus = 'delivered' or eventstatus = 'failed')
and (applicationid = '1C87DF2E-4D34-446A-80E2-013E3BAC7170'
or applicationid = 'F1F5DF7D-E81C-4201-9B94-089163B7EF0F'
or applicationid = 'DC12CD48-BB7F-4955-917A-0F0182683E4F'
or applicationid = 'FBAA081E-596E-47E4-9F46-4089A836CF71'
or applicationid = '61035230-5FCC-44F0-ADD8-594393C96895'
or applicationid = '9894EBB9-D345-4753-8DC3-64E50790B293'
or applicationid = '3E943526-AFE6-417F-BB1A-6E992B37A7BA'
or applicationid = '5D376E05-A8C2-4F14-9CE2-70A2DFECE85E'
or applicationid = '22279E2D-212D-41B7-9854-776FE915720E'
or applicationid = '0020571D-FD4D-49BB-8B28-A2D3800FF318'
or applicationid = '5B6CF6E5-D5FB-4AB0-8BA4-AA962BB3AD3D'
or applicationid = '1748F562-9027-485D-92C4-B01F59498E38'
or applicationid = 'C800ED62-8B9B-48B3-B918-D05A21A00984'
or applicationid = 'B4B30CC1-4389-4C8C-8943-DE27EFDD9EB2'
or applicationid = '34ABBE07-7264-4CA2-AA26-DFF8EEB108E6'
or applicationid = 'C4291322-B9D5-4584-8A07-1DCCDFA28DF5'
or applicationid = '41C1F41E-B4BE-4257-86F9-22C47C655793'
or applicationid = '30E710D1-E90F-46CC-8C26-4A97C019EEBC'
or applicationid = 'F713DC57-029E-43C2-B819-65A1EA525595'
or applicationid = '81D2E11F-1B0F-4275-A0D9-6A42B4F9E1AD'
or applicationid = '14C308B3-0B97-42DC-916A-81EFE86A2B9A'
or applicationid = 'F125BF81-621C-4762-B8D8-858DE2B5A470'
or applicationid = '6DCB03A0-FDA4-4F34-9DCC-A69C6985CAA3'
or applicationid = 'D1C3C46E-42F0-4CE8-A2CC-D25683F2575B'
or applicationid = '9881260B-79B8-4CFC-BC9B-D674AC367BBC'
or applicationid = '5C41B176-9B34-4C9A-85A1-DCDFF2309473'
or applicationid = '267E5070-4188-4C11-B027-F2431240161D'
or applicationid = '295BB4E3-53C1-45A7-BCE3-011B93A3EFE5'
or applicationid = 'C1BEDD2C-E106-4B0D-9F75-084BE645D221'
or applicationid = 'C268B100-C6CC-493C-8057-0A07EFB94F2A'
or applicationid = '79EB81B7-264D-44E4-AC96-273322BB6DCD'
or applicationid = '60EACA1B-FD27-4892-8B33-3D2CD54F6D1E'
or applicationid = '4B4FE5BD-1623-49FE-A334-7505EC18C99F'
or applicationid = '24A1B125-25F8-4C57-89F2-8298603E5278'
or applicationid = '49A81F2B-28B0-42F2-A4DF-878E7F4AE184'
or applicationid = '98056656-C959-4295-95AD-CAD151F5D2A8'
or applicationid = '5507AAC3-C433-4759-9FCF-D8AA5FD1CCBD'
or applicationid = 'BF461C07-1F2A-409B-A81F-0688213CF6FF'
or applicationid = 'B9B9B941-F899-45C8-8CAF-18B0CAE05D8B'
or applicationid = '05A697B9-D60E-49D1-933B-1BF92EF35D71'
or applicationid = '20840C72-788B-4C9E-9D91-2820A81A79A5'
or applicationid = 'A9980DC7-E857-4F97-9039-5038957AD769'
or applicationid = 'D3952526-E615-46F9-A5BE-6A8BA9880A1F'
or applicationid = '0CC5F95F-7AF7-4F62-8FC6-733BD6792829'
or applicationid = 'D5C2B3C6-2BB2-4968-8DB6-8CCFB6FA7AC8'
or applicationid = '0759561E-172A-41F6-92DC-948054D60E7D'
or applicationid = '2E3E340E-C3CF-4784-93E8-A1898E7C9AB6'
or applicationid = '397A38DA-37BD-4BDE-893A-A506A52AE9CF'
or applicationid = '72693855-1406-4690-BBE5-B625AA6DE5C0'
or applicationid = '46101742-D739-4465-97A8-D0E4B645465F'
or applicationid = '618439CC-6833-45E5-94FE-E93B70A2A0E0'
or applicationid = 'AF668F70-403C-403B-8F86-1480D77E66D0'
or applicationid = '8CE79357-4829-428C-A57C-246B286503B7'
or applicationid = '4568A817-5191-4002-A6BC-2B65FA0E756C'
or applicationid = '5F70274F-3C50-4CDE-8389-2B88F17E8031'
or applicationid = '6B6BB985-1D7C-4572-898E-80955D05E12C'
or applicationid = '15E85CF6-B7EC-4031-ADBE-84EDDFFCF6A4'
or applicationid = 'E4DA1784-40AE-4BF4-9806-AE558C9E3C73'
or applicationid = '6CA83DB6-86F3-4AB1-AC4A-E9C1FD46FF2D'
or applicationid = '5555825B-F5FA-4BE3-B083-24443BFE01AA'
or applicationid = 'FF5DD039-D43B-46C1-ADDB-63E0EB6227BE'
or applicationid = '2CA10389-EDE6-469C-BA7C-822A7DD52E67'
or applicationid = '10BB5DCB-D514-47F4-B2E1-9F3A67269529'
or applicationid = 'A4377274-04E9-4579-9D12-B0040A587C7A'
or applicationid = '628AE2DB-EB57-48C8-952E-255AF4C3E22A'
or applicationid = '4F0826EF-D346-4277-A85B-327B008E6132'
or applicationid = '8623B169-A61C-40AF-9849-33839A22ED70'
or applicationid = '90B38C50-8F86-441A-BBF7-382966EEFC70'
or applicationid = '9E8E55CD-6B38-41A3-82F7-521A56EFBA43'
or applicationid = 'E1DDC2D0-DD8D-4650-B91F-65C9B93C728F'
or applicationid = '1B6CB721-6F58-493F-A7BC-724AA276BB0E'
or applicationid = 'B18B18F6-CB0C-4289-9DC5-7F4A12261DC0'
or applicationid = 'B4ECAC21-91D4-4666-8A8A-89EAFEF321D1'
or applicationid = '047D92E3-EBFD-4EB6-BF05-AB14533BA112'
or applicationid = 'E539125E-A725-4DDF-899E-F5B6ABAB41AB'
or applicationid = '5C7CF891-6288-46E3-A353-09DEDAFBEB7C'
or applicationid = '03E5B58A-1A9E-43AF-83D7-B8EE58BD0BF4'
or applicationid = '68803BAF-CFA5-4E86-8318-858529008049'
or applicationid = '59C409AF-9383-4E8B-9044-8C0742822A98'
or applicationid = '6411727D-9E91-47AE-8732-9912444CF27C'
or applicationid = '8ABDA130-2D08-4909-965C-A67766D85D0D'
or applicationid = 'F2DF3932-1CAC-4D27-9B09-A6C26D85AB4A'
or applicationid = 'AE55D8B5-21C4-4B1C-B797-A95C882533D9'
or applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = 'AFC442D8-9F95-4EE2-827B-C38AB45D929B'
or applicationid = '915DB044-EBCC-4442-8520-D91AE4478283'
or applicationid = '5BBC996B-7672-4BF0-9DCD-F531EABEA919'
or applicationid = '840BF386-EAE0-420C-94FF-37D4FEFF8B3B'
or applicationid = 'CF33F5ED-ED4D-430E-8FBC-53C2160A3F2B'
or applicationid = '36D5119E-D91A-4B4E-83BF-79884FA0113A'
or applicationid = '80F8BC6E-E35E-4097-84A0-85CA83EE3C10'
or applicationid = '7585ED89-9D5A-43C5-AFF7-C4D4207E846B'
or applicationid = '551F457D-1A63-47F3-9DDB-13CE37C11F93'
or applicationid = '69212268-D188-455A-94BB-1B783A0D709D'
or applicationid = 'BDC2D475-A1B3-4156-AF72-2ACDEC3DD6D4'
or applicationid = '499958F3-95C8-4B87-92BA-40C6CCE872D7'
or applicationid = '2C94CC37-ABAA-419B-AAEF-4FC922F820E8'
or applicationid = '004165AE-BA1B-4A7D-A107-5BDB46751430'
or applicationid = '445D91A6-3D72-4085-9DE0-74A9754E663D'
or applicationid = '91880A90-4383-4C57-BD3C-8F9E13EEB65B'
or applicationid = '89BCEC73-DEE2-48C5-B576-9E0A52D75956'
or applicationid = '7325E7C8-134F-407C-92F4-A646CACD2C99'
or applicationid = '407D88F0-DE75-48BB-839F-AB539EA58A5D'
or applicationid = '3128084D-EE77-4224-A368-B56EF844DCCB'
or applicationid = '3C89569C-A85C-492A-B9A6-F14D9FC35438'
or applicationid = 'A1CBECE2-D30C-47CD-AE5A-02E38E39021D'
or applicationid = 'C55FCED8-23F8-4D45-8880-03DBBB2718F1'
or applicationid = 'EC870B97-9C08-4C5A-B994-0B587BC97511'
or applicationid = 'EF061CAD-5058-4E80-8668-283B47C91334'
or applicationid = '35EB0C3E-EFD4-41E9-B68B-382289BB6025'
or applicationid = '57585F78-B5B8-485E-ABA8-3F034A8E01C7'
or applicationid = '27E55832-B293-4078-81A8-457085B8CAC8'
or applicationid = 'E5727682-4CA3-4F8C-B834-4757532EFB71'
or applicationid = 'AC9805E4-0D3B-45CF-86B5-5014222EF502'
or applicationid = 'E26D633B-9A95-408B-871B-51F8FDE9CB5A'
or applicationid = '6C0C3BEF-65D1-4AE9-A722-715A947A68BF'
or applicationid = '9F648D07-780F-4B5E-B0FB-754EFFD0DEA2'
or applicationid = '75EE75C1-914B-403A-ADD5-7CC3AD37B0B9'
or applicationid = '21B69912-BF05-4455-B04D-86E65E368B8F'
or applicationid = '83063347-BD87-4128-B0CB-BEF9D7D58E84'
or applicationid = '6A4AFBF8-EBD5-4447-9F26-C13FA4F6ED63'
or applicationid = '30CC5B5E-5EBD-49BB-80FB-CB308A3A33EC'
or applicationid = 'A27B69FC-1507-4F3E-8156-D93D8AE2E952'
or applicationid = '60C5959A-389C-446A-8F75-1FF9E0CA3EBF'
or applicationid = 'C9A38227-BEEE-4156-B427-38EB46ACB9B0'
or applicationid = '8DDFC805-7F99-47A6-A086-46CB3CCD4D3B'
or applicationid = 'CC105B77-8363-4BC4-AA63-51DAFF556898'
or applicationid = 'BE86E144-CEA0-4556-B11D-63FFC7A0B6F3'
or applicationid = 'CF931628-07B6-4A07-AEDD-7976DD336223'
or applicationid = 'D08B4C8C-A696-4CE0-8A1C-7AE4C590EA01'
or applicationid = '98209457-C8F4-4BBB-B124-A301B1A93C72'
or applicationid = '19732564-506D-4C42-B37F-D617B523F371'
or applicationid = 'D5E94CC0-A1ED-4E3C-BD06-E0BE702C911A'
or applicationid = '21CB044C-C9D5-402D-82A2-F21D097F65C1'
or applicationid = 'CF1D7257-AD44-4E91-9B4C-F5BBB60A5665'
or applicationid = '158DFBA5-2FFE-42F7-85C9-4EBB3896DB6A'
or applicationid = '72103917-FF18-4468-BD84-71C290442D71'
or applicationid = 'AE11769E-E76E-4723-BE12-90DFC5B33F2D'
or applicationid = '14A71E48-3864-4B1F-8553-A9A0214322B9'
or applicationid = '12384B4C-1FEB-4ABE-9EDE-B2FF5C1C7AA9'
or applicationid = '2B071D94-2E5F-4FA0-B9E7-B8C2B3D29CA0'
or applicationid = 'A56A3D12-9E7A-4BB0-B735-D4189EAA453A'
or applicationid = 'C9BAEF19-5D80-4176-B711-F104D18608B7'
or applicationid = '9F07CB63-2016-44E1-86E9-F138AEAA2CF5'
or applicationid = 'E64D961F-A9ED-4A1C-90CD-2479ECB6BC54'
or applicationid = '158077FB-878D-44D5-94C3-34062B8EE559'
or applicationid = '2927C51E-AE58-49DB-B116-3416A8E2BE23'
or applicationid = 'F5A78B81-CA56-42A6-B297-3AE3E5188181'
or applicationid = 'BB36EE30-C3ED-49EF-A99B-3B1D6E0700EF'
or applicationid = '22171396-AF8B-4D75-B969-47CC9ABE6069'
or applicationid = '5D24F1D6-7053-4E85-8226-4BF049ED74C6'
or applicationid = 'DC8C8137-D49C-4132-85B9-4E9EE0B6FBA6'
or applicationid = '464D5101-0C2E-46EB-9D69-873C9E01DBA9'
or applicationid = '34ABF1E0-1DCA-4B84-BB54-92090C0E5128'
or applicationid = '49CD9291-A4DE-40B1-B578-A0C019A5150D'
or applicationid = 'FB081147-9320-48E2-BE47-C24DD7451E84'
or applicationid = 'A261297C-403C-45D0-B5CE-CE08BDB635A6'
or applicationid = 'A1B78705-EDBA-4B55-B2B6-CEF2D0D84229'
or applicationid = '502D27D6-AE1B-461F-82C3-E55B4F44C796'
or applicationid = '0BBF438D-195B-4E70-AFD5-FDA0845793A3'
or applicationid = 'BD874883-0E1C-4EC2-883F-09F3685D04AF'
or applicationid = '61C55F7D-E75A-4563-9E0D-0A719ADABCB0'
or applicationid = '98B3331B-AEBC-47AB-8BB8-10F8D8C51602'
or applicationid = '0A99856E-DFC0-46F2-8116-4B014F4DD175'
or applicationid = 'BF21690A-B394-4EA2-AD50-4F3CDBA21017'
or applicationid = '3C9561CB-B2E1-481D-9B42-6FEA976DBA1F'
or applicationid = '36234724-7532-467E-A7DE-7A1F2A32BFE2'
or applicationid = 'E34E75DB-5845-4655-BD33-B1D7B931CFD4'
or applicationid = 'C74AA76A-F1C3-4BE1-9848-C962841A0FC8'
or applicationid = 'C5345CF0-17BB-4360-8E0D-E3DC8A69B6A4'
or applicationid = 'DCAC79D2-2765-45A0-B3C8-E8180B8EFAAD'
or applicationid = '076EC55B-3EEF-451F-9165-EB240B6A00AB'
or applicationid = '92A9D6AC-1011-4D78-ADD0-EFEA6458A484'
or applicationid = 'CD4EE7BB-90EA-465F-B42A-09FF920DA68D'
or applicationid = '83C4B886-A51F-40E0-9796-1C8C9CE77A9E'
or applicationid = '24041366-69B2-4E48-9A00-21D5634B08AA'
or applicationid = '31577CBA-2521-45C4-A81D-2A88AD1A4327'
or applicationid = 'A94CBC3F-E422-4E4F-9C8E-2AD52318F244'
or applicationid = '6CB13100-92D1-40F6-8B93-4AB3D9B05A9A'
or applicationid = '8947DCC6-FD51-47E1-A5EC-5AC2D3A54300'
or applicationid = 'FF2CE048-D431-4F34-97DC-6FAB0111BEB7'
or applicationid = 'F78AB4AC-653C-4420-99E1-9059C0011EC1'
or applicationid = '775E10E8-924A-4148-B134-9FCAD3304883'
or applicationid = '0317001C-A76E-4F48-A743-E99F4F294ED2'
or applicationid = '3036320D-80DE-4003-B4C4-12C6D93CCF9A'
or applicationid = '8EC1B49B-E55A-4D44-B381-3FAF22769444'
or applicationid = '4471573B-4F5E-472B-AC5C-5609E1613B86'
or applicationid = '69C2C5EF-F115-4016-8C2C-57626D279BB3'
or applicationid = 'C6510A51-675F-411C-B86C-7F03DBA7BE53'
or applicationid = 'F7F2FB30-796B-4574-B7E3-9EEBC2AA2D52'
or applicationid = '2192130E-A4AA-421F-898C-B7FEF832061E'
or applicationid = '5E2969E7-892A-4C2B-B0B9-CE26FBAD5D05'
or applicationid = '13F31EEB-D6D8-411C-B718-D9973888695A'
or applicationid = '853A78B0-8C03-43BB-8E68-E3C0EA18F77B'
or applicationid = '7DEB845E-32A6-4690-93C2-547D24793AAB'
or applicationid = '376D080F-D513-4CAB-937B-5A5D0A9FC909'
or applicationid = '7424ECE2-EF48-4A5E-BDD9-7FE0C4B407FD'
or applicationid = '03488131-6A0B-4D1E-9E1C-8D271C43AD46'
or applicationid = '90523B50-5487-4122-9055-9EFA1AFB03D6'
or applicationid = 'CD8252E7-59F2-4333-9FD9-A1784F857A79'
or applicationid = '2B5793ED-7EE9-489F-ACC7-B22AC2249473'
or applicationid = '3EDD4327-8005-4BDC-8D56-195D7EEA9571'
or applicationid = '55FF0FA7-EC70-46FF-BE3A-1F85DB13E0F9'
or applicationid = 'F37795AE-86CC-4C23-9DB4-607172331C94'
or applicationid = 'E7ABB189-7125-482D-B765-765E3E478C7B'
or applicationid = 'C340B9C8-12C2-460D-80C3-77C311AAADDC'
or applicationid = '4A2C9560-35B2-4902-B277-A3A1C2E092EC'
or applicationid = 'C0561536-A8F6-41A2-8E61-B18006EA94B5'
or applicationid = '32652123-AB63-4952-8582-B3BA45A8DE30'
or applicationid = 'FC59A38D-B59F-4F37-95B6-CA8EE546F786'
or applicationid = 'F359AB49-D080-4077-940F-D7AF76FF100B'
or applicationid = '32D100CE-E774-4C78-99CA-19AE7ADC02F7'
or applicationid = '6C914223-6063-4B1F-989F-2EEBC490FD15'
or applicationid = '50F47B9C-BE0A-4EF0-84A4-3681E640C9F8'
or applicationid = '2A6F46A7-E223-4088-BE7A-3B04AA249DEC'
or applicationid = '87AE73B0-2C59-4FE4-9308-5201CC69AD31'
or applicationid = '4CCB7DF4-2DF3-46AC-89A1-5ADC5E18F30F'
or applicationid = 'FE70FD32-5225-451F-B404-614C49879771'
or applicationid = 'BFA57F38-F885-45D5-B912-8413F09EF7B9'
or applicationid = '98E022CE-2568-4546-9E26-99316E9509A7'
or applicationid = '724D7D18-97DE-4E31-B472-9EC51FA7C743'
or applicationid = 'AAC351D1-7510-42D6-988D-9F25831D1CD5'
or applicationid = '548984B0-3F02-4D6F-B593-D39F093265B2'
or applicationid = '8DEC92AC-9A40-4C42-9265-ED71B0EF0569'
or applicationid = 'ED8768E2-ED06-43B2-AE02-18296C0D3B5A'
or applicationid = '5DA8D944-178E-4E81-ADAB-42A71A17C7DC'
or applicationid = '741E45D7-8861-4561-B4A2-4A09A4C30899'
or applicationid = '0B80C244-7A66-4FA1-8EEA-A9C09E6221C6'
or applicationid = 'B9DAAC7C-84B0-4C96-8EE5-B7CAADC0F0D7'
or applicationid = 'C8660149-BA10-4681-9C49-C451878D8DE8'
or applicationid = '9033D8CC-2C02-4BF4-BD37-D6509EE0D5CA'
or applicationid = '0668893E-7234-451B-AF10-E9B4E198721F'
or applicationid = 'B1A5AE3C-A761-4F9C-B0B8-EBDA06D9FC84'
or applicationid = '5C3F4F7E-4621-4676-98B8-1514DF937761'
or applicationid = '09A40898-0D05-434D-9E7F-1F2C569DED4B'
or applicationid = 'ED6770D8-C409-4E56-A745-2AC02DE1CEF2'
or applicationid = '6C172B62-3628-4AAB-8A28-3F3B7B004884'
or applicationid = 'AE7702DA-DE93-4DC0-9852-4411AB0E8581'
or applicationid = '7129A38D-7BB1-4682-B9D3-5A38C873E6D4'
or applicationid = '82270BB7-4492-4485-BEEF-7607DCA88870'
or applicationid = '7B9C1F9A-5437-41AF-9028-7A5A69B243B4'
or applicationid = 'EE9F1AFA-315C-49C2-A944-84339C1FC4BA'
or applicationid = '47EE4849-67C9-414D-9655-84A8CD3138D3'
or applicationid = 'BADEA36A-EB07-41AF-B02E-8D8D7A8B4CEE'
or applicationid = '06CB614E-5A1F-4912-9385-D1F80136273B'
or applicationid = 'D36EB7C2-3D86-4F52-9D11-D907595B5CB0'
or applicationid = 'ED8F2044-7982-42D7-B18B-FBED992BF4E1'
or applicationid = 'D25F4719-BEF8-4FF7-A8FC-1BDDCB4D3569'
or applicationid = '208FDD6E-94FB-42CC-B46D-2739C79397B4'
or applicationid = 'C222A709-8006-42B0-81FB-31DC544616E5'
or applicationid = 'FD3458D9-C62F-408D-9831-4925F36D523A'
or applicationid = 'B6C8F258-D3F0-4C94-854D-57F9F8A77B22'
or applicationid = '7F9D075A-0A50-4A21-98C6-790AF25EA083'
or applicationid = 'BD7245E4-D798-4C37-874A-A0301F09BAC4'
or applicationid = '3BB2E2C1-E58A-49E1-84B7-AA3BD23D52A5'
or applicationid = '694046DE-223A-4E32-B401-FB654A95EC1E'
or applicationid = '284BB2A0-516D-4022-B4F3-FC1F5BFB9425'
or applicationid = 'BB1B07C6-9A2D-4102-A3B0-2790BF44C079'
or applicationid = '5BD23FA4-D45B-4A4A-AFBB-3013FC6A54A8'
or applicationid = '49AEEA59-61DF-40E9-8621-43469A7AAD7F'
or applicationid = '9866A4B3-FDFA-4F96-81A6-4DBF3181A25E'
or applicationid = '4424521C-58D2-4800-83CD-578272616125'
or applicationid = '9E235184-B24B-4633-812D-90F94ED00DB0'
or applicationid = 'F6F545E7-F039-49A6-8F5C-9A7C03C36D98');

/* Table: seamless_events_lvl_3
   Description: This contains all emails with 'opened' and/or 'complained' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
     , case
        when devicetype is null then 'no data'
        else devicetype
       end as devicetype
     , case
        when clienttype is null then 'no data'
        else clienttype
       end as clienttype
     , case
        when clientos is null then 'no data'
        else clientos
       end as clientos
     , case
        when useragent is null then 'no data'
        else useragent
       end as useragent
into jt.nonseamless_events_lvl_3
from mailgun_events
where (eventstatus = 'opened' or eventstatus = 'complained')
and (applicationid = '1C87DF2E-4D34-446A-80E2-013E3BAC7170'
or applicationid = 'F1F5DF7D-E81C-4201-9B94-089163B7EF0F'
or applicationid = 'DC12CD48-BB7F-4955-917A-0F0182683E4F'
or applicationid = 'FBAA081E-596E-47E4-9F46-4089A836CF71'
or applicationid = '61035230-5FCC-44F0-ADD8-594393C96895'
or applicationid = '9894EBB9-D345-4753-8DC3-64E50790B293'
or applicationid = '3E943526-AFE6-417F-BB1A-6E992B37A7BA'
or applicationid = '5D376E05-A8C2-4F14-9CE2-70A2DFECE85E'
or applicationid = '22279E2D-212D-41B7-9854-776FE915720E'
or applicationid = '0020571D-FD4D-49BB-8B28-A2D3800FF318'
or applicationid = '5B6CF6E5-D5FB-4AB0-8BA4-AA962BB3AD3D'
or applicationid = '1748F562-9027-485D-92C4-B01F59498E38'
or applicationid = 'C800ED62-8B9B-48B3-B918-D05A21A00984'
or applicationid = 'B4B30CC1-4389-4C8C-8943-DE27EFDD9EB2'
or applicationid = '34ABBE07-7264-4CA2-AA26-DFF8EEB108E6'
or applicationid = 'C4291322-B9D5-4584-8A07-1DCCDFA28DF5'
or applicationid = '41C1F41E-B4BE-4257-86F9-22C47C655793'
or applicationid = '30E710D1-E90F-46CC-8C26-4A97C019EEBC'
or applicationid = 'F713DC57-029E-43C2-B819-65A1EA525595'
or applicationid = '81D2E11F-1B0F-4275-A0D9-6A42B4F9E1AD'
or applicationid = '14C308B3-0B97-42DC-916A-81EFE86A2B9A'
or applicationid = 'F125BF81-621C-4762-B8D8-858DE2B5A470'
or applicationid = '6DCB03A0-FDA4-4F34-9DCC-A69C6985CAA3'
or applicationid = 'D1C3C46E-42F0-4CE8-A2CC-D25683F2575B'
or applicationid = '9881260B-79B8-4CFC-BC9B-D674AC367BBC'
or applicationid = '5C41B176-9B34-4C9A-85A1-DCDFF2309473'
or applicationid = '267E5070-4188-4C11-B027-F2431240161D'
or applicationid = '295BB4E3-53C1-45A7-BCE3-011B93A3EFE5'
or applicationid = 'C1BEDD2C-E106-4B0D-9F75-084BE645D221'
or applicationid = 'C268B100-C6CC-493C-8057-0A07EFB94F2A'
or applicationid = '79EB81B7-264D-44E4-AC96-273322BB6DCD'
or applicationid = '60EACA1B-FD27-4892-8B33-3D2CD54F6D1E'
or applicationid = '4B4FE5BD-1623-49FE-A334-7505EC18C99F'
or applicationid = '24A1B125-25F8-4C57-89F2-8298603E5278'
or applicationid = '49A81F2B-28B0-42F2-A4DF-878E7F4AE184'
or applicationid = '98056656-C959-4295-95AD-CAD151F5D2A8'
or applicationid = '5507AAC3-C433-4759-9FCF-D8AA5FD1CCBD'
or applicationid = 'BF461C07-1F2A-409B-A81F-0688213CF6FF'
or applicationid = 'B9B9B941-F899-45C8-8CAF-18B0CAE05D8B'
or applicationid = '05A697B9-D60E-49D1-933B-1BF92EF35D71'
or applicationid = '20840C72-788B-4C9E-9D91-2820A81A79A5'
or applicationid = 'A9980DC7-E857-4F97-9039-5038957AD769'
or applicationid = 'D3952526-E615-46F9-A5BE-6A8BA9880A1F'
or applicationid = '0CC5F95F-7AF7-4F62-8FC6-733BD6792829'
or applicationid = 'D5C2B3C6-2BB2-4968-8DB6-8CCFB6FA7AC8'
or applicationid = '0759561E-172A-41F6-92DC-948054D60E7D'
or applicationid = '2E3E340E-C3CF-4784-93E8-A1898E7C9AB6'
or applicationid = '397A38DA-37BD-4BDE-893A-A506A52AE9CF'
or applicationid = '72693855-1406-4690-BBE5-B625AA6DE5C0'
or applicationid = '46101742-D739-4465-97A8-D0E4B645465F'
or applicationid = '618439CC-6833-45E5-94FE-E93B70A2A0E0'
or applicationid = 'AF668F70-403C-403B-8F86-1480D77E66D0'
or applicationid = '8CE79357-4829-428C-A57C-246B286503B7'
or applicationid = '4568A817-5191-4002-A6BC-2B65FA0E756C'
or applicationid = '5F70274F-3C50-4CDE-8389-2B88F17E8031'
or applicationid = '6B6BB985-1D7C-4572-898E-80955D05E12C'
or applicationid = '15E85CF6-B7EC-4031-ADBE-84EDDFFCF6A4'
or applicationid = 'E4DA1784-40AE-4BF4-9806-AE558C9E3C73'
or applicationid = '6CA83DB6-86F3-4AB1-AC4A-E9C1FD46FF2D'
or applicationid = '5555825B-F5FA-4BE3-B083-24443BFE01AA'
or applicationid = 'FF5DD039-D43B-46C1-ADDB-63E0EB6227BE'
or applicationid = '2CA10389-EDE6-469C-BA7C-822A7DD52E67'
or applicationid = '10BB5DCB-D514-47F4-B2E1-9F3A67269529'
or applicationid = 'A4377274-04E9-4579-9D12-B0040A587C7A'
or applicationid = '628AE2DB-EB57-48C8-952E-255AF4C3E22A'
or applicationid = '4F0826EF-D346-4277-A85B-327B008E6132'
or applicationid = '8623B169-A61C-40AF-9849-33839A22ED70'
or applicationid = '90B38C50-8F86-441A-BBF7-382966EEFC70'
or applicationid = '9E8E55CD-6B38-41A3-82F7-521A56EFBA43'
or applicationid = 'E1DDC2D0-DD8D-4650-B91F-65C9B93C728F'
or applicationid = '1B6CB721-6F58-493F-A7BC-724AA276BB0E'
or applicationid = 'B18B18F6-CB0C-4289-9DC5-7F4A12261DC0'
or applicationid = 'B4ECAC21-91D4-4666-8A8A-89EAFEF321D1'
or applicationid = '047D92E3-EBFD-4EB6-BF05-AB14533BA112'
or applicationid = 'E539125E-A725-4DDF-899E-F5B6ABAB41AB'
or applicationid = '5C7CF891-6288-46E3-A353-09DEDAFBEB7C'
or applicationid = '03E5B58A-1A9E-43AF-83D7-B8EE58BD0BF4'
or applicationid = '68803BAF-CFA5-4E86-8318-858529008049'
or applicationid = '59C409AF-9383-4E8B-9044-8C0742822A98'
or applicationid = '6411727D-9E91-47AE-8732-9912444CF27C'
or applicationid = '8ABDA130-2D08-4909-965C-A67766D85D0D'
or applicationid = 'F2DF3932-1CAC-4D27-9B09-A6C26D85AB4A'
or applicationid = 'AE55D8B5-21C4-4B1C-B797-A95C882533D9'
or applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = 'AFC442D8-9F95-4EE2-827B-C38AB45D929B'
or applicationid = '915DB044-EBCC-4442-8520-D91AE4478283'
or applicationid = '5BBC996B-7672-4BF0-9DCD-F531EABEA919'
or applicationid = '840BF386-EAE0-420C-94FF-37D4FEFF8B3B'
or applicationid = 'CF33F5ED-ED4D-430E-8FBC-53C2160A3F2B'
or applicationid = '36D5119E-D91A-4B4E-83BF-79884FA0113A'
or applicationid = '80F8BC6E-E35E-4097-84A0-85CA83EE3C10'
or applicationid = '7585ED89-9D5A-43C5-AFF7-C4D4207E846B'
or applicationid = '551F457D-1A63-47F3-9DDB-13CE37C11F93'
or applicationid = '69212268-D188-455A-94BB-1B783A0D709D'
or applicationid = 'BDC2D475-A1B3-4156-AF72-2ACDEC3DD6D4'
or applicationid = '499958F3-95C8-4B87-92BA-40C6CCE872D7'
or applicationid = '2C94CC37-ABAA-419B-AAEF-4FC922F820E8'
or applicationid = '004165AE-BA1B-4A7D-A107-5BDB46751430'
or applicationid = '445D91A6-3D72-4085-9DE0-74A9754E663D'
or applicationid = '91880A90-4383-4C57-BD3C-8F9E13EEB65B'
or applicationid = '89BCEC73-DEE2-48C5-B576-9E0A52D75956'
or applicationid = '7325E7C8-134F-407C-92F4-A646CACD2C99'
or applicationid = '407D88F0-DE75-48BB-839F-AB539EA58A5D'
or applicationid = '3128084D-EE77-4224-A368-B56EF844DCCB'
or applicationid = '3C89569C-A85C-492A-B9A6-F14D9FC35438'
or applicationid = 'A1CBECE2-D30C-47CD-AE5A-02E38E39021D'
or applicationid = 'C55FCED8-23F8-4D45-8880-03DBBB2718F1'
or applicationid = 'EC870B97-9C08-4C5A-B994-0B587BC97511'
or applicationid = 'EF061CAD-5058-4E80-8668-283B47C91334'
or applicationid = '35EB0C3E-EFD4-41E9-B68B-382289BB6025'
or applicationid = '57585F78-B5B8-485E-ABA8-3F034A8E01C7'
or applicationid = '27E55832-B293-4078-81A8-457085B8CAC8'
or applicationid = 'E5727682-4CA3-4F8C-B834-4757532EFB71'
or applicationid = 'AC9805E4-0D3B-45CF-86B5-5014222EF502'
or applicationid = 'E26D633B-9A95-408B-871B-51F8FDE9CB5A'
or applicationid = '6C0C3BEF-65D1-4AE9-A722-715A947A68BF'
or applicationid = '9F648D07-780F-4B5E-B0FB-754EFFD0DEA2'
or applicationid = '75EE75C1-914B-403A-ADD5-7CC3AD37B0B9'
or applicationid = '21B69912-BF05-4455-B04D-86E65E368B8F'
or applicationid = '83063347-BD87-4128-B0CB-BEF9D7D58E84'
or applicationid = '6A4AFBF8-EBD5-4447-9F26-C13FA4F6ED63'
or applicationid = '30CC5B5E-5EBD-49BB-80FB-CB308A3A33EC'
or applicationid = 'A27B69FC-1507-4F3E-8156-D93D8AE2E952'
or applicationid = '60C5959A-389C-446A-8F75-1FF9E0CA3EBF'
or applicationid = 'C9A38227-BEEE-4156-B427-38EB46ACB9B0'
or applicationid = '8DDFC805-7F99-47A6-A086-46CB3CCD4D3B'
or applicationid = 'CC105B77-8363-4BC4-AA63-51DAFF556898'
or applicationid = 'BE86E144-CEA0-4556-B11D-63FFC7A0B6F3'
or applicationid = 'CF931628-07B6-4A07-AEDD-7976DD336223'
or applicationid = 'D08B4C8C-A696-4CE0-8A1C-7AE4C590EA01'
or applicationid = '98209457-C8F4-4BBB-B124-A301B1A93C72'
or applicationid = '19732564-506D-4C42-B37F-D617B523F371'
or applicationid = 'D5E94CC0-A1ED-4E3C-BD06-E0BE702C911A'
or applicationid = '21CB044C-C9D5-402D-82A2-F21D097F65C1'
or applicationid = 'CF1D7257-AD44-4E91-9B4C-F5BBB60A5665'
or applicationid = '158DFBA5-2FFE-42F7-85C9-4EBB3896DB6A'
or applicationid = '72103917-FF18-4468-BD84-71C290442D71'
or applicationid = 'AE11769E-E76E-4723-BE12-90DFC5B33F2D'
or applicationid = '14A71E48-3864-4B1F-8553-A9A0214322B9'
or applicationid = '12384B4C-1FEB-4ABE-9EDE-B2FF5C1C7AA9'
or applicationid = '2B071D94-2E5F-4FA0-B9E7-B8C2B3D29CA0'
or applicationid = 'A56A3D12-9E7A-4BB0-B735-D4189EAA453A'
or applicationid = 'C9BAEF19-5D80-4176-B711-F104D18608B7'
or applicationid = '9F07CB63-2016-44E1-86E9-F138AEAA2CF5'
or applicationid = 'E64D961F-A9ED-4A1C-90CD-2479ECB6BC54'
or applicationid = '158077FB-878D-44D5-94C3-34062B8EE559'
or applicationid = '2927C51E-AE58-49DB-B116-3416A8E2BE23'
or applicationid = 'F5A78B81-CA56-42A6-B297-3AE3E5188181'
or applicationid = 'BB36EE30-C3ED-49EF-A99B-3B1D6E0700EF'
or applicationid = '22171396-AF8B-4D75-B969-47CC9ABE6069'
or applicationid = '5D24F1D6-7053-4E85-8226-4BF049ED74C6'
or applicationid = 'DC8C8137-D49C-4132-85B9-4E9EE0B6FBA6'
or applicationid = '464D5101-0C2E-46EB-9D69-873C9E01DBA9'
or applicationid = '34ABF1E0-1DCA-4B84-BB54-92090C0E5128'
or applicationid = '49CD9291-A4DE-40B1-B578-A0C019A5150D'
or applicationid = 'FB081147-9320-48E2-BE47-C24DD7451E84'
or applicationid = 'A261297C-403C-45D0-B5CE-CE08BDB635A6'
or applicationid = 'A1B78705-EDBA-4B55-B2B6-CEF2D0D84229'
or applicationid = '502D27D6-AE1B-461F-82C3-E55B4F44C796'
or applicationid = '0BBF438D-195B-4E70-AFD5-FDA0845793A3'
or applicationid = 'BD874883-0E1C-4EC2-883F-09F3685D04AF'
or applicationid = '61C55F7D-E75A-4563-9E0D-0A719ADABCB0'
or applicationid = '98B3331B-AEBC-47AB-8BB8-10F8D8C51602'
or applicationid = '0A99856E-DFC0-46F2-8116-4B014F4DD175'
or applicationid = 'BF21690A-B394-4EA2-AD50-4F3CDBA21017'
or applicationid = '3C9561CB-B2E1-481D-9B42-6FEA976DBA1F'
or applicationid = '36234724-7532-467E-A7DE-7A1F2A32BFE2'
or applicationid = 'E34E75DB-5845-4655-BD33-B1D7B931CFD4'
or applicationid = 'C74AA76A-F1C3-4BE1-9848-C962841A0FC8'
or applicationid = 'C5345CF0-17BB-4360-8E0D-E3DC8A69B6A4'
or applicationid = 'DCAC79D2-2765-45A0-B3C8-E8180B8EFAAD'
or applicationid = '076EC55B-3EEF-451F-9165-EB240B6A00AB'
or applicationid = '92A9D6AC-1011-4D78-ADD0-EFEA6458A484'
or applicationid = 'CD4EE7BB-90EA-465F-B42A-09FF920DA68D'
or applicationid = '83C4B886-A51F-40E0-9796-1C8C9CE77A9E'
or applicationid = '24041366-69B2-4E48-9A00-21D5634B08AA'
or applicationid = '31577CBA-2521-45C4-A81D-2A88AD1A4327'
or applicationid = 'A94CBC3F-E422-4E4F-9C8E-2AD52318F244'
or applicationid = '6CB13100-92D1-40F6-8B93-4AB3D9B05A9A'
or applicationid = '8947DCC6-FD51-47E1-A5EC-5AC2D3A54300'
or applicationid = 'FF2CE048-D431-4F34-97DC-6FAB0111BEB7'
or applicationid = 'F78AB4AC-653C-4420-99E1-9059C0011EC1'
or applicationid = '775E10E8-924A-4148-B134-9FCAD3304883'
or applicationid = '0317001C-A76E-4F48-A743-E99F4F294ED2'
or applicationid = '3036320D-80DE-4003-B4C4-12C6D93CCF9A'
or applicationid = '8EC1B49B-E55A-4D44-B381-3FAF22769444'
or applicationid = '4471573B-4F5E-472B-AC5C-5609E1613B86'
or applicationid = '69C2C5EF-F115-4016-8C2C-57626D279BB3'
or applicationid = 'C6510A51-675F-411C-B86C-7F03DBA7BE53'
or applicationid = 'F7F2FB30-796B-4574-B7E3-9EEBC2AA2D52'
or applicationid = '2192130E-A4AA-421F-898C-B7FEF832061E'
or applicationid = '5E2969E7-892A-4C2B-B0B9-CE26FBAD5D05'
or applicationid = '13F31EEB-D6D8-411C-B718-D9973888695A'
or applicationid = '853A78B0-8C03-43BB-8E68-E3C0EA18F77B'
or applicationid = '7DEB845E-32A6-4690-93C2-547D24793AAB'
or applicationid = '376D080F-D513-4CAB-937B-5A5D0A9FC909'
or applicationid = '7424ECE2-EF48-4A5E-BDD9-7FE0C4B407FD'
or applicationid = '03488131-6A0B-4D1E-9E1C-8D271C43AD46'
or applicationid = '90523B50-5487-4122-9055-9EFA1AFB03D6'
or applicationid = 'CD8252E7-59F2-4333-9FD9-A1784F857A79'
or applicationid = '2B5793ED-7EE9-489F-ACC7-B22AC2249473'
or applicationid = '3EDD4327-8005-4BDC-8D56-195D7EEA9571'
or applicationid = '55FF0FA7-EC70-46FF-BE3A-1F85DB13E0F9'
or applicationid = 'F37795AE-86CC-4C23-9DB4-607172331C94'
or applicationid = 'E7ABB189-7125-482D-B765-765E3E478C7B'
or applicationid = 'C340B9C8-12C2-460D-80C3-77C311AAADDC'
or applicationid = '4A2C9560-35B2-4902-B277-A3A1C2E092EC'
or applicationid = 'C0561536-A8F6-41A2-8E61-B18006EA94B5'
or applicationid = '32652123-AB63-4952-8582-B3BA45A8DE30'
or applicationid = 'FC59A38D-B59F-4F37-95B6-CA8EE546F786'
or applicationid = 'F359AB49-D080-4077-940F-D7AF76FF100B'
or applicationid = '32D100CE-E774-4C78-99CA-19AE7ADC02F7'
or applicationid = '6C914223-6063-4B1F-989F-2EEBC490FD15'
or applicationid = '50F47B9C-BE0A-4EF0-84A4-3681E640C9F8'
or applicationid = '2A6F46A7-E223-4088-BE7A-3B04AA249DEC'
or applicationid = '87AE73B0-2C59-4FE4-9308-5201CC69AD31'
or applicationid = '4CCB7DF4-2DF3-46AC-89A1-5ADC5E18F30F'
or applicationid = 'FE70FD32-5225-451F-B404-614C49879771'
or applicationid = 'BFA57F38-F885-45D5-B912-8413F09EF7B9'
or applicationid = '98E022CE-2568-4546-9E26-99316E9509A7'
or applicationid = '724D7D18-97DE-4E31-B472-9EC51FA7C743'
or applicationid = 'AAC351D1-7510-42D6-988D-9F25831D1CD5'
or applicationid = '548984B0-3F02-4D6F-B593-D39F093265B2'
or applicationid = '8DEC92AC-9A40-4C42-9265-ED71B0EF0569'
or applicationid = 'ED8768E2-ED06-43B2-AE02-18296C0D3B5A'
or applicationid = '5DA8D944-178E-4E81-ADAB-42A71A17C7DC'
or applicationid = '741E45D7-8861-4561-B4A2-4A09A4C30899'
or applicationid = '0B80C244-7A66-4FA1-8EEA-A9C09E6221C6'
or applicationid = 'B9DAAC7C-84B0-4C96-8EE5-B7CAADC0F0D7'
or applicationid = 'C8660149-BA10-4681-9C49-C451878D8DE8'
or applicationid = '9033D8CC-2C02-4BF4-BD37-D6509EE0D5CA'
or applicationid = '0668893E-7234-451B-AF10-E9B4E198721F'
or applicationid = 'B1A5AE3C-A761-4F9C-B0B8-EBDA06D9FC84'
or applicationid = '5C3F4F7E-4621-4676-98B8-1514DF937761'
or applicationid = '09A40898-0D05-434D-9E7F-1F2C569DED4B'
or applicationid = 'ED6770D8-C409-4E56-A745-2AC02DE1CEF2'
or applicationid = '6C172B62-3628-4AAB-8A28-3F3B7B004884'
or applicationid = 'AE7702DA-DE93-4DC0-9852-4411AB0E8581'
or applicationid = '7129A38D-7BB1-4682-B9D3-5A38C873E6D4'
or applicationid = '82270BB7-4492-4485-BEEF-7607DCA88870'
or applicationid = '7B9C1F9A-5437-41AF-9028-7A5A69B243B4'
or applicationid = 'EE9F1AFA-315C-49C2-A944-84339C1FC4BA'
or applicationid = '47EE4849-67C9-414D-9655-84A8CD3138D3'
or applicationid = 'BADEA36A-EB07-41AF-B02E-8D8D7A8B4CEE'
or applicationid = '06CB614E-5A1F-4912-9385-D1F80136273B'
or applicationid = 'D36EB7C2-3D86-4F52-9D11-D907595B5CB0'
or applicationid = 'ED8F2044-7982-42D7-B18B-FBED992BF4E1'
or applicationid = 'D25F4719-BEF8-4FF7-A8FC-1BDDCB4D3569'
or applicationid = '208FDD6E-94FB-42CC-B46D-2739C79397B4'
or applicationid = 'C222A709-8006-42B0-81FB-31DC544616E5'
or applicationid = 'FD3458D9-C62F-408D-9831-4925F36D523A'
or applicationid = 'B6C8F258-D3F0-4C94-854D-57F9F8A77B22'
or applicationid = '7F9D075A-0A50-4A21-98C6-790AF25EA083'
or applicationid = 'BD7245E4-D798-4C37-874A-A0301F09BAC4'
or applicationid = '3BB2E2C1-E58A-49E1-84B7-AA3BD23D52A5'
or applicationid = '694046DE-223A-4E32-B401-FB654A95EC1E'
or applicationid = '284BB2A0-516D-4022-B4F3-FC1F5BFB9425'
or applicationid = 'BB1B07C6-9A2D-4102-A3B0-2790BF44C079'
or applicationid = '5BD23FA4-D45B-4A4A-AFBB-3013FC6A54A8'
or applicationid = '49AEEA59-61DF-40E9-8621-43469A7AAD7F'
or applicationid = '9866A4B3-FDFA-4F96-81A6-4DBF3181A25E'
or applicationid = '4424521C-58D2-4800-83CD-578272616125'
or applicationid = '9E235184-B24B-4633-812D-90F94ED00DB0'
or applicationid = 'F6F545E7-F039-49A6-8F5C-9A7C03C36D98');

/* Table: seamless_events_lvl_4
   Description: This contains all email with 'clicked' and/or 'unsubscribed' and/or 'stored' events tracked by mailgun.
*/

select applicationid
     , messageid
     , recipientemail
     , senderemail
     , subject
     , eventstatus
     , eventtimestamp
     , clickurl
     , id
     , case
        when devicetype is null then 'no data'
        else devicetype
       end as devicetype
     , case
        when clienttype is null then 'no data'
        else clienttype
       end as clienttype
     , case
        when clientos is null then 'no data'
        else clientos
       end as clientos
     , case
        when useragent is null then 'no data'
        else useragent
       end as useragent
into jt.nonseamless_events_lvl_4
from mailgun_events
where (eventstatus = 'clicked' or eventstatus = 'unsubscribed' or eventstatus = 'stored')
and (applicationid = '1C87DF2E-4D34-446A-80E2-013E3BAC7170'
or applicationid = 'F1F5DF7D-E81C-4201-9B94-089163B7EF0F'
or applicationid = 'DC12CD48-BB7F-4955-917A-0F0182683E4F'
or applicationid = 'FBAA081E-596E-47E4-9F46-4089A836CF71'
or applicationid = '61035230-5FCC-44F0-ADD8-594393C96895'
or applicationid = '9894EBB9-D345-4753-8DC3-64E50790B293'
or applicationid = '3E943526-AFE6-417F-BB1A-6E992B37A7BA'
or applicationid = '5D376E05-A8C2-4F14-9CE2-70A2DFECE85E'
or applicationid = '22279E2D-212D-41B7-9854-776FE915720E'
or applicationid = '0020571D-FD4D-49BB-8B28-A2D3800FF318'
or applicationid = '5B6CF6E5-D5FB-4AB0-8BA4-AA962BB3AD3D'
or applicationid = '1748F562-9027-485D-92C4-B01F59498E38'
or applicationid = 'C800ED62-8B9B-48B3-B918-D05A21A00984'
or applicationid = 'B4B30CC1-4389-4C8C-8943-DE27EFDD9EB2'
or applicationid = '34ABBE07-7264-4CA2-AA26-DFF8EEB108E6'
or applicationid = 'C4291322-B9D5-4584-8A07-1DCCDFA28DF5'
or applicationid = '41C1F41E-B4BE-4257-86F9-22C47C655793'
or applicationid = '30E710D1-E90F-46CC-8C26-4A97C019EEBC'
or applicationid = 'F713DC57-029E-43C2-B819-65A1EA525595'
or applicationid = '81D2E11F-1B0F-4275-A0D9-6A42B4F9E1AD'
or applicationid = '14C308B3-0B97-42DC-916A-81EFE86A2B9A'
or applicationid = 'F125BF81-621C-4762-B8D8-858DE2B5A470'
or applicationid = '6DCB03A0-FDA4-4F34-9DCC-A69C6985CAA3'
or applicationid = 'D1C3C46E-42F0-4CE8-A2CC-D25683F2575B'
or applicationid = '9881260B-79B8-4CFC-BC9B-D674AC367BBC'
or applicationid = '5C41B176-9B34-4C9A-85A1-DCDFF2309473'
or applicationid = '267E5070-4188-4C11-B027-F2431240161D'
or applicationid = '295BB4E3-53C1-45A7-BCE3-011B93A3EFE5'
or applicationid = 'C1BEDD2C-E106-4B0D-9F75-084BE645D221'
or applicationid = 'C268B100-C6CC-493C-8057-0A07EFB94F2A'
or applicationid = '79EB81B7-264D-44E4-AC96-273322BB6DCD'
or applicationid = '60EACA1B-FD27-4892-8B33-3D2CD54F6D1E'
or applicationid = '4B4FE5BD-1623-49FE-A334-7505EC18C99F'
or applicationid = '24A1B125-25F8-4C57-89F2-8298603E5278'
or applicationid = '49A81F2B-28B0-42F2-A4DF-878E7F4AE184'
or applicationid = '98056656-C959-4295-95AD-CAD151F5D2A8'
or applicationid = '5507AAC3-C433-4759-9FCF-D8AA5FD1CCBD'
or applicationid = 'BF461C07-1F2A-409B-A81F-0688213CF6FF'
or applicationid = 'B9B9B941-F899-45C8-8CAF-18B0CAE05D8B'
or applicationid = '05A697B9-D60E-49D1-933B-1BF92EF35D71'
or applicationid = '20840C72-788B-4C9E-9D91-2820A81A79A5'
or applicationid = 'A9980DC7-E857-4F97-9039-5038957AD769'
or applicationid = 'D3952526-E615-46F9-A5BE-6A8BA9880A1F'
or applicationid = '0CC5F95F-7AF7-4F62-8FC6-733BD6792829'
or applicationid = 'D5C2B3C6-2BB2-4968-8DB6-8CCFB6FA7AC8'
or applicationid = '0759561E-172A-41F6-92DC-948054D60E7D'
or applicationid = '2E3E340E-C3CF-4784-93E8-A1898E7C9AB6'
or applicationid = '397A38DA-37BD-4BDE-893A-A506A52AE9CF'
or applicationid = '72693855-1406-4690-BBE5-B625AA6DE5C0'
or applicationid = '46101742-D739-4465-97A8-D0E4B645465F'
or applicationid = '618439CC-6833-45E5-94FE-E93B70A2A0E0'
or applicationid = 'AF668F70-403C-403B-8F86-1480D77E66D0'
or applicationid = '8CE79357-4829-428C-A57C-246B286503B7'
or applicationid = '4568A817-5191-4002-A6BC-2B65FA0E756C'
or applicationid = '5F70274F-3C50-4CDE-8389-2B88F17E8031'
or applicationid = '6B6BB985-1D7C-4572-898E-80955D05E12C'
or applicationid = '15E85CF6-B7EC-4031-ADBE-84EDDFFCF6A4'
or applicationid = 'E4DA1784-40AE-4BF4-9806-AE558C9E3C73'
or applicationid = '6CA83DB6-86F3-4AB1-AC4A-E9C1FD46FF2D'
or applicationid = '5555825B-F5FA-4BE3-B083-24443BFE01AA'
or applicationid = 'FF5DD039-D43B-46C1-ADDB-63E0EB6227BE'
or applicationid = '2CA10389-EDE6-469C-BA7C-822A7DD52E67'
or applicationid = '10BB5DCB-D514-47F4-B2E1-9F3A67269529'
or applicationid = 'A4377274-04E9-4579-9D12-B0040A587C7A'
or applicationid = '628AE2DB-EB57-48C8-952E-255AF4C3E22A'
or applicationid = '4F0826EF-D346-4277-A85B-327B008E6132'
or applicationid = '8623B169-A61C-40AF-9849-33839A22ED70'
or applicationid = '90B38C50-8F86-441A-BBF7-382966EEFC70'
or applicationid = '9E8E55CD-6B38-41A3-82F7-521A56EFBA43'
or applicationid = 'E1DDC2D0-DD8D-4650-B91F-65C9B93C728F'
or applicationid = '1B6CB721-6F58-493F-A7BC-724AA276BB0E'
or applicationid = 'B18B18F6-CB0C-4289-9DC5-7F4A12261DC0'
or applicationid = 'B4ECAC21-91D4-4666-8A8A-89EAFEF321D1'
or applicationid = '047D92E3-EBFD-4EB6-BF05-AB14533BA112'
or applicationid = 'E539125E-A725-4DDF-899E-F5B6ABAB41AB'
or applicationid = '5C7CF891-6288-46E3-A353-09DEDAFBEB7C'
or applicationid = '03E5B58A-1A9E-43AF-83D7-B8EE58BD0BF4'
or applicationid = '68803BAF-CFA5-4E86-8318-858529008049'
or applicationid = '59C409AF-9383-4E8B-9044-8C0742822A98'
or applicationid = '6411727D-9E91-47AE-8732-9912444CF27C'
or applicationid = '8ABDA130-2D08-4909-965C-A67766D85D0D'
or applicationid = 'F2DF3932-1CAC-4D27-9B09-A6C26D85AB4A'
or applicationid = 'AE55D8B5-21C4-4B1C-B797-A95C882533D9'
or applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = 'AFC442D8-9F95-4EE2-827B-C38AB45D929B'
or applicationid = '915DB044-EBCC-4442-8520-D91AE4478283'
or applicationid = '5BBC996B-7672-4BF0-9DCD-F531EABEA919'
or applicationid = '840BF386-EAE0-420C-94FF-37D4FEFF8B3B'
or applicationid = 'CF33F5ED-ED4D-430E-8FBC-53C2160A3F2B'
or applicationid = '36D5119E-D91A-4B4E-83BF-79884FA0113A'
or applicationid = '80F8BC6E-E35E-4097-84A0-85CA83EE3C10'
or applicationid = '7585ED89-9D5A-43C5-AFF7-C4D4207E846B'
or applicationid = '551F457D-1A63-47F3-9DDB-13CE37C11F93'
or applicationid = '69212268-D188-455A-94BB-1B783A0D709D'
or applicationid = 'BDC2D475-A1B3-4156-AF72-2ACDEC3DD6D4'
or applicationid = '499958F3-95C8-4B87-92BA-40C6CCE872D7'
or applicationid = '2C94CC37-ABAA-419B-AAEF-4FC922F820E8'
or applicationid = '004165AE-BA1B-4A7D-A107-5BDB46751430'
or applicationid = '445D91A6-3D72-4085-9DE0-74A9754E663D'
or applicationid = '91880A90-4383-4C57-BD3C-8F9E13EEB65B'
or applicationid = '89BCEC73-DEE2-48C5-B576-9E0A52D75956'
or applicationid = '7325E7C8-134F-407C-92F4-A646CACD2C99'
or applicationid = '407D88F0-DE75-48BB-839F-AB539EA58A5D'
or applicationid = '3128084D-EE77-4224-A368-B56EF844DCCB'
or applicationid = '3C89569C-A85C-492A-B9A6-F14D9FC35438'
or applicationid = 'A1CBECE2-D30C-47CD-AE5A-02E38E39021D'
or applicationid = 'C55FCED8-23F8-4D45-8880-03DBBB2718F1'
or applicationid = 'EC870B97-9C08-4C5A-B994-0B587BC97511'
or applicationid = 'EF061CAD-5058-4E80-8668-283B47C91334'
or applicationid = '35EB0C3E-EFD4-41E9-B68B-382289BB6025'
or applicationid = '57585F78-B5B8-485E-ABA8-3F034A8E01C7'
or applicationid = '27E55832-B293-4078-81A8-457085B8CAC8'
or applicationid = 'E5727682-4CA3-4F8C-B834-4757532EFB71'
or applicationid = 'AC9805E4-0D3B-45CF-86B5-5014222EF502'
or applicationid = 'E26D633B-9A95-408B-871B-51F8FDE9CB5A'
or applicationid = '6C0C3BEF-65D1-4AE9-A722-715A947A68BF'
or applicationid = '9F648D07-780F-4B5E-B0FB-754EFFD0DEA2'
or applicationid = '75EE75C1-914B-403A-ADD5-7CC3AD37B0B9'
or applicationid = '21B69912-BF05-4455-B04D-86E65E368B8F'
or applicationid = '83063347-BD87-4128-B0CB-BEF9D7D58E84'
or applicationid = '6A4AFBF8-EBD5-4447-9F26-C13FA4F6ED63'
or applicationid = '30CC5B5E-5EBD-49BB-80FB-CB308A3A33EC'
or applicationid = 'A27B69FC-1507-4F3E-8156-D93D8AE2E952'
or applicationid = '60C5959A-389C-446A-8F75-1FF9E0CA3EBF'
or applicationid = 'C9A38227-BEEE-4156-B427-38EB46ACB9B0'
or applicationid = '8DDFC805-7F99-47A6-A086-46CB3CCD4D3B'
or applicationid = 'CC105B77-8363-4BC4-AA63-51DAFF556898'
or applicationid = 'BE86E144-CEA0-4556-B11D-63FFC7A0B6F3'
or applicationid = 'CF931628-07B6-4A07-AEDD-7976DD336223'
or applicationid = 'D08B4C8C-A696-4CE0-8A1C-7AE4C590EA01'
or applicationid = '98209457-C8F4-4BBB-B124-A301B1A93C72'
or applicationid = '19732564-506D-4C42-B37F-D617B523F371'
or applicationid = 'D5E94CC0-A1ED-4E3C-BD06-E0BE702C911A'
or applicationid = '21CB044C-C9D5-402D-82A2-F21D097F65C1'
or applicationid = 'CF1D7257-AD44-4E91-9B4C-F5BBB60A5665'
or applicationid = '158DFBA5-2FFE-42F7-85C9-4EBB3896DB6A'
or applicationid = '72103917-FF18-4468-BD84-71C290442D71'
or applicationid = 'AE11769E-E76E-4723-BE12-90DFC5B33F2D'
or applicationid = '14A71E48-3864-4B1F-8553-A9A0214322B9'
or applicationid = '12384B4C-1FEB-4ABE-9EDE-B2FF5C1C7AA9'
or applicationid = '2B071D94-2E5F-4FA0-B9E7-B8C2B3D29CA0'
or applicationid = 'A56A3D12-9E7A-4BB0-B735-D4189EAA453A'
or applicationid = 'C9BAEF19-5D80-4176-B711-F104D18608B7'
or applicationid = '9F07CB63-2016-44E1-86E9-F138AEAA2CF5'
or applicationid = 'E64D961F-A9ED-4A1C-90CD-2479ECB6BC54'
or applicationid = '158077FB-878D-44D5-94C3-34062B8EE559'
or applicationid = '2927C51E-AE58-49DB-B116-3416A8E2BE23'
or applicationid = 'F5A78B81-CA56-42A6-B297-3AE3E5188181'
or applicationid = 'BB36EE30-C3ED-49EF-A99B-3B1D6E0700EF'
or applicationid = '22171396-AF8B-4D75-B969-47CC9ABE6069'
or applicationid = '5D24F1D6-7053-4E85-8226-4BF049ED74C6'
or applicationid = 'DC8C8137-D49C-4132-85B9-4E9EE0B6FBA6'
or applicationid = '464D5101-0C2E-46EB-9D69-873C9E01DBA9'
or applicationid = '34ABF1E0-1DCA-4B84-BB54-92090C0E5128'
or applicationid = '49CD9291-A4DE-40B1-B578-A0C019A5150D'
or applicationid = 'FB081147-9320-48E2-BE47-C24DD7451E84'
or applicationid = 'A261297C-403C-45D0-B5CE-CE08BDB635A6'
or applicationid = 'A1B78705-EDBA-4B55-B2B6-CEF2D0D84229'
or applicationid = '502D27D6-AE1B-461F-82C3-E55B4F44C796'
or applicationid = '0BBF438D-195B-4E70-AFD5-FDA0845793A3'
or applicationid = 'BD874883-0E1C-4EC2-883F-09F3685D04AF'
or applicationid = '61C55F7D-E75A-4563-9E0D-0A719ADABCB0'
or applicationid = '98B3331B-AEBC-47AB-8BB8-10F8D8C51602'
or applicationid = '0A99856E-DFC0-46F2-8116-4B014F4DD175'
or applicationid = 'BF21690A-B394-4EA2-AD50-4F3CDBA21017'
or applicationid = '3C9561CB-B2E1-481D-9B42-6FEA976DBA1F'
or applicationid = '36234724-7532-467E-A7DE-7A1F2A32BFE2'
or applicationid = 'E34E75DB-5845-4655-BD33-B1D7B931CFD4'
or applicationid = 'C74AA76A-F1C3-4BE1-9848-C962841A0FC8'
or applicationid = 'C5345CF0-17BB-4360-8E0D-E3DC8A69B6A4'
or applicationid = 'DCAC79D2-2765-45A0-B3C8-E8180B8EFAAD'
or applicationid = '076EC55B-3EEF-451F-9165-EB240B6A00AB'
or applicationid = '92A9D6AC-1011-4D78-ADD0-EFEA6458A484'
or applicationid = 'CD4EE7BB-90EA-465F-B42A-09FF920DA68D'
or applicationid = '83C4B886-A51F-40E0-9796-1C8C9CE77A9E'
or applicationid = '24041366-69B2-4E48-9A00-21D5634B08AA'
or applicationid = '31577CBA-2521-45C4-A81D-2A88AD1A4327'
or applicationid = 'A94CBC3F-E422-4E4F-9C8E-2AD52318F244'
or applicationid = '6CB13100-92D1-40F6-8B93-4AB3D9B05A9A'
or applicationid = '8947DCC6-FD51-47E1-A5EC-5AC2D3A54300'
or applicationid = 'FF2CE048-D431-4F34-97DC-6FAB0111BEB7'
or applicationid = 'F78AB4AC-653C-4420-99E1-9059C0011EC1'
or applicationid = '775E10E8-924A-4148-B134-9FCAD3304883'
or applicationid = '0317001C-A76E-4F48-A743-E99F4F294ED2'
or applicationid = '3036320D-80DE-4003-B4C4-12C6D93CCF9A'
or applicationid = '8EC1B49B-E55A-4D44-B381-3FAF22769444'
or applicationid = '4471573B-4F5E-472B-AC5C-5609E1613B86'
or applicationid = '69C2C5EF-F115-4016-8C2C-57626D279BB3'
or applicationid = 'C6510A51-675F-411C-B86C-7F03DBA7BE53'
or applicationid = 'F7F2FB30-796B-4574-B7E3-9EEBC2AA2D52'
or applicationid = '2192130E-A4AA-421F-898C-B7FEF832061E'
or applicationid = '5E2969E7-892A-4C2B-B0B9-CE26FBAD5D05'
or applicationid = '13F31EEB-D6D8-411C-B718-D9973888695A'
or applicationid = '853A78B0-8C03-43BB-8E68-E3C0EA18F77B'
or applicationid = '7DEB845E-32A6-4690-93C2-547D24793AAB'
or applicationid = '376D080F-D513-4CAB-937B-5A5D0A9FC909'
or applicationid = '7424ECE2-EF48-4A5E-BDD9-7FE0C4B407FD'
or applicationid = '03488131-6A0B-4D1E-9E1C-8D271C43AD46'
or applicationid = '90523B50-5487-4122-9055-9EFA1AFB03D6'
or applicationid = 'CD8252E7-59F2-4333-9FD9-A1784F857A79'
or applicationid = '2B5793ED-7EE9-489F-ACC7-B22AC2249473'
or applicationid = '3EDD4327-8005-4BDC-8D56-195D7EEA9571'
or applicationid = '55FF0FA7-EC70-46FF-BE3A-1F85DB13E0F9'
or applicationid = 'F37795AE-86CC-4C23-9DB4-607172331C94'
or applicationid = 'E7ABB189-7125-482D-B765-765E3E478C7B'
or applicationid = 'C340B9C8-12C2-460D-80C3-77C311AAADDC'
or applicationid = '4A2C9560-35B2-4902-B277-A3A1C2E092EC'
or applicationid = 'C0561536-A8F6-41A2-8E61-B18006EA94B5'
or applicationid = '32652123-AB63-4952-8582-B3BA45A8DE30'
or applicationid = 'FC59A38D-B59F-4F37-95B6-CA8EE546F786'
or applicationid = 'F359AB49-D080-4077-940F-D7AF76FF100B'
or applicationid = '32D100CE-E774-4C78-99CA-19AE7ADC02F7'
or applicationid = '6C914223-6063-4B1F-989F-2EEBC490FD15'
or applicationid = '50F47B9C-BE0A-4EF0-84A4-3681E640C9F8'
or applicationid = '2A6F46A7-E223-4088-BE7A-3B04AA249DEC'
or applicationid = '87AE73B0-2C59-4FE4-9308-5201CC69AD31'
or applicationid = '4CCB7DF4-2DF3-46AC-89A1-5ADC5E18F30F'
or applicationid = 'FE70FD32-5225-451F-B404-614C49879771'
or applicationid = 'BFA57F38-F885-45D5-B912-8413F09EF7B9'
or applicationid = '98E022CE-2568-4546-9E26-99316E9509A7'
or applicationid = '724D7D18-97DE-4E31-B472-9EC51FA7C743'
or applicationid = 'AAC351D1-7510-42D6-988D-9F25831D1CD5'
or applicationid = '548984B0-3F02-4D6F-B593-D39F093265B2'
or applicationid = '8DEC92AC-9A40-4C42-9265-ED71B0EF0569'
or applicationid = 'ED8768E2-ED06-43B2-AE02-18296C0D3B5A'
or applicationid = '5DA8D944-178E-4E81-ADAB-42A71A17C7DC'
or applicationid = '741E45D7-8861-4561-B4A2-4A09A4C30899'
or applicationid = '0B80C244-7A66-4FA1-8EEA-A9C09E6221C6'
or applicationid = 'B9DAAC7C-84B0-4C96-8EE5-B7CAADC0F0D7'
or applicationid = 'C8660149-BA10-4681-9C49-C451878D8DE8'
or applicationid = '9033D8CC-2C02-4BF4-BD37-D6509EE0D5CA'
or applicationid = '0668893E-7234-451B-AF10-E9B4E198721F'
or applicationid = 'B1A5AE3C-A761-4F9C-B0B8-EBDA06D9FC84'
or applicationid = '5C3F4F7E-4621-4676-98B8-1514DF937761'
or applicationid = '09A40898-0D05-434D-9E7F-1F2C569DED4B'
or applicationid = 'ED6770D8-C409-4E56-A745-2AC02DE1CEF2'
or applicationid = '6C172B62-3628-4AAB-8A28-3F3B7B004884'
or applicationid = 'AE7702DA-DE93-4DC0-9852-4411AB0E8581'
or applicationid = '7129A38D-7BB1-4682-B9D3-5A38C873E6D4'
or applicationid = '82270BB7-4492-4485-BEEF-7607DCA88870'
or applicationid = '7B9C1F9A-5437-41AF-9028-7A5A69B243B4'
or applicationid = 'EE9F1AFA-315C-49C2-A944-84339C1FC4BA'
or applicationid = '47EE4849-67C9-414D-9655-84A8CD3138D3'
or applicationid = 'BADEA36A-EB07-41AF-B02E-8D8D7A8B4CEE'
or applicationid = '06CB614E-5A1F-4912-9385-D1F80136273B'
or applicationid = 'D36EB7C2-3D86-4F52-9D11-D907595B5CB0'
or applicationid = 'ED8F2044-7982-42D7-B18B-FBED992BF4E1'
or applicationid = 'D25F4719-BEF8-4FF7-A8FC-1BDDCB4D3569'
or applicationid = '208FDD6E-94FB-42CC-B46D-2739C79397B4'
or applicationid = 'C222A709-8006-42B0-81FB-31DC544616E5'
or applicationid = 'FD3458D9-C62F-408D-9831-4925F36D523A'
or applicationid = 'B6C8F258-D3F0-4C94-854D-57F9F8A77B22'
or applicationid = '7F9D075A-0A50-4A21-98C6-790AF25EA083'
or applicationid = 'BD7245E4-D798-4C37-874A-A0301F09BAC4'
or applicationid = '3BB2E2C1-E58A-49E1-84B7-AA3BD23D52A5'
or applicationid = '694046DE-223A-4E32-B401-FB654A95EC1E'
or applicationid = '284BB2A0-516D-4022-B4F3-FC1F5BFB9425'
or applicationid = 'BB1B07C6-9A2D-4102-A3B0-2790BF44C079'
or applicationid = '5BD23FA4-D45B-4A4A-AFBB-3013FC6A54A8'
or applicationid = '49AEEA59-61DF-40E9-8621-43469A7AAD7F'
or applicationid = '9866A4B3-FDFA-4F96-81A6-4DBF3181A25E'
or applicationid = '4424521C-58D2-4800-83CD-578272616125'
or applicationid = '9E235184-B24B-4633-812D-90F94ED00DB0'
or applicationid = 'F6F545E7-F039-49A6-8F5C-9A7C03C36D98');

/* Table: seamless_events_spine
   Description: This staging table is a spine table with all of the messageids.
*/

select a.*
into jt.nonseamless_events_spine
from jt.nonseamless_delivered_once a
join (select distinct messageid
      from jt.nonseamless_events_lvl_2
      union
      select distinct messageid
      from jt.nonseamless_events_lvl_3
      union
      select distinct messageid
      from jt.nonseamless_events_lvl_4) b
on a.messageid = b.messageid;


/* Table: seamless_events_summary
   Description: This staging table tracks the different states that a message flows through.
*/

select a.*
     , case
         when c.messageid is not null then true
         else false
       end as delivered_flag
     , case
         when c.messageid is not null then c.eventtimestamp
         else null
       end as delivered_time
--     , coalesce(c.cnt,0) as delivered_cnt

     , case
         when d.messageid is not null then true
         else false
       end as failed_flag
     , case
         when d.messageid is not null then d.eventtimestamp
         else null
       end as failed_time
--    , coalesce(d.cnt,0) as failed_cnt

     , case
         when e.messageid is not null then true
         else false
       end as opened_flag
     , case
         when e.messageid is not null then e.eventtimestamp
         else null
       end as opened_time
--     , coalesce(e.cnt,0) as opened_cnt

     , case
         when f.messageid is not null then true
         else false
       end as complained_flag
     , case
         when f.messageid is not null then f.eventtimestamp
         else null
       end as complained_time
--     , coalesce(f.cnt,0) as complained_cnt

     , case
         when g.messageid is not null then true
         else false
       end as clicked_flag
     , case
         when g.messageid is not null then g.eventtimestamp
         else null
       end as clicked_time
--     , coalesce(g.cnt,0) as clicked_cnt
     , case
         when j.messageid is not null then true
         else false
       end as clicked_dnload_flag
     , case
         when j.messageid is not null then j.eventtimestamp
         else null
       end as clicked_dnload_time     
     , case
         when j.messageid is not null then j.clientos
         else null
       end as clicked_dnload_clientos    
     , case
         when j.messageid is not null then j.devicetype
         else null
       end as clicked_dnload_devicetype  
     , case
         when j.messageid is not null then j.clienttype
         else null
       end as clicked_dnload_clienttype
     , case
         when j.messageid is not null then j.useragent
         else null
       end as clicked_dnload_useragent    

       
       
         
     , case
         when h.messageid is not null then true
         else false
       end as unsubscribed_flag
     , case
         when h.messageid is not null then h.eventtimestamp
         else null
       end as unsubscribed_time
--     , coalesce(h.cnt,0) as unsubscribed_cnt

     , case
         when i.messageid is not null then true
         else false
       end as stored_flag
     , case
         when i.messageid is not null then i.eventtimestamp
         else null
       end as stored_time
--     , coalesce(i.cnt,0) as stored_cnt
into jt.nonseamless_events_summary
from jt.nonseamless_events_spine a
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_2 where eventstatus = 'delivered' group by 1) c
on a.messageid = c.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_2 where eventstatus = 'failed' group by 1) d
on a.messageid = d.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_3 where eventstatus = 'opened' group by 1) e
on a.messageid = e.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_3 where eventstatus = 'complained' group by 1) f
on a.messageid = f.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_4 where eventstatus = 'clicked' group by 1) g
on a.messageid = g.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_4 where eventstatus = 'unsubscribed' group by 1) h
on a.messageid = h.messageid
left join (select messageid, max(eventtimestamp) as eventtimestamp, count(*) as cnt from jt.nonseamless_events_lvl_4 where eventstatus = 'stored' group by 1) i
on a.messageid = i.messageid
left join (select a.messageid
                , a.eventtimestamp
                , b.clientos
                , b.devicetype
                , b.clienttype
                , b.useragent
           from (select messageid, min(eventtimestamp) as eventtimestamp from jt.nonseamless_events_lvl_4 where eventstatus = 'clicked' and clickurl like '%download%' group by 1) a
           join (select distinct messageid, clientos, devicetype, clienttype, useragent, eventtimestamp from jt.nonseamless_events_lvl_4 where eventstatus = 'clicked' and clickurl like '%download%') b
           on a.messageid = b.messageid and a.eventtimestamp = b.eventtimestamp) j
on a.messageid = j.messageid;



/* Table: seamless_strange_paths
   Description: This table contains the emails where anolalous events paths (e.g. "Opened" event but no "Delivered" event) occur.
*/

select applicationid
     , case
         when recipientemail like '%<%>%' then substring(recipientemail from (position('<' in recipientemail) + 1) for (position('>' in recipientemail) - position('<' in recipientemail) - 1))
         else recipientemail
       end as recipientemail
     , messageid
     , delivered_flag
     , failed_flag
     , opened_flag
     , complained_flag
     , clicked_flag
     , unsubscribed_flag
     , stored_flag
     , case
         when ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false)
            then 1
         when ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
            then 2
         else -1
       end as case_type
into jt.nonseamless_strange_paths
from jt.nonseamless_events_summary
where ((complained_flag = true or opened_flag = true or clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and delivered_flag = false)
or ((clicked_flag = true or unsubscribed_flag = true or stored_flag = true) and opened_flag = false);


/* Table: seamless_fact_analysis
   Description: This table contains the messages that are not in the strange_paths table.
*/

select a.applicationid
     , a.eventtype
     , a.emailsubjectcatg
     , case
         when a.recipientemail like '%<%>%' then substring(a.recipientemail from (position('<' in a.recipientemail) + 1) for (position('>' in a.recipientemail) - position('<' in a.recipientemail) - 1))
         else a.recipientemail
       end as recipientemail
     , a.messageid
     , a.delivered_flag
     , a.delivered_time
     , a.failed_flag
     , a.failed_time
     , case
         when b.case_type = 1 then true
         else a.opened_flag
       end as opened_flag
     , a.opened_time
     , a.complained_flag
     , a.complained_time
     , a.clicked_flag
     , a.clicked_time
     , a.clicked_dnload_flag
     , a.clicked_dnload_time
     , a.clicked_dnload_clientos
     , a.clicked_dnload_devicetype
     , a.clicked_dnload_clienttype
     , a.clicked_dnload_useragent
     , a.unsubscribed_flag
     , a.unsubscribed_time
     , a.stored_flag
     , a.stored_time
into jt.nonseamless_fact_analysis
from jt.nonseamless_events_summary a
left join jt.nonseamless_strange_paths b
on a.messageid = b.messageid and a.applicationid = b.applicationid
where b.applicationid is null 
or (b.applicationid is not null and b.case_type <> -1);


/* Table: seamless_login_funnel
   Description: This contains the funnel at the event level
*/

select d.applicationid
     , e.name as eventname
     , e.startdate
     , e.enddate
     , d.delivered_count
     , coalesce(o.opened_count,0) as opened_count
     , cast(cast(coalesce(o.opened_count,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as opened_pct
     , coalesce(c.clicked_count,0) as clicked_count
     , cast(cast(coalesce(c.clicked_count,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_pct
     , coalesce(b.clicked_dnload_link,0) as click_dnload_link
     , cast(cast(coalesce(b.clicked_dnload_link,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as click_dnload_link_pct
     , coalesce(m.click_dnload_mobile,0) as click_dnload_mobile
     , cast(cast(coalesce(m.click_dnload_mobile,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_dnload_mobile_pct
     , coalesce(i.click_dnload_mobile_ios,0) as click_dnload_mobile_ios
     , cast(cast(coalesce(i.click_dnload_mobile_ios,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_dnload_mobile_ios_pct
     , coalesce(a.click_dnload_mobile_android,0) as click_dnload_mobile_android
     , cast(cast(coalesce(a.click_dnload_mobile_android,0) as decimal(10,4))/cast(d.delivered_count as decimal(10,4)) as decimal(10,4)) as clicked_dnload_mobile_android_pct  
into jt.nonseamless_login_funnel
from (select applicationid
           , count(*) as delivered_count
      from (select distinct applicationid
                , recipientemail
           from jt.nonseamless_fact_analysis
           where delivered_flag = true) x
      group by 1) d
left join (select applicationid
                , count(*) as opened_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where opened_flag = true) x
            group by 1) o
on d.applicationid = o.applicationid
left join (select applicationid
                , count(*) as clicked_count
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where clicked_flag = true) x
            group by 1) c
on d.applicationid = c.applicationid


left join (select applicationid
                , count(*) as clicked_dnload_link
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where clicked_dnload_flag = true) x
            group by 1) b
on d.applicationid = b.applicationid

left join (select applicationid
                , count(*) as click_dnload_mobile
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where clicked_dnload_flag = true
                 and (clicked_dnload_devicetype = 'mobile'
                 or clicked_dnload_devicetype = 'tablet')) x
            group by 1) m            
on d.applicationid = m.applicationid
        
left join (select applicationid
                , count(*) as click_dnload_mobile_ios
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where clicked_dnload_flag = true
                 and (clicked_dnload_devicetype = 'mobile'
                 or clicked_dnload_devicetype = 'tablet')
                 and clicked_dnload_clientos = 'iOS') x
            group by 1) i            
on d.applicationid = i.applicationid
    
left join (select applicationid
                , count(*) as click_dnload_mobile_android
           from (select distinct applicationid
                      , recipientemail
                 from jt.nonseamless_fact_analysis
                 where clicked_dnload_flag = true
                 and (clicked_dnload_devicetype = 'mobile'
                 or clicked_dnload_devicetype = 'tablet')
                 and clicked_dnload_clientos = 'Android') x
            group by 1) a           
on d.applicationid = a.applicationid 
          
left join jt.tm_eventcubesummary e
on d.applicationid = e.applicationid
where d.delivered_count >= 100
order by 3,4; 


select *
from jt.nonseamless_login_funnel;




select *
from jt.tm_eventcubesummary
where (applicationid = '1C87DF2E-4D34-446A-80E2-013E3BAC7170'
or applicationid = 'F1F5DF7D-E81C-4201-9B94-089163B7EF0F'
or applicationid = 'DC12CD48-BB7F-4955-917A-0F0182683E4F'
or applicationid = 'FBAA081E-596E-47E4-9F46-4089A836CF71'
or applicationid = '61035230-5FCC-44F0-ADD8-594393C96895'
or applicationid = '9894EBB9-D345-4753-8DC3-64E50790B293'
or applicationid = '3E943526-AFE6-417F-BB1A-6E992B37A7BA'
or applicationid = '5D376E05-A8C2-4F14-9CE2-70A2DFECE85E'
or applicationid = '22279E2D-212D-41B7-9854-776FE915720E'
or applicationid = '0020571D-FD4D-49BB-8B28-A2D3800FF318'
or applicationid = '5B6CF6E5-D5FB-4AB0-8BA4-AA962BB3AD3D'
or applicationid = '1748F562-9027-485D-92C4-B01F59498E38'
or applicationid = 'C800ED62-8B9B-48B3-B918-D05A21A00984'
or applicationid = 'B4B30CC1-4389-4C8C-8943-DE27EFDD9EB2'
or applicationid = '34ABBE07-7264-4CA2-AA26-DFF8EEB108E6'
or applicationid = 'C4291322-B9D5-4584-8A07-1DCCDFA28DF5'
or applicationid = '41C1F41E-B4BE-4257-86F9-22C47C655793'
or applicationid = '30E710D1-E90F-46CC-8C26-4A97C019EEBC'
or applicationid = 'F713DC57-029E-43C2-B819-65A1EA525595'
or applicationid = '81D2E11F-1B0F-4275-A0D9-6A42B4F9E1AD'
or applicationid = '14C308B3-0B97-42DC-916A-81EFE86A2B9A'
or applicationid = 'F125BF81-621C-4762-B8D8-858DE2B5A470'
or applicationid = '6DCB03A0-FDA4-4F34-9DCC-A69C6985CAA3'
or applicationid = 'D1C3C46E-42F0-4CE8-A2CC-D25683F2575B'
or applicationid = '9881260B-79B8-4CFC-BC9B-D674AC367BBC'
or applicationid = '5C41B176-9B34-4C9A-85A1-DCDFF2309473'
or applicationid = '267E5070-4188-4C11-B027-F2431240161D'
or applicationid = '295BB4E3-53C1-45A7-BCE3-011B93A3EFE5'
or applicationid = 'C1BEDD2C-E106-4B0D-9F75-084BE645D221'
or applicationid = 'C268B100-C6CC-493C-8057-0A07EFB94F2A'
or applicationid = '79EB81B7-264D-44E4-AC96-273322BB6DCD'
or applicationid = '60EACA1B-FD27-4892-8B33-3D2CD54F6D1E'
or applicationid = '4B4FE5BD-1623-49FE-A334-7505EC18C99F'
or applicationid = '24A1B125-25F8-4C57-89F2-8298603E5278'
or applicationid = '49A81F2B-28B0-42F2-A4DF-878E7F4AE184'
or applicationid = '98056656-C959-4295-95AD-CAD151F5D2A8'
or applicationid = '5507AAC3-C433-4759-9FCF-D8AA5FD1CCBD'
or applicationid = 'BF461C07-1F2A-409B-A81F-0688213CF6FF'
or applicationid = 'B9B9B941-F899-45C8-8CAF-18B0CAE05D8B'
or applicationid = '05A697B9-D60E-49D1-933B-1BF92EF35D71'
or applicationid = '20840C72-788B-4C9E-9D91-2820A81A79A5'
or applicationid = 'A9980DC7-E857-4F97-9039-5038957AD769'
or applicationid = 'D3952526-E615-46F9-A5BE-6A8BA9880A1F'
or applicationid = '0CC5F95F-7AF7-4F62-8FC6-733BD6792829'
or applicationid = 'D5C2B3C6-2BB2-4968-8DB6-8CCFB6FA7AC8'
or applicationid = '0759561E-172A-41F6-92DC-948054D60E7D'
or applicationid = '2E3E340E-C3CF-4784-93E8-A1898E7C9AB6'
or applicationid = '397A38DA-37BD-4BDE-893A-A506A52AE9CF'
or applicationid = '72693855-1406-4690-BBE5-B625AA6DE5C0'
or applicationid = '46101742-D739-4465-97A8-D0E4B645465F'
or applicationid = '618439CC-6833-45E5-94FE-E93B70A2A0E0'
or applicationid = 'AF668F70-403C-403B-8F86-1480D77E66D0'
or applicationid = '8CE79357-4829-428C-A57C-246B286503B7'
or applicationid = '4568A817-5191-4002-A6BC-2B65FA0E756C'
or applicationid = '5F70274F-3C50-4CDE-8389-2B88F17E8031'
or applicationid = '6B6BB985-1D7C-4572-898E-80955D05E12C'
or applicationid = '15E85CF6-B7EC-4031-ADBE-84EDDFFCF6A4'
or applicationid = 'E4DA1784-40AE-4BF4-9806-AE558C9E3C73'
or applicationid = '6CA83DB6-86F3-4AB1-AC4A-E9C1FD46FF2D'
or applicationid = '5555825B-F5FA-4BE3-B083-24443BFE01AA'
or applicationid = 'FF5DD039-D43B-46C1-ADDB-63E0EB6227BE'
or applicationid = '2CA10389-EDE6-469C-BA7C-822A7DD52E67'
or applicationid = '10BB5DCB-D514-47F4-B2E1-9F3A67269529'
or applicationid = 'A4377274-04E9-4579-9D12-B0040A587C7A'
or applicationid = '628AE2DB-EB57-48C8-952E-255AF4C3E22A'
or applicationid = '4F0826EF-D346-4277-A85B-327B008E6132'
or applicationid = '8623B169-A61C-40AF-9849-33839A22ED70'
or applicationid = '90B38C50-8F86-441A-BBF7-382966EEFC70'
or applicationid = '9E8E55CD-6B38-41A3-82F7-521A56EFBA43'
or applicationid = 'E1DDC2D0-DD8D-4650-B91F-65C9B93C728F'
or applicationid = '1B6CB721-6F58-493F-A7BC-724AA276BB0E'
or applicationid = 'B18B18F6-CB0C-4289-9DC5-7F4A12261DC0'
or applicationid = 'B4ECAC21-91D4-4666-8A8A-89EAFEF321D1'
or applicationid = '047D92E3-EBFD-4EB6-BF05-AB14533BA112'
or applicationid = 'E539125E-A725-4DDF-899E-F5B6ABAB41AB'
or applicationid = '5C7CF891-6288-46E3-A353-09DEDAFBEB7C'
or applicationid = '03E5B58A-1A9E-43AF-83D7-B8EE58BD0BF4'
or applicationid = '68803BAF-CFA5-4E86-8318-858529008049'
or applicationid = '59C409AF-9383-4E8B-9044-8C0742822A98'
or applicationid = '6411727D-9E91-47AE-8732-9912444CF27C'
or applicationid = '8ABDA130-2D08-4909-965C-A67766D85D0D'
or applicationid = 'F2DF3932-1CAC-4D27-9B09-A6C26D85AB4A'
or applicationid = 'AE55D8B5-21C4-4B1C-B797-A95C882533D9'
or applicationid = 'AD948081-37D1-4860-9325-C03E7641EED0'
or applicationid = 'AFC442D8-9F95-4EE2-827B-C38AB45D929B'
or applicationid = '915DB044-EBCC-4442-8520-D91AE4478283'
or applicationid = '5BBC996B-7672-4BF0-9DCD-F531EABEA919'
or applicationid = '840BF386-EAE0-420C-94FF-37D4FEFF8B3B'
or applicationid = 'CF33F5ED-ED4D-430E-8FBC-53C2160A3F2B'
or applicationid = '36D5119E-D91A-4B4E-83BF-79884FA0113A'
or applicationid = '80F8BC6E-E35E-4097-84A0-85CA83EE3C10'
or applicationid = '7585ED89-9D5A-43C5-AFF7-C4D4207E846B'
or applicationid = '551F457D-1A63-47F3-9DDB-13CE37C11F93'
or applicationid = '69212268-D188-455A-94BB-1B783A0D709D'
or applicationid = 'BDC2D475-A1B3-4156-AF72-2ACDEC3DD6D4'
or applicationid = '499958F3-95C8-4B87-92BA-40C6CCE872D7'
or applicationid = '2C94CC37-ABAA-419B-AAEF-4FC922F820E8'
or applicationid = '004165AE-BA1B-4A7D-A107-5BDB46751430'
or applicationid = '445D91A6-3D72-4085-9DE0-74A9754E663D'
or applicationid = '91880A90-4383-4C57-BD3C-8F9E13EEB65B'
or applicationid = '89BCEC73-DEE2-48C5-B576-9E0A52D75956'
or applicationid = '7325E7C8-134F-407C-92F4-A646CACD2C99'
or applicationid = '407D88F0-DE75-48BB-839F-AB539EA58A5D'
or applicationid = '3128084D-EE77-4224-A368-B56EF844DCCB'
or applicationid = '3C89569C-A85C-492A-B9A6-F14D9FC35438'
or applicationid = 'A1CBECE2-D30C-47CD-AE5A-02E38E39021D'
or applicationid = 'C55FCED8-23F8-4D45-8880-03DBBB2718F1'
or applicationid = 'EC870B97-9C08-4C5A-B994-0B587BC97511'
or applicationid = 'EF061CAD-5058-4E80-8668-283B47C91334'
or applicationid = '35EB0C3E-EFD4-41E9-B68B-382289BB6025'
or applicationid = '57585F78-B5B8-485E-ABA8-3F034A8E01C7'
or applicationid = '27E55832-B293-4078-81A8-457085B8CAC8'
or applicationid = 'E5727682-4CA3-4F8C-B834-4757532EFB71'
or applicationid = 'AC9805E4-0D3B-45CF-86B5-5014222EF502'
or applicationid = 'E26D633B-9A95-408B-871B-51F8FDE9CB5A'
or applicationid = '6C0C3BEF-65D1-4AE9-A722-715A947A68BF'
or applicationid = '9F648D07-780F-4B5E-B0FB-754EFFD0DEA2'
or applicationid = '75EE75C1-914B-403A-ADD5-7CC3AD37B0B9'
or applicationid = '21B69912-BF05-4455-B04D-86E65E368B8F'
or applicationid = '83063347-BD87-4128-B0CB-BEF9D7D58E84'
or applicationid = '6A4AFBF8-EBD5-4447-9F26-C13FA4F6ED63'
or applicationid = '30CC5B5E-5EBD-49BB-80FB-CB308A3A33EC'
or applicationid = 'A27B69FC-1507-4F3E-8156-D93D8AE2E952'
or applicationid = '60C5959A-389C-446A-8F75-1FF9E0CA3EBF'
or applicationid = 'C9A38227-BEEE-4156-B427-38EB46ACB9B0'
or applicationid = '8DDFC805-7F99-47A6-A086-46CB3CCD4D3B'
or applicationid = 'CC105B77-8363-4BC4-AA63-51DAFF556898'
or applicationid = 'BE86E144-CEA0-4556-B11D-63FFC7A0B6F3'
or applicationid = 'CF931628-07B6-4A07-AEDD-7976DD336223'
or applicationid = 'D08B4C8C-A696-4CE0-8A1C-7AE4C590EA01'
or applicationid = '98209457-C8F4-4BBB-B124-A301B1A93C72'
or applicationid = '19732564-506D-4C42-B37F-D617B523F371'
or applicationid = 'D5E94CC0-A1ED-4E3C-BD06-E0BE702C911A'
or applicationid = '21CB044C-C9D5-402D-82A2-F21D097F65C1'
or applicationid = 'CF1D7257-AD44-4E91-9B4C-F5BBB60A5665'
or applicationid = '158DFBA5-2FFE-42F7-85C9-4EBB3896DB6A'
or applicationid = '72103917-FF18-4468-BD84-71C290442D71'
or applicationid = 'AE11769E-E76E-4723-BE12-90DFC5B33F2D'
or applicationid = '14A71E48-3864-4B1F-8553-A9A0214322B9'
or applicationid = '12384B4C-1FEB-4ABE-9EDE-B2FF5C1C7AA9'
or applicationid = '2B071D94-2E5F-4FA0-B9E7-B8C2B3D29CA0'
or applicationid = 'A56A3D12-9E7A-4BB0-B735-D4189EAA453A'
or applicationid = 'C9BAEF19-5D80-4176-B711-F104D18608B7'
or applicationid = '9F07CB63-2016-44E1-86E9-F138AEAA2CF5'
or applicationid = 'E64D961F-A9ED-4A1C-90CD-2479ECB6BC54'
or applicationid = '158077FB-878D-44D5-94C3-34062B8EE559'
or applicationid = '2927C51E-AE58-49DB-B116-3416A8E2BE23'
or applicationid = 'F5A78B81-CA56-42A6-B297-3AE3E5188181'
or applicationid = 'BB36EE30-C3ED-49EF-A99B-3B1D6E0700EF'
or applicationid = '22171396-AF8B-4D75-B969-47CC9ABE6069'
or applicationid = '5D24F1D6-7053-4E85-8226-4BF049ED74C6'
or applicationid = 'DC8C8137-D49C-4132-85B9-4E9EE0B6FBA6'
or applicationid = '464D5101-0C2E-46EB-9D69-873C9E01DBA9'
or applicationid = '34ABF1E0-1DCA-4B84-BB54-92090C0E5128'
or applicationid = '49CD9291-A4DE-40B1-B578-A0C019A5150D'
or applicationid = 'FB081147-9320-48E2-BE47-C24DD7451E84'
or applicationid = 'A261297C-403C-45D0-B5CE-CE08BDB635A6'
or applicationid = 'A1B78705-EDBA-4B55-B2B6-CEF2D0D84229'
or applicationid = '502D27D6-AE1B-461F-82C3-E55B4F44C796'
or applicationid = '0BBF438D-195B-4E70-AFD5-FDA0845793A3'
or applicationid = 'BD874883-0E1C-4EC2-883F-09F3685D04AF'
or applicationid = '61C55F7D-E75A-4563-9E0D-0A719ADABCB0'
or applicationid = '98B3331B-AEBC-47AB-8BB8-10F8D8C51602'
or applicationid = '0A99856E-DFC0-46F2-8116-4B014F4DD175'
or applicationid = 'BF21690A-B394-4EA2-AD50-4F3CDBA21017'
or applicationid = '3C9561CB-B2E1-481D-9B42-6FEA976DBA1F'
or applicationid = '36234724-7532-467E-A7DE-7A1F2A32BFE2'
or applicationid = 'E34E75DB-5845-4655-BD33-B1D7B931CFD4'
or applicationid = 'C74AA76A-F1C3-4BE1-9848-C962841A0FC8'
or applicationid = 'C5345CF0-17BB-4360-8E0D-E3DC8A69B6A4'
or applicationid = 'DCAC79D2-2765-45A0-B3C8-E8180B8EFAAD'
or applicationid = '076EC55B-3EEF-451F-9165-EB240B6A00AB'
or applicationid = '92A9D6AC-1011-4D78-ADD0-EFEA6458A484'
or applicationid = 'CD4EE7BB-90EA-465F-B42A-09FF920DA68D'
or applicationid = '83C4B886-A51F-40E0-9796-1C8C9CE77A9E'
or applicationid = '24041366-69B2-4E48-9A00-21D5634B08AA'
or applicationid = '31577CBA-2521-45C4-A81D-2A88AD1A4327'
or applicationid = 'A94CBC3F-E422-4E4F-9C8E-2AD52318F244'
or applicationid = '6CB13100-92D1-40F6-8B93-4AB3D9B05A9A'
or applicationid = '8947DCC6-FD51-47E1-A5EC-5AC2D3A54300'
or applicationid = 'FF2CE048-D431-4F34-97DC-6FAB0111BEB7'
or applicationid = 'F78AB4AC-653C-4420-99E1-9059C0011EC1'
or applicationid = '775E10E8-924A-4148-B134-9FCAD3304883'
or applicationid = '0317001C-A76E-4F48-A743-E99F4F294ED2'
or applicationid = '3036320D-80DE-4003-B4C4-12C6D93CCF9A'
or applicationid = '8EC1B49B-E55A-4D44-B381-3FAF22769444'
or applicationid = '4471573B-4F5E-472B-AC5C-5609E1613B86'
or applicationid = '69C2C5EF-F115-4016-8C2C-57626D279BB3'
or applicationid = 'C6510A51-675F-411C-B86C-7F03DBA7BE53'
or applicationid = 'F7F2FB30-796B-4574-B7E3-9EEBC2AA2D52'
or applicationid = '2192130E-A4AA-421F-898C-B7FEF832061E'
or applicationid = '5E2969E7-892A-4C2B-B0B9-CE26FBAD5D05'
or applicationid = '13F31EEB-D6D8-411C-B718-D9973888695A'
or applicationid = '853A78B0-8C03-43BB-8E68-E3C0EA18F77B'
or applicationid = '7DEB845E-32A6-4690-93C2-547D24793AAB'
or applicationid = '376D080F-D513-4CAB-937B-5A5D0A9FC909'
or applicationid = '7424ECE2-EF48-4A5E-BDD9-7FE0C4B407FD'
or applicationid = '03488131-6A0B-4D1E-9E1C-8D271C43AD46'
or applicationid = '90523B50-5487-4122-9055-9EFA1AFB03D6'
or applicationid = 'CD8252E7-59F2-4333-9FD9-A1784F857A79'
or applicationid = '2B5793ED-7EE9-489F-ACC7-B22AC2249473'
or applicationid = '3EDD4327-8005-4BDC-8D56-195D7EEA9571'
or applicationid = '55FF0FA7-EC70-46FF-BE3A-1F85DB13E0F9'
or applicationid = 'F37795AE-86CC-4C23-9DB4-607172331C94'
or applicationid = 'E7ABB189-7125-482D-B765-765E3E478C7B'
or applicationid = 'C340B9C8-12C2-460D-80C3-77C311AAADDC'
or applicationid = '4A2C9560-35B2-4902-B277-A3A1C2E092EC'
or applicationid = 'C0561536-A8F6-41A2-8E61-B18006EA94B5'
or applicationid = '32652123-AB63-4952-8582-B3BA45A8DE30'
or applicationid = 'FC59A38D-B59F-4F37-95B6-CA8EE546F786'
or applicationid = 'F359AB49-D080-4077-940F-D7AF76FF100B'
or applicationid = '32D100CE-E774-4C78-99CA-19AE7ADC02F7'
or applicationid = '6C914223-6063-4B1F-989F-2EEBC490FD15'
or applicationid = '50F47B9C-BE0A-4EF0-84A4-3681E640C9F8'
or applicationid = '2A6F46A7-E223-4088-BE7A-3B04AA249DEC'
or applicationid = '87AE73B0-2C59-4FE4-9308-5201CC69AD31'
or applicationid = '4CCB7DF4-2DF3-46AC-89A1-5ADC5E18F30F'
or applicationid = 'FE70FD32-5225-451F-B404-614C49879771'
or applicationid = 'BFA57F38-F885-45D5-B912-8413F09EF7B9'
or applicationid = '98E022CE-2568-4546-9E26-99316E9509A7'
or applicationid = '724D7D18-97DE-4E31-B472-9EC51FA7C743'
or applicationid = 'AAC351D1-7510-42D6-988D-9F25831D1CD5'
or applicationid = '548984B0-3F02-4D6F-B593-D39F093265B2'
or applicationid = '8DEC92AC-9A40-4C42-9265-ED71B0EF0569'
or applicationid = 'ED8768E2-ED06-43B2-AE02-18296C0D3B5A'
or applicationid = '5DA8D944-178E-4E81-ADAB-42A71A17C7DC'
or applicationid = '741E45D7-8861-4561-B4A2-4A09A4C30899'
or applicationid = '0B80C244-7A66-4FA1-8EEA-A9C09E6221C6'
or applicationid = 'B9DAAC7C-84B0-4C96-8EE5-B7CAADC0F0D7'
or applicationid = 'C8660149-BA10-4681-9C49-C451878D8DE8'
or applicationid = '9033D8CC-2C02-4BF4-BD37-D6509EE0D5CA'
or applicationid = '0668893E-7234-451B-AF10-E9B4E198721F'
or applicationid = 'B1A5AE3C-A761-4F9C-B0B8-EBDA06D9FC84'
or applicationid = '5C3F4F7E-4621-4676-98B8-1514DF937761'
or applicationid = '09A40898-0D05-434D-9E7F-1F2C569DED4B'
or applicationid = 'ED6770D8-C409-4E56-A745-2AC02DE1CEF2'
or applicationid = '6C172B62-3628-4AAB-8A28-3F3B7B004884'
or applicationid = 'AE7702DA-DE93-4DC0-9852-4411AB0E8581'
or applicationid = '7129A38D-7BB1-4682-B9D3-5A38C873E6D4'
or applicationid = '82270BB7-4492-4485-BEEF-7607DCA88870'
or applicationid = '7B9C1F9A-5437-41AF-9028-7A5A69B243B4'
or applicationid = 'EE9F1AFA-315C-49C2-A944-84339C1FC4BA'
or applicationid = '47EE4849-67C9-414D-9655-84A8CD3138D3'
or applicationid = 'BADEA36A-EB07-41AF-B02E-8D8D7A8B4CEE'
or applicationid = '06CB614E-5A1F-4912-9385-D1F80136273B'
or applicationid = 'D36EB7C2-3D86-4F52-9D11-D907595B5CB0'
or applicationid = 'ED8F2044-7982-42D7-B18B-FBED992BF4E1'
or applicationid = 'D25F4719-BEF8-4FF7-A8FC-1BDDCB4D3569'
or applicationid = '208FDD6E-94FB-42CC-B46D-2739C79397B4'
or applicationid = 'C222A709-8006-42B0-81FB-31DC544616E5'
or applicationid = 'FD3458D9-C62F-408D-9831-4925F36D523A'
or applicationid = 'B6C8F258-D3F0-4C94-854D-57F9F8A77B22'
or applicationid = '7F9D075A-0A50-4A21-98C6-790AF25EA083'
or applicationid = 'BD7245E4-D798-4C37-874A-A0301F09BAC4'
or applicationid = '3BB2E2C1-E58A-49E1-84B7-AA3BD23D52A5'
or applicationid = '694046DE-223A-4E32-B401-FB654A95EC1E'
or applicationid = '284BB2A0-516D-4022-B4F3-FC1F5BFB9425'
or applicationid = 'BB1B07C6-9A2D-4102-A3B0-2790BF44C079'
or applicationid = '5BD23FA4-D45B-4A4A-AFBB-3013FC6A54A8'
or applicationid = '49AEEA59-61DF-40E9-8621-43469A7AAD7F'
or applicationid = '9866A4B3-FDFA-4F96-81A6-4DBF3181A25E'
or applicationid = '4424521C-58D2-4800-83CD-578272616125'
or applicationid = '9E235184-B24B-4633-812D-90F94ED00DB0'
or applicationid = 'F6F545E7-F039-49A6-8F5C-9A7C03C36D98')
--and openevent = 0;

-- 264 closed reg events in June 2015
-- 88 of these sent out at least 100 emails
-- 72 of these had normal 


-- Seamless Login Stats (7 events)
-- 11.11% of welcome email recipients clicked on the download link (8% of these clicked on a mobile device) (A)
-- 70.94% of the mobile population of (A) who clicked on the 
-- 11.97% of all app can be accounted for through this channel


-- Non-Seamless Login Stats (72 closed reg events with at least 100 welcome emails sent out)
-- 24% of welcome email recipients clicked on the download link in the email (A)
-- 87% of (A) who clicked on the download button had at least one session
-- 32% of all app can be accounted for through this channel




