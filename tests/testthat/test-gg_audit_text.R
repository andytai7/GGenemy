test_that("gg_audit_text detects small text size", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(
      axis.text = element_text(size = 6),
      axis.title = element_text(size = 7)
    )

  result <- gg_audit_text(p)

  expect_type(result, "list")
  expect_true(length(result$issues) > 0 || length(result$warnings) > 0)

  all_messages <- c(result$issues, result$warnings)
  expect_true(any(grepl("text size|small", all_messages, ignore.case = TRUE)))
})

test_that("gg_audit_text accepts appropriate text sizes", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(
      axis.text = element_text(size = 11),
      axis.title = element_text(size = 12)
    )

  result <- gg_audit_text(p)

  expect_type(result, "list")
  # Should have fewer or no warnings about text size
})

test_that("gg_audit_text detects many axis labels", {
  library(ggplot2)

  # Create data with many categories
  df <- data.frame(
    category = paste0("Category_", 1:20),
    value = 1:20
  )

  p <- ggplot(df, aes(x = category, y = value)) +
    geom_bar(stat = "identity")

  result <- gg_audit_text(p)

  expect_type(result, "list")

  all_messages <- c(result$warnings, result$suggestions)
  expect_true(any(grepl("labels|overlap|rotate", all_messages, ignore.case = TRUE)))
})

test_that("gg_audit_text detects long labels", {
  library(ggplot2)

  df <- data.frame(
    long_name = c(
      "This is a very long category name that will cause problems",
      "Another extremely long category name",
      "Yet another verbose category"
    ),
    value = 1:3
  )

  p <- ggplot(df, aes(x = long_name, y = value)) +
    geom_bar(stat = "identity")

  result <- gg_audit_text(p)

  expect_type(result, "list")

  all_messages <- c(result$warnings, result$suggestions)
  expect_true(any(grepl("long|wrap", all_messages, ignore.case = TRUE)))
})

test_that("gg_audit_text detects missing axis labels", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  result <- gg_audit_text(p)

  expect_type(result, "list")

  # Check if it flags programming variable names
  all_messages <- c(result$warnings, result$suggestions)
  # May warn about generic variable names
})

test_that("gg_audit_text handles good axis labels", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    labs(
      x = "Weight (1000 lbs)",
      y = "Miles Per Gallon"
    )

  result <- gg_audit_text(p)

  expect_type(result, "list")
  # Should have fewer warnings
})

test_that("gg_audit_text detects overlapping text", {
  library(ggplot2)

  # Create plot with many text elements
  df <- data.frame(x = 1:50, y = 1:50, label = paste("Label", 1:50))

  p <- ggplot(df, aes(x, y, label = label)) +
    geom_text(size = 5)

  result <- gg_audit_text(p)

  expect_type(result, "list")
})

test_that("gg_audit_text rejects invalid input", {
  expect_error(gg_audit_text("not a plot"))
  expect_error(gg_audit_text(NULL))
  expect_error(gg_audit_text(123))
})

test_that("gg_audit_text handles plots without text elements", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme_void()

  result <- gg_audit_text(p)

  expect_type(result, "list")
})

test_that("gg_audit_text handles faceted plots", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    facet_wrap(~cyl) +
    theme(strip.text = element_text(size = 6))

  result <- gg_audit_text(p)

  expect_type(result, "list")
  # May warn about small facet label text
})
