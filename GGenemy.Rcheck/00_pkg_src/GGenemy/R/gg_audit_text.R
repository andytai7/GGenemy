#' Audit Text Elements for Readability
#'
#' Checks font sizes, label overlap, and text readability issues.
#'
#' @param plot A ggplot2 object
#' @return A list of issues, warnings, and suggestions
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(x = rownames(mtcars), y = mpg)) +
#'   geom_col() +
#'   theme(axis.text.x = element_text(size = 6))
#' gg_audit_text(p)
gg_audit_text <- function(plot) {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  results <- list(
    issues = character(0),
    warnings = character(0),
    suggestions = character(0)
  )

  # Get theme elements
  theme_elements <- plot$theme

  # Check axis text size
  axis_text_size <- theme_elements$axis.text$size
  if (!is.null(axis_text_size) && axis_text_size < 8) {
    results$warnings <- c(results$warnings,
                          paste0("Axis text size (", axis_text_size,
                                 "pt) is very small and may be hard to read"))
    results$suggestions <- c(results$suggestions,
                             "Increase axis text size: theme(axis.text = element_text(size = 10))")
  }

  # Check title sizes
  title_size <- theme_elements$plot.title$size
  if (!is.null(title_size) && title_size < 11) {
    results$warnings <- c(results$warnings,
                          "Title text is smaller than recommended")
  }

  # Check for many x-axis labels (potential overlap)
  built <- ggplot2::ggplot_build(plot)

  if (length(built$layout$panel_params) > 0) {
    x_labels <- built$layout$panel_params[[1]]$x$get_labels()

    if (length(x_labels) > 15) {
      results$warnings <- c(results$warnings,
                            paste0("Many x-axis labels (", length(x_labels),
                                   ") - text may overlap"))
      results$suggestions <- c(results$suggestions,
                               "Consider: 1) Rotating labels with angle = 45, 2) Using fewer categories, or 3) Flipping coordinates with coord_flip()")
    }

    # Check for long labels
    max_label_length <- max(nchar(as.character(x_labels)), na.rm = TRUE)
    if (!is.na(max_label_length) && max_label_length > 20) {
      results$warnings <- c(results$warnings,
                            "Some axis labels are very long and may be truncated")
      results$suggestions <- c(results$suggestions,
                               "Consider abbreviating labels or wrapping text with scales::label_wrap()")
    }
  }

  # Check for missing axis labels
  if (is.null(plot$labels$x) || plot$labels$x == "") {
    results$warnings <- c(results$warnings,
                          "X-axis label is missing or empty")
    results$suggestions <- c(results$suggestions,
                             "Add descriptive axis label: labs(x = 'Your Variable Name')")
  }

  if (is.null(plot$labels$y) || plot$labels$y == "") {
    results$warnings <- c(results$warnings,
                          "Y-axis label is missing or empty")
    results$suggestions <- c(results$suggestions,
                             "Add descriptive axis label: labs(y = 'Your Variable Name')")
  }

  return(results)
}
