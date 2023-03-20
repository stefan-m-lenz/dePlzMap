#' Choropleth map of Germany based on PLZ regions
#'
#' @description
#' This function creates a map of Germany that is
#' colored according to values given for different PLZ (postal code) regions.
#' The appearance of the map and the legend can be customized with different
#' options.
#'
#' Input values for display on the map can be continuous (numeric) or discrete.
#' There is also an option to plot the values relative to the population in the
#' different PLZ regions, using data from the "Registerzensus 2011" of the
#' Statistisches Bundesamt in Deutschland.
#'
#' In addition to plotting a complete map of Germany, it is possible to show
#' only specific German states (Bundesländer) on the map.
#'
#' @param data A vector of PLZs or a two-column data frame containing a column with name "plz" or "PLZ"
#' and an additional column with a value. If a vector of PLZs is given, the number of occurences
#' of each PLZ in the vector is used as the value.
#' @param bundesland A character vector containing the name(s) of German states (Bundesländer),
#' e.g. "Rheinland-Pfalz". If this argument specified, a map of only the specific states is created.
#' If this argument is not specified, a complete map of Germany is created.
#' @param bundeslandBorderColor A color for the border around the states, default is \code{"gray"}
#' @param highColor The color for the highest value in a plot with continuous values
#' @param naVal If this argument is set to a value that is not NA, this value is used in place of NA values.
#' The value is also used for PLZ regions that are not listed in the input data.
#' @param title The main title for the plot.
#' @param legendTitle A title for the legend.
#' By default, the column name of the value column in the input data frame is used.
#' @param populationRelative If set to \code{TRUE}, the values given for the PLZ regions are divided by the
#' local number of inhabitants. The population data currently used is based on the Registerzensus 2011.
#' @param percentage If set to \code{TRUE}, the legend shows the values as percentages.
#' For example, a value of 1 is displayed as 100 %.
#' By default, percentage values are shown if the argument \code{populationRelative} is set to \code{TRUE}.
#' @param decimalMark The decimal mark for the legend. The default is \code{","} as in German.
#' @param naColor The color to use for displaying missing (\code{NA}) values, defaults to \code{"gray75"}
#' @param naLabel The text of the label in the legend for the missing values.
#' @return A ggplot object representing the plot
dePlzMap <- function(data, bundesland = NA, bundeslandBorderColor = "gray",
                     highColor = "#115e01",
                     naVal = NA,
                     title = "", legendTitle = NA,
                     populationRelative = FALSE, percentage = populationRelative,
                     decimalMark = ",",
                     naColor = "grey75", naLabel = "No Data") {

  if (is.vector(data)) { # input is vector of PLZs
    data <- as.character(data)
    data <- data.frame(plz = data, x = 1)
    data <- stats::aggregate(x~plz, data = data, FUN = sum)
    if (is.na(legendTitle)) {
      legendTitle <- ""
    }
  } else { # input must be a data frame
    colnames(data)[colnames(data) %in% c("PLZ", "Plz")] <- "plz"
    if (!is.data.frame(data) || ncol(data) != 2 || !("plz" %in% colnames(data))) {
      stop("Argument \"data\" must be a two-column data frame with one column named \"plz\".")
    }
  }

  if (any(!(data$plz %in% plzShapes$id))) {
    warning("There is no shape information for the following PLZs:\n",
            paste(sort(data$plz[!(data$plz %in% plzShapes$id)]), collapse = ", "), "\n",
            "These PLZs are ignored. Are you sure these are correct?")
    data <- data[data$plz %in% plzShapes$id, ]
  }

  otherColName <- colnames(data)[colnames(data) != "plz"]

  if (!is.na(naVal)) {
    data <- merge(populationData[, c("plz"), drop = FALSE], data, by = "plz", all.x = TRUE)
    data[is.na(data[, otherColName]), otherColName] <- naVal
  }

  if (populationRelative) {
    # calculate population-relative values in new column
    data <- merge(data, populationData[, c("plz", "Population")], by = "plz")
    newOtherColName <- paste(otherColName, "pro Einwohner")
    data[, newOtherColName] <- data[, otherColName] / data$Population
    # use this new column for plotting
    data[, otherColName] <- NULL
    otherColName <- newOtherColName
  }

  if (length(bundesland) > 1 || !is.na(bundesland)) {
    plzShapes <- plzShapes[plzShapes$id %in% populationData$plz[populationData$Bundesland %in% bundesland], ]
    bundeslaenderShapes <- bundeslaenderShapes[bundeslaenderShapes$id %in% bundesland, ]
  }
  plotDf <- merge(plzShapes, data, by.x = "id", by.y = "plz", all.x = TRUE)
  plotDf <- plotDf[order(plotDf$order), ]

  if (percentage) {
    continousColorScale <- ggplot2::scale_fill_gradient(
      low = "#FFFFFF", high = highColor, na.value = naColor,
      guide = "colourbar", aesthetics = "fill",
      labels = scales::label_percent(decimal.mark = decimalMark),
    )
  } else {
    continousColorScale <- ggplot2::scale_fill_gradient(
      low = "#FFFFFF", high = highColor, na.value = naColor,
      guide = "colourbar", aesthetics = "fill"
    )
  }

  if (!is.na(legendTitle) && legendTitle != "") {
    # rename column because this defines the legend title in the plot
    colnames(plotDf)[colnames(plotDf) == otherColName] <- legendTitle
    otherColName <- legendTitle
  }

  ret <- ggplot2::ggplot() +
    ggplot2::geom_polygon(data = plotDf,
                          ggplot2::aes(x = long, y = lat, group = group, fill = .data[[otherColName]])) +
    ggplot2::geom_polygon(data = bundeslaenderShapes,
                          ggplot2::aes(x = long, y = lat, group = group),
                          colour = bundeslandBorderColor, fill = NA) +
    ggplot2::coord_map() +
    ggmap::theme_nothing(legend = TRUE)

  if (!is.na(legendTitle) && legendTitle == "") {
    ret <- ret + ggplot2::theme(legend.title = ggplot2::element_blank())
  }

  if (is.numeric(plotDf[, otherColName])) {
    ret <- ret + continousColorScale

    if (anyNA(plotDf[, otherColName])) {
      # Argument colour = "" as a trick that is needed to display the legend for the NA values
      # see https://stackoverflow.com/questions/42365483/add-a-box-for-the-na-values-to-the-ggplot-legend-for-a-continuous-map
      ret <- ret + ggplot2::geom_polygon(data = plotDf[1, ],
                                         ggplot2::aes(x = long, y = lat, group = group, color = ""))
      ret <- ret + ggplot2::scale_colour_manual(values = NA, drop = FALSE)

      # put color bar before legend for NA
      ret <- ret + ggplot2::guides(fill = ggplot2::guide_colorbar(order = 1),
                                   color = ggplot2::guide_legend(naLabel,
                                                                 order = 2,
                                                                 override.aes = list(fill = naColor, color = NA)))
    }
  }

  if (title != "") {
    ret <- ret + ggplot2::ggtitle(title) +
      ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) # center title
  }
  ret
}
