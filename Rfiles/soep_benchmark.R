require("RPostgreSQL")
require("ggplot2")
require("data.table")
library("plyr")
library("reshape2")
library("scales")
library("cowplot")
library("gtable")

# Establish Connection to Robin using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "analytics", host="10.223.192.6", port = "5432", user = "etl", password = "s0.Much.Data")


# Get Data from Robin
posts <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_Posts;")
likes <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_Likes;")
comments <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_Comments;")
follows <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_Follows;")
bookmarks <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_Bookmarks;")
activityfeed <- dbGetQuery(con, "SELECT * FROM JT.SOEP_Benchmark_ActivityFeed;")

# Combine Hour and Minute Window Fields to make one Field
posts$hourwindow <- posts$hour * 100 + posts$minutewindow
likes$hourwindow <- likes$hour * 100 + likes$minutewindow
comments$hourwindow <- comments$hour * 100 + comments$minutewindow
follows$hourwindow <- follows$hour * 100 + follows$minutewindow
bookmarks$hourwindow <- bookmarks$hour * 100 + bookmarks$minutewindow
activityfeed$hourwindow <- activityfeed$hour * 100 + activityfeed$minutewindow

# Posts Scatter Plot
posts_plot <- ggplot(data = posts, mapping = aes(x = hourwindow, y = postcnt)) + geom_point() + ggtitle("Posts per 15 Minute Window (2016)\n") + ylab("Number of Posts\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Posts w/Images Scatter Plot
posts_image_plot <- ggplot(data = posts, mapping = aes(x = hourwindow, y = imagepostcnt)) + geom_point() + ggtitle("Posts w/Images per 15 Minute Window (2016)\n") + ylab("Number of Posts w/ Images\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Likes Scatter Plot
likes_plot <- ggplot(data = likes, mapping = aes(x = hourwindow, y = likecnt)) + geom_point() + ggtitle("Likes per 15 Minute Window (2016)\n") + ylab("Number of Likes\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Comments Scatter Plot
comments_plot <- ggplot(data = likes, mapping = aes(x = hourwindow, y = likecnt)) + geom_point() + ggtitle("Comments per 15 Minute Window (2016)\n") + ylab("Number of Comments\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Follows Scatter Plot
follows_plot <- ggplot(data = likes, mapping = aes(x = hourwindow, y = likecnt)) + geom_point() + ggtitle("Follows per 15 Minute Window (2016)\n") + ylab("Number of Follows\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Bookmarks Scatter Plot
bookmarks_plot <- ggplot(data = likes, mapping = aes(x = hourwindow, y = likecnt)) + geom_point() + ggtitle("Bookmarks per 15 Minute Window (2016)\n") + ylab("Number of Bookmarks\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
# Activity Feed Scatter Plot
activityfeed_plot <- ggplot(data = likes, mapping = aes(x = hourwindow, y = likecnt)) + geom_point() + ggtitle("Activity Feed Views per 15 Minute Window (2016)\n") + ylab("Number of Activity Feed Views\n") + xlab("\n15 Minute Window") + theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Disconnect from Robin
dbDisconnect(con)