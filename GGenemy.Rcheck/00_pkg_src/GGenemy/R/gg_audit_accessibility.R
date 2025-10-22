#' Comprehensive Accessibility Audit
#'
#' Checks overall accessibility including color, contrast, and readability.
#'
#' @param plot A ggplot2 object
#' @return A list of issues, warnings, and suggestions
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg)) + geom_point(size = 1)
#' gg_audit_accessibility(p)
gg_audit_accessibility <- function(plot) {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  results <- list(
    issues = character(0),
    warnings = character(0),
    suggestions = character(0)
  )

  # Check point sizes
  geom_types <- sapply(plot$layers, function(l) class(l$geom)[1])

  if (any(grepl("GeomPoint", geom_types))) {
    point_layers <- which(grepl("GeomPoint", geom_types))

    for (i in point_layers) {
      size <- plot$layers[[i]]$aes_params$size
      if (!is.null(size) && size < 2) {
        results$warnings <- c(results$warnings,
                              paste0("Point size (", size, ") may be too small for some viewers"))
        results$suggestions <- c(results$suggestions,
                                 "Increase point size: geom_point(size = 3)")
      }
    }
  }

  # Check line widths
  if (any(grepl("GeomLine|GeomPath", geom_types))) {
    line_layers <- which(grepl("GeomLine|GeomPath", geom_types))

    for (i in line_layers) {
      size <- plot$layers[[i]]$aes_params$size
      if (!is.null(size) && size < 0.5) {
        results$warnings <- c(results$warnings,
                              "Line width may be too thin")
        results$suggestions <- c(results$suggestions,
                                 "Increase line width: geom_line(size = 1)")
      }
    }
  }

  # Check background contrast
  theme_elements <- plot$theme

  bg_color <- theme_elements$panel.background$fill %||% "white"

  if (tolower(bg_color) == "white" || tolower(bg_color) == "#ffffff") {
    results$suggestions <- c(results$suggestions,
                             "White backgrounds work well, but ensure sufficient contrast with data elements")
  }

  # Check for color as only distinguishing feature
  built <- ggplot2::ggplot_build(plot)
  uses_color <- any(sapply(built$data, function(d) "colour" %in% names(d)))
  uses_shape <- any(sapply(built$data, function(d) "shape" %in% names(d)))
  uses_linetype <- any(sapply(built$data, function(d) "linetype" %in% names(d)))

  if (uses_color && !uses_shape && !uses_linetype) {
    results$warnings <- c(results$warnings,
                          "Color is the only visual distinction between groups")
    results$suggestions <- c(results$suggestions,
                             "Add shape or linetype for redundant encoding: aes(shape = group) or aes(linetype = group)")
  }

  return(results)
}
