#' Audit Scales and Axes for Misleading Practices
#'
#' Checks for truncated axes, inappropriate transformations,
#' and other scale-related issues that can mislead viewers.
#'
#' @param plot A ggplot2 object
#' @return A list of issues, warnings, and suggestions
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point() +
#'   ylim(15, 35)
#' gg_audit_scales(p)
gg_audit_scales <- function(plot) {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  results <- list(
    issues = character(0),
    warnings = character(0),
    suggestions = character(0)
  )

  built <- ggplot2::ggplot_build(plot)

  # Check y-axis starts at zero for bar charts
  geom_types <- sapply(plot$layers, function(l) class(l$geom)[1])

  if (any(grepl("GeomBar|GeomCol", geom_types))) {
    y_range <- built$layout$panel_params[[1]]$y.range

    if (!is.null(y_range) && y_range[1] != 0) {
      results$issues <- c(results$issues,
                          paste0("Bar chart y-axis does not start at zero (starts at ",
                                 round(y_range[1], 2), ")"))
      results$suggestions <- c(results$suggestions,
                               "Bar charts should start at zero. Remove ylim() or use expand_limits(y = 0)")
    }
  }

  # Check for truncated axes on other plots
  if (!any(grepl("GeomBar|GeomCol", geom_types))) {
    # For scatter plots, line plots, etc., check if axis is unnecessarily truncated
    if (!is.null(built$layout$panel_params[[1]]$y.range)) {
      y_range <- built$layout$panel_params[[1]]$y.range
      y_data_range <- range(unlist(lapply(built$data, function(d) d$y)), na.rm = TRUE)

      # Check if the axis limits are much tighter than the data
      data_span <- diff(y_data_range)
      axis_span <- diff(y_range)

      if (axis_span < data_span * 1.5 && y_range[1] > y_data_range[1]) {
        results$warnings <- c(results$warnings,
                              "Y-axis appears to be truncated, which may exaggerate differences")
      }
    }
  }

  # Check for dual y-axes (generally discouraged)
  if (length(plot$scales$scales) > 0) {
    scale_types <- sapply(plot$scales$scales, function(s) class(s)[1])
    y_scales <- sum(grepl("ScaleContinuousPosition", scale_types) &
                      sapply(plot$scales$scales, function(s) s$aesthetics[1] == "y"))

    if (y_scales > 1) {
      results$issues <- c(results$issues,
                          "Dual y-axes detected - these are often misleading and should be avoided")
      results$suggestions <- c(results$suggestions,
                               "Consider: 1) Using facets, 2) Normalizing data, or 3) Using separate plots")
    }
  }

  # Check for aspect ratio issues
  if (any(grepl("GeomPoint|GeomLine", geom_types))) {
    x_range <- built$layout$panel_params[[1]]$x.range
    y_range <- built$layout$panel_params[[1]]$y.range

    if (!is.null(x_range) && !is.null(y_range)) {
      aspect_ratio <- diff(y_range) / diff(x_range)

      if (aspect_ratio > 3 || aspect_ratio < 0.33) {
        results$warnings <- c(results$warnings,
                              paste0("Unusual aspect ratio (", round(aspect_ratio, 2),
                                     ") may distort perception of relationships"))
        results$suggestions <- c(results$suggestions,
                                 "Consider using coord_fixed() for appropriate aspect ratio")
      }
    }
  }

  # Check for log scales without indication
  has_log_scale <- any(sapply(plot$scales$scales, function(s) {
    inherits(s, "ScaleContinuous") && !is.null(s$trans) &&
      (s$trans$name == "log-10" || s$trans$name == "log-2")
  }))

  if (has_log_scale) {
    axis_labels <- c(plot$labels$x, plot$labels$y)
    if (!any(grepl("log|Log|LOG", axis_labels))) {
      results$warnings <- c(results$warnings,
                            "Log scale detected but not clearly indicated in axis labels")
      results$suggestions <- c(results$suggestions,
                               "Add 'log' to axis label: labs(y = 'Value (log scale)')")
    }
  }

  return(results)
}
