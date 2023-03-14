test_that("Plotting of continuous values works", {
  data <- read.table(system.file("extdata", "populationData.csv", package = "dePlzMap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzMap(data[, c("plz", "Population")], title = "Population in RLP",
                  bundesland = "Rheinland-Pfalz",
                  bundeslandBorderColor = "black")
  expect_s3_class(plt, "ggplot")

  data2 <- data.frame(plz = data$plz, Zwei = data$Population*2)
  plt <- dePlzMap(data2, title = "Population in RLP",
                  populationRelative = TRUE,
                  legendTitle = "Pro Einwohner",
                  bundesland = "Rheinland-Pfalz")
  expect_s3_class(plt, "ggplot")

  plt <- dePlzMap(data.frame(plz = c("94160", "89134", "79104", "55131"), val = c(1,2,3,4)),
                  title = "Orte",
                  naVal = 0,
                  bundesland = c("Bayern", "Baden-Württemberg", "Rheinland-Pfalz"))
  expect_s3_class(plt, "ggplot")
})


test_that("Plotting of discrete values works", {
  data <- read.table(system.file("extdata", "populationData.csv", package = "dePlzMap"),
                     sep =",", header = TRUE, colClasses = c("character", "integer", "character"))
  plt <- dePlzMap(data[, c("plz", "Bundesland")], title = "Bundesländer",
                  bundeslandBorderColor = "black")
  expect_s3_class(plt, "ggplot")
})


test_that("Warning about unknown PLZs", {
  expect_warning({plt <- dePlzMap(data.frame(plz = c("941600", "891344", "791040", "55131"),
                                             val = c(1,2,3,4)),
                                  title = "Orte",
                                  naVal = 0,
                                  bundesland = c("Bayern", "Baden-Württemberg", "Rheinland-Pfalz"))},
                 regexp = "791040, 891344, 941600")
  expect_s3_class(plt, "ggplot")
})

test_that("Providing a vector as input works", {
  plt <- dePlzMap(data = c(rep("94160", 19), rep("79104", 40), rep("55131", 5), rep("89134", 5)),
                  bundesland = c("Bayern", "Baden-Württemberg", "Rheinland-Pfalz"))
  expect_s3_class(plt, "ggplot")
})
