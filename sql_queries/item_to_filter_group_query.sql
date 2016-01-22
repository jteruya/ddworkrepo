select *
from ratings.dbo.filtergroups
where applicationid = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and isdisabled = 'false'
and name = 'Categories';

select top 10 *
from ratings.dbo.filters;

select top 10 *
from ratings.dbo.item;

select top 10 *
from ratings.dbo.topic;

select top 10 *
from ratings.dbo.item;

select top 10 *
from ratings.dbo.itemfiltermappings;

// How to combine item and filter groups //

select t.topicid
     , i.itemid
     , f.filterid
     , t.listtypeid
     , t.name as topicname
     , i.name as itemname
     , f.name as filtername
     , g.name as categoryfiltername
from ratings.dbo.topic t
join ratings.dbo.item i
on t.topicid = i.parenttopicid
join ratings.dbo.itemfiltermappings m
on i.itemid = m.itemid
join ratings.dbo.filters f
on m.filterid = f.filterid
join ratings.dbo.filtergroups g
on g.topicid = t.topicid and f.filtergroupid = g.filtergroupid
where t.listtypeid = 3
and t.applicationid = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and i.applicationid = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and g.applicationid = '45ec741e-fcd2-4bc3-8b47-36bfd60d59a1'
and f.isdisabled = 'false'
and m.isdisabled = 'false'
and g.isdisabled = 'false'
and i.isdisabled = 0
and t.isdisabled = 0
and g.name = 'Categories'
order by 7,6;
