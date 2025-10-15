#' Audit Color Palette for Accessibility Issues
#'
#' Checks if a ggplot2 object uses colors that may be problematic
#' for colorblind users and provides detailed analysis.
#'
#' @importFrom stats sd
#' @param plot A ggplot2 object
#' @return A list of issues, warnings, and suggestions
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_manual(values = c("red", "green", "blue"))
#' gg_audit_color(p)
gg_audit_color <- function(plot) {

  if (!inherits(plot, "gg")) {
    stop("Input must be a ggplot2 object", call. = FALSE)
  }

  results <- list(
    issues = character(0),
    warnings = character(0),
    suggestions = character(0)
  )

  # Extract colors from the plot
  built <- ggplot2::ggplot_build(plot)

  # Get unique colors used
  all_colors <- unique(unlist(lapply(built$data, function(layer) {
    c(layer$colour, layer$fill)
  })))
  all_colors <- all_colors[!is.na(all_colors) & all_colors != "NA"]

  if (length(all_colors) == 0) {
    return(results)
  }

  # Convert colors to hex for analysis
  hex_colors <- tryCatch({
    grDevices::col2rgb(all_colors)
    all_colors
  }, error = function(e) {
    results$warnings <- c(results$warnings,
                          "Could not parse some colors for analysis")
    character(0)
  })

  # Check 1: Red-Green combinations
  has_red <- any(grepl("red|#[Ff][0-9A-Fa-f]{2}[0-9A-Fa-f]{2}", hex_colors, ignore.case = TRUE))
  has_green <- any(grepl("green|#[0-9A-Fa-f]{2}[Ff][0-9A-Fa-f]{2}", hex_colors, ignore.case = TRUE))

  if (has_red && has_green) {
    results$issues <- c(results$issues,
                        "Red-green color combination detected (problematic for 8% of males with deuteranopia/protanopia)")
    results$suggestions <- c(results$suggestions,
                             "Use colorblind-safe palettes: viridis::scale_color_viridis() or RColorBrewer")
  }

  # Check 2: Too many colors
  if (length(hex_colors) > 7) {
    results$warnings <- c(results$warnings,
                          paste0("Using ", length(hex_colors), " colors may be difficult to distinguish"))
    results$suggestions <- c(results$suggestions,
                             "Consider grouping categories or using facets instead of many colors")
  }

  # Check 3: Check for rainbow palette (often problematic)
  if (length(hex_colors) >= 6) {
    # Simple heuristic: if we have many colors spread across hues
    rgb_matrix <- grDevices::col2rgb(hex_colors)
    if (max(apply(rgb_matrix, 1, sd)) > 100) {
      results$warnings <- c(results$warnings,
                            "Possible rainbow palette detected - these can be perceptually non-uniform")
      results$suggestions <- c(results$suggestions,
                               "Consider perceptually uniform palettes like viridis, plasma, or cividis")
    }
  }

  # Check 4: Contrast analysis
  if (length(hex_colors) >= 2) {
    contrast_issues <- check_color_contrast(hex_colors)
    if (length(contrast_issues) > 0) {
      results$warnings <- c(results$warnings, contrast_issues)
    }
  }

  # Check 5: Colorblind simulation
  cvd_issues <- check_cvd_issues(hex_colors)
  if (length(cvd_issues) > 0) {
    results$warnings <- c(results$warnings, cvd_issues)
    results$suggestions <- c(results$suggestions,
                             "Test your plot with gg_simulate_cvd() to see how colorblind users perceive it")
  }

  return(results)
}

# Helper function to check color contrast
check_color_contrast <- function(colors) {
  issues <- character(0)

  if (length(colors) < 2) return(issues)

  # Simple contrast check using luminance
  rgb_matrix <- grDevices::col2rgb(colors) / 255

  # Calculate relative luminance
  luminance <- apply(rgb_matrix, 2, function(rgb) {
    # sRGB to linear RGB
    rgb_linear <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
    # Calculate luminance
    0.2126 * rgb_linear[1] + 0.7152 * rgb_linear[2] + 0.0722 * rgb_linear[3]
  })

  # Check for low contrast pairs
  low_contrast <- FALSE
  for (i in 1:(length(luminance) - 1)) {
    for (j in (i + 1):length(luminance)) {
      ratio <- (max(luminance[i], luminance[j]) + 0.05) / (min(luminance[i], luminance[j]) + 0.05)
      if (ratio < 3) {  # WCAG minimum for large text
        low_contrast <- TRUE
        break
      }
    }
    if (low_contrast) break
  }

  if (low_contrast) {
    issues <- c(issues, "Some colors have low contrast - may be hard to distinguish")
  }

  return(issues)
}

# Helper function to check CVD issues
check_cvd_issues <- function(colors) {
  issues <- character(0)

  if (length(colors) < 2) return(issues)

  tryCatch({
    # Simulate deuteranopia (most common)
    deutan_colors <- colorspace::deutan(colors, severity = 1)

    # Check if colors become too similar
    if (length(unique(deutan_colors)) < length(unique(colors))) {
      issues <- c(issues,
                  "Some colors become indistinguishable under deuteranopia (green-blind) simulation")
    }
  }, error = function(e) {
    # Silently continue if colorspace has issues
  })

  return(issues)
}
