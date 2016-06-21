-- Get Events with 6.3 version or higher
drop table if exists jt.pa506_events;
create table jt.pa506_events as
select c.bundleid
     , a.*
from eventcube.eventcubesummary a
left join eventcube.testevents b
on a.applicationid = b.applicationid
join authdb_applications c
on a.applicationid = c.applicationid
where a.binaryversion like '6.%'
and a.binaryversion not like '6.0%'
and a.binaryversion not like '6.1%'
and a.binaryversion not like '6.2%'
and a.binaryversion not like '6.3%'
and b.applicationid is null
;

-- Get Login Checkpoints
drop table if exists jt.pa506_checkpoint_metrics;
create table jt.pa506_checkpoint_metrics as
select a.*
from fact_checkpoints_live a
join jt.pa506_events b
on a.bundle_id = lower(b.bundleid)
where a.identifier in ('loginFlowStart', 'accountPickerLoginSuccess', 'enterEmailLoginSuccess', 'enterPasswordLoginSuccess', 'eventPickerLoginSuccess','profileFillerLoginSuccess','webLoginSuccess')
;

create index indx_pa506_checkpoint_metrics on jt.pa506_checkpoint_metrics (bundle_id, device_id, device_type);

-- Get (Possible) Login Views
drop table if exists jt.pa506_view_metrics;
create table jt.pa506_view_metrics as
select a.*
from fact_views_live a
join jt.pa506_events b
on a.bundle_id = lower(b.bundleid)
where identifier in ('accountPicker','enterEmail','enterPassword','remoteSsoLogin','resetPassword','eventPicker','profileFiller','eventProfileChoice')
;

create index indx_pa506_view_metrics on jt.pa506_view_metrics (bundle_id, device_id, device_type);

-- Get (Possible) Login Actions
drop table if exists jt.pa506_action_metrics;
create table jt.pa506_action_metrics as
select a.*
from fact_actions_live a
join jt.pa506_events b
on a.bundle_id = lower(b.bundleid)
where a.identifier in ('accountSelectButton','anotherAccountButton','enterEmailTextField','submitEmailButton','enterPasswordTextField','submitPasswordButton','resetPasswordButton','cancelResetPasswordButton','submitResetPasswordButton','eventSelectButton','changeProfilePhotoButton','cancelProfilePhotoAction','enterFirstNameTextField','enterLastNameTextField','enterCompanyTextField','enterTitleTextField','addSocialNetworkToProfileButton','submitProfileButton','createProfileButton')
;

create index indx_pa506_actions_metrics on jt.pa506_action_metrics (bundle_id, device_id, device_type);


-- Get Email Support Login Actions (Add on to the actions)
drop table if exists jt.pa506_action_email_support_metrics;
create table jt.pa506_action_email_support_metrics as
select a.*
from fact_actions_live a
join jt.pa506_events b
on a.bundle_id = lower(b.bundleid)
where a.identifier in ('emailSupport')
;

-- Check to make sure proportions look good.
select identifier
     , count(distinct device_id) as total
     , count(distinct case when device_type = 'ios' then device_id else null end) as ios
     , count(distinct case when device_type = 'android' then device_id else null end) as android
     , count(distinct case when device_type = 'ios' then device_id else null end)::decimal(12,4)/count(distinct device_id)::decimal(12,4) as iospct
     , count(distinct case when device_type = 'android' then device_id else null end)::decimal(12,4)/count(distinct device_id)::decimal(12,4) as androidpct
from jt.pa506_checkpoint_metrics
group by 1
;
-- Passed

drop table if exists jt.pa506_checkpoint_spine;
create table jt.pa506_checkpoint_spine as
select bundle_id
     , device_id
     , device_type
     
     , count(distinct session_id) as sessionCnt  

     -- Checkpoints
     -- loginFlowStart (Initial - enterEmail)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'enterEmail' then created else null end) as loginFlowStartInitialEnterEmailMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'enterEmail' then created else null end) as loginFlowStartInitialEnterEmailMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'InitialView' = 'enterEmail' then session_id else null end) as loginFlowStartInitialEnterEmailSessionCnt

     -- loginFlowStart (Initial - accountPicker)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'accountPicker' then created else null end) as loginFlowStartInitialAccountPickerMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true') and metadata->>'InitialView' = 'accountPicker' then created else null end) as loginFlowStartInitialAccountPickerMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'InitialView' = 'accountPicker' then session_id else null end) as loginFlowStartInitialAccountPickerSessionCnt
     
     -- accountPickerLoginSuccess (Initial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessInitialOpenMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessInitialOpenMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then session_id else null end) as accountPickerLoginSuccessInitialOpenSessionCnt

     -- enterEmailLoginSuccess (Initial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessInitialOpenMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessInitialOpenMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'open' then session_id else null end) as enterEmailLoginSuccessInitialOpenSessionCnt  

     -- accountPickerLoginSuccess (Initial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessInitialClosedMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessInitialClosedMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then session_id else null end) as accountPickerLoginSuccessInitialClosedSessionCnt

     -- enterEmailLoginSuccess (Initial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessInitialClosedMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessInitialClosedMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  and metadata->>'EventRegType' = 'closed' then session_id else null end) as enterEmailLoginSuccessInitialClosedSessionCnt  
     
     -- enterPasswordLoginSuccess (Initial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as enterPasswordLoginSuccessInitialMinDate
     , max(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as enterPasswordLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as enterPasswordLoginSuccessInitialSessionCnt  

     -- eventPickerLoginSuccess (Initial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as eventPickerLoginSuccessInitialMinDate
     , max(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as eventPickerLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as eventPickerLoginSuccessInitialSessionCnt  

     -- profileFillerLoginSuccess (Initial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as profileFillerLoginSuccessInitialMinDate
     , max(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then created else null end) as profileFillerLoginSuccessInitialMaxDate
     , count(distinct case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'true' or metadata->>'Initiallogin' = 'true')  then session_id else null end) as profileFillerLoginSuccessInitialSessionCnt  

     -- loginFlowStart (NonInitial)
     , min(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false')  then created else null end) as loginFlowStartNonInitialMinDate
     , max(case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as loginFlowStartNonInitialMaxDate
     , count(distinct case when identifier = 'loginFlowStart' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as loginFlowStartNonInitialSessionCnt
     
     -- accountPickerLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessNonInitialOpenMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as accountPickerLoginSuccessNonInitialOpenMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and metadata->>'InitialLogin' = 'false' and metadata->>'EventRegType' = 'open' then session_id else null end) as accountPickerLoginSuccessNonInitialOpenSessionCnt

     -- enterEmailLoginSuccess (NonInitial - Open)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessNonInitialOpenMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then created else null end) as enterEmailLoginSuccessNonInitialOpenMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'open' then session_id else null end) as enterEmailLoginSuccessNonInitialOpenSessionCnt  

     -- accountPickerLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessNonInitialClosedMinDate
     , max(case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as accountPickerLoginSuccessNonInitialClosedMaxDate
     , count(distinct case when identifier = 'accountPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then session_id else null end) as accountPickerLoginSuccessNonInitialClosedSessionCnt

     -- enterEmailLoginSuccess (NonInitial - Closed)
     , min(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessNonInitialClosedMinDate
     , max(case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then created else null end) as enterEmailLoginSuccessNonInitialClosedMaxDate
     , count(distinct case when identifier = 'enterEmailLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') and metadata->>'EventRegType' = 'closed' then session_id else null end) as enterEmailLoginSuccessNonInitialClosedSessionCnt  
     
     -- enterPasswordLoginSuccess (NonInitial)
     , min(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as enterPasswordLoginSuccessNonInitialMinDate
     , max(case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as enterPasswordLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'enterPasswordLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as enterPasswordLoginSuccessNonInitialSessionCnt  

     -- eventPickerLoginSuccess (NonInitial)
     , min(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as eventPickerLoginSuccessNonInitialMinDate
     , max(case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as eventPickerLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'eventPickerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as eventPickerLoginSuccessNonInitialSessionCnt  

     -- profileFillerLoginSuccess (NonInitial)
     , min(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as profileFillerLoginSuccessNonInitialMinDate
     , max(case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then created else null end) as profileFillerLoginSuccessNonInitialMaxDate
     , count(distinct case when identifier = 'profileFillerLoginSuccess' and (metadata->>'InitialLogin' = 'false' or metadata->>'Initiallogin' = 'false') then session_id else null end) as profileFillerLoginSuccessNonInitialSessionCnt         

from jt.pa506_checkpoint_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from jt.pa506_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;


select device_type
     , login_path
     , count(*) as cnt
from (
select device_type
     , case when loginFlowStartInitialMinDate is not null then cast('loginFlowStart ' as text) else '' end ||
       case when accountPickerLoginSuccessInitialOpenMinDate is not null or accountPickerLoginSuccessInitialClosedMinDate is not null then cast(' accountPickerLoginSuccess' as text) else '' end ||
       case when enterEmailLoginSuccessInitialOpenMinDate is not null or enterEmailLoginSuccessInitialClosedMinDate is not null then cast(' enterEmailLoginSuccess' as text) else '' end ||
       case when enterPasswordLoginSuccessInitialMinDate is not null then cast(' enterPasswordLoginSuccess' as text) else '' end ||
       case when eventPickerLoginSuccessInitialMinDate is not null then cast(' eventPickerLoginSuccess' as text) else '' end ||
       case when profileFillerLoginSuccessInitialMinDate is not null then cast(' profileFillerLoginSuccess' as text) else '' end
       as login_path
from jt.pa506_checkpoint_spine
where loginFlowStartInitialMinDate is not null) a
group by 1,2
order by 1,3 desc;


drop table if exists jt.pa506_view_spine;
create table jt.pa506_view_spine as
select bundle_id
     , device_id
     , device_type
     
     , count(distinct session_id) as sessionCnt  

     -- Views & Actions
     -- accountPicker (View)
     , min(case when identifier = 'accountPicker' then created else null end) as accountPickerMinDate
     , max(case when identifier = 'accountPicker' then created else null end) as accountPickerMaxDate
     , count(distinct case when identifier = 'accountPicker' then session_id else null end) as accountPickerSessionCnt  
     
     -- enterEmail (View)
     , min(case when identifier = 'enterEmail' then created else null end) as enterEmailMinDate
     , max(case when identifier = 'enterEmail' then created else null end) as enterEmailMaxDate
     , count(distinct case when identifier = 'enterEmail' then session_id else null end) as enterEmailSessionCnt
       
     -- enterPassword (View)
     , min(case when identifier = 'enterPassword' then created else null end) as enterPasswordMinDate
     , max(case when identifier = 'enterPassword' then created else null end) as enterPasswordMaxDate
     , count(distinct case when identifier = 'enterPassword' then session_id else null end) as enterPasswordSessionCnt  
    
     -- resetPassword (View)
     , min(case when identifier = 'resetPassword' then created else null end) as resetPasswordMinDate
     , max(case when identifier = 'resetPassword' then created else null end) as resetPasswordMaxDate
     , count(distinct case when identifier = 'resetPassword' then session_id else null end) as resetPasswordSessionCnt       
             
      -- eventPicker (View)
     , min(case when identifier = 'eventPicker' then created else null end) as eventPickerMinDate
     , max(case when identifier = 'eventPicker' then created else null end) as eventPickerMaxDate
     , count(distinct case when identifier = 'eventPicker' then session_id else null end) as eventPickerSessionCnt  
     
     -- eventProfileChoice (View)
     , min(case when identifier = 'eventProfileChoice' then created else null end) as eventProfileChoiceMinDate
     , max(case when identifier = 'eventProfileChoice' then created else null end) as eventProfileChoiceMaxDate
     , count(distinct case when identifier = 'eventProfileChoice' then session_id else null end) as eventProfileChoiceSessionCnt  
    
     -- profileFiller (View)
     , min(case when identifier = 'profileFiller' then created else null end) as profileFillerMinDate
     , max(case when identifier = 'profileFiller' then created else null end) as profileFillerMaxDate
     , count(distinct case when identifier = 'profileFiller' then session_id else null end) as profileFillerSessionCnt  
             
from jt.pa506_view_metrics
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from jt.pa506_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;


drop table if exists jt.pa506_action_spine;
create table jt.pa506_action_spine as
select bundle_id
     , device_id
     , device_type
     
     , count(distinct session_id) as sessionCnt  

     -- accountSelectButton (Action)
     , min(case when identifier = 'accountSelectButton' then created else null end) as accountSelectButtonMinDate
     , max(case when identifier = 'accountSelectButton' then created else null end) as accountSelectButtonMaxDate
     , count(distinct case when identifier = 'accountSelectButton' then session_id else null end) as accountSelectButtonSessionCnt 

     -- anotherAccountButton (Action)
     , min(case when identifier = 'anotherAccountButton' then created else null end) as anotherAccountButtonMinDate
     , max(case when identifier = 'anotherAccountButton' then created else null end) as anotherAccountButtonMaxDate
     , count(distinct case when identifier = 'anotherAccountButton' then session_id else null end) as anotherAccountButtonSessionCnt 

     -- emailSupport (Action - Account Picker View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then created else null end) as emailSupportAccountPickerMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then created else null end) as emailSupportAccountPickerMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'accountPicker' then session_id else null end) as emailSupportAccountPickerSessionCnt
     
     -- enterEmailTextField (Action)
     , min(case when identifier = 'enterEmailTextField' then created else null end) as enterEmailTextFieldMinDate
     , max(case when identifier = 'enterEmailTextField' then created else null end) as enterEmailTextFieldMaxDate
     , count(distinct case when identifier = 'enterEmailTextField' then session_id else null end) as enterEmailTextFieldSessionCnt

     -- submitEmailButton (Action)
     , min(case when identifier = 'submitEmailButton' then created else null end) as submitEmailButtonMinDate
     , max(case when identifier = 'submitEmailButton' then created else null end) as submitEmailButtonMaxDate
     , count(distinct case when identifier = 'submitEmailButton' then session_id else null end) as submitEmailButtonSessionCnt

     -- emailSupport (Action - Enter Email View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then created else null end) as emailSupportEnterEmailMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then created else null end) as emailSupportEnterEmailMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'enterEmail' then session_id else null end) as emailSupportEnterEmailSessionCnt

     -- enterPasswordTextField (Action)
     , min(case when identifier = 'enterPasswordTextField' then created else null end) as enterPasswordTextFieldMinDate
     , max(case when identifier = 'enterPasswordTextField' then created else null end) as enterPasswordTextFieldMaxDate
     , count(distinct case when identifier = 'enterPassword' then session_id else null end) as enterPasswordTextFieldSessionCnt 

     -- submitPasswordButton (Action)
     , min(case when identifier = 'submitPasswordButton' then created else null end) as submitPasswordButtonMinDate
     , max(case when identifier = 'submitPasswordButton' then created else null end) as submitPasswordButtonMaxDate
     , count(distinct case when identifier = 'submitPasswordButton' then session_id else null end) as submitPasswordButtonSessionCnt 
     
     -- resetPasswordButton (Action)
     , min(case when identifier = 'resetPasswordButton' then created else null end) as resetPasswordButtonMinDate
     , max(case when identifier = 'resetPasswordButton' then created else null end) as resetPasswordButtonMaxDate
     , count(distinct case when identifier = 'resetPasswordButton' then session_id else null end) as resetPasswordButtonSessionCnt 

     -- cancelResetPasswordButton (Action)
     , min(case when identifier = 'cancelResetPasswordButton' then created else null end) as cancelResetPasswordButtonMinDate
     , max(case when identifier = 'cancelResetPasswordButton' then created else null end) as cancelResetPasswordButtonMaxDate
     , count(distinct case when identifier = 'cancelResetPasswordButton' then session_id else null end) as cancelResetPasswordButtonSessionCnt  

     -- submitResetPasswordButton (Action)
     , min(case when identifier = 'submitResetPasswordButton' then created else null end) as submitResetPasswordButtonMinDate
     , max(case when identifier = 'submitResetPasswordButton' then created else null end) as submitResetPasswordButtonMaxDate
     , count(distinct case when identifier = 'submitResetPasswordButton' then session_id else null end) as submitResetPasswordButtonSessionCnt       

     -- emailSupport (Action - Enter Password View)
     , min(case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then created else null end) as emailSupportEnterPasswordMinDate
     , max(case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then created else null end) as emailSupportEnterPasswordMaxDate
     , count(distinct case when identifier = 'emailSupport' and metadata->>'View' = 'enterPassword' then session_id else null end) as emailSupportEnterPasswordSessionCnt

      -- eventSelectButton (Action)
     , min(case when identifier = 'eventSelectButton' then created else null end) as eventSelectButtonMinDate
     , max(case when identifier = 'eventSelectButton' then created else null end) as eventSelectButtonMaxDate
     , count(distinct case when identifier = 'eventSelectButton' then session_id else null end) as eventSelectButtonSessionCnt 

     -- createProfileButton - Manual (Action)
     , min(case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then created else null end) as createProfileButtonManualMinDate
     , max(case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then created else null end) as createProfileButtonManualMaxDate
     , count(distinct case when identifier = 'createProfileButton' and metadata->>'Type' = 'manual' then session_id else null end) as createProfileButtonManualSessionCnt  

     -- createProfileButton (EPC View) - Import (Action)
     , min(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then created else null end) as createProfileButtonLinkedInEPCMinDate
     , max(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then created else null end) as createProfileButtonLinkedInEPCMaxDate
     , count(distinct case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'eventProfileChoice' then session_id else null end) as createProfileButtonLinkedInEPCSessionCnt  

     -- createProfileButton (PF View) - Import (Action)
     , min(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then created else null end) as createProfileButtonLinkedInPFMinDate
     , max(case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then created else null end) as createProfileButtonLinkedInPFMaxDate
     , count(distinct case when identifier = 'createProfileButton' and (metadata->>'Type' = 'linkedIn' or metadata->>'Type' = 'linkedin') and metadata->>'View' = 'profileFiller' then session_id else null end) as createProfileButtonLinkedInPFSessionCnt

     -- changeProfilePhotoButton (Action)
     , min(case when identifier = 'changeProfilePhotoButton' then created else null end) as changeProfilePhotoButtonMinDate
     , max(case when identifier = 'changeProfilePhotoButton' then created else null end) as changeProfilePhotoButtonMaxDate
     , count(distinct case when identifier = 'changeProfilePhotoButton' then session_id else null end) as changeProfilePhotoButtonSessionCnt

     -- cancelProfilePhotoAction (Action)
     , min(case when identifier = 'cancelProfilePhotoAction' then created else null end) as cancelProfilePhotoActionMinDate
     , max(case when identifier = 'cancelProfilePhotoAction' then created else null end) as cancelProfilePhotoActionMaxDate
     , count(distinct case when identifier = 'cancelProfilePhotoAction' then session_id else null end) as cancelProfilePhotoActionSessionCnt

     -- enterFirstNameTextField (Action)
     , min(case when identifier = 'enterFirstNameTextField' then created else null end) as enterFirstNameTextFieldMinDate
     , max(case when identifier = 'enterFirstNameTextField' then created else null end) as enterFirstNameTextFieldMaxDate
     , count(distinct case when identifier = 'enterFirstNameTextField' then session_id else null end) as enterFirstNameTextFieldSessionCnt

     -- enterLastNameTextField (Action)
     , min(case when identifier = 'enterLastNameTextField' then created else null end) as enterLastNameTextFieldMinDate
     , max(case when identifier = 'enterLastNameTextField' then created else null end) as enterLastNameTextFieldMaxDate
     , count(distinct case when identifier = 'enterLastNameTextField' then session_id else null end) as enterLastNameTextFieldSessionCnt

     -- enterCompanyTextField (Action)
     , min(case when identifier = 'enterCompanyTextField' then created else null end) as enterCompanyTextFieldMinDate
     , max(case when identifier = 'enterCompanyTextField' then created else null end) as enterCompanyTextFieldMaxDate
     , count(distinct case when identifier = 'enterCompanyTextField' then session_id else null end) as enterCompanyTextFieldSessionCnt

     -- enterTitleTextField (Action)
     , min(case when identifier = 'enterTitleTextField' then created else null end) as enterTitleTextFieldMinDate
     , max(case when identifier = 'enterTitleTextField' then created else null end) as enterTitleTextFieldMaxDate
     , count(distinct case when identifier = 'enterTitleTextField' then session_id else null end) as enterTitleTextFieldSessionCnt

     -- addSocialNetworkToProfileButton (Action)
     , min(case when identifier = 'addSocialNetworkToProfileButton' then created else null end) as addSocialNetworkToProfileButtonMinDate
     , max(case when identifier = 'addSocialNetworkToProfileButton' then created else null end) as addSocialNetworkToProfileButtonMaxDate
     , count(distinct case when identifier = 'addSocialNetworkToProfileButton' then session_id else null end) as addSocialNetworkToProfileButtonSessionCnt

     -- submitProfileButton (Action)
     , min(case when identifier = 'submitProfileButton' then created else null end) as submitProfileButtonMinDate
     , max(case when identifier = 'submitProfileButton' then created else null end) as submitProfileButtonMaxDate
     , count(distinct case when identifier = 'submitProfileButton' then session_id else null end) as submitProfileButtonSessionCnt        
from (select *
      from jt.pa506_action_metrics
      union all
      select *
      from jt.pa506_action_email_support_metrics) a
-- Filter out SSO bundles
where bundle_id not in (select distinct bundle_id
                        from jt.pa506_view_metrics
                        where identifier = 'remoteSsoLogin')
group by 1,2,3
;

-- Drive Spine
drop table if exists jt.pa506_device_spine;
create table jt.pa506_device_spine as
select distinct bundle_id
     , device_id
     , device_type
from jt.pa506_checkpoint_spine
union
select distinct bundle_id
     , device_id
     , device_type
from jt.pa506_view_spine
union
select distinct bundle_id
     ,device_id
     , device_type
from jt.pa506_action_spine;

-- Login Cube
drop table if exists jt.pa506_logincube;
create table jt.pa506_logincube as
select device.device_id
     , device.bundle_id
     , device.device_type
     
     , checkpoint.loginFlowStartInitialEnterEmailMinDate
     , checkpoint.loginFlowStartInitialAccountPickerMinDate
     , checkpoint.loginFlowStartNonInitialMinDate
     
     -- Account Picker
     , view.accountPickerMinDate
     , action.accountSelectButtonMinDate
     , action.anotherAccountButtonMinDate
     , action.emailSupportAccountPickerMinDate
     , checkpoint.accountPickerLoginSuccessInitialOpenMinDate
     , checkpoint.accountPickerLoginSuccessInitialClosedMinDate
     
     -- Enter Email
     , view.enterEmailMinDate
     , action.enterEmailTextFieldMinDate
     , action.submitEmailButtonMinDate
     , action.emailSupportEnterEmailMinDate
     , checkpoint.enterEmailLoginSuccessInitialOpenMinDate
     , checkpoint.enterEmailLoginSuccessInitialClosedMinDate
     
     -- Enter Password
     , view.enterPasswordMinDate
     , action.enterPasswordTextFieldMinDate
     , action.submitPasswordButtonMinDate
     , action.resetPasswordButtonMinDate
     , action.emailSupportEnterPasswordMinDate
     , checkpoint.enterPasswordLoginSuccessInitialMinDate
      
     -- Reset Password     
     , view.resetPasswordMinDate
     , action.cancelResetPasswordButtonMinDate
     , action.submitResetPasswordButtonMinDate

     -- Event Picker    
     , view.eventPickerMinDate
     , action.eventSelectButtonMinDate
     , checkpoint.eventPickerLoginSuccessInitialMinDate
     
     -- Event Choice
     , view.eventProfileChoiceMinDate
     , action.createProfileButtonManualMinDate
     , action.createProfileButtonLinkedInEPCMinDate
     
     -- Profile Filler
     , view.profileFillerMinDate
     , action.changeProfilePhotoButtonMinDate
     , action.cancelProfilePhotoActionMinDate
     , action.createProfileButtonLinkedInPFMinDate
     , action.enterFirstNameTextFieldMinDate
     , action.enterLastNameTextFieldMinDate
     , action.enterCompanyTextFieldMinDate
     , action.enterTitleTextFieldMinDate
     , action.addSocialNetworkToProfileButtonMinDate
     , action.submitProfileButtonMinDate
     , checkpoint.profileFillerLoginSuccessInitialMinDate
     
from jt.pa506_device_spine device
left join jt.pa506_checkpoint_spine checkpoint
on device.device_id = checkpoint.device_id
and device.bundle_id = checkpoint.bundle_id
left join jt.pa506_view_spine view
on device.device_id = view.device_id
and device.bundle_id = view.bundle_id
left join jt.pa506_action_spine action
on device.device_id = action.device_id
and device.bundle_id = action.bundle_id;


-- Get 1st Session Date
drop table if exists jt.pa506_logincube_sessions;
create table jt.pa506_logincube_sessions as
select a.device_id
     , a.bundle_id
     , min(created) as firstlogin
from fact_sessions_live a
join jt.pa506_logincube b
on a.device_id = b.device_id
and a.bundle_id = b.bundle_id
where a.identifier = 'start'
group by 1,2;


-- Check Device Distribution
select count(*) as totaldevicecnt
     , count(case when (loginflowstartinitialEnterEmailMinDate is not null or loginflowstartinitialAccountPickerMinDate is not null) then 1 else null end) as initialLoginCnt
     --, count(case when (loginflowstartinitialEnterEmailMinDate is not null or loginflowstartinitialAccountPickerMinDate is not null) and loginFlowStartNonInitialMinDate is null then 1 else null end) as onlyInitialLoginCnt
     --, count(case when (loginflowstartinitialEnterEmailMinDate is not null or loginflowstartinitialAccountPickerMinDate is not null) and loginFlowStartNonInitialMinDate is null and (loginflowstartinitialEnterEmailMinDate <= firstLogin or loginflowstartinitialAccountPickerMinDate <= firstLogin) then 1 else null end)
     , count(case when loginFlowStartNonInitialMinDate is not null and (loginflowstartinitialEnterEmailMinDate is null and loginflowstartinitialAccountPickerMinDate is null) then 1 else null end) as subsequentLoginCnt
     , count(case when loginFlowStartNonInitialMinDate is null and (loginflowstartinitialEnterEmailMinDate is null and loginflowstartinitialAccountPickerMinDate is null) then 1 else null end) as issueLoginCnt
     --, count(case when loginflowstartinitialmindate is not null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as initialLoginPct 
     --, count(case when loginFlowStartNonInitialMinDate is not null and loginflowstartinitialmindate is null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as subsequentLoginPct
     --, count(case when loginFlowStartNonInitialMinDate is null and loginflowstartinitialmindate is null then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4) as issueLoginPct
from jt.pa506_logincube a
left join jt.pa506_logincube_sessions b
on a.device_id = b.device_id
and a.bundle_id = b.bundle_id
;

-- Classify Bundles (New)
drop table if exists jt.pa506_bundle_reg_type;
create table jt.pa506_bundle_reg_type as
select lower(a.bundleid) as bundle_id
     , count(*) as eventcnt
     , count(case when b.canregister = true then 1 else null end) as openeventcnt
     , count(case when b.canregister = false then 1 else null end) as closedeventcnt
     , case
         when count(case when b.canregister = true then 1 else null end) > 0 and count(case when b.canregister = false then 1 else null end) = 0 then 'open'
         when count(case when b.canregister = false then 1 else null end) > 0 and count(case when b.canregister = true then 1 else null end) = 0 then 'closed'
         else 'mixed'
       end as bundle_type
from (select distinct bundleid
      from jt.pa506_events) a
join authdb_applications b
on a.bundleid = b.bundleid
group by 1;


-- iOS (Funnel)
select bundles.bundle_type
     , count(*) as totalcnt

     , count(case when enterEmailMinDate is not null then 1 else null end) as enterEmail
     , count(case when enterEmailTextFieldMinDate is not null then 1 else null end) as enterEmailTextField
     , count(case when submitEmailButtonMinDate is not null then 1 else null end) as submitEmailButton
     , count(case when emailSupportEnterEmailMinDate is not null then 1 else null end) as emailSupportEnterEmail
     , count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialOpen
     , count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is not null then 1 else null end) as enterEmailLoginSuccessInitialMixed
     , count(case when enterEmailLoginSuccessInitialClosedMinDate is not null and enterEmailLoginSuccessInitialOpenMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialClosed
     
     , count(case when enterPasswordMinDate is not null then 1 else null end) as enterPassword
     , count(case when enterPasswordTextFieldMinDate is not null then 1 else null end) as enterPasswordTextField
     , count(case when submitPasswordButtonMinDate is not null then 1 else null end) as submitPasswordButton
     , count(case when resetPasswordButtonMinDate is not null then 1 else null end) as resetPasswordButton
     , count(case when emailSupportEnterPasswordMinDate is not null then 1 else null end) as emailSupportEnterPassword
     , count(case when enterPasswordLoginSuccessInitialMinDate is not null then 1 else null end) as enterPasswordLoginSuccessInitial
     
     , count(case when resetPasswordMinDate is not null then 1 else null end) as resetPassword
     , count(case when cancelResetPasswordButtonMinDate is not null then 1 else null end) as cancelResetPasswordButton
     , count(case when submitResetPasswordButtonMinDate is not null then 1 else null end) as submitResetPasswordButton
     
     , count(case when eventPickerMinDate is not null then 1 else null end) as eventPicker
     , count(case when eventSelectButtonMinDate is not null then 1 else null end) as eventSelectButton
     , count(case when eventPickerLoginSuccessInitialMinDate is not null then 1 else null end) as eventPickerLoginSuccessInitial
     
     , count(case when eventProfileChoiceMinDate is not null then 1 else null end) as eventProfileChoice
     , count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is null then 1 else null end) as createProfileButtonManual
     , count(case when createProfileButtonLinkedInEPCMinDate is not null and createProfileButtonManualMinDate is null then 1 else null end) createProfileButtonLinkedInEPC
     , count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is not null then 1 else null end) as createProfileButtonBoth
     
     , count(case when profileFillerMinDate is not null then 1 else null end) as profileFiller
     , count(case when changeProfilePhotoButtonMinDate is not null then 1 else null end) as changeProfilePhotoButton
     , count(case when cancelProfilePhotoActionMinDate is not null then 1 else null end) as cancelProfilePhotoAction
     , count(case when createProfileButtonLinkedInPFMinDate is not null then 1 else null end) createProfileButtonLinkedInPF
     , count(case when enterFirstNameTextFieldMinDate is not null then 1 else null end) as enterFirstNameTextField
     , count(case when enterLastNameTextFieldMinDate is not null then 1 else null end) as enterLastNameTextField
     , count(case when enterCompanyTextFieldMinDate is not null then 1 else null end) as enterCompanyTextField
     , count(case when enterTitleTextFieldMinDate is not null then 1 else null end) as enterTitleTextField
     , count(case when addSocialNetworkToProfileButtonMinDate is not null then 1 else null end) as addSocialNetworkToProfileButton
     , count(case when submitProfileButtonMinDate is not null then 1 else null end) as submitProfileButton
     , count(case when profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as profileFillerLoginSuccessInitial
from jt.pa506_logincube spine
join (select *
      from jt.pa506_bundle_reg_type
      /*where bundle_tolerance <= 0.1*/) bundles
on spine.bundle_id = bundles.bundle_id
join jt.pa506_logincube_sessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialEnterEmailMinDate is not null)
and spine.loginFlowStartNonInitialMinDate is null
and (spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin)
and spine.device_type = 'ios'
--and bundles.bundle_type = 'open'
group by 1
order by 1
;




-- Android (Funnel)
select bundles.bundle_type
     , case
         when spine.loginFlowStartInitialAccountPickerMinDate is not null then 'accountPicker'
         when spine.loginFlowStartInitialEnterEmailMinDate is not null and spine.loginFlowStartInitialAccountPickerMinDate is null then 'enterEmail'
         else '?'
       end as start_view
     , count(*) as totalcnt

     , count(case when accountPickerMinDate is not null then 1 else null end) as accountPicker
     , count(case when accountSelectButtonMinDate is not null then 1 else null end) as accountSelectButton
     , count(case when anotherAccountButtonMinDate is not null then 1 else null end) as anotherAccountButton
     , count(case when emailSupportAccountPickerMinDate is not null then 1 else null end) as emailSupportAccountPicker
     , count(case when accountPickerLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialOpenMinDate is null then 1 else null end) as accountPickerLoginSuccessInitialOpen
     , count(case when accountPickerLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is not null then 1 else null end) as accountPickerLoginSuccessInitialMixed
     , count(case when accountPickerLoginSuccessInitialClosedMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is null then 1 else null end) as accountPickerLoginSuccessInitialClosed

     , count(case when enterEmailMinDate is not null then 1 else null end) as enterEmail
     , count(case when enterEmailTextFieldMinDate is not null then 1 else null end) as enterEmailTextField
     , count(case when submitEmailButtonMinDate is not null then 1 else null end) as submitEmailButton
     , count(case when emailSupportEnterEmailMinDate is not null then 1 else null end) as emailSupportEnterEmail
     , count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialOpen
     , count(case when enterEmailLoginSuccessInitialOpenMinDate is not null and enterEmailLoginSuccessInitialClosedMinDate is not null then 1 else null end) as enterEmailLoginSuccessInitialMixed
     , count(case when enterEmailLoginSuccessInitialClosedMinDate is not null and enterEmailLoginSuccessInitialOpenMinDate is null then 1 else null end) as enterEmailLoginSuccessInitialClosed
     
     , count(case when enterPasswordMinDate is not null then 1 else null end) as enterPassword
     , count(case when enterPasswordTextFieldMinDate is not null then 1 else null end) as enterPasswordTextField
     , count(case when submitPasswordButtonMinDate is not null then 1 else null end) as submitPasswordButton
     , count(case when resetPasswordButtonMinDate is not null then 1 else null end) as resetPasswordButton
     , count(case when emailSupportEnterPasswordMinDate is not null then 1 else null end) as emailSupportEnterPassword
     , count(case when enterPasswordLoginSuccessInitialMinDate is not null then 1 else null end) as enterPasswordLoginSuccessInitial
     
     , count(case when resetPasswordMinDate is not null then 1 else null end) as resetPassword
     , count(case when cancelResetPasswordButtonMinDate is not null then 1 else null end) as cancelResetPasswordButton
     , count(case when submitResetPasswordButtonMinDate is not null then 1 else null end) as submitResetPasswordButton
     
     , count(case when eventPickerMinDate is not null then 1 else null end) as eventPicker
     , count(case when eventSelectButtonMinDate is not null then 1 else null end) as eventSelectButton
     , count(case when eventPickerLoginSuccessInitialMinDate is not null then 1 else null end) as eventPickerLoginSuccessInitial
     
     , count(case when eventProfileChoiceMinDate is not null then 1 else null end) as eventProfileChoice
     , count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is null then 1 else null end) as createProfileButtonManual
     , count(case when createProfileButtonLinkedInEPCMinDate is not null and createProfileButtonManualMinDate is null then 1 else null end) createProfileButtonLinkedInEPC
     , count(case when createProfileButtonManualMinDate is not null and createProfileButtonLinkedInEPCMinDate is not null then 1 else null end) as createProfileButtonBoth
     
     , count(case when profileFillerMinDate is not null then 1 else null end) as profileFiller
     , count(case when changeProfilePhotoButtonMinDate is not null then 1 else null end) as changeProfilePhotoButton
     , count(case when cancelProfilePhotoActionMinDate is not null then 1 else null end) as cancelProfilePhotoAction
     , count(case when createProfileButtonLinkedInPFMinDate is not null then 1 else null end) createProfileButtonLinkedInPF
     , count(case when enterFirstNameTextFieldMinDate is not null then 1 else null end) as enterFirstNameTextField
     , count(case when enterLastNameTextFieldMinDate is not null then 1 else null end) as enterLastNameTextField
     , count(case when enterCompanyTextFieldMinDate is not null then 1 else null end) as enterCompanyTextField
     , count(case when enterTitleTextFieldMinDate is not null then 1 else null end) as enterTitleTextField
     , count(case when addSocialNetworkToProfileButtonMinDate is not null then 1 else null end) as addSocialNetworkToProfileButton
     , count(case when submitProfileButtonMinDate is not null then 1 else null end) as submitProfileButton
     , count(case when profileFillerLoginSuccessInitialMinDate is not null then 1 else null end) as profileFillerLoginSuccessInitial
from jt.pa506_logincube spine
join (select *
      from jt.pa506_bundle_reg_type
      /*where bundle_tolerance <= 0.1*/) bundles
on spine.bundle_id = bundles.bundle_id
join jt.pa506_logincube_sessions sessions
on spine.bundle_id = sessions.bundle_id
and spine.device_id = sessions.device_id
where (spine.loginFlowStartInitialEnterEmailMinDate is not null or spine.loginFlowStartInitialAccountPickerMinDate is not null)
and spine.loginFlowStartNonInitialMinDate is null
and ((spine.loginFlowStartInitialEnterEmailMinDate is not null and spine.loginFlowStartInitialEnterEmailMinDate <= sessions.firstLogin) or (spine.loginFlowStartInitialAccountPickerMinDate is not null and spine.loginFlowStartInitialAccountPickerMinDate <= sessions.firstLogin))
and spine.device_type = 'android'
--and bundles.bundle_type = 'open'
group by 1,2
order by 1,2
;





















