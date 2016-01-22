drop table reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015;
drop table reportingdb.dbo.jonathan_usersurveyresponses_ACMP_Change_Management_2015;
drop table reportingdb.dbo.jonathan_usersurveycube_ACMP_Change_Management_2015;
drop table reportingdb.dbo.jonathan_usersurveycube_fact_points_ACMP_Change_Management_2015;

select *
into reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015
from (select applicationid
           , name
           , surveyid
           , itemid
      from ratings.dbo.surveys
      where isdisabled = 'false'
      and applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D'
      union
      select distinct a.applicationid
           , a.name
           , b.surveyid
           , b.itemid
      from ratings.dbo.surveys a
      join ratings.dbo.surveymappings b
      on a.surveyid = b.surveyid
      where a.isdisabled = 'false'
      and b.isdisabled = 'false'
      and a.applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D') a;
      
select *
into reportingdb.dbo.jonathan_usersurveyresponses_ACMP_Change_Management_2015
from (select s.applicationid
           , r.userid
           , q.surveyid
           , r.itemid
           , r.surveyquestionoptionid questionoptionid
           , max(surveyresponseid) responseid
      from ratings.dbo.surveyresponses r
      join ratings.dbo.surveyquestions q
      on r.surveyquestionid = q.surveyquestionid
      join (select * from reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015 where itemid is not null) s
      on q.surveyid = s.surveyid
      and r.itemid = s.itemid
      where s.applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D'
      group by s.applicationid, r.userid, q.surveyid, r.itemid, r.surveyquestionoptionid
      union
      select s.applicationid
           , r.userid
           , q.surveyid
           , r.itemid
           , r.surveyquestionoptionid questionoptionid
           , max(surveyresponseid) responseid
      from ratings.dbo.surveyresponses r
      join ratings.dbo.surveyquestions q
      on r.surveyquestionid = q.surveyquestionid
      join (select * from reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015 where itemid is null) s
      on q.surveyid = s.surveyid
      where s.applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D'
      group by s.applicationid, r.userid, q.surveyid, r.itemid, r.surveyquestionoptionid) a;
      
      
      
      
      
      
select *
into reportingdb.dbo.jonathan_usersurveycube_ACMP_Change_Management_2015
from (
select
  -- User
  s.applicationid,
  u.userid,
  -- Qualified
  case when b.userid is not null and b.itemid is not null then 1 else 0 end bookmarked,
  case when c.userid is not null and c.itemid is not null then 1 else 0 end checkedin,
  -- Survey
  s.surveyid,
  s.survey,
  -- Item
  s.itemid,
  i.name as itemname,
  s.itemtype,
  -- Question
  s.questionid,
  s.question,
  s.questiontype,
  s.questiondisplayorder,
  -- Option
  s.questionoptionid,
  s.questionoption,
  s.questionoptiondisplayorder,
  -- Response
  r.responseid,
  case when r.userid is not null and r.questionoptionid is not null then 1 else 0 end responded
from
( select
    s.applicationid,
    q.surveyid,
    s.name survey,
    s.itemid,
    case
      when t.listtypeid = 1 then 'Regular'
      when t.listtypeid = 2 then 'Agenda'
      when t.listtypeid = 3 then 'Exhibitors'
      when t.listtypeid = 4 then 'Speakers'
      when t.listtypeid = 5 then 'File'
    else null
    end itemtype,
    q.surveyquestionid questionid,
    q.name question,
    y.name questiontype,
    q.displayorder+1 questiondisplayorder,
    o.surveyquestionoptionid questionoptionid,
    o.name questionoption,
    o.displayorder+1 questionoptiondisplayorder
  from ratings.dbo.surveyquestions q
  left outer join ratings.dbo.surveyquestionoptions o on q.surveyquestionid = o.surveyquestionid
  join ratings.dbo.surveyquestiontypes y on q.typeid = y.surveyquestiontypeid
  join (select * from reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015 where itemid is not null) s on q.surveyid = s.surveyid
  left outer join ratings.dbo.item i on s.itemid = i.itemid
  left outer join ratings.dbo.topic t on i.parenttopicid = t.topicid
  where s.applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D'
) s
join (select distinct userid, surveyid, itemid from jonathan_usersurveyresponses_ACMP_Change_Management_2015) u on s.surveyid = u.surveyid and s.itemid = u.itemid
left join (select distinct itemid, name from ratings.dbo.item where isdisabled = 0) i on s.itemid = i.itemid
left outer join (select distinct userid, itemid, questionoptionid, responseid from jonathan_usersurveyresponses_ACMP_Change_Management_2015) r on u.userid = r.userid and s.questionoptionid = r.questionoptionid and s.itemid = r.itemid
left outer join (select distinct userid, itemid from ratings.dbo.userfavorites where applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D' and isdisabled = 0) b on u.userid = b.userid and s.itemid = b.itemid
left outer join (select distinct userid, itemid from ratings.dbo.showups where applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D' and isdisabled = 0) c on u.userid = c.userid and s.itemid = c.itemid

union

select
  -- User
  s.applicationid,
  u.userid,
  -- Qualified
  null as bookmarked,
  null as checkedin,
  -- Survey
  s.surveyid,
  s.survey,
  -- Item
  s.itemid,
  null as itemname,
  s.itemtype,
  -- Question
  s.questionid,
  s.question,
  s.questiontype,
  s.questiondisplayorder,
  -- Option
  s.questionoptionid,
  s.questionoption,
  s.questionoptiondisplayorder,
  -- Response
  r.responseid,
  case when r.userid is not null and r.questionoptionid is not null then 1 else 0 end responded
from
( select
    s.applicationid,
    q.surveyid,
    s.name survey,
    s.itemid,
    null as itemtype,
    q.surveyquestionid questionid,
    q.name question,
    y.name questiontype,
    q.displayorder+1 questiondisplayorder,
    o.surveyquestionoptionid questionoptionid,
    o.name questionoption,
    o.displayorder+1 questionoptiondisplayorder
  from ratings.dbo.surveyquestions q
  left outer join ratings.dbo.surveyquestionoptions o on q.surveyquestionid = o.surveyquestionid
  join ratings.dbo.surveyquestiontypes y on q.typeid = y.surveyquestiontypeid
  join (select * from reportingdb.dbo.jonathan_usersurveyuniquesurveyitem_ACMP_Change_Management_2015 where itemid is null) s on q.surveyid = s.surveyid
  where s.applicationid = 'C5FF303D-E312-4795-B37F-8918A7892A9D'
) s
join (select distinct userid, surveyid from jonathan_usersurveyresponses_ACMP_Change_Management_2015 where itemid is null) u on s.surveyid = u.surveyid
left outer join (select distinct userid, itemid, questionoptionid, responseid from jonathan_usersurveyresponses_ACMP_Change_Management_2015 where itemid is null) r on u.userid = r.userid and s.questionoptionid = r.questionoptionid) a;   


select surveyid
     , survey
     , itemid
     , itemname
     , question_num
     , questionid
     , question
     , questionoptionid
     , option_num
     , questionoption
     , points
     , pct_of_responses
     , count_of_responses
     , (points * count_of_responses) as total_points
into reportingdb.dbo.jonathan_usersurveycube_fact_points_ACMP_Change_Management_2015
from (
select distinct surveyid
     , survey
     , itemid
     , itemname
     , questiondisplayorder+1 question_num
     , questionid
     , question
     , questionoptionid
     , questionoptiondisplayorder+1 option_num
     , questionoption
     , case
         when questionid = 134721 and questionoptionid = 489325 then 5
         when questionid = 134721 and questionoptionid = 489326 then 4
         when questionid = 134721 and questionoptionid = 489327 then 3
         when questionid = 134721 and questionoptionid = 489328 then 1
         when questionid = 134721 and questionoptionid = 489329 then 0
         when questionid = 134722 and questionoptionid = 489330 then 5
         when questionid = 134722 and questionoptionid = 489331 then 4
         when questionid = 134722 and questionoptionid = 489332 then 3
         when questionid = 134722 and questionoptionid = 489333 then 1
         when questionid = 134722 and questionoptionid = 489334 then 0
         when questionid = 134723 and questionoptionid = 489335 then 5
         when questionid = 134723 and questionoptionid = 489336 then 3
         when questionid = 134723 and questionoptionid = 489337 then 2
         when questionid = 134723 and questionoptionid = 489338 then 0
         when questionid = 134724 and questionoptionid = 489339 then 5
         when questionid = 134724 and questionoptionid = 489340 then 4
         when questionid = 134724 and questionoptionid = 489341 then 3
         when questionid = 134724 and questionoptionid = 489342 then 1
         when questionid = 134724 and questionoptionid = 489343 then 0
         else -1
       end as points
     , case
         when sum(responded) over (partition by survey, itemid, question) = 0 then 0.0
         else 1.0*sum(responded) over (partition by survey, itemid, question, questionoption)/sum(responded) over (partition by survey, itemid, question)
       end pct_of_responses
     , sum(responded) over (partition by survey, itemid, question, questionoption) count_of_responses
from reportingdb.dbo.jonathan_usersurveycube_ACMP_Change_Management_2015
where questiontype = 'Multiple Choice'
and surveyid = 23875
and itemid is not null) a; 



select *
from reportingdb.dbo.jonathan_usersurveycube_fact_points_ACMP_Change_Management_2015;



select itemid
     , itemname
     , sum(count_of_responses) as total_responses
     , cast(cast(sum(case when questionid = 134721 then total_points else 0 end) as decimal(12,4))/cast(sum(case when questionid = 134721 then count_of_responses else 0 end) as decimal(12,4)) as decimal(2,1)) as "How would you rate the presentation skills, audience engagement and interaction of this session?"
     , cast(cast(sum(case when questionid = 134722 then total_points else 0 end) as decimal(12,4))/cast(sum(case when questionid = 134722 then count_of_responses else 0 end) as decimal(12,4)) as decimal(2,1)) as "How would you rate the topic knowledge of the speaker?"
     , cast(cast(sum(case when questionid = 134723 then total_points else 0 end) as decimal(12,4))/cast(sum(case when questionid = 134723 then count_of_responses else 0 end) as decimal(12,4)) as decimal(2,1)) as "Was your time in this session valuable, did you leave with a take-away that you can apply?"
     , cast(cast(sum(case when questionid = 134724 then total_points else 0 end) as decimal(12,4))/cast(sum(case when questionid = 134724 then count_of_responses else 0 end) as decimal(12,4)) as decimal(2,1)) as "Is this a topic you would like to learn more about in the future?"
from reportingdb.dbo.jonathan_usersurveycube_fact_points_ACMP_Change_Management_2015
group by itemid, itemname
order by itemid;
