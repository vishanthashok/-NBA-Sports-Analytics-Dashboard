# Install all dependencies by running this script once
# Non-interactive R has no default CRAN mirror; set one explicitly.
options(repos = c(CRAN = "https://cloud.r-project.org"))

packages <- c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "dplyr",
  "tidyr",
  "plotly",
  "DT"
)

installed <- rownames(installed.packages())
to_install <- packages[!packages %in% installed]

if (length(to_install) > 0) {
  message("Installing: ", paste(to_install, collapse = ", "))
  install.packages(to_install)
} else {
  message("All packages already installed!")
}

message("Run the app with: shiny::runApp()")
