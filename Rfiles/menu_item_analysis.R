require("RPostgreSQL")
require("ggplot2")
library("plyr")
library("reshape2")
library("scales")
library("cowplot")
library("gtable")

# Establish Connection to Robin using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "analytics", host="10.223.192.6", port = "5432", user = "etl", password = "s0.Much.Data")

# Total Users/Taps 


# Click Rate Order Analysis
gridItem <- dbGetQuery(con, "SELECT GridIndex
                                  , CASE
                                      WHEN GridIndex = -2 THEN 'Profile Button'
                                      WHEN GridIndex = -1 THEN 'Notifications Button'
                                      WHEN GridIndex = 0 THEN '1st Menu Item'
                                      WHEN GridIndex = 1 THEN '2nd Menu Item'
                                      WHEN GridIndex = 2 THEN '3rd Menu Item'
                                      WHEN GridIndex = 3 THEN '4th Menu Item'
                                      WHEN GridIndex = 4 THEN '5th Menu Item'
                                      WHEN GridIndex = 5 THEN '6th Menu Item'
                                      WHEN GridIndex = 6 THEN '7th Menu Item'
                                      WHEN GridIndex = 7 THEN '8th Menu Item'
                                      WHEN GridIndex = 8 THEN '9th Menu Item'
                                      WHEN GridIndex = 9 THEN '10th Menu Item'
                                    END AS Position
                                  , '''' || regexp_replace(Title, '''', '', 'g') || '''' AS Title
                                  , MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS Pct
                                  , MENU_ITEMS.OneTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS OneTapPct 
                                  , MENU_ITEMS.TwoTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoTapPct 
                                  , MENU_ITEMS.ThreeTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeTapPct 
                                  , MENU_ITEMS.FourTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FourTapPct 
                                  , MENU_ITEMS.FiveTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveTapPct 
                                  , MENU_ITEMS.FiveOrMoreTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveOrMoreTapPct 
                                  , (MENU_ITEMS.TwoTapUserCnt + MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoOrMorePct
                                  , (MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeOrMorePct
                                  , (MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FourOrMorePct
                                  , EVENTS.OpenEvent
                                  , EVENTS.EventType
                                  , EVENTS.Adoption
                                  , EVENTS.Sessions/EVENTS.UsersActive AS SessionsPerUser
                                  , EVENTS.ApplicationId
                                  , MENU_ITEMS.TapCnt
                                  , COUNT(*) OVER (PARTITION BY EVENTS.ApplicationId) AS AgendaCnt
                             FROM JT.MenuItemTopicTaps MENU_ITEMS
                             JOIN JT.MenuEvents EVENTS
                             ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
                             WHERE EVENTS.UsersActive > 0 AND EVENTS.UsersActive >= MENU_ITEMS.UserCnt
                             AND GridIndex <= 9
                       ;")

# Everything Analysis (Grid Only)
#gridMedian <- aggregate(gridItem[,4], gridItem[1], median)
#gridMean <- aggregate(gridItem[,4], gridItem[1], mean)
gridCount <- aggregate(gridItem[,4], gridItem[1], length)
gridQuantile <- aggregate(gridItem[,4], gridItem[1], quantile)
gridSummary <- cbind(gridQuantile, gridCount[,2])



# Plot (% of Active Users vs. Grid Item Index)
plot <- ggplot(gridItem[,], aes(factor(position, c("Profile Button", "Notifications Button", "1st Menu Item", "2nd Menu Item", "3rd Menu Item", "4th Menu Item", "5th Menu Item", "6th Menu Item", "7th Menu Item", "8th Menu Item", "9th Menu Item", "10th Menu Item"), ordered = FALSE), pct), main = "Box Plot: % of Active Users vs Grid Index", xlab = "Grid Index", ylab = "% of Active Users")
scatterplot <- plot + geom_boxplot(fill = "blue", colour = "blue") + geom_jitter() + ggtitle("% of Active Users Clicked vs Menu Order\n") + ylab("% of Active Users Clicked\n") + xlab("\nMenu Item Order") + scale_y_continuous(labels=percent) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
boxplot <- plot + geom_boxplot(colour = "blue") + ggtitle("% of Active Users Clicked vs Menu Order\n") + ylab("% of Active Users Clicked\n") + xlab("\nMenu Item Order") + scale_y_continuous(labels=percent) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
scatterplot
boxplot

# Plot: Where do users tap (All Users and Repeat Users only >= 2 taps)?
gridMedian <- aggregate(gridItem[,c(4,11,12,13,10)], gridItem[2], median)
plot2 <- ggplot(gridMedian, aes(factor(position, c("Profile Button", "Notifications Button", "1st Menu Item", "2nd Menu Item", "3rd Menu Item", "4th Menu Item", "5th Menu Item", "6th Menu Item", "7th Menu Item", "8th Menu Item", "9th Menu Item", "10th Menu Item"), ordered = FALSE))) + geom_line(aes(y = pct, colour = "All Active Users", group = 1)) + geom_line(aes(y = twoormorepct, colour = "All Active Users w/ >= 2 Clicks", group = 1)) + geom_line(aes(y = threeormorepct, colour = "All Active Users w/ >= 3 Clicks", group = 1)) + geom_line(aes(y = fourormorepct, colour = "All Active Users w/ >= 4 Clicks", group = 1)) + geom_line(aes(y = fiveormoretappct, colour = "All Active Users w/ >= 5 Clicks", group = 1)) 
plot2 <- plot2 + ggtitle("Median % of Active Users Clicked \nvs Menu Order (Repeat Users)\n") + ylab("Median % of Active Users Clicked\n") + xlab("\nMenu Item Order") + scale_y_continuous(labels=percent) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
plot2

# Micro App Specific Analysis
catGridItem <- dbGetQuery(con, "SELECT MENU_ITEMS.TypeId
                                     , CASE
                                         WHEN MENU_ITEMS.TypeId = 2 THEN MENU_ITEMS.ListTypeId
                                         ELSE NULL
                                       END AS ListTypeId
                                     , CASE
                                          WHEN MENU_ITEMS.TypeId = 1 THEN 'Custom Event Items'
                                          WHEN MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId = 1 THEN 'Event Info'
                                          WHEN MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId = 2 THEN 'Agenda'
                                          WHEN MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId = 3 THEN 'Exhibitor'
                                          WHEN MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId = 4 THEN 'Speakers'
                                          WHEN MENU_ITEMS.TypeId = 4 THEN 'Downloads'
                                          WHEN MENU_ITEMS.TypeId = 3 THEN 'Subject Event'
                                          WHEN MENU_ITEMS.TypeId = 5 THEN 'Activity Feed'
                                          WHEN MENU_ITEMS.TypeId = 6 THEN 'Leaderboard'
                                          WHEN MENU_ITEMS.TypeId = 7 THEN 'Favorites'
                                          WHEN MENU_ITEMS.TypeId = 8 THEN 'Attendees'
                                          WHEN MENU_ITEMS.TypeId = 9 THEN 'External Website'
                                          WHEN MENU_ITEMS.TypeId = 10 THEN 'Map'
                                          WHEN MENU_ITEMS.TypeId = 11 THEN 'Photo Feed'
                                          WHEN MENU_ITEMS.TypeId = 12 THEN 'Survey'
                                          WHEN MENU_ITEMS.TypeId = 13 THEN 'App By DoubleDutch'
                                          WHEN MENU_ITEMS.TypeId = 14 THEN 'Leads'
                                          WHEN MENU_ITEMS.TypeId = 15 THEN 'QRCodeScanner'
                                          WHEN MENU_ITEMS.TypeId = 16 THEN 'Update'
                                          WHEN MENU_ITEMS.TypeId = 17 THEN 'Profile'
                                          WHEN MENU_ITEMS.TypeId = 18 THEN 'Exhibitior Dashboard'
                                          WHEN MENU_ITEMS.TypeId = 19 THEN 'Poll'
                                          WHEN MENU_ITEMS.TypeId = 20 THEN 'Targeted Offers'
                                          WHEN MENU_ITEMS.TypeId = 200 THEN 'Settings'
                                          WHEN MENU_ITEMS.TypeId = 201 THEN 'Badges'
                                          WHEN MENU_ITEMS.TypeId = 205 THEN 'Messages'
                                          WHEN MENU_ITEMS.TypeId = 206 THEN 'Channels'
                                          WHEN MENU_ITEMS.TypeId = 207 THEN 'Meetings'
                                      ELSE NULL
                                      END AS MicroAppCat
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 0 THEN 1 ELSE NULL END) AS \"1st Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 1 THEN 1 ELSE NULL END) AS \"2nd Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 2 THEN 1 ELSE NULL END) AS \"3rd Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 3 THEN 1 ELSE NULL END) AS \"4th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 4 THEN 1 ELSE NULL END) AS \"5th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 5 THEN 1 ELSE NULL END) AS \"6th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 6 THEN 1 ELSE NULL END) AS \"7th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 7 THEN 1 ELSE NULL END) AS \"8th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 8 THEN 1 ELSE NULL END) AS \"9th Menu Item\"
                                    , COUNT(CASE WHEN MENU_ITEMS.GridIndex = 9 THEN 1 ELSE NULL END) AS \"10th Menu Item\"
                          FROM JT.MenuItemTopicTaps MENU_ITEMS
                          JOIN JT.MenuEvents EVENTS
                          ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
                          WHERE MENU_ITEMS.TypeId IS NOT NULL
                          AND MENU_ITEMS.TypeId NOT IN (-3, -2)
                          AND (MENU_ITEMS.TypeId <> 2 OR (MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId IS NOT NULL))
                          GROUP BY 1,2,3
                          HAVING COUNT(CASE WHEN MENU_ITEMS.GridIndex <= 9 THEN 1 ELSE NULL END) >= 200
                          ;")

# Heatmap
catGridItem <- catGridItem[order(catGridItem$typeid, catGridItem$listtypeid),]
catGridItem.m <- melt(catGridItem[,c(3:13)])
#catGridItem.m <- ddply(catGridItem.m, .(variable, variable), transform, rescale = rescale(value))
catGridItem.m <- ddply(catGridItem.m, .(variable), transform, rescale = rescale(value))
heatmap <- ggplot(catGridItem.m, aes(variable, microappcat)) + geom_tile(aes(fill = rescale),colour = "white") + geom_text(aes(label = catGridItem.m$value)) + scale_fill_gradient(low = "white",high = "steelblue") + ggtitle("How are Content Categories Organized in\n our Navigation Menu Across Events?\n") + ylab("Common Content Categories\n") + xlab("\nMenu Item Order") + ylim(rev(levels(factor(catGridItem.m$microappcat)))) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
heatmap

# Median % of users content
catGridUserItem <- dbGetQuery(con, "SELECT SPINE.TypeId
                                     , CASE
                              WHEN SPINE.TypeId = 2 THEN SPINE.ListTypeId
                              ELSE NULL
                              END AS ListTypeId
                              , SPINE.GridIndex
                              , CASE 
                                  WHEN SPINE.GridIndex = 0 THEN '1st Menu Item'
                                  WHEN SPINE.GridIndex = 1 THEN '2nd Menu Item'
                                  WHEN SPINE.GridIndex = 2 THEN '3rd Menu Item'
                                  WHEN SPINE.GridIndex = 3 THEN '4th Menu Item'
                                  WHEN SPINE.GridIndex = 4 THEN '5th Menu Item'
                                  WHEN SPINE.GridIndex = 5 THEN '6th Menu Item'
                                  WHEN SPINE.GridIndex = 6 THEN '7th Menu Item'
                                  WHEN SPINE.GridIndex = 7 THEN '8th Menu Item'
                                  WHEN SPINE.GridIndex = 8 THEN '9th Menu Item'
                                  WHEN SPINE.GridIndex = 9 THEN '10th Menu Item'
                                  ELSE NULL
                              END AS Position
                              , CASE
                              WHEN SPINE.TypeId = 1 THEN 'Custom Event Items'
                              WHEN SPINE.TypeId = 2 AND SPINE.ListTypeId = 1 THEN 'Event Info'
                              WHEN SPINE.TypeId = 2 AND SPINE.ListTypeId = 2 THEN 'Agenda'
                              WHEN SPINE.TypeId = 2 AND SPINE.ListTypeId = 3 THEN 'Exhibitor'
                              WHEN SPINE.TypeId = 2 AND SPINE.ListTypeId = 4 THEN 'Speakers'
                              WHEN SPINE.TypeId = 4 THEN 'Downloads'
                              WHEN SPINE.TypeId = 3 THEN 'Subject Event'
                              WHEN SPINE.TypeId = 5 THEN 'Activity Feed'
                              WHEN SPINE.TypeId = 6 THEN 'Leaderboard'
                              WHEN SPINE.TypeId = 7 THEN 'Favorites'
                              WHEN SPINE.TypeId = 8 THEN 'Attendees'
                              WHEN SPINE.TypeId = 9 THEN 'External Website'
                              WHEN SPINE.TypeId = 10 THEN 'Map'
                              WHEN SPINE.TypeId = 11 THEN 'Photo Feed'
                              WHEN SPINE.TypeId = 12 THEN 'Survey'
                              WHEN SPINE.TypeId = 13 THEN 'App By DoubleDutch'
                              WHEN SPINE.TypeId = 14 THEN 'Leads'
                              WHEN SPINE.TypeId = 15 THEN 'QRCodeScanner'
                              WHEN SPINE.TypeId = 16 THEN 'Update'
                              WHEN SPINE.TypeId = 17 THEN 'Profile'
                              WHEN SPINE.TypeId = 18 THEN 'Exhibitior Dashboard'
                              WHEN SPINE.TypeId = 19 THEN 'Poll'
                              WHEN SPINE.TypeId = 20 THEN 'Targeted Offers'
                              WHEN SPINE.TypeId = 200 THEN 'Settings'
                              WHEN SPINE.TypeId = 201 THEN 'Badges'
                              WHEN SPINE.TypeId = 205 THEN 'Messages'
                              WHEN SPINE.TypeId = 206 THEN 'Channels'
                              WHEN SPINE.TypeId = 207 THEN 'Meetings'
                              ELSE NULL
                              END AS MicroAppCat
                              , PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY MENU_ITEMS.UserCnt::DECIMAL(12,4)/MENU_ITEMS.UsersActive::DECIMAL(12,4)) AS MedianPct
                              FROM (SELECT *
                              FROM (SELECT DISTINCT GridIndex
                              FROM JT.MenuItemTopicTaps
                              WHERE GridIndex >= 0 AND GridIndex <= 9
                              ) ALL_INDEX
                              JOIN (SELECT TypeId, CASE WHEN TypeId = 2 THEN ListTypeId ELSE NULL END AS ListTypeId
                              FROM JT.MenuItemTopicTaps
                              WHERE GridIndex >= 0 AND GridIndex <= 9
                              GROUP BY 1,2
                              HAVING COUNT(*) >= 200
                              ) ALL_TYPES
                              ON 1 = 1
                              ) SPINE
                              LEFT JOIN (SELECT MENU_ITEMS.*
                              , EVENTS.UsersActive
                              FROM JT.MenuItemTopicTaps MENU_ITEMS
                              JOIN JT.MenuEvents EVENTS
                              ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
                              WHERE MENU_ITEMS.TypeId IS NOT NULL
                              AND MENU_ITEMS.TypeId NOT IN (-3, -2)
                              AND (MENU_ITEMS.TypeId <> 2 OR (MENU_ITEMS.TypeId = 2 AND MENU_ITEMS.ListTypeId IS NOT NULL))
                              AND EVENTS.UsersActive > 0 AND EVENTS.UsersActive >= MENU_ITEMS.UserCnt
                              AND MENU_ITEMS.GridIndex <= 9
                              ) MENU_ITEMS
                              ON (MENU_ITEMS.TypeId = 2 AND SPINE.TypeId = MENU_ITEMS.TypeId AND SPINE.ListTypeId = MENU_ITEMS.ListTypeId AND SPINE.GridIndex = MENU_ITEMS.GridIndex) OR (MENU_ITEMS.TypeId <> 2 AND SPINE.TypeId = MENU_ITEMS.TypeId AND SPINE.GridIndex = MENU_ITEMS.GridIndex)                  
                              GROUP BY 1,2,3,4,5
                               ;")

# Heatmap 3
catGridUserItem <- catGridUserItem[order(catGridUserItem$typeid, catGridUserItem$listtypeid),]

catGridUserItem <- ddply(catGridUserItem, .(microappcat), transform, rescale = rescale(medianpct))
#heatmap2 <- ggplot(catGridUserItem, aes(position, microappcat)) + geom_tile(aes(fill = rescale),colour = "white") + geom_text(aes(label = round(catGridUserItem$medianpct * 100,2)), na.rm = TRUE) + scale_fill_gradient(low = "white",high = "steelblue") + ggtitle("How are Content Categories Organized in\n our Navigation Menu Across Events?\n") + ylab("Common Content Categories\n") + xlab("\nMenu Item Order") + ylim(rev(levels(factor(catGridUserItem$microappcat)))) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
#heatmap2

heatmap3 <- ggplot(catGridUserItem, aes(factor(position, c("1st Menu Item", "2nd Menu Item", "3rd Menu Item", "4th Menu Item", "5th Menu Item", "6th Menu Item", "7th Menu Item", "8th Menu Item", "9th Menu Item", "10th Menu Item"), ordered = FALSE), microappcat)) + geom_tile(aes(fill = rescale),colour = "white") + geom_text(aes(label = round(catGridUserItem$medianpct * 100,2)), na.rm = TRUE) + scale_fill_gradient(low = "white",high = "steelblue") + ggtitle("What are users clicking on (Median % Active Users)\n") + ylab("Common Content Categories\n") + xlab("\nMenu Item Order") + ylim(rev(levels(factor(catGridUserItem$microappcat)))) + theme(axis.text.x = element_text(angle = 45, hjust = 1))
heatmap3  
    


# Agenda Analysis
# agendaGridItem <- dbGetQuery(con, "SELECT GridIndex
#                                   , '''' || regexp_replace(Title, '''', '', 'g') || '''' AS Title
#                                   , MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS Pct
#                                   , MENU_ITEMS.OneTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS OneTapPct 
#                                   , MENU_ITEMS.TwoTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoTapPct 
#                                   , MENU_ITEMS.ThreeTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeTapPct 
#                                   , MENU_ITEMS.FourTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FourTapPct 
#                                   , MENU_ITEMS.FiveTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveTapPct 
#                                   , MENU_ITEMS.FiveOrMoreTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveOrMoreTapPct 
#                                   , (MENU_ITEMS.TwoTapUserCnt + MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoOrMorePct
#                                   , (MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeOrMorePct
#                                   , EVENTS.Adoption
#                                   , EVENTS.Sessions/EVENTS.UsersActive AS SessionsPerUser
#                                   , EVENTS.ApplicationId
#                                   , COUNT(*) OVER (PARTITION BY EVENTS.ApplicationId) AS AgendaCnt
#                              FROM JT.MenuItemTopicTaps MENU_ITEMS
#                              JOIN JT.MenuEvents EVENTS
#                              ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
#                              WHERE EVENTS.UsersActive > 0 AND EVENTS.UsersActive >= MENU_ITEMS.UserCnt
#                              AND TypeId = 2 AND ListTypeId = 2
#                       ;")
# 
# 
# 
# # Event Subset Based on Micro App Name having the word "Agenda".
# agenda <- agendaGridItem[grep("Agenda", agendaGridItem[,2]),]
# nonAgenda <- agendaGridItem[grep("Agenda", agendaGridItem[,2], invert = TRUE),]
# 
# # Histogram of both event subset populations where there is only one agenda item. (Separate Histogram)
# #hist(agenda[agenda$agendacnt == 1,3], main = "Event Histogram w/ One Agenda Option and 'Agenda' in Name", xlab = "% of Active Users with >= 1 Agenda Click", ylab = "Event Count")
# #hist(nonAgenda[nonAgenda$agendacnt == 1,3], main = "Event Histogram w/ One Agenda Option and 'Agenda' not in Name", xlab = "% of Active Users with >= 1 Agenda Click", ylab = "Event Count")
# 
# # Histogram of both event subset populations where there is only one agenda item. (Overlap)
# # hist(agenda[agenda$agendacnt == 1,11], col=rgb(1,0,0,0.5), main = "Event Histogram w/ One Agenda Option", xlab = "% of Active Users with >= 1 Agenda Click", ylab = "Event Count")
# # hist(nonAgenda[nonAgenda$agendacnt == 1,11], col=rgb(0,0,1,0.5), add = TRUE)
# # box()
# 
# # Subset by Name containing "Agenda"
# agendaMedian <- aggregate(agenda[,11], agenda[1], median)
# agendaCount <- aggregate(agenda[,11], agenda[1], length)
# agendaSummary <- cbind(agendaMedian, agendaCount[,2])
# 
# # Subset by Name not containing "Agenda"
# nonAgendaMedian <- aggregate(nonAgenda[,11], nonAgenda[1], median)
# nonAgendaCount <- aggregate(nonAgenda[,11], nonAgenda[1], length)
# nonAgendaSummary <- cbind(nonAgendaMedian, nonAgendaCount[,2])
# 
# # Label Subset Data frames
# names(agendaSummary) <- c("gridIndex", "Median", "Count")
# names(nonAgendaSummary) <- c("gridIndex", "Median", "Count")
# 
# # Histogram of both event subset populations where there is more than one agenda item.
# #hist(agenda[agenda$agendacnt > 1,3], main = "Event Histogram w/ Two or More Agenda Options and 'Agenda' in Name", xlab = "% of Active Users with >= 1 Agenda Click", ylab = "Event Count")
# #hist(nonAgenda[nonAgenda$agendacnt > 1,3], main = "Event Histogram w/ Two or More Agenda Options and 'Agenda' not in Name", xlab = "% of Active Users with >= 1 Agenda Click", ylab = "Event Count")
# 
# # Exhibitor List
# exhibitGridItem <- dbGetQuery(con, "SELECT GridIndex
#                                   , '''' || regexp_replace(Title, '''', '', 'g') || '''' AS Title
#                                   , MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS Pct
#                                   , MENU_ITEMS.OneTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS OneTapPct 
#                                   , MENU_ITEMS.TwoTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoTapPct 
#                                   , MENU_ITEMS.ThreeTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeTapPct 
#                                   , MENU_ITEMS.FourTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FourTapPct 
#                                   , MENU_ITEMS.FiveTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveTapPct 
#                                   , MENU_ITEMS.FiveOrMoreTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveOrMoreTapPct 
#                                   , (MENU_ITEMS.TwoTapUserCnt + MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoOrMorePct
#                                   , (MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeOrMorePct
#                                   , EVENTS.Adoption
#                                   , EVENTS.Sessions/EVENTS.UsersActive AS SessionsPerUser
#                                   , EVENTS.ApplicationId
#                                   , COUNT(*) OVER (PARTITION BY EVENTS.ApplicationId) AS ExhibitCnt
#                              FROM JT.MenuItemTopicTaps MENU_ITEMS
#                              JOIN JT.MenuEvents EVENTS
#                              ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
#                              WHERE EVENTS.UsersActive > 0 AND EVENTS.UsersActive >= MENU_ITEMS.UserCnt
#                              AND ListTypeId = 3
#                       ;")
# 
# # hist(exhibitGridItem[exhibitGridItem$exhibitcnt == 1,11], col=rgb(1,0,0,0.5), main = "Event Histogram w/ One Agenda Option", xlab = "% of Active Users with >= 1 Exhibitor Click", ylab = "Event Count")
# 
# # Speakers List
# speakerGridItem <- dbGetQuery(con, "SELECT GridIndex
#                                   , '''' || regexp_replace(Title, '''', '', 'g') || '''' AS Title
#                                   , MENU_ITEMS.UserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS Pct
#                                   , MENU_ITEMS.OneTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS OneTapPct 
#                                   , MENU_ITEMS.TwoTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoTapPct 
#                                   , MENU_ITEMS.ThreeTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeTapPct 
#                                   , MENU_ITEMS.FourTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FourTapPct 
#                                   , MENU_ITEMS.FiveTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveTapPct 
#                                   , MENU_ITEMS.FiveOrMoreTapUserCnt::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS FiveOrMoreTapPct 
#                                   , (MENU_ITEMS.TwoTapUserCnt + MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS TwoOrMorePct
#                                   , (MENU_ITEMS.ThreeTapUserCnt + MENU_ITEMS.FourTapUserCnt + MENU_ITEMS.FiveTapUserCnt + MENU_ITEMS.FiveOrMoreTapUserCnt)::DECIMAL(12,4)/UsersActive::DECIMAL(12,4) AS ThreeOrMorePct
#                                   , EVENTS.Adoption
#                                   , EVENTS.Sessions/EVENTS.UsersActive AS SessionsPerUser
#                                   , EVENTS.ApplicationId
#                                   , COUNT(*) OVER (PARTITION BY EVENTS.ApplicationId) AS SpeakerCnt
#                              FROM JT.MenuItemTopicTaps MENU_ITEMS
#                              JOIN JT.MenuEvents EVENTS
#                              ON MENU_ITEMS.ApplicationId = EVENTS.ApplicationId
#                              WHERE EVENTS.UsersActive > 0 AND EVENTS.UsersActive >= MENU_ITEMS.UserCnt
#                              AND ListTypeId = 4
#                       ;")
# 
# # hist(speakerGridItem[speakerGridItem$speakercnt == 1,11], col=rgb(1,0,0,0.5), main = "Event Histogram w/ One Speaker Option", xlab = "% of Active Users with >= 1 Speaker Click", ylab = "Event Count")
# 
# # hist(speakerGridItem[speakerGridItem$gridindex == 0 & speakerGridItem$speakercnt == 1,11], col=rgb(1,0,0,0.5), main = "Event Histogram w/ One Speaker Option", xlab = "% of Active Users with >= 1 Speaker Click", ylab = "Event Count")

# Disconnect from Robin
dbDisconnect(con)