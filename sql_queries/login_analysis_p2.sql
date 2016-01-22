select open_closed_flag
     , sum(enteremailview) as enteremailview
     , sum(enteremailtextfieldaction) as enteremailtextfieldaction
     , sum(submitemailbuttonaction) as submitemailbuttonaction
     , sum(enterpasswordview) as enterpasswordview
     , sum(enterpasswordtextfieldaction) as enterpasswordtextfieldaction
     , sum(submitpasswordbuttonaction) as submitpasswordbuttonaction  
     , sum(eventpickerview) as eventpickerview     
     , sum(eventselectbuttonaction) as eventselectbuttonaction
     , sum(profilefillerview) as profilefillerview
     , sum(changeprofilephotobuttonaction) as changeprofilephotobuttonaction
     , sum(cancelprofilephotoactionaction) as cancelprofilephotoactionaction
     , sum(enterfirstnametextfieldaction) as enterfirstnametextfieldaction
     , sum(enterlastnametextfieldaction) as enterlastnametextfieldaction
     , sum(entercompanytextfieldaction) as entercompanytextfieldaction
     , sum(entertitletextfieldaction) as entertitletextfieldaction
     , sum(submitprofilebuttonaction) as submitprofilebuttonaction
     , sum(sessionstart) as sessionstart          
     , sum(globalactivityview) as globalactivityview
from (
select a.bundle_id
     , canregister
     , b.open_closed_flag
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction        
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview     
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart          
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview
from jt.login_funnel_ios_granular a
join (select distinct device_id
           , bundle_id
           , case
               when open_closed_flag = 'open' and view_path like '%password%' then 1
               when view_path like '%globalactivityfeed%' and view_path not like '%profilefillerview%' then 1
               else 0
             end as open_password_flag
           , open_closed_flag
           from (select a.device_id
                      , a.bundle_id
                      , a.canregister
                      , b.open_closed_flag
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||                        
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||                      
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' else '' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_ios_granular a
                 join (select bundle_id
                            , canregister
                            , case
                                 when count(case when enterpasswordviewflag = 1 then 1 else null end) < count(case when eventpickerviewflag = 1 then 1 else null end) then 'open'
                                 else 'closed'
                              end as open_closed_flag
                       from jt.login_funnel_ios_granular
                       group by 1,2) b
                 on a.bundle_id = b.bundle_id
                ) a
           where view_path <> ''
           and view_path like '%enteremailview%'
           ) b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where b.open_password_flag = 0
group by 1,2,3) a
group by 1;    






select open_closed_flag
     , sum(accountpickerview) as accountpickerview
     , sum(accountselectbuttonaction) as accountselectbuttonaction
     , sum(anotheraccountbuttonaction) as anotheraccountbuttonaction
     , sum(enteremailview) as enteremailview
     , sum(enteremailtextfieldaction) as enteremailtextfieldaction
     , sum(submitemailbuttonaction) as submitemailbuttonaction
     , sum(enterpasswordview) as enterpasswordview
     , sum(enterpasswordtextfieldaction) as enterpasswordtextfieldaction
     , sum(submitpasswordbuttonaction) as submitpasswordbuttonaction     
     , sum(eventpickerview) as eventpickerview     
     , sum(eventselectbuttonaction) as eventselectbuttonaction
     , sum(profilefillerview) as profilefillerview
     , sum(changeprofilephotobuttonaction) as changeprofilephotobuttonaction
     , sum(cancelprofilephotoactionaction) as cancelprofilephotoactionaction
     , sum(enterfirstnametextfieldaction) as enterfirstnametextfieldaction
     , sum(enterlastnametextfieldaction) as enterlastnametextfieldaction
     , sum(entercompanytextfieldaction) as entercompanytextfieldaction
     , sum(entertitletextfieldaction) as entertitletextfieldaction
     , sum(submitprofilebuttonaction) as submitprofilebuttonaction
     , sum(sessionstart) as sessionstart          
     , sum(globalactivityview) as globalactivityview
from (
select a.bundle_id
     , canregister
     , b.open_closed_flag
     , count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when anotheraccountbuttonflag = 1 then 1 else null end) as anotheraccountbuttonaction    
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction     
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview     
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart          
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview
from jt.login_funnel_android_granular a
join (select distinct device_id
           , bundle_id
           , case
               when open_closed_flag = 'open' and view_path like '%password%' then 1
               when view_path like '%globalactivityfeed%' and view_path not like '%profilefillerview%' then 1
               else 0
             end as open_password_flag
           , open_closed_flag
           from (select a.device_id
                      , a.bundle_id
                      , a.canregister
                      , b.open_closed_flag
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when anotheraccountbuttonflag = 1 then 'anotheraccountbuttonaction ' else '' end ||   
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||     
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_android_granular a
                 join (select bundle_id
                            , canregister
                            , case
                                 when count(case when enterpasswordviewflag = 1 then 1 else null end) < count(case when eventpickerviewflag = 1 then 1 else null end) then 'open'
                                 else 'closed'
                              end as open_closed_flag
                       from jt.login_funnel_android_granular
                       group by 1,2) b
                 on a.bundle_id = b.bundle_id
                ) a
           where view_path <> ''
           and view_path like 'accountpickerview%'
           ) b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where b.open_password_flag = 0
group by 1,2,3) a
group by 1;  


----------------------End---------------



create table as jt.login_funnel_checkpoint_flag as
select a.*
     , case
         when b.device_id is not null then 1
         else 0
       end as action_flag
     , case
         when c.device_id is not null then 1
         else 0
       end as view_flag
from jt.login_funnel_device_spine a
left join (select distinct lower(device_id) as device_id from fact_actions) b
on a.device_id = b.device_id
left join (select distinct lower(device_id) as device_id from fact_views) c
on a.device_id = c.device_id;

/* Explore Later */
select count(*)
     , count(case when action_flag = 1 then 1 else null end)
     , count(case when action_flag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4)
     , count(case when view_flag = 1 then 1 else null end)
     , count(case when view_flag = 1 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4)
from jt.login_funnel_checkpoint_flag;

---------New Output------------



select possible_open_flag
     , sum(enteremailview) as enteremailview
     , sum(enteremailtextfieldaction) as enteremailtextfieldaction
     , sum(submitemailbuttonaction) as submitemailbuttonaction
     , sum(enterpasswordview) as enterpasswordview
     , sum(enterpasswordtextfieldaction) as enterpasswordtextfieldaction
     , sum(submitpasswordbuttonaction) as submitpasswordbuttonaction     
     , sum(eventpickerview) as eventpickerview     
     , sum(eventselectbuttonaction) as eventselectbuttonaction
     , sum(profilefillerview) as profilefillerview
     , sum(changeprofilephotobuttonaction) as changeprofilephotobuttonaction
     , sum(cancelprofilephotoactionaction) as cancelprofilephotoactionaction
     , sum(enterfirstnametextfieldaction) as enterfirstnametextfieldaction
     , sum(enterlastnametextfieldaction) as enterlastnametextfieldaction
     , sum(entercompanytextfieldaction) as entercompanytextfieldaction
     , sum(entertitletextfieldaction) as entertitletextfieldaction
     , sum(submitprofilebuttonaction) as submitprofilebuttonaction
     , sum(sessionstart) as sessionstart          
     , sum(globalactivityview) as globalactivityview
from (
select a.bundle_id
     , canregister
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction     
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview     
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart          
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview
     , case
         when count(case when enterpasswordviewflag = 1 then 1 else null end) < count(case when eventpickerviewflag = 1 then 1 else null end) then 'open'
         else 'closed'
       end as possible_open_flag
     , case
         when count(case when eventpickerviewflag = 1 then 1 else null end) > 0 then 
         count(case when enterpasswordviewflag = 1 then 1 else null end)::decimal(12,4)/count(case when eventpickerviewflag = 1 then 1 else null end)::decimal(12,4)
         else 0
       end as pct_change
from jt.login_funnel_ios_granular a
join (select distinct device_id
           , bundle_id
           from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||                      
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' else '' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                      /*, case 
                          when eventpickerviewflag = 1 and eventpickerviewtime <= enteremailviewtime and globalloginstartflag = 1 and globalloginsuccessflag = 1 then 1
                          when profilefillerviewflag = 1 and (profilefillerviewtime <= eventpickerviewtime or profilefillerviewtime <= enteremailviewtime) and globalloginstartflag = 1 and globalloginsuccessflag = 1 and logineventsuccessflag = 1 then 1
                          when globalactivityflag = 1 and (globalactivitytime <= eventpickerviewtime or globalactivitytime <= enteremailviewtime or globalactivitytime <= profilefillerviewtime) and globalloginstartflag = 1 and globalloginsuccessflag = 1 and logineventsuccessflag = 1 and profilecompleteflag = 1 then 1
                          when globalactivityflag = 1 and profilefillerviewflag = 0 then 1
                          else 0
                        end as strange_paths_flag*/
                 from jt.login_funnel_ios_granular
                 --where globalloginstartflag = 1 or globalloginsuccessflag = 1 or logineventsuccessflag = 1 or profilecompleteflag = 1
                ) a
           where view_path <> ''
           and view_path like 'enteremailview%'
           --and strange_paths_flag = 0
           --and view_path not like '%password%'
           ) b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
group by 1,2) a
group by 1;    



select possible_open_flag
     , sum(accountpickerview) as accountpickerview
     , sum(accountselectbuttonaction) as accountselectbuttonaction
     , sum(anotheraccountbuttonaction) as anotheraccountbuttonaction
     , sum(enteremailview) as enteremailview
     , sum(enteremailtextfieldaction) as enteremailtextfieldaction
     , sum(submitemailbuttonaction) as submitemailbuttonaction
     , sum(enterpasswordview) as enterpasswordview
     , sum(enterpasswordtextfieldaction) as enterpasswordtextfieldaction
     , sum(submitpasswordbuttonaction) as submitpasswordbuttonaction     
     , sum(eventpickerview) as eventpickerview     
     , sum(eventselectbuttonaction) as eventselectbuttonaction
     , sum(profilefillerview) as profilefillerview
     , sum(changeprofilephotobuttonaction) as changeprofilephotobuttonaction
     , sum(cancelprofilephotoactionaction) as cancelprofilephotoactionaction
     , sum(enterfirstnametextfieldaction) as enterfirstnametextfieldaction
     , sum(enterlastnametextfieldaction) as enterlastnametextfieldaction
     , sum(entercompanytextfieldaction) as entercompanytextfieldaction
     , sum(entertitletextfieldaction) as entertitletextfieldaction
     , sum(submitprofilebuttonaction) as submitprofilebuttonaction
     , sum(sessionstart) as sessionstart          
     , sum(globalactivityview) as globalactivityview
from (
select a.bundle_id
     , canregister
     , count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when anotheraccountbuttonflag = 1 then 1 else null end) as anotheraccountbuttonaction    
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction     
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview     
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart          
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview
     , case
         when count(case when enterpasswordviewflag = 1 then 1 else null end) < count(case when eventpickerviewflag = 1 then 1 else null end) then 'open'
         else 'closed'
       end as possible_open_flag
     , case
         when count(case when eventpickerviewflag = 1 then 1 else null end) > 0 then 
         count(case when enterpasswordviewflag = 1 then 1 else null end)::decimal(12,4)/count(case when eventpickerviewflag = 1 then 1 else null end)::decimal(12,4)
         else 0
       end as pct_change
from jt.login_funnel_android_granular a
join (select distinct device_id
           , bundle_id
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when anotheraccountbuttonflag = 1 then 'anotheraccountbuttonaction ' else '' end ||   
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||     
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_android_granular
                ) a
           where view_path <> ''
           and view_path like 'accountpickerview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
group by 1,2) a
group by 1;  
-------------End New Output----------


------ Output ----

select count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview     
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart          
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview
from jt.login_funnel_ios_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||                      
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' else '' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_ios_granular
                 where canregister = true
                ) a
           where view_path <> ''
           and view_path not like '%password%'
           and view_path like 'enteremailview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = true;




select count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction     
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview     
from jt.login_funnel_ios_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||                      
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' else '' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_ios_granular
                 where canregister = false
                ) a
           where view_path <> ''
           and view_path like 'enteremailview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = false;





select count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when anotheraccountbuttonflag = 1 then 1 else null end) as anotheraccountbuttonaction     
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction    
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart     
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview        
from jt.login_funnel_android_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when anotheraccountbuttonflag = 1 then 'anotheraccountbuttonaction ' else '' end ||   
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||     
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else '' end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = true
                ) a
           where view_path <> ''
           and view_path not like '%password%'
           and view_path like 'accountpickerview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = true;



select count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when anotheraccountbuttonflag = 1 then 1 else null end) as anotheraccountbuttonaction
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction     
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when changeprofilephotobuttonflag = 1 then 1 else null end) as changeprofilephotobuttonaction
     , count(case when cancelprofilephotoactionflag = 1 then 1 else null end) as cancelprofilephotoactionaction
     , count(case when enterfirstnametextfieldflag = 1 then 1 else null end) as enterfirstnametextfieldaction
     , count(case when enterlastnametextfieldflag = 1 then 1 else null end) as enterlastnametextfieldaction
     , count(case when entercompanytextfieldflag = 1 then 1 else null end) as entercompanytextfieldaction
     , count(case when entertitletextfieldflag = 1 then 1 else null end) as entertitletextfieldaction    
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
     , count(case when sessionflag = 1 then 1 else null end) as sessionstart  
     , count(case when globalactivityflag = 1 then 1 else null end) as globalactivityview           
from jt.login_funnel_android_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when anotheraccountbuttonflag = 1 then 'anotheraccountbuttonaction ' else '' end ||
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when changeprofilephotobuttonflag = 1 then 'changeprofilephotobuttonaction ' else '' end ||
                        case when cancelprofilephotoactionflag = 1 then 'cancelprofilephotoaction ' else '' end ||
                        case when enterfirstnametextfieldflag = 1 then 'enterfirstnametextfieldaction ' else '' end ||
                        case when enterlastnametextfieldflag = 1 then 'enterlastnametextfieldaction ' else '' end ||
                        case when entercompanytextfieldflag = 1 then 'entercompanytextfieldaction ' else '' end ||
                        case when entertitletextfieldflag = 1 then 'entertitletextfieldaction ' else '' end ||     
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end ||
                        case when sessionflag = 1 then 'session ' end || 
                        case when globalactivityflag = 1 then 'globalactivityfeed ' else ''end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = false
                ) a
           where view_path <> ''
           and view_path like 'accountpickerview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = false;

-------- End Output -----



truncate table jt.events_login_funnel_actions;
drop table if exists jt.events_login_funnel_actions;
create table jt.events_login_funnel_actions as
select *
     , case
         when identifier = 'eventselectbutton' then metadata->>'applicationid'
         else null
       end as event_select_application_id
from fact_actions
where (identifier = 'enteremailtextfield' 
       or identifier = 'submitemailbutton' 
       or identifier = 'enterpasswordtextfield' 
       or identifier = 'submitpasswordbutton' 
       or identifier = 'eventselectbutton' 
       or identifier = 'resetpasswordbutton' 
       or identifier = 'submitresetpasswordbutton' 
       or identifier = 'changeprofilephotobutton' 
       or identifier = 'cancelprofilephotoaction' 
       or identifier = 'enterfirstnametextfield' 
       or identifier = 'enterlastnametextfield' 
       or identifier = 'entercompanytextfield' 
       or identifier = 'entertitletextfield' 
       or identifier = 'cancelresetpasswordbutton'
       or identifier = 'anotheraccountbutton'
       or identifier = 'accountselectbutton'
       or identifier = 'emailsupport'
       or identifier = 'privacypolicy'
       or identifier = 'submitresetpasswordbutton'
       or identifier = 'submitprofilebutton');

drop index ndx_events_login_funnel_actions;
create index ndx_events_login_funnel_actions on jt.events_login_funnel_actions (bundle_id, global_user_id, identifier, created);

truncate table jt.events_login_funnel_views;
drop table if exists jt.events_login_funnel_views;

create table jt.events_login_funnel_views as
select *
     , case
         when identifier = 'eventselectbutton' then metadata->>'applicationid'
         else null
       end as event_select_application_id
from fact_views
where (identifier = 'enteremail' 
       or identifier = 'enterpassword' 
       or identifier = 'eventpicker' 
       or identifier = 'profilefiller' 
       or identifier = 'resetpassword');

drop index ndx_events_login_funnel_views;
create index ndx_events_login_funnel_views on jt.events_login_funnel_views (bundle_id, global_user_id, identifier, created);


truncate table jt.login_funnel_spine;
drop table if exists jt.login_funnel_spine;

create table jt.login_funnel_spine as 
select distinct lower(bundle_id) as bundle_id
     , lower(device_id) as device_id
     , lower(global_user_id) as global_user_id
from jt.login_funnel_loginaction
where bundle_id <> '00000000-0000-0000-0000-000000000000'
and device_id <> '00000000-0000-0000-0000-000000000000'
and global_user_id <> '00000000-0000-0000-0000-000000000000'
union 
select distinct lower(bundle_id) as bundle_id
     , lower(device_id) as device_id
     , lower(global_user_id) as global_user_id
from jt.login_funnel_loginview
where bundle_id <> '00000000-0000-0000-0000-000000000000'
and device_id <> '00000000-0000-0000-0000-000000000000'
and global_user_id <> '00000000-0000-0000-0000-000000000000';


drop table if exists jt.login_funnel_spine_p2;

create table jt.login_funnel_spine_p2 as
select s.*
     , case
         when u.global_user_id is null then 0
         else 1
       end as reg_user_flag
     , u.application_id
     , u.isdisabled
from jt.login_funnel_spine s
left join (select distinct lower(a.bundleid::varchar) as bundle_id
           , lower(a.applicationid::varchar) as application_id 
           , lower(u.globaluserid::varchar) as global_user_id
           , u.isdisabled
      from authdb_applications a
      join authdb_is_users u
      on a.applicationid = u.applicationid) u
on s.global_user_id = u.global_user_id and s.bundle_id = u.bundle_id;


drop table if exists jt.login_funnel_spine_multiple_reg_users;

create table jt.login_funnel_spine_multiple_reg_users as
select bundle_id
     , device_id
from (select distinct bundle_id
           , device_id
           , global_user_id
      from jt.login_funnel_spine_p2
      where reg_user_flag = 1) a
group by 1,2
having count(*) >= 2;


drop table if exists jt.login_funnel_spine_p3;

create table jt.login_funnel_spine_p3 as
select a.*
from jt.login_funnel_spine_p2 a
left join jt.login_funnel_spine_multiple_reg_users b
on a.bundle_id = b.bundle_id
and a.device_id = b.device_id
where b.bundle_id is null;


drop table if exists jt.login_funnel_spine_user_xref;

create table jt.login_funnel_spine_user_xref as
select coalesce(a.device_id, b.device_id) as device_id
     , coalesce(a.bundle_id, b.bundle_id) as bundle_id
     , a.global_user_id as final_global_user_id
     , b.global_user_id as temp_global_user_id
from (select distinct bundle_id, device_id, global_user_id from jt.login_funnel_spine_p3 where reg_user_flag = 1) a
full outer join (select distinct bundle_id, device_id, global_user_id from jt.login_funnel_spine_p3 where reg_user_flag = 0) b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
union
select distinct device_id
     , bundle_id
     , global_user_id as final_global_user_id
     , global_user_id as temp_global_user_id 
from jt.login_funnel_spine_p3 where reg_user_flag = 1;


drop table if exists jt.login_funnel_spine_events_views;

create table jt.login_funnel_spine_events_views as
select a.app_type_id
     , lower(a.device_id) as device_id
     , 'view' as metric_type
     , min(a.created) as first_created
     , a.identifier
     , lower(a.bundle_id) as bundle_id
     , b.final_global_user_id
from jt.login_funnel_loginview a
join jt.login_funnel_spine_user_xref b
on lower(a.device_id) = b.device_id and lower(a.bundle_id) = b.bundle_id and a.global_user_id = b.temp_global_user_id
where a.device_id <> '00000000-0000-0000-0000-000000000000'
and a.bundle_id <> '00000000-0000-0000-0000-000000000000'
group by 1,2,3,5,6,7
union
select a.app_type_id
     , lower(a.device_id) as device_id
     , 'action' as metric_type
     , min(a.created) as first_created
     , a.identifier
     , lower(a.bundle_id) as bundle_id
     , b.final_global_user_id
from jt.login_funnel_loginaction a
join jt.login_funnel_spine_user_xref b
on lower(a.device_id) = b.device_id and lower(a.bundle_id) = b.bundle_id and a.global_user_id = b.temp_global_user_id
where a.device_id <> '00000000-0000-0000-0000-000000000000'
and a.bundle_id <> '00000000-0000-0000-0000-000000000000'
group by 1,2,3,5,6,7;


drop table if exists jt.login_funnel_ios_granular;

create table jt.login_funnel_ios_granular as
select a.device_id
     , a.bundle_id
     , a.final_global_user_id
     , f.bundle_event_cnt
     , f.canregister
     , case
         when b.device_id is not null then 1
         else 0
       end as enteremailviewflag
     , case
         when b.device_id is not null then b.first_created
         else null
       end as enteremailviewtime
       
     , case
         when b2.device_id is not null then 1
         else 0
       end as enteremailtextfieldflag
     , case
         when b2.device_id is not null then b2.first_created
         else null
       end as enteremailtextfieldtime
       
     , case
         when b3.device_id is not null then 1
         else 0
       end as submitemailbuttonflag
     , case
         when b3.device_id is not null then b3.first_created
         else null
       end as submitemailbuttontime  

     , case
         when c.device_id is not null then 1
         else 0
       end as enterpasswordviewflag
     , case
         when c.device_id is not null then c.first_created
         else null
       end as enterpasswordviewtime

     , case
         when c2.device_id is not null then 1
         else 0
       end as enterpasswordtextfieldflag
     , case
         when c2.device_id is not null then c2.first_created
         else null
       end as enterpasswordtextfieldtime
       
      , case
         when c3.device_id is not null then 1
         else 0
       end as submitpasswordbuttonflag
     , case
         when c3.device_id is not null then c3.first_created
         else null
       end as submitpasswordbuttontime       


     , case
         when d.device_id is not null then 1
         else 0
       end as eventpickerviewflag   
     , case
         when d.device_id is not null then d.first_created
         else null
       end as eventpickerviewtime     
       
     , case
         when d2.device_id is not null then 1
         else 0
       end as eventselectbuttonflag   
     , case
         when d2.device_id is not null then d2.first_created
         else null
       end as eventselectbuttontime              
         
     , case
         when e.device_id is not null then 1
         else 0
       end as profilefillerviewflag 
     , case
         when e.device_id is not null then e.first_created
         else null
       end as profilefillerviewtime   
       
     , case
         when e2.device_id is not null then 1
         else 0
       end as submitprofilebuttonflag 
     , case
         when e2.device_id is not null then e2.first_created
         else null
       end as submitprofilebuttontime           
                       
            
from (select distinct device_id, bundle_id, final_global_user_id from jt.login_funnel_spine_events_views
      where app_type_id in (1,2)) a
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'enteremail') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'enteremailtextfield') b2
on a.device_id = b2.device_id and a.bundle_id = b2.bundle_id
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'submitemailbutton') b3
on a.device_id = b3.device_id and a.bundle_id = b3.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'enterpassword') c
on a.device_id = c.device_id and a.bundle_id = c.bundle_id

left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'enterpasswordtextfield') c2
on a.device_id = c2.device_id and a.bundle_id = c2.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'submitpasswordbutton') c3
on a.device_id = c3.device_id and a.bundle_id = c3.bundle_id


left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'eventpicker') d
on a.device_id = d.device_id and a.bundle_id = d.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'eventselectbutton') d2
on a.device_id = d2.device_id and a.bundle_id = d2.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'profilefiller') e
on a.device_id = e.device_id and a.bundle_id = e.bundle_id

left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'submitprofilebutton') e2
on a.device_id = e2.device_id and a.bundle_id = e2.bundle_id

join (select lower(a.bundleid) as bundle_id
           , a.canregister
           , min(a.startdate) as first_event_start_date
           , count(*) as bundle_event_cnt
      from authdb_applications a
      join authdb_bundles b
      on a.bundleid = b.bundleid
      where lower(a.name) not like '%doubledutch%' and lower(b.name) not like '%doubledutch%' and lower(b.name) not in ('pride','ddqa')
      and lower(a.bundleid) not in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
      and a.startdate is not null
      and a.enddate is not null
      group by 1,2) f
on a.bundle_id = f.bundle_id
where f.first_event_start_date >= '2015-06-01';



select count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
from jt.login_funnel_ios_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_ios_granular
                 where canregister = true
                ) a
           where view_path <> ''
           and view_path not like '%password%'
           and view_path like 'enteremailview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = true;



select count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
from jt.login_funnel_ios_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_ios_granular
                 where canregister = false
                ) a
           where view_path <> ''
           --and view_path like '%password%'
           and view_path like 'enteremailview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = false;











drop table if exists jt.login_funnel_android_granular;

create table jt.login_funnel_android_granular as
select a.device_id
     , a.bundle_id
     , a.final_global_user_id
     , f.bundle_event_cnt
     , f.canregister
     , case
         when a2.device_id is not null then 1
         else 0
       end as accountpickerviewflag
     , case
         when a2.device_id is not null then a2.first_created
         else null
       end as accountpickerviewtime
     , case
         when a3.device_id is not null then 1
         else 0
       end as accountselectbuttonactionflag
     , case
         when a3.device_id is not null then a3.first_created
         else null
       end as accountselectbuttonactiontime       
       
     , case
         when b.device_id is not null then 1
         else 0
       end as enteremailviewflag
     , case
         when b.device_id is not null then b.first_created
         else null
       end as enteremailviewtime
       
     , case
         when b2.device_id is not null then 1
         else 0
       end as enteremailtextfieldflag
     , case
         when b2.device_id is not null then b2.first_created
         else null
       end as enteremailtextfieldtime
       
     , case
         when b3.device_id is not null then 1
         else 0
       end as submitemailbuttonflag
     , case
         when b3.device_id is not null then b3.first_created
         else null
       end as submitemailbuttontime  

     , case
         when c.device_id is not null then 1
         else 0
       end as enterpasswordviewflag
     , case
         when c.device_id is not null then c.first_created
         else null
       end as enterpasswordviewtime

     , case
         when c2.device_id is not null then 1
         else 0
       end as enterpasswordtextfieldflag
     , case
         when c2.device_id is not null then c2.first_created
         else null
       end as enterpasswordtextfieldtime
       
      , case
         when c3.device_id is not null then 1
         else 0
       end as submitpasswordbuttonflag
     , case
         when c3.device_id is not null then c3.first_created
         else null
       end as submitpasswordbuttontime       


     , case
         when d.device_id is not null then 1
         else 0
       end as eventpickerviewflag   
     , case
         when d.device_id is not null then d.first_created
         else null
       end as eventpickerviewtime     
       
     , case
         when d2.device_id is not null then 1
         else 0
       end as eventselectbuttonflag   
     , case
         when d2.device_id is not null then d2.first_created
         else null
       end as eventselectbuttontime              
         
     , case
         when e.device_id is not null then 1
         else 0
       end as profilefillerviewflag 
     , case
         when e.device_id is not null then e.first_created
         else null
       end as profilefillerviewtime   
       
     , case
         when e2.device_id is not null then 1
         else 0
       end as submitprofilebuttonflag 
     , case
         when e2.device_id is not null then e2.first_created
         else null
       end as submitprofilebuttontime           
                       
            
from (select distinct device_id, bundle_id, final_global_user_id from jt.login_funnel_spine_events_views
      where app_type_id in (3)) a
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'accountpicker') a2
on a.device_id = a2.device_id and a.bundle_id = a2.bundle_id
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'accountselectbutton') a3
on a.device_id = a3.device_id and a.bundle_id = a3.bundle_id

left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'enteremail') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'enteremailtextfield') b2
on a.device_id = b2.device_id and a.bundle_id = b2.bundle_id
left join (select device_id, bundle_id, first_created from jt.login_funnel_spine_events_views where identifier = 'submitemailbutton') b3
on a.device_id = b3.device_id and a.bundle_id = b3.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'enterpassword') c
on a.device_id = c.device_id and a.bundle_id = c.bundle_id

left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'enterpasswordtextfield') c2
on a.device_id = c2.device_id and a.bundle_id = c2.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'submitpasswordbutton') c3
on a.device_id = c3.device_id and a.bundle_id = c3.bundle_id


left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'eventpicker') d
on a.device_id = d.device_id and a.bundle_id = d.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'eventselectbutton') d2
on a.device_id = d2.device_id and a.bundle_id = d2.bundle_id
left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'profilefiller') e
on a.device_id = e.device_id and a.bundle_id = e.bundle_id

left join (select device_id, bundle_id, first_created  from jt.login_funnel_spine_events_views where identifier = 'submitprofilebutton') e2
on a.device_id = e2.device_id and a.bundle_id = e2.bundle_id

join (select lower(a.bundleid) as bundle_id
           , a.canregister
           , min(a.startdate) as first_event_start_date
           , count(*) as bundle_event_cnt
      from authdb_applications a
      join authdb_bundles b
      on a.bundleid = b.bundleid
      where lower(a.name) not like '%doubledutch%' and lower(b.name) not like '%doubledutch%' and lower(b.name) not in ('pride','ddqa')
      and lower(a.bundleid) not in ('00000000-0000-0000-0000-000000000000','025aa15b-ce74-40aa-a4cc-04028401c8b3','89fd8f03-0d59-41ab-a6a7-2237d8ac4eb2','5a46600a-156a-441e-b594-40f7defb54f2','f95fe4a7-e86a-4661-ac59-8b423f1f540a','34b4e501-3f31-46a0-8f2a-0fb6ea5e4357','09e25995-8d8f-4c2d-8f55-15ba22595e11','5637be65-6e3f-4095-beb8-115849b5584a','9f3489d7-c93c-4c8b-8603-dda6a9061116','d0f56154-e8e7-4566-a845-d3f47b8b35cc','bc35d4ce-c571-4f91-834a-a8136ca137c4','3e3fda3d-a606-4013-8ddf-711a1871bd12','75ce91a5-bcc0-459a-b479-b3956ea09abc','384d052e-0abd-44d1-a643-bc590135f5a0','b752a5b3-aa53-4bcf-9f52-d5600474d198','15740a5a-25d8-4dc6-a9ed-7f610ff94085','0cbc9d00-1e6d-4db3-95fc-c5fbb156c6de','f0c4b2db-a743-4fb2-9e8f-a80463e52b55','8a995a58-c574-421b-8f82-e3425d9054b0','6dbb91c8-6544-48ef-8b8d-a01b435f3757','f21325d8-3a43-4275-a8b8-b4b6e3f62de0','de8d1832-b4ea-4bd2-ab4b-732321328b04','7e289a59-e573-454c-825b-cf31b74c8506')
      and a.startdate is not null
      and a.enddate is not null
      group by 1,2) f
on a.bundle_id = f.bundle_id
where f.first_event_start_date >= '2015-06-01';





select count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
from jt.login_funnel_android_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = true
                ) a
           where view_path <> ''
           and view_path not like '%password%'
           and view_path like 'accountpickerview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = true;



select  view_path
     , count(*)
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = true
                ) a
           where view_path = 'accountpickerview accountselectbuttonaction eventpickerview profilefillerview ' or 
view_path = 'accountpickerview eventpickerview profilefillerview ' or 
view_path = 'accountpickerview accountselectbuttonaction eventpickerview profilefillerview submitprofilebuttonaction ' or 
view_path = 'accountpickerview enteremailview enteremailtextfieldaction submitemailbuttonaction eventpickerview profilefillerview ' or 
view_path = 'accountpickerview accountselectbuttonaction eventpickerview eventselectbuttonaction profilefillerview ' or 
view_path = 'accountpickerview eventpickerview eventselectbuttonaction profilefillerview ' or 
view_path = 'accountpickerview enteremailview enteremailtextfieldaction submitemailbuttonaction eventpickerview profilefillerview submitprofilebuttonaction ' or 
view_path = 'accountpickerview enteremailview enteremailtextfieldaction submitemailbuttonaction eventpickerview eventselectbuttonaction profilefillerview ' or 
view_path = 'accountpickerview accountselectbuttonaction eventpickerview eventselectbuttonaction profilefillerview submitprofilebuttonaction ' or 
view_path = 'accountpickerview ' or 
view_path = 'accountpickerview accountselectbuttonaction enteremailview eventpickerview profilefillerview ' or 
view_path = 'accountpickerview enteremailview enteremailtextfieldaction eventpickerview profilefillerview ' or 
view_path = 'accountpickerview eventpickerview '
           group by 1
           order by 2 desc;




select count(case when accountpickerviewflag = 1 then 1 else null end) as accountpickerview
     , count(case when accountselectbuttonactionflag = 1 then 1 else null end) as accountselectbuttonaction
     , count(case when enteremailviewflag = 1 then 1 else null end) as enteremailview
     , count(case when enteremailtextfieldflag = 1 then 1 else null end) as enteremailtextfieldaction
     , count(case when submitemailbuttonflag = 1 then 1 else null end) as submitemailbuttonaction
     , count(case when enterpasswordviewflag = 1 then 1 else null end) as enterpasswordview
     , count(case when enterpasswordtextfieldflag = 1 then 1 else null end) as enterpasswordtextfieldaction
     , count(case when submitpasswordbuttonflag = 1 then 1 else null end) as submitpasswordbuttonaction
     , count(case when eventpickerviewflag = 1 then 1 else null end) as eventpickerview
     , count(case when eventselectbuttonflag = 1 then 1 else null end) as eventselectbuttonaction
     , count(case when profilefillerviewflag = 1 then 1 else null end) as profilefillerview
     , count(case when submitprofilebuttonflag = 1 then 1 else null end) as submitprofilebuttonaction
from jt.login_funnel_android_granular a
join (select distinct device_id
                , bundle_id
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = false
                ) a
           where view_path <> ''
           --and view_path like '%password%'
           and view_path like 'accountpickerview%') b
on a.device_id = b.device_id and a.bundle_id = b.bundle_id
where a.canregister = false;




select view_path
     , count(*)
           from (select device_id
                      , bundle_id
                      , case when accountpickerviewflag = 1 then 'accountpickerview ' else '' end ||
                        case when accountselectbuttonactionflag = 1 then 'accountselectbuttonaction ' else '' end ||
                        case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_android_granular
                 where canregister = false
                ) a
           where view_path <> ''
           --and view_path like '%password%'
           and view_path like 'accountpickerview%'
group by 1
order by 2 desc;




select device_id
     , bundle_id
from (select device_id
                      , bundle_id
                      , case when enteremailviewflag = 1 then 'enteremailview ' else '' end || 
                        case when enteremailtextfieldflag = 1 then 'enteremailtextfieldaction ' else '' end ||
                        case when submitemailbuttonflag = 1 then 'submitemailbuttonaction ' else '' end ||
                        case when enterpasswordviewflag = 1 then 'enterpasswordview ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end ||
                        case when submitpasswordbuttonflag = 1 then 'submitpasswordbuttonaction ' else '' end ||
                        case when enterpasswordtextfieldflag = 1 then 'enterpasswordtextfieldaction ' else '' end||
                        case when eventpickerviewflag = 1 then 'eventpickerview ' else '' end ||
                        case when eventselectbuttonflag = 1 then 'eventselectbuttonaction ' else '' end ||
                        case when profilefillerviewflag = 1 then 'profilefillerview ' else '' end ||
                        case when submitprofilebuttonflag = 1 then 'submitprofilebuttonaction ' else '' end as view_path
                 from jt.login_funnel_ios_granular
                 where canregister = false
                ) a
           where view_path = 'enteremailview enteremailtextfieldaction submitemailbuttonaction eventpickerview eventselectbuttonaction profilefillerview submitprofilebuttonaction '
group by 1,2
order by 2 desc;


select *
from authdb_applications
where lower(bundleid) = 'fe9acb11-1403-4932-96fc-dd2e8260965a'





select *
from authdb_applications
where lower(bundleid) = 'ef2289d4-b586-4be5-b2ba-8097487229a5';


select *
from jt.login_funnel_ios_granular
where bundle_id = '01c8fc94-1b91-4ee3-9e16-50f72445fd20'
and device_id = '9aafc63f-ff77-4847-9d61-10f96c2b9a65';

select *
from authdb_applications
where lower(bundleid) = '01c8fc94-1b91-4ee3-9e16-50f72445fd20';

select *
from jt.login_funnel_spine_p3 
where bundle_id = '01c8fc94-1b91-4ee3-9e16-50f72445fd20'
and device_id = '9aafc63f-ff77-4847-9d61-10f96c2b9a65';

select *
from jt.login_funnel_loginaction
where (lower(bundle_id) = '01c8fc94-1b91-4ee3-9e16-50f72445fd20' and lower(device_id) = '9aafc63f-ff77-4847-9d61-10f96c2b9a65') or
(lower(bundle_id) = '02205d6d-9a2d-4ace-9268-221993094920' and lower(device_id) = '2845dc66-fd79-4087-b2c2-7d904368ec26') or
(lower(bundle_id) = '04078e49-dee6-4046-9ff8-7714586de782' and lower(device_id) = '03db91d0-dc2b-4170-8987-793179735073') or
(lower(bundle_id) = '04078e49-dee6-4046-9ff8-7714586de782' and lower(device_id) = '6f691085-a726-435f-83b8-47c305eb9318') or
(lower(bundle_id) = '04078e49-dee6-4046-9ff8-7714586de782' and lower(device_id) = 'a664537e-a116-4a23-b655-331928307b56') or
(lower(bundle_id) = '04078e49-dee6-4046-9ff8-7714586de782' and lower(device_id) = 'd679f85c-472c-4232-8a99-19126bdb593a') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '0cb10a14-3d89-4b13-b877-544a16596f0b') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '173d9033-33e2-4307-b088-3c33cc21413b') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '19673476-a5f2-4cd6-9c86-5fad5b561443') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '38df10c2-0446-47ff-8fb4-f390d402d1ba') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '51395440-2280-4a8b-8009-940c269ccf11') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '6a9499d1-f5ee-4dbc-ae9e-6c9fcfda4f2c') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '794a3c59-3722-45e7-8c36-380bbbd11a44') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = '7beef99f-c66c-433d-a0ee-c01ceb7c2581') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = 'deec6b2f-e5a6-49bd-ac7b-77bfc1d860c8') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = 'f04e710b-08e3-445e-8dda-1f61591f4b0b') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = 'f6721659-b96f-444e-aa22-f07e9737ce50') or
(lower(bundle_id) = '0c388482-2a9f-43ed-a932-826f779cebb7' and lower(device_id) = 'fcdfcbef-a804-4794-a1cc-4d7c08e99a8c') or
(lower(bundle_id) = '2be18a57-56ca-4234-a027-d093f72be78c' and lower(device_id) = '2a863415-ab2e-49a2-80a7-8df9c8025ba1') or
(lower(bundle_id) = '2be18a57-56ca-4234-a027-d093f72be78c' and lower(device_id) = '3dd0bd58-c46a-4eb9-8948-468a10c296d2') or
(lower(bundle_id) = '2be18a57-56ca-4234-a027-d093f72be78c' and lower(device_id) = '91992f75-3299-470d-bb5e-2e6694b8516d') or
(lower(bundle_id) = '2be18a57-56ca-4234-a027-d093f72be78c' and lower(device_id) = 'c93bd1c3-4475-4514-9da1-880fe90a3379') or
(lower(bundle_id) = '2c631059-30ee-4a7b-b387-62c7c7d2552d' and lower(device_id) = 'b6209bff-9b55-43bb-8d8a-17f7352b8f15') or
(lower(bundle_id) = '2c631059-30ee-4a7b-b387-62c7c7d2552d' and lower(device_id) = 'f2f24817-07bd-41a4-a02b-f7507a326e5d') or
(lower(bundle_id) = '2ee83a64-b448-4028-aef5-f5a773ee3c5f' and lower(device_id) = 'fb8a9a4b-8057-4f80-8a64-7ba4e3210080') or
(lower(bundle_id) = '325651b2-9369-470d-88eb-b96923b2bf02' and lower(device_id) = 'b5040b3b-db5d-4bbf-b884-5326ff245714') or
(lower(bundle_id) = '35918a1b-a85b-421e-b217-cb5a54812693' and lower(device_id) = '500417ff-b160-4e5f-84e9-23b77d935ab5') or
(lower(bundle_id) = '38f9710a-60e5-4a08-bf4d-eab59ee0ed55' and lower(device_id) = '7df06a16-16c9-4464-81b2-ea81d2740b19') or
(lower(bundle_id) = '43b7b1be-590e-42ad-afdf-4d13ee20fe86' and lower(device_id) = '09ddb4e0-5a50-475f-ad99-71da68de4459') or
(lower(bundle_id) = '43b7b1be-590e-42ad-afdf-4d13ee20fe86' and lower(device_id) = '3357672d-ffc7-47a6-90b6-8dd1db32ab53') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = '3303e7b4-8f71-44f6-b6f2-b662ae3af583') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = '382076c9-c2bc-4142-b251-11f4185ae68c') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = '6066efa5-245e-412a-bc76-2371348155af') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = '61619813-135c-4255-b5d0-ff8202d04a1c') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = '816e721b-f7b8-4ad2-956b-c5c8cc5dd3b6') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'ad1f79ed-b617-4762-84db-61b8f6879aea') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'bfde6b01-fccd-49dc-9983-b965d238819b') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'ce1f070e-3884-4925-a512-5c42c9b2f555') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'd4feb51c-ec2f-4c6f-b6a9-074ca9171130') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'dcb4cf75-70d2-436e-be93-a360b4025553') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'e69baffe-93c0-40f3-a5c3-0b3960d24983') or
(lower(bundle_id) = '442360b8-523b-4dc4-a475-afd40d93babf' and lower(device_id) = 'f57ba862-82ce-40da-b5d4-8beeb1d9435b') or
(lower(bundle_id) = '53f473b2-4783-4a16-8185-11b462557777' and lower(device_id) = '06490319-2059-4ba2-ac31-13726fa16a98') or
(lower(bundle_id) = '53f473b2-4783-4a16-8185-11b462557777' and lower(device_id) = '849b7379-cb50-4764-b478-481ba62b3e6e') or
(lower(bundle_id) = '57cbbc2d-6039-4874-8760-50b3e058dd6c' and lower(device_id) = '9d13d5ef-e245-4fd7-ba53-a2d5029f2c22') or
(lower(bundle_id) = '5b1f2920-3ab7-4419-a7f6-1eef005ac27c' and lower(device_id) = 'a5fb7f26-0e3d-4ad4-a944-4757ad6c8781') or
(lower(bundle_id) = '5e6e5f8e-8010-422e-a8f7-f00131f299fc' and lower(device_id) = '2366efe8-d581-4225-9001-b182f00a8660') or
(lower(bundle_id) = '5e6e5f8e-8010-422e-a8f7-f00131f299fc' and lower(device_id) = '4e7b0b3a-ca94-461b-b7dd-d627aca225b0') or
(lower(bundle_id) = '5e6e5f8e-8010-422e-a8f7-f00131f299fc' and lower(device_id) = '9a82d4d3-8b19-4f67-9a7b-d413065f6f26') or
(lower(bundle_id) = '5e6e5f8e-8010-422e-a8f7-f00131f299fc' and lower(device_id) = 'e201da45-5b55-4f67-ad93-b71e25601b74') or
(lower(bundle_id) = '5e6e5f8e-8010-422e-a8f7-f00131f299fc' and lower(device_id) = 'e7dbae8f-6f0c-4771-a14a-e4fb910ed940') or
(lower(bundle_id) = '641e2d2d-08d5-4bdb-a3a5-f578b18d3b8c' and lower(device_id) = '4136cd8a-01ea-43a8-8979-603b09e0c510') or
(lower(bundle_id) = '6f8c72a9-0b14-4630-abc5-3276768acb68' and lower(device_id) = '093349b6-5f74-46e2-8f1d-1d05eb5674c3') or
(lower(bundle_id) = '6f8c72a9-0b14-4630-abc5-3276768acb68' and lower(device_id) = '21bb6ad6-d5fb-4afb-bec0-ecf80f941250') or
(lower(bundle_id) = '6f8c72a9-0b14-4630-abc5-3276768acb68' and lower(device_id) = '33f48bf8-6f62-4b30-9594-f01f07d2381d') or
(lower(bundle_id) = '6f8c72a9-0b14-4630-abc5-3276768acb68' and lower(device_id) = '74bafc1b-c3f7-48a2-a35a-fe03533399b3') or
(lower(bundle_id) = '73c19375-9624-47a8-a975-63f620cd04e2' and lower(device_id) = 'd26e448e-507d-4539-a326-7e93bf58c92a') or
(lower(bundle_id) = '814eb91c-9796-4323-91b0-5ac358c13577' and lower(device_id) = 'df019ffb-92bf-4afa-b783-a4edb5226dc9') or
(lower(bundle_id) = '84457321-62e5-4c32-bc4b-32cdc55c45c5' and lower(device_id) = '9db557b6-2e2a-4a89-81eb-6ca6b07e8cf7') or
(lower(bundle_id) = '8d983f0f-c1e7-468a-8e83-5a40fcc4dc61' and lower(device_id) = 'd7b01182-8737-4362-ab73-66afa4280b70') or
(lower(bundle_id) = '947ea0f7-fdac-4169-9256-a6e012c33d94' and lower(device_id) = '2d9a902c-29eb-4c37-933f-5fdb7fca160a') or
(lower(bundle_id) = '96332da5-d337-44e6-b41e-63d346deece2' and lower(device_id) = '7e9c0c6b-c5b8-4c11-ba96-eb83622378bf') or
(lower(bundle_id) = '96332da5-d337-44e6-b41e-63d346deece2' and lower(device_id) = 'f2370494-07da-4f26-a74c-e4ea47f26312') or
(lower(bundle_id) = '9789277a-246b-47df-b64e-37dbd74b0843' and lower(device_id) = '529a0be2-5a13-4100-b78b-b365a93630fa') or
(lower(bundle_id) = '9c44c4f1-72bf-4c20-893b-bc828c4056a2' and lower(device_id) = '48448842-d67c-44f9-8282-5bc55c2f2bf9') or
(lower(bundle_id) = '9ce44861-1e7d-4128-b04e-a2447327a5e7' and lower(device_id) = '241dc477-c444-44f8-8634-06f4d020220b') or
(lower(bundle_id) = '9ce44861-1e7d-4128-b04e-a2447327a5e7' and lower(device_id) = '88fd4c28-7867-4d40-8e8e-f8a0e0bac628') or
(lower(bundle_id) = '9ce44861-1e7d-4128-b04e-a2447327a5e7' and lower(device_id) = '9f80591f-09c6-406c-9c08-0d61a677e724') or
(lower(bundle_id) = '9ce44861-1e7d-4128-b04e-a2447327a5e7' and lower(device_id) = 'd64a92e8-f7a5-4548-807d-f0de3017b581') or
(lower(bundle_id) = '9ce44861-1e7d-4128-b04e-a2447327a5e7' and lower(device_id) = 'fed00403-825f-4963-abaa-985732668ca8') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '093e6509-b704-4b55-b915-592dbf005707') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '1361fb94-7e31-44fe-87b3-ec5be9c0bfa8') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '1b2f702d-b727-44d2-b5fa-5d921e022430') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '3198e645-8944-4565-ad64-51bcab34b128') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '41434ac3-65a8-4023-859f-7692e8e25ee8') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '4c26b616-cc4e-4335-a9aa-473691e5afb5') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '59101a77-5f6c-4cbc-a4bd-8f0776773386') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '60e0b248-2bb3-4a41-898c-0580ee85274b') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '70e1c015-53f3-4ac3-98b9-cf8817bf0237') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = '8c6d4bbb-5829-4142-b42f-6b7d38e053af') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = 'a613b702-a93e-4f9c-9d35-f8535fd0f18c') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = 'ca9d592b-f2a2-42d6-8701-c165c7a42964') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = 'e816d843-e417-47f7-9422-db8742fdef47') or
(lower(bundle_id) = 'a1376e10-70dd-4a9b-911f-4354092c782f' and lower(device_id) = 'f3b9b31d-e99c-4b0d-9355-c78f6eb0b86a') or
(lower(bundle_id) = 'a2fb5ade-bf91-47b1-84dc-e2942e9aeab0' and lower(device_id) = '59d0a81f-e15a-4e27-bc51-47009c97b4e0') or
(lower(bundle_id) = 'a5f5917c-5a59-4975-b3c5-8410599c3744' and lower(device_id) = '9cdffb15-2c47-47d1-b625-1a66cf4fc43e') or
(lower(bundle_id) = 'a5f5917c-5a59-4975-b3c5-8410599c3744' and lower(device_id) = 'c5b8aec8-5867-4a6c-a336-96881d7f14db') or
(lower(bundle_id) = 'a8e0d778-e0de-4c97-93ad-86d9138dbc23' and lower(device_id) = 'af95d4c2-c11f-4dd7-9324-42a097fb97f8') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '19cf5a53-1223-46e2-b28e-1c717e8fbde5') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '1f231d6b-4bf0-494d-aa64-6bcf5e0998ad') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '3c4e22c5-8346-4b18-bd22-058bd0438a3f') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '3c6d4154-9ed4-4f5e-bfac-0f78ad7774d6') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '554ac966-cb16-4570-9efd-6737a09b6f07') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '5621e5f9-2967-4128-a8ac-e29f3e143ed9') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '638d1935-b5bb-4ee2-b186-4dfd6a1eb69b') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '70a8259b-cdd3-4adc-82fe-2e26b4e94280') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = '84a75b69-cbbd-464c-9664-a372828ddb0f') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = 'b9a8fe7a-ddd1-45f9-b244-4cee5dbf5d7f') or
(lower(bundle_id) = 'adf7e68b-47d5-46f3-8bea-7f417bca0052' and lower(device_id) = 'd643bfbd-ad86-4443-94b2-c3785f07930b') or
(lower(bundle_id) = 'b07d533a-5f60-45c5-abb4-e8f0f17a3392' and lower(device_id) = 'd2672b11-3814-4f8c-8619-ad548ebef586') or
(lower(bundle_id) = 'b1c5f14b-4101-41f4-964b-ddc8ad042ee9' and lower(device_id) = '2e7a81b6-769a-4b24-ada4-0db8f59852e3') or
(lower(bundle_id) = 'b85bd2d3-e0b1-4778-a17d-a7c42a64ce7b' and lower(device_id) = '2de5ace0-4ddd-483e-94f5-c60d2e65cb87') or
(lower(bundle_id) = 'b85bd2d3-e0b1-4778-a17d-a7c42a64ce7b' and lower(device_id) = '5f8ea85f-4a35-4894-9966-0c61bccb9aa5') or
(lower(bundle_id) = 'b85bd2d3-e0b1-4778-a17d-a7c42a64ce7b' and lower(device_id) = 'e9cb2bcf-4107-4ac6-801d-0b41d5ba1610') or
(lower(bundle_id) = 'c6c367d3-3e89-4c0c-86dc-254b14fc19e0' and lower(device_id) = '27831904-c14e-4d54-bd45-874a900c340a') or
(lower(bundle_id) = 'c6c367d3-3e89-4c0c-86dc-254b14fc19e0' and lower(device_id) = '5becbb36-2579-4306-99a2-5805baaf021b') or
(lower(bundle_id) = 'c9cc093e-80a2-4d71-9cfe-b3e8983b976e' and lower(device_id) = '4242db34-c074-422b-acf9-d47d9c6879ac') or
(lower(bundle_id) = 'd9481981-605b-4801-b8cd-16bb374b63ce' and lower(device_id) = '99751cbc-1336-4baf-acad-c57cd2db095e') or
(lower(bundle_id) = 'f145f158-d875-4f7e-bb08-ca98083178a7' and lower(device_id) = '39f783f2-098a-4619-9b6e-7c362c45c02f');

select *
from fact_actions
where lower(bundle_id) = '01c8fc94-1b91-4ee3-9e16-50f72445fd20'
and lower(device_id) = '9aafc63f-ff77-4847-9d61-10f96c2b9a65'
and cast(created as date) = '2015-07-17';



/* iOS Exceptions */

select *
from jt.login_funnel_ios_granular
where profilefillerviewflag = 1
and final_global_user_id is null;
-- 1


select *
from jt.login_funnel_ios_granular
where profilefillerviewflag = 0
and final_global_user_id is not null;
-- 153

select bundle_id
     , count(*)
from jt.login_funnel_ios_granular
where bundle_event_cnt >= 2
and eventpickerviewflag = 0
and profilefillerviewflag = 1
group by 1
order by 2 desc;



























------------------ Old -----------------------
select *
from jt.login_funnel_spine_events_views
where device_id = '00000bf2-6e6f-430c-bdc3-060e41797aa5'
and bundle_id = '13ba26b4-e51a-4ffb-86b2-94dfc2b53ede';

select device_id
     , bundle_id
from (
select device_id
     , bundle_id
     , final_global_user_id
from jt.login_funnel_spine_events_views
group by 1,2,3) a
group by 1,2
having count(*) > 1;


select app_type_id
     , 'view' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginview 
where lower(device_id) = '562f0e84-8ec5-4a55-93f0-7d17dcae0455'
union
select app_type_id
     , 'action' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginaction 
where lower(device_id) = '562f0e84-8ec5-4a55-93f0-7d17dcae0455'
order by created;













select count(*)
     , count(case when device_cnt >= 2 then 1 else null end)
     , count(case when device_cnt >= 2 then 1 else null end)::decimal(12,4)/count(*)::decimal(12,4)
from (
select bundle_id
     , device_id
     , count(*) as device_cnt
from (select distinct bundle_id
           , device_id
           , global_user_id
      from jt.login_funnel_spine_p2
      where reg_user_flag = 1
      and isdisabled = 0) a
group by 1,2) a;
-- 449,520
-- 7200 (1.6% of all unique bundle app/device combination with more than one registered users)

-- 441,704
-- 5,765 (1.3% of all unique app/device combinations with more than one non-disabled registered users)




select *
from jt.login_funnel_spine_p2
where device_id = '6eb4a97b-b5f0-4d9f-a263-1a575d322c07';

select *
from jt.login_funnel_globalloginstart
where deviceid = '6eb4a97b-b5f0-4d9f-a263-1a575d322c07';

select app_type_id
     , 'view' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginview 
where device_id = '6eb4a97b-b5f0-4d9f-a263-1a575d322c07'
union
select app_type_id
     , 'action' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginaction 
where device_id = '6eb4a97b-b5f0-4d9f-a263-1a575d322c07'
order by created;



select bundle_id
     , device_id
     , count(*) as device_cnt
from jt.login_funnel_spine_p2
where reg_user_flag = 1
and bundle_id = '00202dd8-6550-4681-bc9b-a5f02420498e'
and device_id = '0f268128-0c57-4a77-bc77-a7ab17e941ae'
group by 1,2
having count(*) > 1;


select *
from jt.login_funnel_spine_p2
where bundle_id = '00202dd8-6550-4681-bc9b-a5f02420498e'
and device_id = '0f268128-0c57-4a77-bc77-a7ab17e941ae';


select bundle_id
     , device_id
     , count(*) from (
select distinct bundle_id
     , device_id
     , global_user_id
from jt.login_funnel_spine_p2
where reg_user_flag = 1) a
group by 1,2
having count(*) > 1
order by 3 desc
limit 10;



select *
from jt.login_funnel_spine_p2
where bundle_id = 'ad7972cd-90b3-4e7e-b3c3-aeca66eb50e4'
and device_id = '562f0e84-8ec5-4a55-93f0-7d17dcae0455';

select *
from authdb_applications
where lower(applicationid) = '3128084d-ee77-4224-a368-b56ef844dccb';

select *
from authdb_is_users
where lower(globaluserid) in ('5e823e73-d6c0-40f6-aecb-92d0b8c4ede6',
'5ed6ed31-8df1-4863-8093-b31e02c3331a',
'6e7282af-dca3-40e4-8cd5-3344cdc8413e',
'789ce38d-27da-4f65-879c-d43643b5563a',
'85fc6124-5fed-4d6f-90d0-5b958b1e450d',
'8a1e7601-b73b-41ed-b5a4-08b925e997bb',
'8eb19b36-f8ef-49f1-8040-1ad5a5556775',
'8eb19b36-f8ef-49f1-8040-1ad5a5556775',
'8eb19b36-f8ef-49f1-8040-1ad5a5556775',
'8eb19b36-f8ef-49f1-8040-1ad5a5556775',
'8eb19b36-f8ef-49f1-8040-1ad5a5556775',
'90a673a0-8139-40d0-885a-9a6f66421c61',
'a23e9a06-25ec-44eb-9b00-6fca42154514',
'af108630-f12f-4992-bfc8-c3d17f108f33',
'afc65673-3ad3-4c8a-8b52-036efcb64e6a',
'b4e3f457-597a-4e11-9590-19042dfc9baf',
'b6e2bf86-37b6-42a4-baf7-27a3fc339465',
'beda595c-88ec-4934-a5b3-5677288061e9',
'c62443a0-e9ad-4e80-8a39-bb4b56d90825',
'fada9922-6339-41ab-afb8-83104c7cb716',
'1642d0bb-8b09-40e1-a24a-435686308853',
'1642d0bb-8b09-40e1-a24a-435686308853',
'19e5b740-2119-4a98-a0c1-77fdb3b055b2',
'53b41042-d145-461a-86cb-2f2177bfff0a',
'5a399040-d772-48ab-991a-9773c3407a92')
and lower(applicationid) = '256521c7-f1db-44a8-b174-5290ef33a4b6';




select app_type_id
     , 'view' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginview 
where lower(device_id) = '562f0e84-8ec5-4a55-93f0-7d17dcae0455'
union
select app_type_id
     , 'action' as metric_type
     , created
     , identifier
     , bundle_id
     , application_id
     , global_user_id
from jt.login_funnel_loginaction 
where lower(device_id) = '562f0e84-8ec5-4a55-93f0-7d17dcae0455'
order by created;