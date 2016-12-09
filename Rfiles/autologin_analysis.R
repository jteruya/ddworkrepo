require("RPostgreSQL")

# Establish Connection to Robin using RPostgreSQL
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "analytics", host="10.223.192.6", port = "5432", user = "etl", password = "s0.Much.Data")

# Get Password Fork Choices at User Level
choiceItem <- dbGetQuery(con, "SELECT BundleId
                                    , DeviceId
                                    , DeviceType
                                    , DeviceType
                                    , CASE WHEN AutoLoginFlag = 1 AND (EnterPasswordFlag = 0 OR (EnterPasswordFlag = 1 AND AutoLoginCreated <= EnterPasswordCreated)) THEN 1 ELSE 0 END AS AutoLoginFlag
                               FROM JT.AutoLogin_ClosedDevices
                               WHERE EnterEmailErrorFlag = 0
                               AND EnterPasswordErrorFlag = 0 AND AutoLoginErrorFlag = 0
                               AND (EnterPasswordCreated IS NOT NULL OR AutoLoginCreated IS NOT NULL);"
                         )

trials <- dim(choiceItem)[1]
success <- length(choiceItem[choiceItem$autologinflag == 1,2])

# Null Hypothesis: No significant difference between Enter Password and Autologin Choices on the Password Fork View:
# with the following conditions:
# (1) Users make a choice at the password fork
# (2) This accounts for the users first choice.

# Alternative Hypothesis: Users choose Autologin over Enter Password
btest <- binom.test(success,trials,(1/2),alternative="greater")



# Disconnect from Robin
dbDisconnect(con)