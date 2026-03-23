# 🏀 NBA Sports Analytics Dashboard

An interactive **R Shiny** web app for exploring NBA player and team statistics with dynamic charts, filters, and player comparisons.

![R](https://img.shields.io/badge/R-4.3%2B-blue?logo=r)
![Shiny](https://img.shields.io/badge/Shiny-1.8%2B-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## ✨ Features

| Tab | What you get |
|-----|-------------|
| **Player Stats** | Value boxes for leaders, interactive scatter plot with custom axes, full searchable table |
| **Team Standings** | East / West conference tables + Win% bar chart |
| **Compare** | Side-by-side bar comparison for 2–3 players |
| **About** | App info and data sources |

---

## 🚀 Quick Start

```r
# 1. Clone the repo
# git clone https://github.com/YOUR_USERNAME/sports_analytics_shiny.git
# cd sports_analytics_shiny

# 2. Install dependencies
source("install_packages.R")

# 3. Launch the app
shiny::runApp()
```

---

## 📁 Project Structure

```
sports_analytics_shiny/
├── app.R                  # Main Shiny app (UI + Server)
├── install_packages.R     # One-time dependency installer
├── R/
│   └── helpers.R          # Utility functions & constants
├── data/
│   ├── nba_stats.csv      # Player stats (2022-24)
│   └── nba_standings.csv  # Team standings (2023-24)
├── www/                   # Static assets (CSS, images)
├── .gitignore
└── README.md
```

---

## 🔄 Using Live Data

Replace the CSV files with real data using the [`hoopR`](https://hoopr.sportsdataverse.org/) package:

```r
install.packages("hoopR")
library(hoopR)

# Current season player stats
player_stats <- nba_player_box(seasons = 2024)
write.csv(player_stats, "data/nba_stats.csv", row.names = FALSE)
```

---

## ☁️ Deploy to shinyapps.io

```r
install.packages("rsconnect")
library(rsconnect)

rsconnect::setAccountInfo(name   = "YOUR_ACCOUNT",
                          token  = "YOUR_TOKEN",
                          secret = "YOUR_SECRET")

rsconnect::deployApp()
```

---

## 🤝 Contributing

Pull requests are welcome! Open an issue first for major changes.

---

## 📄 License

[MIT](LICENSE)
