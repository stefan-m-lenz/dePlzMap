# install.packages("openxlsx")

# Data source:
# https://www.suche-postleitzahl.org/downloads
# Open Database License (Copyright OpenStreetMap contributors)
# Population data: Copyright Statistische Ämter des Bundes und der Länder


plz_einwohner <- read.table("preprocessing/plz_einwohner.csv", sep = ",", header = TRUE, 
                            colClasses = c(rep("character", 2), rep("numeric", 4)))
plz_einwohner <- plz_einwohner[, c(1,3)]
zuordnung_plz_ort <- read.table("preprocessing/zuordnung_plz_ort.csv", sep = ",", header = TRUE,
                                colClasses = "character")

zuordnung_plz_ort <- zuordnung_plz_ort[, c("plz", "bundesland")]
zuordnung_plz_ort <- zuordnung_plz_ort[!duplicated(zuordnung_plz_ort$plz), ]

populationData <- merge(plz_einwohner, zuordnung_plz_ort, by = "plz", all.x = TRUE)
colnames(populationData)[colnames(populationData) == "einwohner"] <- "population"
# Sanity check:
sum(populationData$population)

write.table(populationData, file = "data/populationData.csv", sep = ",", 
            row.names = FALSE, fileEncoding = "UTF-8", quote = FALSE)
