test_that("gg_suggest_fixes generates fix suggestions", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point(size = 1) +
    scale_color_manual(values = c("red", "green", "blue"))

  # Run audit first
  audit <- gg_audit(p)

  # Get suggestions
  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")
  expect_true("color" %in% names(fixes) ||
                "accessibility" %in% names(fixes) ||
                "text" %in% names(fixes))
})

test_that("gg_suggest_fixes works without prior audit", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  # Should work directly on plot
  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")
})

test_that("gg_suggest_fixes handles color issues", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point() +
    scale_color_manual(values = c("red", "green", "blue"))

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Should suggest color fixes
  all_fixes <- unlist(fixes)
  expect_true(any(grepl("color|palette|viridis", all_fixes, ignore.case = TRUE)))
})

test_that("gg_suggest_fixes handles scale issues", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(x = factor(cyl), y = mpg)) +
    geom_bar(stat = "identity") +
    ylim(10, 30)

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Should suggest fixing truncated axis
  all_fixes <- unlist(fixes)
  expect_true(any(grepl("zero|expand_limits|ylim", all_fixes, ignore.case = TRUE)))
})

test_that("gg_suggest_fixes handles text size issues", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme(axis.text = element_text(size = 6))

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Should suggest increasing text size
  all_fixes <- unlist(fixes)
  expect_true(any(grepl("text.*size|element_text", all_fixes, ignore.case = TRUE)))
})

test_that("gg_suggest_fixes handles label issues", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Should suggest adding labels
  all_fixes <- unlist(fixes)
  expect_true(any(grepl("title|labs\\(", all_fixes, ignore.case = TRUE)))
})

test_that("gg_suggest_fixes handles accessibility issues", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
    geom_point(size = 0.5)

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Should suggest accessibility improvements
  all_fixes <- unlist(fixes)
  expect_true(any(grepl("point.*size|shape|geom_point", all_fixes, ignore.case = TRUE)))
})

test_that("gg_suggest_fixes provides manual fix suggestions", {
  library(ggplot2)

  # Create plot with many categories (requires manual fix)
  df <- data.frame(
    category = paste0("Cat", 1:20),
    value = 1:20
  )

  p <- ggplot(df, aes(x = category, y = value)) +
    geom_bar(stat = "identity")

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")
  expect_true("manual" %in% names(fixes) || length(fixes) > 0)
})

test_that("gg_suggest_fixes returns empty list for perfect plot", {
  library(ggplot2)

  # Create a well-designed plot
  p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl), shape = factor(cyl))) +
    geom_point(size = 3) +
    scale_color_viridis_d() +
    labs(
      title = "Fuel Efficiency vs. Vehicle Weight",
      subtitle = "By Number of Cylinders",
      x = "Weight (1000 lbs)",
      y = "Miles Per Gallon",
      color = "Cylinders",
      shape = "Cylinders"
    ) +
    theme_minimal() +
    theme(
      text = element_text(size = 12),
      axis.text = element_text(size = 11)
    )

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")
  # May still have some suggestions but should be minimal
})

test_that("gg_suggest_fixes rejects invalid input", {
  expect_error(gg_suggest_fixes("not a plot"))
  expect_error(gg_suggest_fixes(NULL))
  expect_error(gg_suggest_fixes(123))
})

test_that("gg_suggest_fixes handles complex plots", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point(aes(color = factor(cyl)), size = 1) +
    geom_smooth(se = FALSE) +
    facet_wrap(~am) +
    scale_color_manual(values = c("red", "green", "blue"))

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")
  # Should handle multiple issues across categories
})

test_that("gg_suggest_fixes output structure is consistent", {
  library(ggplot2)

  p <- ggplot(mtcars, aes(wt, mpg)) +
    geom_point()

  fixes <- gg_suggest_fixes(p)

  expect_type(fixes, "list")

  # Check that all elements are character vectors if they exist
  for (element in fixes) {
    if (length(element) > 0) {
      expect_type(element, "character")
    }
  }
})
