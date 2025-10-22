test_that("gg_audit runs all checks by default", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  report <- gg_audit(p)

  expect_s3_class(report, "gg_audit_report")
  expect_true("issues" %in% names(report))
  expect_true("warnings" %in% names(report))
  expect_true("suggestions" %in% names(report))
})

test_that("gg_audit can run specific checks", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  report <- gg_audit(p, checks = "color")

  expect_s3_class(report, "gg_audit_report")
})

test_that("gg_audit rejects invalid input", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  expect_error(gg_audit(p, checks = "invalid_check"))
  expect_error(gg_audit("not a plot"))
})
