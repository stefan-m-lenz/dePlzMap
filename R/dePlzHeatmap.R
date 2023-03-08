library(ggplot2)

.onLoad <- function(libname, pkgname) {
  packageStartupMessage("Preparing map data (this might take some time)")

  # Source: https://public.opendatasoft.com/explore/dataset/georef-germany-postleitzahl/export/
  plzShapes <<- maptools::readShapeSpatial(system.file("data", "georef-germany-postleitzahl.shp",
                                                      package = pkgname, mustWork = TRUE))

  # By using the argument "region", we accomplish
  # that the column "id" contains the PLZ in the resulting data frame
  plzShapes <<- ggplot2::fortify(plzShapes, region = "plz_code")

  populationData <<- read.table(system.file("data", "populationData.csv", package = "dePlzHeatmap"),
                                sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
}

#'
#' @return a plot of Germany or a set of countries in Germany with colored PLZ areas
dePlzHeatmap <- function(data, title = "", bundesland = NA,
                         populationRelative = FALSE, color = "#115e01") {

  if (!is.data.frame(data) || ncol(data) != 2 || !("plz" %in% colnames(data))) {
    stop("Argument \"data\" must be a two-column data frame with one column named \"plz\".")
  }

  otherColName <- colnames(data)[colnames(data) != "plz"]

  if (length(bundesland) > 1 || !is.na(bundesland)) {
    plzShapes <- plzShapes[plzShapes$id %in% populationData$plz[populationData$bundesland %in% bundesland], ]
  }
  plotDf <- merge(plzShapes, data, by.x = "id", by.y = "plz", all.x = TRUE)
  plotDf <- plotDf[order(plotDf$order), ]

  ggplot2::ggplot() +
    geom_polygon(data = plotDf,
                 aes(x = long, y = lat, group = group, fill = .data[[otherColName]])) +
    scale_colour_gradient(
      low = "#FFFFFF", high = color, na.value = "grey50",
      guide = "colourbar", aesthetics = "fill"
    ) +
    coord_map() +
    ggmap::theme_nothing(legend = TRUE) +
    ggtitle(title) +
    theme(plot.title = element_text(hjust = 0.5)) # center title
}
