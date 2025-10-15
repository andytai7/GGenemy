test_that("gg_audit_color detects red-green combinations", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point() +
    scale_color_manual(values = c("red", "green", "blue"))

  result <- gg_audit_color(p)

  expect_type(result, "list")
  expect_true(length(result$issues) > 0 || length(result$warnings) > 0)

  # Check that it mentions red-green
  all_messages <- c(result$issues, result$warnings)
  expect_true(any(grepl("red-green|Red-green", all_messages, ignore.case = TRUE)))
})

test_that("gg_audit_color handles plots without color", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  result <- gg_audit_color(p)

  expect_type(result, "list")
  expect_true("issues" %in% names(result))
  expect_true("warnings" %in% names(result))
})

test_that("gg_audit_color rejects invalid input", {
  expect_error(gg_audit_color("not a plot"))
  expect_error(gg_audit_color(NULL))
  expect_error(gg_audit_color(123))
})

test_that("gg_audit_color detects too many colors", {
  library(ggplot2)

  # Create a plot with 10 colors
  mtcars_subset <- mtcars[1:10, ]
  mtcars_subset$many_groups <- factor(1:10)
  p <- ggplot(mtcars_subset, aes(wt, mpg, color = many_groups)) +
    geom_point() +
    scale_color_manual(values = rainbow(10))

  result <- gg_audit_color(p)

  # Should warn about many colors
  all_messages <- c(result$issues, result$warnings)
  expect_true(any(grepl("many|colors", all_messages, ignore.case = TRUE)))
})
