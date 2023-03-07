#install.packages(c("ggplot2", "maptools", "mapproj", "Cairo", "ggmap"))

plotTitle <- "Anzahl Patienten in Studien"

library(ggplot2)
# Source: https://public.opendatasoft.com/explore/dataset/georef-germany-postleitzahl/export/
plzShapes <- maptools::readShapeSpatial("georef-germany-postleitzahl/georef-germany-postleitzahl.shp")

# Daten über Bevölkerung gibt es hier:
#https://www.zensus2011.de/DE/Home/Aktuelles/DemografischeGrunddaten.html?nn=559100

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
               aes(x = long, y = lat, group = group, fill = anzahlPatienten), 
               color = "black", linewidth = 0.25) + 
  coord_map() +
  ggmap::theme_nothing(legend = TRUE, plot) +
  ggtitle(plotTitle) +
  theme(plot.title = element_text(hjust = 0.5)) # center title
  