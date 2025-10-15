#' Audit Plot Labels and Annotations
#'
#' Checks for appropriate titles, labels, and legends.
#'
#' @param plot A ggplot2 object
#' @return A list of issues, warnings, and suggestions
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point()
#' gg_audit_labels(p)
gg_audit_labels <- function(plot) {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  results <- list(
    issues = character(0),
    warnings = character(0),
    suggestions = character(0)
  )

  # Check for title
  if (is.null(plot$labels$title)) {
    results$warnings <- c(results$warnings,
                          "Plot has no title")
    results$suggestions <- c(results$suggestions,
                             "Add a descriptive title: labs(title = 'Your Title Here')")
  }

  # Check for programming artifacts in labels
  problem_patterns <- c("factor\\(", "as\\.", "\\$", "_")

  for (label_name in c("x", "y", "colour", "color", "fill", "size", "shape")) {
    label_value <- plot$labels[[label_name]]

    if (!is.null(label_value)) {
      if (any(sapply(problem_patterns, function(p) grepl(p, label_value)))) {
        results$issues <- c(results$issues,
                            paste0("Label '", label_value, "' contains programming syntax"))
        results$suggestions <- c(results$suggestions,
                                 paste0("Clean up label: labs(", label_name, " = 'Human Readable Name')"))
      }
    }
  }

  # Check legend title
  if (!is.null(plot$labels$colour) || !is.null(plot$labels$color) ||
      !is.null(plot$labels$fill)) {
    legend_title <- plot$labels$colour %||% plot$labels$color %||% plot$labels$fill

    if (is.null(legend_title) || legend_title == "") {
      results$warnings <- c(results$warnings,
                            "Legend has no title")
    }
  }

  return(results)
}
