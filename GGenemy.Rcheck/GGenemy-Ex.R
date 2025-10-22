pkgname <- "GGenemy"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
base::assign(".ExTimings", "GGenemy-Ex.timings", pos = 'CheckExEnv')
base::cat("name\tuser\tsystem\telapsed\n", file=base::get(".ExTimings", pos = 'CheckExEnv'))
base::assign(".format_ptime",
function(x) {
  if(!is.na(x[4L])) x[1L] <- x[1L] + x[4L]
  if(!is.na(x[5L])) x[2L] <- x[2L] + x[5L]
  options(OutDec = '.')
  format(x[1L:3L], digits = 7L)
},
pos = 'CheckExEnv')

### * </HEADER>
library('GGenemy')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("gg_audit")
### * gg_audit

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit
### Title: Comprehensive Audit of ggplot2 Visualization
### Aliases: gg_audit

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_manual(values = c("red", "green", "blue"))
report <- gg_audit(p)
print(report)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_audit_accessibility")
### * gg_audit_accessibility

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit_accessibility
### Title: Comprehensive Accessibility Audit
### Aliases: gg_audit_accessibility

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) + geom_point(size = 1)
gg_audit_accessibility(p)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit_accessibility", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_audit_color")
### * gg_audit_color

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit_color
### Title: Audit Color Palette for Accessibility Issues
### Aliases: gg_audit_color

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_manual(values = c("red", "green", "blue"))
gg_audit_color(p)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit_color", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_audit_labels")
### * gg_audit_labels

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit_labels
### Title: Audit Plot Labels and Annotations
### Aliases: gg_audit_labels

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point()
gg_audit_labels(p)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit_labels", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_audit_scales")
### * gg_audit_scales

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit_scales
### Title: Audit Scales and Axes for Misleading Practices
### Aliases: gg_audit_scales

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg)) +
  geom_point() +
  ylim(15, 35)
gg_audit_scales(p)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit_scales", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_audit_text")
### * gg_audit_text

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_audit_text
### Title: Audit Text Elements for Readability
### Aliases: gg_audit_text

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(x = rownames(mtcars), y = mpg)) +
  geom_col() +
  theme(axis.text.x = element_text(size = 6))
gg_audit_text(p)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_audit_text", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_simulate_cvd")
### * gg_simulate_cvd

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_simulate_cvd
### Title: Simulate Colorblind Vision
### Aliases: gg_simulate_cvd

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_manual(values = c("red", "green", "blue"))
gg_simulate_cvd(p, type = "deutan")



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_simulate_cvd", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
cleanEx()
nameEx("gg_suggest_fixes")
### * gg_suggest_fixes

flush(stderr()); flush(stdout())

base::assign(".ptime", proc.time(), pos = "CheckExEnv")
### Name: gg_suggest_fixes
### Title: Generate Code Suggestions to Fix Issues
### Aliases: gg_suggest_fixes

### ** Examples

library(ggplot2)
p <- ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_manual(values = c("red", "green", "blue"))

# Get suggestions
gg_suggest_fixes(p)

# Auto-fix the plot
p_fixed <- gg_suggest_fixes(p, auto_fix = TRUE)



base::assign(".dptime", (proc.time() - get(".ptime", pos = "CheckExEnv")), pos = "CheckExEnv")
base::cat("gg_suggest_fixes", base::get(".format_ptime", pos = 'CheckExEnv')(get(".dptime", pos = "CheckExEnv")), "\n", file=base::get(".ExTimings", pos = 'CheckExEnv'), append=TRUE, sep="\t")
### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
