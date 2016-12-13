require("RPostgreSQL")
require("ggplot2")
require("lubridate")

# Establish Connection to Robin using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "analytics", host="10.223.192.6", port = "5432", user = "etl", password = "s0.Much.Data")

# Get Data from Robin
msgevents <- dbGetQuery(con, "SELECT CAST(EXTRACT(YEAR FROM StartDate) * 100 + EXTRACT(MONTH FROM StartDate) AS INT) AS YearMonth
                                   , COUNT(*) AS EventCnt
                                   , COUNT(CASE WHEN DirectMessaging = 1 THEN 1 ELSE NULL END) AS DMEventCnt
                                   , COUNT(CASE WHEN TopicChannel = 1 THEN 1 ELSE NULL END) AS TCEventCnt
                                   , COUNT(CASE WHEN SessionChannel = 1 THEN 1 ELSE NULL END) AS SCEventCnt
                                   , COUNT(*)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS EventPct
                                   , COUNT(CASE WHEN DirectMessaging = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS DMEventPct
                                   , COUNT(CASE WHEN TopicChannel = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS TCEventPct
                                   , COUNT(CASE WHEN SessionChannel = 1 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS SCEventPct
                                   , COUNT(CASE WHEN DirectMessaging = 0 AND TopicChannel = 0 AND SessionChannel = 0 THEN 1 ELSE NULL END)::DECIMAL(12,4)/COUNT(*)::DECIMAL(12,4) AS NoMsgEventPct
                              FROM JT.DP529_Events
                              WHERE StartDate >= '2016-01-01' AND StartDate <= '2016-11-30' AND EndDate <= '2016-11-30'
                              GROUP BY 1
                              ORDER BY 1;
                              ")
dmfunnel <- dbGetQuery(con, "SELECT * FROM JT.DP529_DMFunnel WHERE StartDate >= '2016-01-01' AND StartDate <= '2016-11-30' AND EndDate <= '2016-11-30';")
tcfunnel <- dbGetQuery(con, "SELECT * FROM JT.DP529_TCFunnel WHERE StartDate >= '2016-01-01' AND StartDate <= '2016-11-30' AND EndDate <= '2016-11-30';")
scfunnel <- dbGetQuery(con, "SELECT * FROM JT.DP529_SCFunnel WHERE StartDate >= '2016-04-01' AND StartDate <= '2016-11-30' AND EndDate <= '2016-11-30';")

# Events Feature Availability Analysis
msgevents_plot <- ggplot(data = msgevents, aes(x = factor(msgevents$yearmonth))) + geom_line(aes(y = msgevents$eventcnt, colour = "Total Events", group = 1)) + ggtitle("Events with Messaging Features") + xlab("Year Month") + ylab("Event Count") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
msgevents_plot <- msgevents_plot + geom_line(aes(y = msgevents$dmeventcnt, colour = "Direct Messages Events", group = 2)) + geom_line(aes(y = msgevents$tceventcnt, colour = "Topic Channels Events", group = 3)) + geom_line(aes(y = msgevents$sceventcnt, colour = "Session Channels Events", group = 3))

msgevents_areaplot <- ggplot(data = msgevents, aes(x = factor(msgevents$yearmonth))) + ggtitle("Percent of Events with Messaging Features") + xlab("Year Month") + ylab("Percent of Events") + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent, limits = c(0,1))
msgevents_areaplot <- msgevents_areaplot + geom_line(aes(y = msgevents$dmeventpct, colour = "Direct Messages Events", group = 1)) + geom_label(aes(y = msgevents$dmeventpct, label = sprintf("%.02f %%", msgevents$dmeventpct*100)))
msgevents_areaplot <- msgevents_areaplot + geom_line(aes(y = msgevents$tceventpct, colour = "Topic Channels Events", group = 2)) + geom_label(aes(y = msgevents$tceventpct, label = sprintf("%.02f %%", msgevents$tceventpct*100)))
msgevents_areaplot <- msgevents_areaplot + geom_line(aes(y = msgevents$sceventpct, colour = "Session Channels Events", group = 3)) + geom_label(aes(y = msgevents$sceventpct, label = sprintf("%.02f %%", msgevents$sceventpct*100)))

#msgevents_areaplot <- ggplot(data = msgevents_melt, aes(x = factor(msgevents_melt$yearmonth), y = msgevents_melt$value, group = msgevents_melt$variable, fill = msgevents_melt$variable)) + geom_area(position = "fill") + ggtitle("Percent of Events with Messaging Features") + xlab("Year Month") + ylab("Percent of Events")
#msgevents_areaplot <- msgevents_areaplot + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent, limits = c(0,1))


# Discoverability Analysis (Time Series)

# Get YearMonth Field
dmfunnel$yearmonth <- year(dmfunnel$startdate) * 100 + month(dmfunnel$startdate)
tcfunnel$yearmonth <- year(tcfunnel$startdate) * 100 + month(tcfunnel$startdate)
scfunnel$yearmonth <- year(scfunnel$startdate) * 100 + month(scfunnel$startdate)


# DM Scatterplots (Time Series)
dmfunnel_microapp_plot <- ggplot(data = dmfunnel, aes(x = factor(dmfunnel$yearmonth), y = dmfunnel$dmmicroappuserpct)) + ggtitle("% of Active User Clicked on DM MicroApp") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
dmfunnel_view_plot <- ggplot(data = dmfunnel, aes(x = factor(dmfunnel$yearmonth), y = dmfunnel$dmviewuserpct)) + ggtitle("% of Active User Viewed at least on DM") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
dmfunnel_msgsent_plot <- ggplot(data = dmfunnel, aes(x = factor(dmfunnel$yearmonth), y = dmfunnel$dmsentmsguserpct)) + ggtitle("% of Active User Sent at least one DM") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)

# TC Scatterplots (Time Series)
tcfunnel_microapp_plot <- ggplot(data = tcfunnel, aes(x = factor(tcfunnel$yearmonth), y = tcfunnel$tcmicroappuserpct)) + ggtitle("% of Active User Clicked on TC MicroApp") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
tcfunnel_view_plot <- ggplot(data = tcfunnel, aes(x = factor(tcfunnel$yearmonth), y = tcfunnel$tcchannelviewuserpct)) + ggtitle("% of Active User Views a TC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
tcfunnel_join_plot <- ggplot(data = tcfunnel, aes(x = factor(tcfunnel$yearmonth), y = tcfunnel$tcchanneljoinuserpct)) + ggtitle("% of Active User Joins a TC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
tcfunnel_msgsent_plot <- ggplot(data = tcfunnel, aes(x = factor(tcfunnel$yearmonth), y = tcfunnel$tcchannelsentuserpct)) + ggtitle("% of Active User Sent Message in TC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)

# SC Scatterplots (Time Series)
scfunnel_microapp_plot <- ggplot(data = scfunnel, aes(x = factor(scfunnel$yearmonth), y = scfunnel$scmicroappuserpct)) + ggtitle("% of Active User Viewed Session Detail View") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
scfunnel_view_plot <- ggplot(data = scfunnel, aes(x = factor(scfunnel$yearmonth), y = scfunnel$scchannelviewuserpct)) + ggtitle("% of Active User Views a SC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
scfunnel_join_plot <- ggplot(data = scfunnel, aes(x = factor(scfunnel$yearmonth), y = scfunnel$scchanneljoinuserpct)) + ggtitle("% of Active User Joins a SC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)
scfunnel_msgsent_plot <- ggplot(data = scfunnel, aes(x = factor(scfunnel$yearmonth), y = scfunnel$scchannelsentuserpct)) + ggtitle("% of Active User Sent Message in SC") + xlab("Year Month") + ylab("% of Active Users") + geom_point() + geom_jitter() + geom_boxplot() + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_continuous(labels=percent)

# 2016 DM Funnel 
dmfunnel_melt <- melt(dmfunnel[,11:13])
dmfunnel_median <- ddply(dmfunnel_melt, .(variable), summarise, med = median(value), count = length(value), firstquantile = quantile(value)[2], thirdquantile = quantile(value)[4])
dmfunnel_plot <- ggplot(data = dmfunnel_melt, aes(x = revalue(factor(variable), c("dmmicroappuserpct" = "Micro App Click", "dmviewuserpct" = "View DM", "dmsentmsguserpct" = "Send DM")), y = value)) + geom_jitter() + geom_boxplot() + scale_y_continuous(labels=percent, limits = c(0, 1)) + ggtitle("Direct Messaging 2016 Usage Funnel") + xlab("Direct Messaging Steps") + ylab("% of Active Users") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
#dmfunnel_plot <- dmfunnel_plot + geom_text(data = dmfunnel_median, aes(x = revalue(factor(variable), c("dmmicroappuserpct" = "Micro App Click", "dmviewuserpct" = "View DM", "dmsentmsguserpct" = "Send DM")), y = med, label = sprintf("Median: %.02f %%", med*100)), size = 3, vjust = -1.0)

# 2016 TC Funnel
tcfunnel_melt <- melt(tcfunnel[,13:16])
tcfunnel_median <- ddply(tcfunnel_melt, .(variable), summarise, med = median(value), count = length(value), firstquantile = quantile(value)[2], thirdquantile = quantile(value)[4])
tcfunnel_plot <- ggplot(data = tcfunnel_melt, aes(x = revalue(factor(variable), c("tcmicroappuserpct" = "Micro App Click", "tcchannelviewuserpct" = "View a TC", "tcchanneljoinuserpct" = "Join a TC", "tcchannelsentuserpct" = "Send a TC Message")), y = value)) + geom_jitter() + geom_boxplot() + scale_y_continuous(labels=percent, limits = c(0, 1)) + ggtitle("Topic Channel 2016 Usage Funnel") + xlab("Topic Channel Steps") + ylab("% of Active Users") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
#tcfunnel_plot <- tcfunnel_plot + geom_text(data = tcfunnel_median, aes(x = revalue(factor(variable), c("tcmicroappuserpct" = "Micro App Click", "tcchannelviewuserpct" = "View a TC", "tcchanneljoinuserpct" = "Join a TC", "tcchannelsentuserpct" = "Send a TC Message")), y = med, label = sprintf("Median: %.02f %%", med*100)), size = 3, vjust = -1.0)

# 2016 SC Funnel
scfunnel_melt <- melt(scfunnel[,13:16])
scfunnel_median <- ddply(scfunnel_melt, .(variable), summarise, med = median(value), count = length(value), firstquantile = quantile(value)[2], thirdquantile = quantile(value)[4])
scfunnel_plot <- ggplot(data = scfunnel_melt, aes(x = revalue(factor(variable), c("scmicroappuserpct" = "View Session Detail", "scchannelviewuserpct" = "View a SC", "scchanneljoinuserpct" = "Join a SC", "scchannelsentuserpct" = "Send a SC Message")), y = value)) + geom_jitter() + geom_boxplot() + scale_y_continuous(labels=percent, limits = c(0, 1)) + ggtitle("Session Channel 2016 Usage Funnel") + xlab("Session Channel Steps") + ylab("% of Active Users") + theme(axis.text.x = element_text(angle = 45, hjust = 1))



# Disconnect from Robin
dbDisconnect(con)