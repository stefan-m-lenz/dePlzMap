test_that("Plotting of continuous values works", {
  data <- read.table(system.file("extdata", "populationData.csv", package = "dePlzHeatmap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzHeatmap(data[, c("PLZ", "Population")], title = "Population in RLP",
                      bundesland = "Rheinland-Pfalz",
                      bundeslandBorderColor = "black")
  expect_s3_class(plt, "ggplot")

  data2 <- data.frame(plz = data$PLZ, Zwei = data$Population*2)
  plt <- dePlzHeatmap(data2, title = "Population in RLP",
                      populationRelative = "pro Einwohner",
                      bundesland = "Rheinland-Pfalz")
  expect_s3_class(plt, "ggplot")

  plt <- dePlzHeatmap(data.frame(plz = c("94160", "79104", "55131"), val = c(1,2,3)),
                      title = "Population in RLP",
                      naVal = 0,
                      bundesland = c("Bayern", "Baden-Württemberg", "Rheinland-Pfalz"))
  expect_s3_class(plt, "ggplot")
})


test_that("Plotting of discrete values works", {
  data <- read.table(system.file("extdata", "populationData.csv", package = "dePlzHeatmap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzHeatmap(data[, c("PLZ", "Bundesland")], title = "Bundesländer",
                      bundeslandBorderColor = "black")
  expect_s3_class(plt, "ggplot")
})
