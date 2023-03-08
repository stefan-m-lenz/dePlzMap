test_that("Plotting works", {
  data <- read.table(system.file("data", "populationData.csv", package = "dePlzHeatmap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzHeatmap(data[, c("plz", "population")], title = "Population in RLP",
                      bundesland = "Rheinland-Pfalz")
  expect_s3_class(plt, "ggplot")
})
