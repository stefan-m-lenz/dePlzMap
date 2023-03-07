#install.packages(c("ggplot2", "maptools", "mapproj", "Cairo", "ggmap"))

plotTitle <- "Anzahl Patienten in Studien"

print_and_capture <- function(x) {
  paste(capture.output(print(x, row.names = FALSE)), collapse = "\n")
}

library(ggplot2)
# Source: https://public.opendatasoft.com/explore/dataset/georef-germany-postleitzahl/export/
plzShapes <- maptools::readShapeSpatial("georef-germany-postleitzahl/georef-germany-postleitzahl.shp")

anzahlPlzCodes <- length(plzShapes$plz_code)
anzahlPatientenProPlz <- rpois(anzahlPlzCodes, 5)

dataPerPlz <- data.frame(id = plzShapes$plz_code, 
                   anzahlPatienten = anzahlPatientenProPlz)

# By using the argument "region", we accomplish 
# that the column "id" contains the PLZ in the resulting data frame.
plzShapesDf <- ggplot2::fortify(plzShapes, region = "plz_code")

plotDf <- merge(plzShapesDf, dataPerPlz, by = "id", all.x = TRUE)
plotDf <- plotDf[order(plotDf$order), ]

ggplot() +
  geom_polygon(data = plotDf, 
               aes(x = long, y = lat, group = group, fill = anzahlPatienten)) + 
  scale_colour_gradient(
    low = "#FFFFFF", high = "#115e01", na.value = "grey50", 
    guide = "colourbar", aesthetics = "fill"
  ) +
  coord_map() +
  ggmap::theme_nothing(legend = TRUE) +
  ggtitle(plotTitle) +
  theme(plot.title = element_text(hjust = 0.5)) # center title

# PLZ für Gemeinde
# https://github.com/zauberware/postal-codes-json-xml-csv

# ags zu plz
# https://www.suche-postleitzahl.org/downloads

# Bevölkerungszahl nach Gemeinde
# Gemeindeverzeichnis-Informationssystem (GV-ISys)
# https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/_inhalt.html#101366

destatisDataPopulation <- read.fwf("Population_GV-ISys/GV100AD_31122021.txt",
                                   c(2,8,2,2,1,2,4,3,))

library(openxlsx)
destatisDataPopulation <- read.xlsx("31122021_Auszug_GV.xlsx", sheet = 2,
                                    startRow = 12)
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
agsToPlz <- read.table("plz_ags.csv", sep = ",", header = TRUE, 
                       colClasses = "character")

plzNotKnownForAgs <- destatisDataPopulation[!(destatisDataPopulation$ags %in% agsToPlz$ags) & 
                            destatisDataPopulation$Population > 0, c("Gemeindename", "ags")]
if (nrow(plzNotKnownForAgs) > 0) {
  warning("The following AGS-keys with non-zero population could not be mapped to a PLZ",
          print_and_capture(plzNotKnownForAgs))
}


