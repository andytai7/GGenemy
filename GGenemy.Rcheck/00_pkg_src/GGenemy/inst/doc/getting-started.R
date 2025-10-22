## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----eval = FALSE-------------------------------------------------------------
# # Install from GitHub
# devtools::install_github("yourusername/GGenemy")

## ----setup--------------------------------------------------------------------
library(GGenemy)
library(ggplot2)

## ----problematic-plot---------------------------------------------------------
# A plot using red and green (problematic for colorblind users)
problematic_plot <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size = 2) +
  scale_color_manual(values = c("red", "green", "blue"))

problematic_plot

## ----audit--------------------------------------------------------------------
report <- gg_audit(problematic_plot)
print(report)

## ----color-audit--------------------------------------------------------------
gg_audit_color(problematic_plot)

## ----simulate-cvd-------------------------------------------------------------
# Deuteranopia (most common type of colorblindness)
gg_simulate_cvd(problematic_plot, type = "deutan")

## ----suggestions--------------------------------------------------------------
gg_suggest_fixes(problematic_plot)

## ----improved-plot------------------------------------------------------------
improved_plot <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point(size = 3) +
  scale_color_viridis_d(option = "plasma") +
  labs(
    title = "Car Weight vs Fuel Efficiency",
    x = "Weight (1000 lbs)",
    y = "Miles Per Gallon",
    color = "Cylinders"
  ) +
  theme_minimal()

improved_plot

## ----check-improved-----------------------------------------------------------
gg_audit(improved_plot)

## ----simulate-improved--------------------------------------------------------
gg_simulate_cvd(improved_plot, type = "deutan")

