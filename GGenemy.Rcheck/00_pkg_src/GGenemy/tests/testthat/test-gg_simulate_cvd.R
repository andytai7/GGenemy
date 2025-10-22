test_that("gg_simulate_cvd returns a ggplot object", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point()

  result <- gg_simulate_cvd(p, type = "deutan")

  expect_s3_class(result, "gg")
})

test_that("gg_simulate_cvd handles all CVD types", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point()

  expect_s3_class(gg_simulate_cvd(p, type = "deutan"), "gg")
  expect_s3_class(gg_simulate_cvd(p, type = "protan"), "gg")
  expect_s3_class(gg_simulate_cvd(p, type = "tritan"), "gg")
})

test_that("gg_simulate_cvd rejects invalid input", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  expect_error(gg_simulate_cvd("not a plot"))
  expect_error(gg_simulate_cvd(p, type = "invalid"))
})
