-- Temp Table: Get all Bundles
DROP TABLE IF EXISTS AutoLogin_Bundles_Temp;
CREATE TEMPORARY TABLE AutoLogin_Bundles_Temp AS
SELECT UPPER(Bundle_Id) AS BundleId
     , COUNT(DISTINCT Device_Id) AS DeviceCnt
     , COUNT(DISTINCT CASE WHEN Device_Type = 'ios' THEN Device_Id ELSE NULL END) AS iOSDeviceCnt
     , COUNT(DISTINCT CASE WHEN Device_Type = 'android' THEN Device_Id ELSE NULL END) AS AndroidDeviceCnt
FROM Dashboard.KPI_Login_View_Metrics
WHERE (Identifier = 'emailLoginSent' AND Metadata->>'Type' = 'autoLogin' AND Binary_Version >= '6.32')
OR (Identifier = 'passwordFork' AND Binary_Version >= '6.32')
GROUP BY 1
;

-- Get the Events associated with the bundles that are:
DROP TABLE IF EXISTS JT.AutoLogin_Events;
CREATE TABLE JT.AutoLogin_Events AS
SELECT EVENTS.*
     , CASE WHEN ParentBinaryVersion >= '6.32' THEN 1 ELSE 0 END AS ALBVFlag
FROM (SELECT DISTINCT APP.BundleId, ECS.*, PUBLIC.Fn_Parent_BinaryVersion(ECS.BinaryVersion) AS ParentBinaryVersion
           , CASE WHEN TE.ApplicationId IS NOT NULL THEN 1 ELSE 0 END AS TestEvent
      FROM EventCube.EventCubeSummary ECS
      JOIN PUBLIC.AuthDB_Applications APP
      ON ECS.ApplicationId = APP.ApplicationId
      JOIN (SELECT DISTINCT BundleId FROM AutoLogin_Bundles_Temp) BUNDLES
      ON BUNDLES.BundleId = APP.BundleId
      LEFT JOIN EventCube.TestEvents TE
      ON ECS.ApplicationId = TE.ApplicationId
     ) EVENTS
;


-- Using the presence of the EmailLoginSent View (autoLogin Type) to determine Auto Login
DROP TABLE IF EXISTS JT.AutoLogin_Bundles;
CREATE TABLE JT.AutoLogin_Bundles AS
SELECT BUNDLES.BundleId
     , BUNDLES.DeviceCnt
     , BUNDLES.iOSDeviceCnt
     , BUNDLES.AndroidDeviceCnt
     , COUNT(EVENTS.ApplicationId) AS EventCnt
     , COUNT(CASE WHEN EVENTS.OpenEvent = 1 THEN 1 ELSE NULL END) AS OpenEventCnt
     , COUNT(CASE WHEN EVENTS.OpenEvent = 0 THEN 1 ELSE NULL END) AS ClosedEventCnt
     , COUNT(CASE WHEN TestEvent = 0 THEN EVENTS.ApplicationId ELSE NULL END) AS NonTestEventCnt
     , COUNT(CASE WHEN ALBVFlag = 1 THEN EVENTS.ApplicationId ELSE NULL END) AS ALBVEventCnt
     , COUNT(CASE WHEN TestEvent = 0 AND ALBVFlag = 1 THEN EVENTS.ApplicationId ELSE NULL END) AS AllCondEventCnt
FROM AutoLogin_Bundles_Temp BUNDLES
LEFT JOIN JT.AutoLogin_Events EVENTS
ON BUNDLES.BundleId = EVENTS.BundleId
GROUP BY 1,2,3,4
;

-- Get all Login Bundle Actions
DROP TABLE IF EXISTS JT.AutoLogin_Actions;
CREATE TABLE JT.AutoLogin_Actions AS
SELECT METRICS.*
FROM PUBLIC.Fact_Actions_Live METRICS
JOIN (SELECT DISTINCT BundleId FROM JT.AutoLogin_Bundles WHERE AllCondEventCnt = 1) BUNDLES
ON METRICS.Bundle_Id = LOWER(BUNDLES.BundleId)
WHERE METRICS.Identifier IN ('enterEmail', 
                             'passwordFork', 
                             'emailLoginSent', 
                             'enterPassword', 
                             'emailLoginSent', 
                             'eventPicker', 
                             'profileFiller', 
                             'loginFlowStart', 
                             'enterPasswordLoginSuccess', 
                             'eventPickerLoginSuccess', 
                             'profileFillerLoginSuccess', 
                             'enterEmailTextField', 
                             'submitEmailButton',
                             'showPasswordOptionButton',
                             'enterPasswordTextField',
                             'submitPasswordButton',
                             'resetPasswordButton',
                             'cancelResetPasswordButton',
                             'submitResetPasswordButton',
                             'tosAgreeCheckBox', 
                             'passwordForkChoice', 
                             'openMailApp', 
                             'eventSelectButton', 
                             'createProfileButton',
                             'changeProfilePhotoButton', 
                             'enterFirstNameTextField', 
                             'enterLastNameTextField', 
                             'enterCompanyTextField', 
                             'enterTitleTextField', 
                             'addSocialNetworkToProfileButton', 
                             'submitProfileButton')
;



/*
-- Bad Views
SELECT Binary_Version
     , MMM_Info
     , Device_Type
     , COUNT(*)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NULL
GROUP BY 1,2,3
ORDER BY 1,2,3
;

-- Good Views
SELECT Binary_Version
     , MMM_Info
     , Device_Type
     , COUNT(*)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NOT NULL
GROUP BY 1,2,3
ORDER BY 1,2,3
;


SELECT Binary_Version
     , Device_Type
     , COUNT(*)
     , COUNT(CASE WHEN Metadata = '{}' THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN Metadata = '{}' THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NULL
GROUP BY 1,2
ORDER BY 1,2
;

SELECT binary_Version
     , Device_Type
     , Identifier
     , COUNT(*)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NULL
GROUP BY 1,2,3
ORDER BY 1,2,3
;


SELECT Binary_Version
     , Device_Type
     , COUNT(*)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NOT NULL
GROUP BY 1,2
ORDER BY 1,2
;

SELECT *
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND (Metadata->'InitialLogin') IS NULL
;

SELECT Identifier
     , COUNT(*)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NOT NULL THEN 1 ELSE NULL END) 
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
GROUP BY 1
;

SELECT Device_Type
     , Identifier
     , Binary_Version
     , COUNT(*)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NOT NULL THEN 1 ELSE NULL END) 
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NOT NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
     , COUNT(CASE WHEN (Metadata->'InitialLogin') IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4)
FROM Dashboard.KPI_Login_View_Metrics
WHERE Binary_Version >= '6.32'
AND Identifier IN ('enterEmail', 'enterPassword', 'resetPassword')
GROUP BY 1,2,3
ORDER BY 2,1,3
;

*/

-- Devices Views
DROP TABLE IF EXISTS JT.AutoLogin_Devices_Checklist;
CREATE TABLE JT.AutoLogin_Devices_Checklist AS
SELECT UPPER(Bundle_Id) AS BundleId
     , CASE
         WHEN OpenEventCnt = 0 AND ClosedEventCnt > 0 THEN 'Closed'
         WHEN OpenEventCnt > 0 AND ClosedEventCnt = 0 THEN 'Open'
         ELSE 'Mixed'
       END AS BundleType
     , OpenEventCnt
     , ClosedEventCnt
     , UPPER(Device_Id) AS DeviceId
     , Device_Type AS DeviceType
     
     -- First Binary Version
     , PUBLIC.FN_Parent_BinaryVersion(MIN(Binary_Version)) AS FirstParentBinaryVersion
     
     -- Initial Login Metrics
     
     -- Login Funnel Checkpoint
     , MIN(CASE WHEN Identifier = 'loginFlowStart' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS LoginFlowStartCreated
     
     -- SSO Web Login
     , MIN(CASE WHEN Identifier = 'remoteSsoLogin' THEN Created ELSE NULL END) AS SSOLoginCreated
     , MIN(CASE WHEN Identifier = 'webLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SSOLoginSuccessCreated
     
     -- Enter Email View/Action(s)/Checkpoint(s)
     , MIN(CASE WHEN Identifier = 'enterEmail' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterEmailCreated
     , MIN(CASE WHEN Identifier = 'enterEmailTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterEmailButtonCreated
     , MIN(CASE WHEN Identifier = 'submitEmailButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SubmitEnterEmailButtonCreated
     , MIN(CASE WHEN Identifier = 'tosAgreeCheckBox' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS TOSAgreeButtonCreated
     , MIN(CASE WHEN Identifier = 'enterEmailLoginError' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterEmailLoginErrorCreated
     , MIN(CASE WHEN Identifier = 'enterEmailLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterEmailLoginSuccessCreated
     
     -- Password Fork View/Action(s)
     , MIN(CASE WHEN Identifier = 'passwordFork' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS PasswordForkCreated
     , MIN(CASE WHEN Identifier = 'passwordForkChoice' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS PasswordForkButtonCreated
     -- Issue with Checkpoint
     
     -- AutoLogin Email Sent View/Action(s) (MIN)
     , MIN(CASE WHEN Identifier = 'emailLoginSent' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'autoLogin' THEN Created ELSE NULL END) AS AutoLoginCreated
     , MIN(CASE WHEN Identifier = 'openMailApp' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'autoLogin' THEN Created ELSE NULL END) AS AutoLoginButtonCreated
     -- Issue with Checkpoint 

     -- AutoLogin Email Sent View/Action(s) (MAX)
     , MAX(CASE WHEN Identifier = 'emailLoginSent' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'autoLogin' THEN Created ELSE NULL END) AS MaxAutoLoginCreated
     , MAX(CASE WHEN Identifier = 'openMailApp' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'autoLogin' THEN Created ELSE NULL END) AS MaxAutoLoginButtonCreated
     
     -- Enter Password View/Action(s)/Checkpoint (MIN)
     , MIN(CASE WHEN Identifier = 'enterPassword' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterPasswordCreated
     , MIN(CASE WHEN Identifier = 'showPasswordOptionButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS ShowPasswordCreated
     , MIN(CASE WHEN Identifier = 'enterPasswordTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterPasswordTextCreated
     , MIN(CASE WHEN Identifier = 'submitPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SubmitPasswordButtonCreated
     , MIN(CASE WHEN Identifier = 'resetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS ResetPasswordButtonCreated
     , MIN(CASE WHEN Identifier = 'cancelResetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS CancelResetButtonCreated
     , MIN(CASE WHEN Identifier = 'submitResetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SubmitResetButtonCreated
     , MIN(CASE WHEN Identifier = 'enterPasswordLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterPasswordLoginSuccessCreated

     -- Enter Password View/Action(s)/Checkpoint (MAX)
     , MAX(CASE WHEN Identifier = 'enterPassword' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxEnterPasswordCreated
     , MAX(CASE WHEN Identifier = 'showPasswordOptionButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxShowPasswordCreated
     , MAX(CASE WHEN Identifier = 'enterPasswordTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxEnterPasswordTextCreated
     , MAX(CASE WHEN Identifier = 'submitPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxSubmitPasswordButtonCreated
     , MAX(CASE WHEN Identifier = 'resetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxResetPasswordButtonCreated
     , MAX(CASE WHEN Identifier = 'cancelResetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxCancelResetButtonCreated
     , MAX(CASE WHEN Identifier = 'submitResetPasswordButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxSubmitResetButtonCreated
     , MAX(CASE WHEN Identifier = 'enterPasswordLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS MaxEnterPasswordLoginSuccessCreated
     
     -- Reset Password Sent View
     , MIN(CASE WHEN Identifier = 'emailLoginSent' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'resetPassword' THEN Created ELSE NULL END) AS ResetPasswordCreated
     , MIN(CASE WHEN Identifier = 'openMailApp' AND Metadata->>'InitialLogin' = 'true' AND Metadata->>'Type' = 'resetPassword' THEN Created ELSE NULL END) AS ResetButtonCreated
     -- Issue with Checkpoint Metric
     
     -- Event Picker View/Action/Checkpoint
     , MIN(CASE WHEN Identifier = 'eventPicker' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EventPickerCreated
     , MIN(CASE WHEN Identifier = 'eventSelectButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EventSelectButtonCreated
     , MIN(CASE WHEN Identifier = 'eventPickerLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EventPickerLoginSuccessCreated
     
     -- Event Profile Choice View
     , MIN(CASE WHEN Identifier = 'eventProfileChoice' THEN Created ELSE NULL END) AS EventProfileCreated
     , MIN(CASE WHEN Identifier = 'createProfileButton' THEN Created ELSE NULL END) AS CreateProfileCreated
     
     -- Profile Filler View/Checkpoint
     , MIN(CASE WHEN Identifier = 'profileFiller' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS ProfileFillerCreated
     , MIN(CASE WHEN Identifier = 'changeProfilePhotoButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS ChangeProfilePhotoCreated
     , MIN(CASE WHEN Identifier = 'enterFirstNameTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterFirstNameCreated
     , MIN(CASE WHEN Identifier = 'enterLastNameTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterLastNameCreated
     , MIN(CASE WHEN Identifier = 'enterCompanyTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterCompanyNameCreated
     , MIN(CASE WHEN Identifier = 'enterTitleTextField' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS EnterTitleNameCreated
     , MIN(CASE WHEN Identifier = 'addSocialNetworkToProfileButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SocialNetworkCreated
     , MIN(CASE WHEN Identifier = 'submitProfileButton' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS SubmitProfileCreated
     , MIN(CASE WHEN Identifier = 'profileFillerLoginSuccess' AND Metadata->>'InitialLogin' = 'true' THEN Created ELSE NULL END) AS ProfileFillerLoginSuccessCreated
     
     -- Non-initial Login
     , MIN(CASE WHEN Identifier IN ('enterEmail', 'passwordFork', 'emailLoginSent', 'enterPassword', 'emailLoginSent', 'eventPicker', 'profileFiller', 'loginFlowStart', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess', 'profileFillerLoginSuccess', 'enterEmailTextField', 'submitEmailButton', 'tosAgreeCheckBox', 'passwordForkChoice', 'openMailApp', 'eventSelectButton', 'changeProfilePhotoButton', 'enterFirstNameTextField', 'enterLastNameTextField', 'enterCompanyTextField', 'enterTitleTextField', 'addSocialNetworkToProfileButton', 'submitProfileButton') AND Metadata->>'InitialLogin' = 'false' THEN Created ELSE NULL END) AS NonIntialViewCreated 
     
     -- Non-login Views
     , MIN(CASE WHEN Identifier IN ('eventPicker', 'profileFiller', 'eventSelectButton', 'changeProfilePhotoButton', 'enterFirstNameTextField', 'enterLastNameTextField', 'enterCompanyTextField', 'enterTitleTextField', 'addSocialNetworkToProfileButton', 'submitProfileButton') AND (Metadata->'InitialLogin') IS NULL THEN Created ELSE NULL END) AS NonLoginViewCreated       
     
FROM (SELECT *
      FROM Dashboard.KPI_Login_View_Metrics METRICS
      JOIN (SELECT BundleId, OpenEventCnt, ClosedEventCnt
            FROM JT.AutoLogin_Bundles
            WHERE AllCondEventCnt >= 1
           ) BUNDLES
      ON METRICS.Bundle_Id = LOWER(BUNDLES.BundleId)
      UNION ALL
      SELECT *
      FROM Dashboard.KPI_Login_Checkpoint_Metrics METRICS
      JOIN (SELECT BundleId, OpenEventCnt, ClosedEventCnt
            FROM JT.AutoLogin_Bundles 
            WHERE AllCondEventCnt >= 1
           ) BUNDLES
      ON METRICS.Bundle_Id = LOWER(BUNDLES.BundleId)
      UNION ALL
      SELECT *
      FROM JT.AutoLogin_Actions METRICS
      JOIN (SELECT BundleId, OpenEventCnt, ClosedEventCnt
            FROM JT.AutoLogin_Bundles 
            WHERE AllCondEventCnt >= 1
           ) BUNDLES
      ON METRICS.Bundle_Id = LOWER(BUNDLES.BundleId)
     ) METRICS      
GROUP BY 1,2,3,4,5,6
;


DROP TABLE IF EXISTS JT.AutoLogin_Devices_Checklist_Detail;
CREATE TABLE JT.AutoLogin_Devices_Checklist_Detail AS
SELECT BundleId
     , BundleType
     , OpenEventCnt
     , ClosedEventCnt
     , DeviceID
     , DeviceType
     , FirstParentBinaryVersion
     , CASE
        WHEN SSOLoginCreated IS NOT NULL OR SSOLoginSuccessCreated IS NOT NULL THEN 1
        ELSE 0
       END AS SSOFlag
     , CASE
         WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL OR EnterEmailButtonCreated IS NOT NULL OR SubmitEnterEmailButtonCreated IS NOT NULL OR TOSAgreeButtonCreated IS NOT NULL OR EnterEmailLoginErrorCreated IS NOT NULL OR EnterEmailLoginSuccessCreated IS NOT NULL THEN 1
         ELSE 0
       END AS EnterEmailFlag
     , CASE 
         WHEN PasswordForkCreated IS NOT NULL OR PasswordForkButtonCreated IS NOT NULL THEN 1
         ELSE 0
       END AS PasswordForkFlag       
     , CASE
         WHEN EnterPasswordCreated IS NOT NULL OR ShowPasswordCreated IS NOT NULL OR EnterPasswordTextCreated IS NOT NULL OR SubmitPasswordButtonCreated IS NOT NULL OR ResetPasswordButtonCreated IS NOT NULL OR SubmitResetButtonCreated IS NOT NULL OR CancelResetButtonCreated IS NOT NULL OR EnterPasswordLoginSuccessCreated IS NOT NULL THEN 1
         ELSE 0
       END AS EnterPasswordFlag
     , CASE
         WHEN SubmitResetButtonCreated IS NOT NULL OR ResetPasswordCreated IS NOT NULL OR ResetButtonCreated IS NOT NULL THEN 1
         ELSE 0
       END AS ResetPasswordFlag
     , CASE
         WHEN AutoLoginCreated IS NOT NULL OR AutoLoginButtonCreated IS NOT NULL THEN 1
         ELSE 0
       END AS AutoLoginFlag
     , CASE
         WHEN EventPickerCreated IS NOT NULL OR EventSelectButtonCreated IS NOT NULL OR EventPickerLoginSuccessCreated IS NOT NULL THEN 1
         ELSE 0
       END AS EventPickerFlag
     , CASE
         WHEN EventProfileCreated IS NOT NULL OR CreateProfileCreated IS NOT NULL THEN 1
         ELSE 0
       END AS EventProfileFlag
     , CASE
         WHEN ProfileFillerCreated IS NOT NULL OR ChangeProfilePhotoCreated IS NOT NULL OR EnterFirstNameCreated IS NOT NULL OR EnterLastNameCreated IS NOT NULL OR EnterCompanyNameCreated IS NOT NULL OR EnterTitleNameCreated IS NOT NULL OR SocialNetworkCreated IS NOT NULL OR SubmitProfileCreated IS NOT NULL OR ProfileFillerLoginSuccessCreated IS NOT NULL THEN 1
         ELSE 0
       END AS ProfileFillerFlag
     , CASE
         WHEN NonIntialViewCreated IS NOT NULL THEN 1
         ELSE 0
       END AS NonIntialViewFlag
     , CASE
         WHEN NonLoginViewCreated IS NOT NULL THEN 1
         ELSE 0
       END AS NonLoginViewFlag
     , COALESCE(SSOLoginCreated, SSOLoginSuccessCreated) AS SSOLoginCreated
     , COALESCE(LoginFlowStartCreated, EnterEmailCreated, EnterEmailButtonCreated, SubmitEnterEmailButtonCreated, TOSAgreeButtonCreated, EnterEmailLoginErrorCreated, EnterEmailLoginSuccessCreated) AS EnterEmailCreated
     , COALESCE(PasswordForkCreated, PasswordForkButtonCreated) AS PasswordForkCreated
     , COALESCE(EnterPasswordCreated, ShowPasswordCreated, EnterPasswordTextCreated, SubmitPasswordButtonCreated, ResetPasswordButtonCreated, SubmitResetButtonCreated, CancelResetButtonCreated, EnterPasswordLoginSuccessCreated) AS EnterPasswordCreated
     , COALESCE(MaxEnterPasswordCreated, MaxShowPasswordCreated, MaxEnterPasswordTextCreated, MaxSubmitPasswordButtonCreated, MaxResetPasswordButtonCreated, MaxSubmitResetButtonCreated, MaxCancelResetButtonCreated, MaxEnterPasswordLoginSuccessCreated) AS MaxEnterPasswordCreated
     , COALESCE(SubmitResetButtonCreated, ResetPasswordCreated, ResetButtonCreated) AS SubmitResetButtonCreated
     , COALESCE(AutoLoginCreated, AutoLoginButtonCreated) AS AutoLoginCreated
     , COALESCE(MaxAutoLoginCreated, MaxAutoLoginButtonCreated) AS MaxAutoLoginCreated
     , COALESCE(EventPickerCreated, EventSelectButtonCreated, EventPickerLoginSuccessCreated) AS EventPickerCreated
     , COALESCE(EventProfileCreated, CreateProfileCreated) AS EventProfileCreated
     , COALESCE(ProfileFillerCreated, ChangeProfilePhotoCreated, EnterFirstNameCreated, EnterLastNameCreated, EnterCompanyNameCreated, EnterTitleNameCreated, SocialNetworkCreated, SubmitProfileCreated, ProfileFillerLoginSuccessCreated) AS ProfileFillerCreated
     , NonIntialViewCreated
     , NonLoginViewCreated
FROM JT.AutoLogin_Devices_Checklist
;



-- Device Sample/Metrics Analysis 
 
-- Weird Device Metrics
DROP TABLE IF EXISTS JT.AutoLogin_ErrorDevices;
CREATE TABLE JT.AutoLogin_ErrorDevices AS
SELECT BundleId
     , BundleType
     , DeviceId
     , DeviceType
     , FirstParentBinaryVersion
     , CASE WHEN EnterEmailFlag = 0 THEN 1 ELSE 0 END AS EnterEmailErrorFlag
     , CASE WHEN EnterEmailFlag = 1 AND AutoLoginFlag = 1 AND PasswordForkFlag = 0 THEN 1 ELSE 0 END AS AutoLoginErrorFlag
     , CASE WHEN EnterEmailFlag = 1 AND EnterEmailFlag = 1 AND PasswordForkFlag = 0 THEN 1 ELSE 0 END AS EnterPasswordErrorFlag     
     , CASE WHEN EnterEmailFlag = 1 AND EnterEmailFlag = 0 AND AutoLoginFlag = 0 AND PasswordForkFlag = 0 AND (EventPickerFlag = 1 OR ProfileFillerFlag = 1) THEN 1 ELSE 0 END AS PasswordErrorFlag
FROM JT.AutoLogin_Devices_Checklist_Detail
WHERE FirstParentBinaryVersion >= '6.32'
AND BundleType = 'Closed'
;

SELECT DISTINCT BundleId
FROM AutoLogin_ClosedDevices
;
--26

SELECT DISTINCT BundleId
FROM JT.AutoLogin_Bundles
;
--43



-- Overall Counts
SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailErrorCnt
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END) AS AutoLoginErrorCnt
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterPasswordErrorCnt
     , COUNT(CASE WHEN PasswordErrorFlag = 1 THEN 1 ELSE NULL END) AS PasswordErrorCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterEmailErrorPct
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS AutoLoginErrorPct
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterPasswordErrorPct
     , COUNT(CASE WHEN PasswordErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS PasswordErrorPct                    
FROM AutoLogin_ErrorDevices
;

-- By Bundle
SELECT BundleId
     , BundleType
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailErrorCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterEmailErrorPct
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END) AS AutoLoginErrorCnt
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS AutoLoginErrorPct
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterPasswordErrorPct
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterPasswordErrorPct
FROM AutoLogin_ErrorDevices
GROUP BY 1,2
ORDER BY 1,2
;

-- By Binary Version
SELECT FirstParentBinaryVersion
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailErrorCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterEmailErrorPct
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END) AS AutoLoginErrorCnt
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS AutoLoginErrorPct     
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterPasswordErrorPct
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterPasswordErrorPct
FROM AutoLogin_ErrorDevices
GROUP BY 1
ORDER BY 1
;

-- By Device Type/Binary Version
SELECT DeviceType
     , FirstParentBinaryVersion
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailErrorCnt
     , COUNT(CASE WHEN EnterEmailErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterEmailErrorPct
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END) AS AutoLoginErrorCnt
     , COUNT(CASE WHEN AutoLoginErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS AutoLoginErrorPct     
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END) AS EnterPasswordErrorPct
     , COUNT(CASE WHEN EnterPasswordErrorFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EnterPasswordErrorPct
FROM AutoLogin_ErrorDevices
GROUP BY 1,2
ORDER BY 1,2
;

-- Define Closed Bundle Device Samples
DROP TABLE IF EXISTS JT.AutoLogin_ClosedDevices;
CREATE TABLE JT.AutoLogin_ClosedDevices AS
SELECT DETAIL.*
     , ERRORS.EnterEmailErrorFlag
     , ERRORS.AutoLoginErrorFlag
     , ERRORS.EnterPasswordErrorFlag
     , ERRORS.PasswordErrorFlag
FROM JT.AutoLogin_Devices_Checklist_Detail DETAIL
JOIN JT.AutoLogin_ErrorDevices ERRORS
ON DETAIL.BundleId = ERRORS.BundleId AND DETAIL.DeviceId = ERRORS.DeviceId
WHERE DETAIL.FirstParentBinaryVersion >= '6.33'
;

SELECT COUNT(*)
FROM JT.AutoLogin_Devices_Checklist_Detail DETAIL
WHERE DETAIL.FirstParentBinaryVersion >= '6.33'
AND DETAIL.BundleType = 'Closed'
;
-- 1393

SELECT COUNT(*)
FROM AutoLogin_ClosedDevices
;
-- 1196


-- Enter Email Step (Overall)
SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN PasswordForkFlag = 1 THEN 1 ELSE NULL END) AS PasswordForkCnt
     , COUNT(CASE WHEN PasswordForkFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN EnterEmailFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4) AS PasswordForkPct
FROM AutoLogin_ClosedDevices
WHERE EnterEmailErrorFlag = 0
;

-- Enter Email Step (By Bundle)
SELECT DEVICES.BundleId AS "Bundle ID"
     , BUNDLES.Name AS "Bundle Name"
     , COUNT(CASE WHEN EnterEmailFlag = 1 THEN 1 ELSE NULL END) AS "Enter Email View - Device Count"
     , COUNT(CASE WHEN PasswordForkFlag = 1 THEN 1 ELSE NULL END) AS "Password Fork View - Device Count"
     , COUNT(CASE WHEN PasswordForkFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN EnterEmailFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4) AS "Password Fork View - Device %"
FROM AutoLogin_ClosedDevices DEVICES
LEFT JOIN PUBLIC.AuthDB_Bundles BUNDLES
ON DEVICES.BundleId = BUNDLES.BundleId
WHERE EnterEmailErrorFlag = 0
GROUP BY 1,2
ORDER BY 1
;


-- Auto Login/Reset Password Step
SELECT COUNT(*) AS PasswordForkCnt
     , COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS NextStepCnt
     , COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS NextStepPct
     , COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS AutoLoginCnt
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END) AS EnterPasswordCnt
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS BothCnt
     , COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4) AS AutoLoginPct
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4) AS EnterPasswordPct
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4) AS BothPct
FROM AutoLogin_ClosedDevices
WHERE EnterEmailErrorFlag = 0
AND EnterPasswordErrorFlag = 0 AND AutoLoginErrorFlag = 0
;


SELECT DEVICES.BundleId AS "Bundle ID"
     , BUNDLES.Name AS "Bundle Name"
     , COUNT(*) AS "Password Fork View - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS "Enter Password/Auto Login View - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS "Enter Password/Auto Login View - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS "Auto Login View Only - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END) AS "Enter Password View Only - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS "Both, Auto Login View Last - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS  "Both, Enter Password View Last - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Auto Login View Only - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Enter Password View Only - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Both, Auto Login View Last - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 OR AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Both, Enter Password View Last - Device %"
FROM AutoLogin_ClosedDevices DEVICES
JOIN PUBLIC.AuthDB_Bundles BUNDLES
ON DEVICES.BundleId = BUNDLES.BundleId
WHERE EnterEmailErrorFlag = 0
AND EnterPasswordErrorFlag = 0 AND AutoLoginErrorFlag = 0
GROUP BY 1,2
ORDER BY 1
;


SELECT DEVICES.BundleId AS "Bundle ID"
     , BUNDLES.Name AS "Bundle Name"
     , COUNT(*) AS "Password View - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 THEN 1 ELSE NULL END) AS "EventPicker View - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(*)::DECIMAL(12,4),0) AS "EventPicker View - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS "Auto Login View Only - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END) AS "Enter Password View Only - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS "Both, Auto Login View Last - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS  "Both, Enter Password View Last - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END) AS "Auto Login View Only to EventPicker View - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END) AS "Enter Password View Only to EventPicker View - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS "Both, Auto Login View Last to EventPicker View - Device Count" 
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS "Both, Enter Password View Last to EventPicker View - Device Count"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 0 AND AutoLoginFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Auto Login View Only to EventPicker View - Device %"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Enter Password View Only to EventPicker View - Device %" 
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4), 0) AS "Both, Auto Login View Last to EventPicker View - Device %"
     , COUNT(CASE WHEN EventPickerFlag = 1 AND EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4), 0) AS "Both, Enter Password View Last to EventPicker View - Device %"     
FROM AutoLogin_ClosedDevices DEVICES
JOIN PUBLIC.AuthDB_Bundles BUNDLES
ON DEVICES.BundleId = BUNDLES.BundleId
WHERE EnterEmailErrorFlag = 0
AND EnterPasswordErrorFlag = 0 AND AutoLoginErrorFlag = 0
AND (EnterPasswordFlag = 1 OR AutoLoginFlag = 1)
GROUP BY 1,2
ORDER BY 1
;


-- Both Analysis
DROP TABLE IF EXISTS AutoLogin_Both;
CREATE TEMPORARY TABLE AutoLogin_Both AS
SELECT DeviceId
     , CASE WHEN AutoLoginCreated >= EnterEmailCreated THEN 1 ELSE 0 END AS AutoLoginPath
     , CASE WHEN ResetPasswordCreated IS NOT NULL THEN 1 ELSE 0 END AS ResetPassword
     , CASE WHEN EventPickerCreated IS NOT NULL THEN 1 ELSE 0 END AS EventPicker
FROM (
SELECT LIST.DeviceId
     , COALESCE(AutoLoginCreated, AutoLoginButtonCreated) AS AutoLoginCreated
     , COALESCE(EnterPasswordCreated, ShowPasswordCreated, EnterPasswordTextCreated, SubmitPasswordButtonCreated, ResetPasswordButtonCreated, CancelResetButtonCreated, SubmitResetButtonCreated, EnterPasswordLoginSuccessCreated) AS EnterEmailCreated
     , COALESCE(ResetPasswordCreated, ResetButtonCreated) AS ResetPasswordCreated
     , COALESCE(EventPickerCreated, EventSelectButtonCreated, EventPickerLoginSuccessCreated) AS EventPickerCreated
FROM JT.AutoLogin_Devices_Checklist LIST
JOIN (SELECT DeviceId
           , BundleId 
      FROM AutoLogin_ClosedDevices
      WHERE EnterPasswordFlag = 1 AND AutoLoginFlag = 1
      AND PasswordErrorFlag = 0
     ) DEVICES
ON LIST.BundleId = DEVICES.BundleId AND LIST.DeviceId = DEVICES.DeviceId
) A
;


SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EventPicker = 1 THEN 1 ELSE NULL END) AS EventPicker
     , COUNT(CASE WHEN ResetPassword = 1 THEN 1 ELSE NULL END) AS ResetPasswordCnt
     , COUNT(CASE WHEN ResetPassword = 0 THEN 1 ELSE NULL END) AS NoResetPasswordCnt     
     , COUNT(CASE WHEN ResetPassword = 1 AND EventPicker = 1 THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN ResetPassword = 0 AND EventPicker = 1 THEN 1 ELSE NULL END)
FROM AutoLogin_Both
WHERE AutoLoginPath = 0
;

SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EventPicker = 1 THEN 1 ELSE NULL END) AS EventPicker
     , COUNT(CASE WHEN ResetPassword = 1 THEN 1 ELSE NULL END) AS ResetPasswordCnt
     , COUNT(CASE WHEN ResetPassword = 0 THEN 1 ELSE NULL END) AS NoResetPasswordCnt     
     , COUNT(CASE WHEN ResetPassword = 1 AND EventPicker = 1 THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN ResetPassword = 0 AND EventPicker = 1 THEN 1 ELSE NULL END)
FROM AutoLogin_Both
WHERE AutoLoginPath = 1
;


-- Reset Password Analysis
SELECT DEVICES.BundleId AS "Bundle ID"
     , BUNDLES.Name AS "Bundle Name"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 THEN 1 ELSE NULL END) AS "Enter Password View - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END) AS "Reset Password Button - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Reset Password Button - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END) AS "Enter Password View Only - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS "Both, Auto Login View Last - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END) AS  "Both, Enter Password View Last - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END) AS "Enter Password View Only, Reset Password Button - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END) AS "Both, Auto Login View Last, Reset Password Button - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END) AS "Both, Enter Password View Last, Reset Password Button - Device Count"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Enter Password View Only, Reset Password Button - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated >= MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Both, Auto Login View Last, Reset Password Button - Device %"
     , COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated AND ResetPasswordFlag = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/NULLIF(COUNT(CASE WHEN EnterPasswordFlag = 1 AND AutoLoginFlag = 1 AND MaxAutoLoginCreated < MaxEnterPasswordCreated THEN 1 ELSE NULL END)::DECIMAL(12,4),0) AS "Both, Enter Password View Last, Reset Password Button - Device %"          
FROM AutoLogin_ClosedDevices DEVICES
JOIN PUBLIC.AuthDB_Bundles BUNDLES
ON DEVICES.BundleId = BUNDLES.BundleId
WHERE EnterPasswordErrorFlag = 0
GROUP BY 1,2
ORDER BY 1
;






--------------- Old Stuff ---------------------


SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN EnterEmailFlag = 1 THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN EnterEmailNextStepFlag = 1 THEN 1 ELSE NULL END) AS PasswordCnt
FROM JT.AutoLogin_Devices_Checklist_Detail
WHERE FirstParentBinaryVersion >= '6.32'
;

SELECT COUNT(*)
     , COUNT(CASE WHEN NonIntialViewFlag = 1 OR NonLoginViewFlag = 1 THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_Checklist_Detail
WHERE FirstParentBinaryVersion >= '6.32'
AND EnterEmailFlag = 0
;

-- Breakdown of what's inlucded/excluded and reasons
-- Include only....
--      Devices that have a initial enter email created and start initial login at v6.32.
-- Exclude ....
--      Devices that started initial before v6.32.
--      Are already in the app
--      Devices with metrics issues
SELECT COUNT(*) AS AllBundleDeviceCnt
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' THEN 1 ELSE NULL END) AS BinaryAnalysisDeviceCnt
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' AND EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS BinaryIncludedCnt     
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS BinaryExcludedCnt
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' AND EnterEmailCreated IS NULL AND NonIntialViewCreated IS NOT NULL THEN 1 ELSE NULL END) AS BinaryNonLoginDeviceCnt
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' AND EnterEmailCreated IS NULL AND NonLoginViewCreated IS NOT NULL AND NonIntialViewCreated IS NULL THEN 1 ELSE NULL END) AS BinaryAlreadyInAppCnt  
     , COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN FirstParentBinaryVersion >= '6.32' THEN 1 ELSE NULL END)::DECIMAL(12,4) AS BinaryExcludedPct
FROM JT.AutoLogin_Devices_Checklist
;



-- 14,287 Devices
-- 8,584 Eligible for inclusion in Analysis (first metric is from build 6.32 and up)
--      8,131 Included in Analysis (94.72%)
--      453 Excluded from Analysis (5.28%)
--              345 Devices - Already in (non-initial login metrics)
--              0 Devices - Already in (non-login metrics)
--              rest is metrics issues


-- Enter Email Step

-- Overall
SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS ExcludeCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND EnterEmailLoginErrorCreated IS NOT NULL THEN 1 ELSE NULL END) AS ErrorCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) THEN 1 ELSE NULL END) AS SuccessCnt
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
;

-- By Binary Version
SELECT FirstParentBinaryVersion
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS ExcludeCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND EnterEmailLoginErrorCreated IS NOT NULL THEN 1 ELSE NULL END) AS ErrorCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) THEN 1 ELSE NULL END) AS SuccessCnt
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
GROUP BY 1
ORDER BY 1
;

-- By Device Type
SELECT DeviceType
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS ExcludeCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND EnterEmailLoginErrorCreated IS NOT NULL THEN 1 ELSE NULL END) AS ErrorCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) THEN 1 ELSE NULL END) AS SuccessCnt
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
GROUP BY 1
ORDER BY 1
;

-- By BundleType
SELECT BundleType
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS ExcludeCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND EnterEmailLoginErrorCreated IS NOT NULL THEN 1 ELSE NULL END) AS ErrorCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) THEN 1 ELSE NULL END) AS SuccessCnt
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
GROUP BY 1
ORDER BY 1
;

-- By Bundle
SELECT BundleId
     , BundleType
     , COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS ExcludeCnt
     , COUNT(CASE WHEN LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND EnterEmailLoginErrorCreated IS NOT NULL THEN 1 ELSE NULL END) AS ErrorCnt
     , COUNT(CASE WHEN (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) THEN 1 ELSE NULL END) AS SuccessCnt
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
GROUP BY 1,2
ORDER BY 1
;

-- Automatic Login Devices
SELECT COUNT(*) AS DeviceCnt
     , COUNT(CASE WHEN PasswordForkCreated IS NOT NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN EnterEmailCreated IS NOT NULL AND PasswordForkCreated IS NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
AND (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) 
AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL)
;



SELECT *
FROM JT.AutoLogin_Devices_Checklist
WHERE FirstParentBinaryVersion >= '6.32'
AND (LoginFlowStartCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL) 
AND (EnterEmailLoginSuccessCreated IS NOT NULL OR PasswordForkCreated IS NOT NULL OR EnterEmailCreated IS NOT NULL)
AND EnterEmailCreated IS NULL AND PasswordForkCreated IS NULL
AND BundleType = 'Open'
;

SELECT *
FROM PUBLIC.Fact_Views_Live
WHERE UPPER(Bundle_Id) = 'F5908D45-F2BB-47E3-AD31-880FE2FA0655'
AND UPPER(Device_Id) = '202D1924-D76B-428F-A41E-9D68D0A66898'
UNION ALL
SELECT *
FROM PUBLIC.Fact_Actions_Live
WHERE UPPER(Bundle_Id) = 'F5908D45-F2BB-47E3-AD31-880FE2FA0655'
AND UPPER(Device_Id) = '202D1924-D76B-428F-A41E-9D68D0A66898'
UNION ALL
SELECT *
FROM PUBLIC.Fact_Checkpoints_Live
WHERE UPPER(Bundle_Id) = 'F5908D45-F2BB-47E3-AD31-880FE2FA0655'
AND UPPER(Device_Id) = '202D1924-D76B-428F-A41E-9D68D0A66898'
ORDER BY Created
;





-- Breakdown by Bundle
SELECT Bundle_Id, COUNT(*) AS AllBundleDeviceCnt
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' THEN 1 ELSE NULL END) AS BinaryAnalysisDeviceCnt
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' AND EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS BinaryIncludedCnt     
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS BinaryExcludedCnt
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' AND EnterEmailCreated IS NULL AND NonIntialViewCreated IS NOT NULL THEN 1 ELSE NULL END) AS BinaryNonLoginDeviceCnt
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' AND EnterEmailCreated IS NULL AND NonLoginViewCreated IS NOT NULL AND NonIntialViewCreated IS NULL THEN 1 ELSE NULL END) AS BinaryAlreadyInAppCnt  
     , COUNT(CASE WHEN First_Binary_Version >= '6.32' AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(CASE WHEN First_Binary_Version >= '6.32' THEN 1 ELSE NULL END)::DECIMAL(12,4) AS BinaryExcludedPct
FROM JT.AutoLogin_Devices_View
GROUP BY 1
;


SELECT First_Binary_Version
     , Device_Type
     , COUNT(*)
     , COUNT(CASE WHEN PasswordForkCreated IS NOT NULL OR EnterPasswordCreated IS NOT NULL THEN 1 ELSE NULL END)
     , COUNT(CASE WHEN PasswordForkCreated IS NOT NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE First_Binary_Version >= '6.32' AND EnterEmailCreated IS NOT NULL
GROUP BY 1,2
ORDER BY 1,2
;

-- Subset of Devices Seen Password Fork Grouping
SELECT COUNT(*)
     -- Enter Email Only Funnel
     , COUNT(CASE WHEN EnterEmailCreated IS NOT NULL AND AutoLoginCreated IS NULL THEN 1 ELSE NULL END) AS EnterEmailOnlyCreated
     , COUNT(CASE WHEN EnterEmailCreated IS NOT NULL AND AutoLoginCreated IS NULL AND EventPickerCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailOnlySuccessCreated
     
     -- AutoLogin Only Funnel
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NULL THEN 1 ELSE NULL END) AS AutoLoginOnlyCreated
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NULL AND EventPickerCreated IS NOT NULL THEN 1 ELSE NULL END) AS AutoLoginOnlySuccessCreated
     
     -- Both Funnel     
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL THEN 1 ELSE NULL END) AS BothCreated
     
     -- Both (AutoLogin then EnterEmail G1)
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL AND AutoLoginCreated < EnterEmailCreated THEN 1 ELSE NULL END)
     -- Both (EnterEmail then AutoLogin G2)
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL AND AutoLoginCreated > EnterEmailCreated THEN 1 ELSE NULL END)     
     -- Succsess
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL AND EventPickerCreated IS NOT NULL THEN 1 ELSE NULL END) AS BothSuccessCreated
     -- G1 Success
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL AND EventPickerCreated IS NOT NULL AND AutoLoginCreated < EnterEmailCreated THEN 1 ELSE NULL END)
     -- G2 Success
     , COUNT(CASE WHEN AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL AND EventPickerCreated IS NOT NULL AND AutoLoginCreated > EnterEmailCreated THEN 1 ELSE NULL END)                     
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NOT NULL
;



-- Look at devices that went to both views
SELECT COUNT(*)
     , COUNT(CASE WHEN EventPickerCreated IS NULL AND EventProfileCreated IS NULL AND ProfileFillerCreated IS NULL AND NonIntialViewCreated IS NULL AND NonLoginViewCreated IS NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NOT NULL AND AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL
;

SELECT COUNT(*)
     , COUNT(CASE WHEN ResetPasswordCreated IS NOT NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE (PasswordForkCreated IS NULL AND EnterEmailCreated IS NOT NULL)
AND (EventPickerCreated IS NOT NULL OR EventProfileCreated IS NOT NULL OR ProfileFillerCreated IS NOT NULL OR NonIntialViewCreated IS NOT NULL OR NonLoginViewCreated IS NOT NULL) 
;

SELECT COUNT(*)
     , COUNT(CASE WHEN ResetPasswordCreated IS NOT NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE (PasswordForkCreated IS NOT NULL AND EnterEmailCreated IS NULL)
AND (EventPickerCreated IS NOT NULL OR EventProfileCreated IS NOT NULL OR ProfileFillerCreated IS NOT NULL OR NonIntialViewCreated IS NOT NULL OR NonLoginViewCreated IS NOT NULL) 
;


SELECT COUNT(*)
     , COUNT(CASE WHEN ResetPasswordCreated IS NOT NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NOT NULL AND AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL
AND (EventPickerCreated IS NOT NULL OR EventProfileCreated IS NOT NULL OR ProfileFillerCreated IS NOT NULL OR NonIntialViewCreated IS NOT NULL OR NonLoginViewCreated IS NOT NULL) 
;


SELECT COUNT(*)
     , COUNT(CASE WHEN ResetPasswordCreated IS NOT NULL THEN 1 ELSE NULL END)
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NOT NULL AND AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL
AND EventPickerCreated IS NULL AND EventProfileCreated IS NULL AND ProfileFillerCreated IS NULL AND NonIntialViewCreated IS NULL AND NonLoginViewCreated IS NULL 
;

SELECT *
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NOT NULL AND AutoLoginCreated IS NOT NULL AND EnterEmailCreated IS NOT NULL
AND EventPickerCreated IS NULL AND EventProfileCreated IS NULL AND ProfileFillerCreated IS NULL AND NonIntialViewCreated IS NULL AND NonLoginViewCreated IS NULL 
;

-- Non Password Fork
SELECT COUNT(*)
     -- Enter Email Only Funnel
     , COUNT(CASE WHEN EnterEmailCreated IS NOT NULL AND AutoLoginCreated IS NULL THEN 1 ELSE NULL END) AS EnterEmailOnlyCreated
     , COUNT(CASE WHEN EnterEmailCreated IS NOT NULL AND AutoLoginCreated IS NULL AND EventPickerCreated IS NOT NULL THEN 1 ELSE NULL END) AS EnterEmailOnlySuccessCreated
                       
FROM JT.AutoLogin_Devices_View
WHERE PasswordForkCreated IS NULL AND EnterEmailCreated IS NOT NULL
;

