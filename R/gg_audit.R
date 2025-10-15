#' Comprehensive Audit of ggplot2 Visualization
#'
#' Runs all available audit checks on a ggplot2 object and returns
#' a comprehensive report of potential issues and suggestions.
#'
#' @param plot A ggplot2 object
#' @param checks Character vector of checks to run. Default is "all".
#'   Options: "color", "scales", "text", "accessibility", "labels"
#' @return A list with class "gg_audit_report" containing audit results
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_manual(values = c("red", "green", "blue"))
#' report <- gg_audit(p)
#' print(report)
gg_audit <- function(plot, checks = "all") {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  available_checks <- c("color", "scales", "text", "accessibility", "labels")

  if (identical(checks, "all")) {
    checks <- available_checks
  } else {
    invalid <- setdiff(checks, available_checks)
    if (length(invalid) > 0) {
      stop("Invalid checks: ", paste(invalid, collapse = ", "),
           "\nAvailable checks: ", paste(available_checks, collapse = ", "),
           call. = FALSE)
    }
  }

  results <- list(
    plot_info = extract_plot_info(plot),
    issues = list(),
    warnings = list(),
    suggestions = list(),
    passed = list()
  )

  # Run each requested check
  if ("color" %in% checks) {
    color_results <- gg_audit_color(plot)
    results <- merge_audit_results(results, color_results, "color")
  }

  if ("scales" %in% checks) {
    scale_results <- gg_audit_scales(plot)
    results <- merge_audit_results(results, scale_results, "scales")
  }

  if ("text" %in% checks) {
    text_results <- gg_audit_text(plot)
    results <- merge_audit_results(results, text_results, "text")
  }

  if ("accessibility" %in% checks) {
    access_results <- gg_audit_accessibility(plot)
    results <- merge_audit_results(results, access_results, "accessibility")
  }

  if ("labels" %in% checks) {
    label_results <- gg_audit_labels(plot)
    results <- merge_audit_results(results, label_results, "labels")
  }

  class(results) <- c("gg_audit_report", "list")
  return(results)
}

#' @export
print.gg_audit_report <- function(x, ...) {
  cat("\n")
  cat("=== GGenemy Audit Report ===\n\n")

  cat("Plot Type:", x$plot_info$geom_types, "\n")
  cat("Layers:", x$plot_info$n_layers, "\n\n")

  total_issues <- length(x$issues) + length(x$warnings)

  if (total_issues == 0) {
    cat("SUCCESS: No issues found!\n")
    cat("Your plot follows data visualization best practices.\n\n")
    return(invisible(x))
  }

  if (length(x$issues) > 0) {
    cat("CRITICAL ISSUES (", length(x$issues), "):\n", sep = "")
    for (i in seq_along(x$issues)) {
      cat("  ", i, ". [", x$issues[[i]]$category, "] ",
          x$issues[[i]]$message, "\n", sep = "")
    }
    cat("\n")
  }

  if (length(x$warnings) > 0) {
    cat("WARNINGS (", length(x$warnings), "):\n", sep = "")
    for (i in seq_along(x$warnings)) {
      cat("  ", i, ". [", x$warnings[[i]]$category, "] ",
          x$warnings[[i]]$message, "\n", sep = "")
    }
    cat("\n")
  }

  if (length(x$suggestions) > 0) {
    cat("SUGGESTIONS:\n")
    for (i in seq_along(x$suggestions)) {
      cat("  - ", x$suggestions[[i]], "\n", sep = "")
    }
    cat("\n")
  }

  cat("Run gg_suggest_fixes() for code recommendations.\n")
  invisible(x)
}

# Helper function to extract plot information
extract_plot_info <- function(plot) {
  built <- ggplot2::ggplot_build(plot)

  geom_types <- sapply(plot$layers, function(l) class(l$geom)[1])

  list(
    n_layers = length(plot$layers),
    geom_types = paste(unique(geom_types), collapse = ", "),
    has_title = !is.null(plot$labels$title),
    has_subtitle = !is.null(plot$labels$subtitle),
    has_caption = !is.null(plot$labels$caption)
  )
}

# Helper function to merge audit results
merge_audit_results <- function(results, new_results, category) {
  if (!is.null(new_results$issues)) {
    results$issues <- c(results$issues, lapply(new_results$issues, function(x) {
      list(category = category, message = x)
    }))
  }
  if (!is.null(new_results$warnings)) {
    results$warnings <- c(results$warnings, lapply(new_results$warnings, function(x) {
      list(category = category, message = x)
    }))
  }
  if (!is.null(new_results$suggestions)) {
    results$suggestions <- c(results$suggestions, new_results$suggestions)
  }
  if (!is.null(new_results$passed)) {
    results$passed <- c(results$passed, new_results$passed)
  }
  return(results)
}
