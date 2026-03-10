# one-time package install for this app
pkgs <- c("shiny", "bslib", "dplyr", "plotly", "readr", "lubridate")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}
cat("Done. Run: shiny::runApp('app.R')\n")
