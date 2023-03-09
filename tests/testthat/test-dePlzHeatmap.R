test_that("Plotting works", {
  data <- read.table(system.file("extdata", "populationData.csv", package = "dePlzHeatmap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzHeatmap(data[, c("plz", "population")], title = "Population in RLP",
                      bundesland = "Rheinland-Pfalz",
                      bundeslandBorderColor = "black")
  expect_s3_class(plt, "ggplot")

  data2 <- data.frame(plz = data$plz, Zwei = data$population*2)
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
