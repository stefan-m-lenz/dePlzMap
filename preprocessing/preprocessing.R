# install.packages("openxlsx")

# PLZ für Gemeinde
# https://github.com/zauberware/postal-codes-json-xml-csv

print_and_capture <- function(x) {
  paste(capture.output(print(x, row.names = FALSE)), collapse = "\n")
}

# ags zu plz
# https://www.suche-postleitzahl.org/downloads

# Bevölkerungszahl nach Gemeinde
# Gemeindeverzeichnis-Informationssystem (GV-ISys)
# https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/_inhalt.html#101366

library(openxlsx)
destatisDataPopulation <- read.xlsx("31122021_Auszug_GV.xlsx", sheet = 2,
                                    startRow = 7)
colnames(destatisDataPopulation)[1:10] <- c("Satzart", 
                                            "Textkennzeichen",
                                            "ARS_Land",
                                            "ARS_RB",
                                            "ARS_Kreis",
                                            "ARS_VB",
                                            "ARS_Gem",
                                            "Gemeindename",
                                            "Flaeche", 
                                            "Population")

destatisDataPopulation <- destatisDataPopulation[!is.na(destatisDataPopulation$ARS_Gem), ]

# 8-digit AGS (Amtlicher Gemeindeschlüssel)
destatisDataPopulation$ags <- paste0(destatisDataPopulation$ARS_Land,
                                     destatisDataPopulation$ARS_RB,
                                     destatisDataPopulation$ARS_Kreis,
                                     destatisDataPopulation$ARS_Gem)

# TODO OpenstreetMap  Open Data Commons Open Database Lizenz 
agsToPlz <- read.table("data/plz_ags.csv", sep = ",", header = TRUE, 
                       colClasses = "character")

plzNotKnownForAgs <- destatisDataPopulation[!(destatisDataPopulation$ags %in% agsToPlz$ags) & 
                                              destatisDataPopulation$Population > 0, c("Gemeindename", "ags")]
if (nrow(plzNotKnownForAgs) > 0) {
  warning("The following AGS-keys with non-zero population could not be mapped to a PLZ",
          print_and_capture(plzNotKnownForAgs))
}

populationData <- merge(x = agsToPlz, destatisDataPopulation, by = "ags", all.x = TRUE)

if (anyNA(populationData$Population)) {
  warning("There are entries with missing population data")
}

if (anyNA(populationData$ags)) {
  warning("There are entries with missing AGS")
}

if (anyNA(populationData$plz)) {
  warning("There are entries with missing PLZ")
}

# Problem: Es gibt teilweise mehrere PLZs pro AGS.
# Damit kann einer einzigen PLZ nicht direkt eine Einwohnerzahl zugeordnet werden.
populationData[duplicated(populationData$ags), ]