# install.packages(c("maptools", "rgeos", "rgdal"))

# Data source:
# https://www.suche-postleitzahl.org/downloads
# Open Database License (Copyright OpenStreetMap contributors)
# Population data: Copyright Statistische Ämter des Bundes und der Länder


plz_einwohner <- read.table("preprocessing/data/plz_einwohner.csv", sep = ",", header = TRUE,
                            colClasses = c(rep("character", 2), rep("numeric", 4)),
                            encoding = "UTF-8")
plz_einwohner <- plz_einwohner[, c(1,3)]
zuordnung_plz_ort <- read.table("preprocessing/data/zuordnung_plz_ort.csv", sep = ",", header = TRUE,
                                colClasses = "character",
                                encoding = "UTF-8")

zuordnung_plz_ort <- zuordnung_plz_ort[, c("plz", "bundesland")]
zuordnung_plz_ort <- zuordnung_plz_ort[!duplicated(zuordnung_plz_ort$plz), ]

populationData <- merge(plz_einwohner, zuordnung_plz_ort, by = "plz", all.x = TRUE)
colnames(populationData)[colnames(populationData) == "einwohner"] <- "population"
# Sanity check:
sum(populationData$population)

# correction (more are in the other Bundesland):
populationData$bundesland[populationData$plz == "19357"] <- "Brandenburg"
populationData$bundesland[populationData$plz == "17337"] <- "Brandenburg"

colnames(populationData) <- c("plz", "Population", "Bundesland")

write.csv(populationData, file = "inst/extdata/populationData.csv",
          quote = FALSE, row.names = FALSE)

#======================================
# Geodata
#======================================

# Source: https://www.suche-postleitzahl.org/downloads
plzShapes <- maptools::readShapeSpatial(file.path("preprocessing", "data", "plz-5stellig", "plz-5stellig.shp"))

# By using the argument "region", we accomplish
# that the column "id" contains the PLZ in the resulting data frame
plzShapes <- ggplot2::fortify(plzShapes, region = "plz")


# Source: https://public.opendatasoft.com/explore/dataset/georef-germany-land/
# and https://public.opendatasoft.com/explore/dataset/georef-germany-land-millesime/
# For some crazy reason, in one file set, one set of Bundesländer work, in the other file set, the other ones
bundeslaenderShapes1 <- maptools::readShapeSpatial(file.path("preprocessing", "data", "bundeslaender",
                                                             "1", "georef-germany-land-millesime.shp"),
                                                  delete_null_obj = TRUE)
bundeslaenderShapes1 <- ggplot2::fortify(bundeslaenderShapes1, region = "lan_name")
bundeslaenderShapes2 <- maptools::readShapeSpatial(file.path("preprocessing", "data", "bundeslaender",
                                                             "2", "georef-germany-land-millesime.shp"),
                                                   delete_null_obj = TRUE)
bundeslaenderShapes2 <- ggplot2::fortify(bundeslaenderShapes2, region = "lan_name")
bundeslaenderShapes2$order <- max(bundeslaenderShapes1$order) + bundeslaenderShapes2$order
bundeslaenderShapes <- rbind(bundeslaenderShapes1, bundeslaenderShapes2)
bundeslaenderShapes$id <- gsub(pattern = "\\['(.*)'\\]", replacement = "\\1", x = bundeslaenderShapes$id)

library(usethis)
# Save Data to sysdata.rda, see https://r-pkgs.org/data.html#sec-data-sysdata
usethis::use_data(populationData, plzShapes, bundeslaenderShapes,
                  internal = TRUE, overwrite = TRUE)
