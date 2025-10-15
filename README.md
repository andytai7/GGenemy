
# GGenemy

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

> **Enemy of Bad Practices in Data Visualization**

GGenemy is an R package that audits your ggplot2 visualizations for
accessibility issues, misleading practices, and readability problems.
Think of it as a linter for your data visualizations.

## Why GGenemy?

Data visualizations can inadvertently mislead or exclude audiences
through:

- 🎨 **Poor color choices** that are invisible to colorblind users (~8%
  of males)
- 📊 **Misleading scales** like truncated axes or dual y-axes
- 📝 **Readability issues** like tiny text or overlapping labels
- ♿ **Accessibility barriers** that make charts hard to interpret

GGenemy catches these issues automatically and suggests fixes.

## Installation

``` r
# Install from GitHub (not on CRAN yet)
# install.packages("devtools")
devtools::install_github("andytai7/GGenemy")
```

## Quick Start

``` r
library(GGenemy)
library(ggplot2)

# Create a plot with some issues
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_manual(values = c("red", "green", "blue"))

# Run comprehensive audit
report <- gg_audit(p)
print(report)
```

## Key Features

### 🔍 Comprehensive Auditing

``` r
# Check everything
gg_audit(your_plot)

# Check specific aspects
gg_audit(your_plot, checks = c("color", "scales"))
```

### 🎨 Color Accessibility

Detects problematic color combinations and suggests colorblind-safe
alternatives:

``` r
gg_audit_color(your_plot)
```

### 👁️ Colorblind Simulation

See how your plot appears to colorblind users:

``` r
# Simulate different types of color vision deficiency
gg_simulate_cvd(your_plot, type = "deutan")  # green-blind
gg_simulate_cvd(your_plot, type = "protan")  # red-blind
gg_simulate_cvd(your_plot, type = "tritan")  # blue-blind
```

### 📊 Scale & Axis Checks

Catches misleading practices:

- Truncated axes on bar charts
- Dual y-axes
- Inappropriate aspect ratios
- Unlabeled log scales

``` r
gg_audit_scales(your_plot)
```

### 🔧 Automatic Fixes

Get code suggestions or apply fixes automatically:

``` r
# Get copy-paste code suggestions
gg_suggest_fixes(your_plot)

# Apply automatic fixes
fixed_plot <- gg_suggest_fixes(your_plot, auto_fix = TRUE)
```

### ♿ Accessibility Auditing

Checks for:

- Text size and readability
- Point/line sizes
- Redundant encoding (not relying on color alone)
- Label clarity

``` r
gg_audit_accessibility(your_plot)
```

## Example Workflow

``` r
library(ggplot2)
library(GGenemy)

# Create a problematic plot
problematic_plot <- ggplot(mtcars, aes(x = wt, y = mpg, color = factor(cyl))) +
  geom_point(size = 1) +
  scale_color_manual(values = c("red", "green", "blue")) +
  labs(title = "Plot", x = "wt", y = "mpg")

# Audit it
report <- gg_audit(problematic_plot)

# Get fix suggestions
gg_suggest_fixes(problematic_plot)

# Apply automatic fixes
improved_plot <- gg_suggest_fixes(problematic_plot, auto_fix = TRUE)

# View the improved plot
print(improved_plot)
```

## Philosophy

GGenemy believes in:

1.  **Accessibility First**: Visualizations should be perceivable by
    everyone
2.  **Honest Representation**: Data should be presented without
    distortion
3.  **Clarity Over Aesthetics**: Readability trumps flashiness
4.  **Constructive Guidance**: We suggest fixes, not just criticisms

## Roadmap

- [x] Color accessibility checking
- [x] Colorblind vision simulation
- [x] Scale and axis auditing
- [x] Text readability checks
- [x] Automatic fix suggestions
- [ ] Integration with RMarkdown/Quarto for batch auditing
- [ ] Custom rule sets
- [ ] Interactive Shiny app for exploration
- [ ] AI-powered suggestions (GGenemy.ai extension)

## Contributing

GGenemy is in active development! Contributions are welcome:

- 🐛 [Report bugs](https://github.com/yourusername/GGenemy/issues)
- 💡 [Suggest features](https://github.com/yourusername/GGenemy/issues)
- 📝 Improve documentation
- 🔧 Submit pull requests

## Related Packages

- [colorspace](https://colorspace.r-forge.r-project.org/) - Color vision
  deficiency simulation
- [viridis](https://sjmgarnier.github.io/viridis/) - Colorblind-safe
  palettes
- [ggplot2](https://ggplot2.tidyverse.org/) - The grammar of graphics

## Citation

``` r
citation("GGenemy")
```

## License

MIT © Andy Man Yeung Tai

------------------------------------------------------------------------

**GGenemy**: Making data visualization more accessible, honest, and
clear. 🎨⚔️
