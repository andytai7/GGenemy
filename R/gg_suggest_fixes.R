#' Generate Code Suggestions to Fix Issues
#'
#' Takes an audit report and generates actionable R code to fix issues.
#' Can also attempt to automatically fix the plot.
#'
#' @param audit_report An object returned by gg_audit(), or a ggplot2 object
#' @param auto_fix Logical. If TRUE, attempts to automatically apply fixes. Default is FALSE.
#' @param copy_to_clipboard Logical. If TRUE, copies suggested code to clipboard. Default is FALSE.
#' @return If auto_fix is TRUE, returns a fixed ggplot2 object. Otherwise returns a list of code suggestions.
#' @export
#' @examples
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
#'   geom_point() +
#'   scale_color_manual(values = c("red", "green", "blue"))
#'
#' # Get suggestions
#' gg_suggest_fixes(p)
#'
#' # Auto-fix the plot
#' p_fixed <- gg_suggest_fixes(p, auto_fix = TRUE)
gg_suggest_fixes <- function(audit_report, auto_fix = FALSE, copy_to_clipboard = FALSE) {

  # If user passed a ggplot directly, run audit first
  if (inherits(audit_report, "gg")) {
    plot <- audit_report
    audit_report <- gg_audit(plot)
  } else if (inherits(audit_report, "gg_audit_report")) {
    plot <- NULL  # We don't have the original plot
  } else {
    stop("Input must be either a ggplot2 object or a gg_audit_report", call. = FALSE)
  }

  # If no issues, return early
  total_issues <- length(audit_report$issues) + length(audit_report$warnings)
  if (total_issues == 0) {
    message("No issues found. Your plot looks good!")
    return(invisible(NULL))
  }

  # Generate fix code
  fixes <- generate_fix_code(audit_report)

  # If auto_fix is requested
  if (auto_fix) {
    if (is.null(plot)) {
      stop("Cannot auto-fix: original plot not available. Pass the ggplot object directly.",
           call. = FALSE)
    }

    fixed_plot <- apply_fixes(plot, audit_report)

    cat("\n=== Auto-Fixed Plot ===\n")
    cat("Applied ", length(fixes$applied), " fixes automatically.\n", sep = "")
    if (length(fixes$manual) > 0) {
      cat("\nNote: ", length(fixes$manual), " issues require manual fixing:\n", sep = "")
      for (i in seq_along(fixes$manual)) {
        cat("  ", i, ". ", fixes$manual[[i]], "\n", sep = "")
      }
    }

    return(fixed_plot)
  }

  # Otherwise, display suggestions
  display_fix_suggestions(fixes, copy_to_clipboard)

  invisible(fixes)
}

#' Generate fix code based on audit results
#' @keywords internal
generate_fix_code <- function(audit_report) {

  fixes <- list(
    color = character(0),
    scales = character(0),
    labels = character(0),
    text = character(0),
    accessibility = character(0),
    applied = character(0),
    manual = character(0)
  )

  all_issues <- c(audit_report$issues, audit_report$warnings)

  for (issue in all_issues) {
    category <- issue$category
    message <- issue$message

    # Color fixes
    if (category == "color") {
      if (grepl("red-green|Red-green", message, ignore.case = TRUE)) {
        fixes$color <- c(fixes$color,
                         "# Replace with colorblind-safe palette",
                         "scale_color_viridis_d(option = 'plasma') +")
        fixes$applied <- c(fixes$applied, "Replaced color scale with viridis")
      }

      if (grepl("too many colors|many colors", message, ignore.case = TRUE)) {
        fixes$color <- c(fixes$color,
                         "# Consider using fewer colors or faceting",
                         "# Option 1: Use facets",
                         "facet_wrap(~your_grouping_variable) +",
                         "# Option 2: Reduce categories with fct_lump from forcats")
        fixes$manual <- c(fixes$manual, "Reduce number of color categories")
      }

      if (grepl("contrast", message, ignore.case = TRUE)) {
        fixes$color <- c(fixes$color,
                         "# Use high-contrast palette",
                         "scale_color_brewer(palette = 'Set1') +")
        fixes$applied <- c(fixes$applied, "Applied high-contrast palette")
      }
    }

    # Scale fixes
    if (category == "scales") {
      if (grepl("does not start at zero|should start at zero", message, ignore.case = TRUE)) {
        fixes$scales <- c(fixes$scales,
                          "# Fix: Start y-axis at zero",
                          "expand_limits(y = 0) +")
        fixes$applied <- c(fixes$applied, "Set y-axis to start at zero")
      }

      if (grepl("truncated", message, ignore.case = TRUE)) {
        fixes$scales <- c(fixes$scales,
                          "# Remove manual y-axis limits",
                          "# Delete any ylim() or scale_y_continuous(limits = ...) calls")
        fixes$manual <- c(fixes$manual, "Remove truncated axis limits")
      }

      if (grepl("dual y-axes|Dual y-axes", message, ignore.case = TRUE)) {
        fixes$scales <- c(fixes$scales,
                          "# Replace dual y-axes with facets",
                          "# Reshape data to long format and use:",
                          "facet_wrap(~variable, scales = 'free_y') +")
        fixes$manual <- c(fixes$manual, "Replace dual y-axes with facets")
      }

      if (grepl("aspect ratio", message, ignore.case = TRUE)) {
        fixes$scales <- c(fixes$scales,
                          "# Fix aspect ratio",
                          "coord_fixed(ratio = 1) +")
        fixes$applied <- c(fixes$applied, "Applied fixed aspect ratio")
      }

      if (grepl("log scale", message, ignore.case = TRUE)) {
        fixes$scales <- c(fixes$scales,
                          "# Add log scale indicator to label",
                          "labs(y = 'Your Variable (log scale)') +")
        fixes$applied <- c(fixes$applied, "Added log scale to label")
      }
    }

    # Label fixes
    if (category == "labels") {
      if (grepl("programming syntax|programming artifact", message, ignore.case = TRUE)) {
        fixes$labels <- c(fixes$labels,
                          "# Clean up labels - replace with human-readable text",
                          "labs(",
                          "  x = 'Descriptive X Label',",
                          "  y = 'Descriptive Y Label',",
                          "  color = 'Group Name'",
                          ") +")
        fixes$manual <- c(fixes$manual, "Replace programming syntax in labels with descriptive text")
      }

      if (grepl("no title|missing.*title", message, ignore.case = TRUE)) {
        fixes$labels <- c(fixes$labels,
                          "# Add descriptive title",
                          "labs(title = 'Your Descriptive Title Here') +")
        fixes$manual <- c(fixes$manual, "Add a descriptive title")
      }

      if (grepl("Legend has no title", message, ignore.case = TRUE)) {
        fixes$labels <- c(fixes$labels,
                          "# Add legend title",
                          "labs(color = 'Your Legend Title') +")
        fixes$manual <- c(fixes$manual, "Add legend title")
      }
    }

    # Text fixes
    if (category == "text") {
      if (grepl("text size.*small|Axis text size", message, ignore.case = TRUE)) {
        fixes$text <- c(fixes$text,
                        "# Increase text size",
                        "theme(axis.text = element_text(size = 11)) +")
        fixes$applied <- c(fixes$applied, "Increased axis text size")
      }

      if (grepl("many.*labels|overlap", message, ignore.case = TRUE)) {
        fixes$text <- c(fixes$text,
                        "# Fix overlapping labels - choose one:",
                        "# Option 1: Rotate labels",
                        "theme(axis.text.x = element_text(angle = 45, hjust = 1)) +",
                        "# Option 2: Flip coordinates",
                        "coord_flip() +",
                        "# Option 3: Reduce categories")
        fixes$manual <- c(fixes$manual, "Fix overlapping axis labels")
      }

      if (grepl("long.*labels", message, ignore.case = TRUE)) {
        fixes$text <- c(fixes$text,
                        "# Wrap long labels",
                        "scale_x_discrete(labels = scales::label_wrap(10)) +")
        fixes$applied <- c(fixes$applied, "Added label wrapping")
      }

      if (grepl("axis label is missing", message, ignore.case = TRUE)) {
        fixes$text <- c(fixes$text,
                        "# Add axis labels",
                        "labs(x = 'X Axis Label', y = 'Y Axis Label') +")
        fixes$manual <- c(fixes$manual, "Add missing axis labels")
      }
    }

    # Accessibility fixes
    if (category == "accessibility") {
      if (grepl("point size.*small|Point size", message, ignore.case = TRUE)) {
        fixes$accessibility <- c(fixes$accessibility,
                                 "# Increase point size",
                                 "geom_point(size = 3) +")
        fixes$applied <- c(fixes$applied, "Increased point size")
      }

      if (grepl("line width.*thin|Line width", message, ignore.case = TRUE)) {
        fixes$accessibility <- c(fixes$accessibility,
                                 "# Increase line width",
                                 "geom_line(size = 1) +")
        fixes$applied <- c(fixes$applied, "Increased line width")
      }

      if (grepl("Color is the only", message, ignore.case = TRUE)) {
        fixes$accessibility <- c(fixes$accessibility,
                                 "# Add redundant encoding with shape",
                                 "aes(shape = your_grouping_variable) +",
                                 "# Or for lines:",
                                 "aes(linetype = your_grouping_variable) +")
        fixes$manual <- c(fixes$manual, "Add shape or linetype for redundant encoding")
      }
    }
  }

  return(fixes)
}

#' Display fix suggestions in a readable format
#' @keywords internal
display_fix_suggestions <- function(fixes, copy_to_clipboard = FALSE) {

  cat("\n")
  cat("====================================\n")
  cat("    GGenemy Fix Suggestions\n")
  cat("====================================\n\n")

  all_code <- character(0)

  # Build the code suggestion
  cat("Copy and add these layers to your plot:\n\n")
  cat("your_plot <- ggplot(...) +\n")
  cat("  geom_*(...) +\n")

  if (length(fixes$color) > 0) {
    cat("\n  # COLOR FIXES\n")
    for (line in fixes$color) {
      cat("  ", line, "\n", sep = "")
      all_code <- c(all_code, line)
    }
  }

  if (length(fixes$scales) > 0) {
    cat("\n  # SCALE FIXES\n")
    for (line in fixes$scales) {
      cat("  ", line, "\n", sep = "")
      all_code <- c(all_code, line)
    }
  }

  if (length(fixes$labels) > 0) {
    cat("\n  # LABEL FIXES\n")
    for (line in fixes$labels) {
      cat("  ", line, "\n", sep = "")
      all_code <- c(all_code, line)
    }
  }

  if (length(fixes$text) > 0) {
    cat("\n  # TEXT FIXES\n")
    for (line in fixes$text) {
      cat("  ", line, "\n", sep = "")
      all_code <- c(all_code, line)
    }
  }

  if (length(fixes$accessibility) > 0) {
    cat("\n  # ACCESSIBILITY FIXES\n")
    for (line in fixes$accessibility) {
      cat("  ", line, "\n", sep = "")
      all_code <- c(all_code, line)
    }
  }

  cat("\n  theme_minimal()  # Optional: clean theme\n")

  if (length(fixes$manual) > 0) {
    cat("\n")
    cat("====================================\n")
    cat("  Manual Fixes Required:\n")
    cat("====================================\n")
    for (i in seq_along(fixes$manual)) {
      cat(i, ". ", fixes$manual[[i]], "\n", sep = "")
    }
  }

  cat("\n")
  cat("TIP: Use auto_fix = TRUE to automatically apply some fixes:\n")
  cat("     fixed_plot <- gg_suggest_fixes(your_plot, auto_fix = TRUE)\n")
  cat("\n")

}

#' Apply automatic fixes to a plot
#' @keywords internal
apply_fixes <- function(plot, audit_report) {

  fixed_plot <- plot

  all_issues <- c(audit_report$issues, audit_report$warnings)

  for (issue in all_issues) {
    category <- issue$category
    message <- issue$message

    # Auto-fix: Replace problematic colors
    if (category == "color" && grepl("red-green|Red-green", message, ignore.case = TRUE)) {
      fixed_plot <- fixed_plot +
        ggplot2::scale_color_viridis_d(option = "plasma") +
        ggplot2::scale_fill_viridis_d(option = "plasma")
    }

    # Auto-fix: Start bar charts at zero
    if (category == "scales" && grepl("does not start at zero", message, ignore.case = TRUE)) {
      fixed_plot <- fixed_plot + ggplot2::expand_limits(y = 0)
    }

    # Auto-fix: Increase small text
    if (category == "text" && grepl("text size.*small", message, ignore.case = TRUE)) {
      fixed_plot <- fixed_plot +
        ggplot2::theme(axis.text = ggplot2::element_text(size = 11))
    }

    # Auto-fix: Log scale label
    if (category == "scales" && grepl("log scale", message, ignore.case = TRUE)) {
      current_y_label <- fixed_plot$labels$y
      if (is.null(current_y_label)) {
        current_y_label <- "Value"
      }
      if (!grepl("log", current_y_label, ignore.case = TRUE)) {
        fixed_plot <- fixed_plot +
          ggplot2::labs(y = paste0(current_y_label, " (log scale)"))
      }
    }
  }

  return(fixed_plot)
}
