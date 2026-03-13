# one-time package install for this app
user_lib <- file.path(getwd(), ".Rlib")
dir.create(user_lib, recursive = TRUE, showWarnings = FALSE)
.libPaths(c(user_lib, .libPaths()))

pkgs <- c("shiny", "bslib", "dplyr", "plotly", "readr", "DT")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org", lib = user_lib)
  }
}

cat("Done. Run: shiny::runApp('app.R')\n")
