#'
#' @return a plot of Germany or a set of countries in Germany with colored PLZ areas
dePlzHeatmap <- function(data, title = "", bundesland = NA, bundeslandBorderColor = "gray",
                         populationRelative = NA, color = "#115e01") {

  if (!is.data.frame(data) || ncol(data) != 2 || !("plz" %in% colnames(data))) {
    stop("Argument \"data\" must be a two-column data frame with one column named \"plz\".")
  }

  otherColName <- colnames(data)[colnames(data) != "plz"]

  if (!is.na(populationRelative)) {
    data <- merge(data, populationData[, c("plz", "population")], by = "plz")
    newOtherColName <- paste(otherColName, populationRelative)
    data[, newOtherColName] <- data[, otherColName] / data$population
    data[, otherColName] <- NULL
    otherColName <- newOtherColName
  }

  if (length(bundesland) > 1 || !is.na(bundesland)) {
    plzShapes <- plzShapes[plzShapes$id %in% populationData$plz[populationData$bundesland %in% bundesland], ]
    bundeslaenderShapes <- bundeslaenderShapes[bundeslaenderShapes$id %in% bundesland, ]
  }
  plotDf <- merge(plzShapes, data, by.x = "id", by.y = "plz", all.x = TRUE)
  plotDf <- plotDf[order(plotDf$order), ]

  ggplot2::ggplot() +
    ggplot2::geom_polygon(data = plotDf,
                          ggplot2::aes(x = long, y = lat, group = group, fill = .data[[otherColName]])) +
    ggplot2::geom_polygon(data = bundeslaenderShapes,
                          ggplot2::aes(x = long, y = lat, group = group),
                          colour = bundeslandBorderColor, fill = NA) +
    ggplot2::scale_colour_gradient(
      low = "#FFFFFF", high = color, na.value = "grey50",
      guide = "colourbar", aesthetics = "fill"
    ) +
    ggplot2::coord_map() +
    ggmap::theme_nothing(legend = TRUE) +
    ggplot2::ggtitle(title) +
    ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) # center title
}
