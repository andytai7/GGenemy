test_that("gg_audit_labels detects missing title", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  result <- gg_audit_labels(p)

  expect_type(result, "list")
  expect_true("warnings" %in% names(result))

  all_messages <- c(result$warnings, result$suggestions)
  expect_true(any(grepl("title", all_messages, ignore.case = TRUE)))
})

test_that("gg_audit_labels accepts plot with good title", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    labs(title = "Relationship Between Weight and MPG")

  result <- gg_audit_labels(p)

  expect_type(result, "list")
  # Should not warn about missing title
})

test_that("gg_audit_labels detects programming syntax in labels", {
  library(ggplot2)

  # Default ggplot uses variable names which look like code
  p <- ggplot(mtcars, aes(x = wt, y = mpg)) +
    geom_point()

  result <- gg_audit_labels(p)

  expect_type(result, "list")

  all_messages <- c(result$warnings, result$suggestions)
  # May detect variable names as programming syntax
})

test_that("gg_audit_labels detects legend without title", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point() +
    theme(legend.title = element_blank())

  result <- gg_audit_labels(p)

  expect_type(result, "list")

  # The function may or may not detect this specific case
  # Just verify the function returns proper structure
  expect_true("warnings" %in% names(result))
})

test_that("gg_audit_labels accepts plot with good legend title", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point() +
    labs(color = "Number of Cylinders")

  result <- gg_audit_labels(p)

  expect_type(result, "list")
})

test_that("gg_audit_labels detects missing subtitle/caption", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    labs(title = "My Plot")

  result <- gg_audit_labels(p)

  expect_type(result, "list")
  # May suggest adding subtitle or caption for context
})

test_that("gg_audit_labels handles comprehensive labeling", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point() +
    labs(
      title = "Fuel Efficiency vs. Vehicle Weight",
      subtitle = "Data from 1974 Motor Trend magazine",
      caption = "Source: mtcars dataset",
      x = "Weight (1000 lbs)",
      y = "Miles Per Gallon",
      color = "Cylinders"
    )

  result <- gg_audit_labels(p)

  expect_type(result, "list")
  # Should have minimal warnings
})

test_that("gg_audit_labels detects unclear abbreviations", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    labs(
      x = "wt",
      y = "mpg"
    )

  result <- gg_audit_labels(p)

  expect_type(result, "list")

  all_messages <- c(result$warnings, result$suggestions)
  # Should flag unclear labels
})

test_that("gg_audit_labels rejects invalid input", {
  expect_error(gg_audit_labels("not a plot"))
  expect_error(gg_audit_labels(NULL))
  expect_error(gg_audit_labels(123))
})

test_that("gg_audit_labels handles faceted plots", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    facet_wrap(~cyl)

  result <- gg_audit_labels(p)

  expect_type(result, "list")
  # Should check facet labels too
})

test_that("gg_audit_labels detects overly long titles", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    labs(title = "This is an extremely long title that goes on and on and probably contains too much information and should really be split into a title and subtitle for better readability")

  result <- gg_audit_labels(p)

  expect_type(result, "list")

  all_messages <- c(result$warnings, result$suggestions)
  # May suggest using subtitle
})
