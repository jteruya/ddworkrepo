library("RODBC")

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# Create a connection to the database called "channel"
con <- dbConnect(drv, dbname="analytics",host="10.223.192.6",port=5432,user="etl",password="s0.Much.Data")

# Check that connection is working (Optional)
isPostgresqlIdCurrent(con)

# Query the database and put the results into the data frame "dataframe"
device_type <- dbGetQuery(con, "
 select case
          when iphone_sessions > 0 or ipad_sessions > 0 and android_sessions = 0 and html5_sessions = 0 then 'ios'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions > 0 and html5_sessions = 0 then 'android'
          when iphone_sessions = 0 or ipad_sessions = 0 and android_sessions = 0 and html5_sessions > 0 then 'html5'
          else 'mixed'
       end as device_type
     , case
         when externalimageid is not null then 1
         else 0
       end as imageflag
from jt.pa549_active_users")


device_model.glm <- glm(imageflag ~ device_type, data = device_type)
summary(device_model.glm)


event_type <- dbGetQuery(con, "
select case
          when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
          else ecs.eventtype
       end as eventtype
                       , case
                       when externalimageid is not null then 1
                       else 0
                       end as imageflag
                       , case
                       when title is not null then 1
                       else 0
                       end as titleflag
                       , case
                       when company is not null then 1
                       else 0
                       end as companyflag
                       , case
                       when facebookuserid > 0 then 1
                       else 0
                       end as fbflag
                       , case
                       when twitterusername is not null then 1
                       else 0
                       end as twitterflag
                       , case
                       when linkedinid is not null then 1
                       else 0
                       end as linkedinflag
                       from jt.pa549_active_users users
                       join eventcube.eventcubesummary ecs
                       on users.applicationid = ecs.applicationid")

event_model_image.glm <- glm(imageflag ~ eventtype, family = binomial, data = event_type)
event_model_title.glm <- glm(titleflag ~ eventtype, family = binomial, data = event_type)
event_model_company.glm <- glm(companyflag ~ eventtype, family = binomial, data = event_type)
event_model_fb.glm <- glm(fbflag ~ eventtype, family = binomial, data = event_type)
event_model_twitter.glm <- glm(twitterflag ~ eventtype, family = binomial, data = event_type)
event_model_linkedin.glm <- glm(linkedinflag ~ eventtype, family = binomial, data = event_type)


event_reg_type <- dbGetQuery(con, "
select eventtype || '-' || reg_type as eventregtype
     , imageflag
     , titleflag
                         , companyflag
                         , fbflag
                         , twitterflag
                         , linkedinflag
                         from (
                         select case
                         when ecs.eventtype = '' or ecs.eventtype = '_Unknown' then 'Unknown'
                         else ecs.eventtype
                         end as eventtype
                         , case
                         when ecs.openevent = 0 then 'closed'
                         else 'open'
                         end as reg_type
                         , case
                         when externalimageid is not null then 1
                         else 0
                         end as imageflag
                         , case
                         when title is not null then 1
                         else 0
                         end as titleflag
                         , case
                         when company is not null then 1
                         else 0
                         end as companyflag
                         , case
                         when facebookuserid > 0 then 1
                         else 0
                         end as fbflag
                         , case
                         when twitterusername is not null then 1
                         else 0
                         end as twitterflag
                         , case
                         when linkedinid is not null then 1
                         else 0
                         end as linkedinflag
                         from jt.pa549_active_users users
                         join eventcube.eventcubesummary ecs
                         on users.applicationid = ecs.applicationid
                         ) a
                         ")

event_reg_model_image.glm <- glm(imageflag ~ eventregtype, family = binomial, data = event_reg_type)
event_reg_model_title.glm <- glm(titleflag ~ eventregtype, family = binomial, data = event_reg_type)
event_reg_model_company.glm <- glm(companyflag ~ eventregtype, family = binomial, data = event_reg_type)
event_reg_model_fb.glm <- glm(fbflag ~ eventregtype, family = binomial, data = event_reg_type)
event_reg_model_twitter.glm <- glm(twitterflag ~ eventregtype, family = binomial, data = event_reg_type)
event_reg_model_linkedin.glm <- glm(linkedinflag ~ eventregtype, family = binomial, data = event_reg_type)
