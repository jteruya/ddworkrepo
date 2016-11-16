require("RPostgreSQL")
require("nFactors")

# Establish Connection to Robin using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "analytics", host="10.223.192.6", port = "5432", user = "etl", password = "s0.Much.Data")

# Read Input Table
usercount <- dbReadTable(con, c("jt","sessionscanusercount"))

# Use only sessions where at least one person is scanned.
scanned <- subset(usercount, usercount[,4] > 0)

# Histogram of Differences
hist(scanned[,5])

# Mean
mean(scanned[,5])

# Median
median(scanned[,5])

# Standard Deviation
sd(scanned[,5])

# Disconnect from Robin
dbDisconnect(con)