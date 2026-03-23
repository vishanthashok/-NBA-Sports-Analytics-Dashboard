# ============================================================
# app.R — NBA Sports Analytics Dashboard
# ============================================================
# Run with: shiny::runApp()
# ============================================================

library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(DT)
library(plotly)

source("R/helpers.R")

# ── Data ────────────────────────────────────────────────────
players  <- read.csv("data/nba_stats.csv",    stringsAsFactors = FALSE)
standings <- read.csv("data/nba_standings.csv", stringsAsFactors = FALSE)

players <- players |>
  mutate(Score = compute_score(Points, Assists, Rebounds, Steals, Blocks, FG_Pct),
         Tier  = efficiency_label(Score))

seasons <- sort(unique(players$Season), decreasing = TRUE)

# ── UI ──────────────────────────────────────────────────────
ui <- dashboardPage(
  skin = "blue",

  dashboardHeader(title = "🏀 NBA Analytics"),

  dashboardSidebar(
    sidebarMenu(
      menuItem("Player Stats",   tabName = "players",   icon = icon("user")),
      menuItem("Team Standings", tabName = "standings", icon = icon("trophy")),
      menuItem("Compare",        tabName = "compare",   icon = icon("chart-bar")),
      menuItem("About",          tabName = "about",     icon = icon("info-circle"))
    ),
    hr(),
    selectInput("season_filter", "Season", choices = seasons, selected = seasons[1])
  ),

  dashboardBody(
    tags$head(tags$style(HTML("
      .content-wrapper { background: #f4f6f9; }
      .box { border-radius: 8px; }
      .value-box .icon { font-size: 2.5rem; }
    "))),

    tabItems(

      # ── Tab 1: Player Stats ──────────────────────────────
      tabItem(tabName = "players",
        fluidRow(
          valueBoxOutput("vb_top_scorer"),
          valueBoxOutput("vb_top_assists"),
          valueBoxOutput("vb_top_rebounder")
        ),
        fluidRow(
          box(width = 4, title = "Filters", status = "primary", solidHeader = TRUE,
            selectInput("position_filter", "Position",
                        choices = c("All", sort(unique(players$Position)))),
            sliderInput("min_games", "Min Games Played",
                        min = 1, max = 82, value = 30),
            selectInput("stat_x", "X Axis Stat",
                        choices = names(stat_labels), selected = "Points"),
            selectInput("stat_y", "Y Axis Stat",
                        choices = names(stat_labels), selected = "Assists")
          ),
          box(width = 8, title = "Player Scatter Plot", status = "primary",
              solidHeader = TRUE, plotlyOutput("scatter_plot", height = "350px"))
        ),
        fluidRow(
          box(width = 12, title = "Player Stats Table", status = "info",
              solidHeader = TRUE,
              DTOutput("player_table"))
        )
      ),

      # ── Tab 2: Standings ────────────────────────────────
      tabItem(tabName = "standings",
        fluidRow(
          box(width = 6, title = "Eastern Conference", status = "primary",
              solidHeader = TRUE,
              DTOutput("east_table")),
          box(width = 6, title = "Western Conference", status = "danger",
              solidHeader = TRUE,
              DTOutput("west_table"))
        ),
        fluidRow(
          box(width = 12, title = "Win % by Team", status = "warning",
              solidHeader = TRUE,
              plotlyOutput("standings_bar", height = "400px"))
        )
      ),

      # ── Tab 3: Compare Players ──────────────────────────
      tabItem(tabName = "compare",
        fluidRow(
          box(width = 4, title = "Select Players to Compare", status = "primary",
              solidHeader = TRUE,
              selectInput("player1", "Player 1",
                          choices = sort(unique(players$Player)),
                          selected = "LeBron James"),
              selectInput("player2", "Player 2",
                          choices = sort(unique(players$Player)),
                          selected = "Stephen Curry"),
              selectInput("player3", "Player 3 (optional)",
                          choices = c("None", sort(unique(players$Player))),
                          selected = "None")
          ),
          box(width = 8, title = "Radar / Bar Comparison", status = "info",
              solidHeader = TRUE,
              plotlyOutput("compare_plot", height = "420px"))
        )
      ),

      # ── Tab 4: About ────────────────────────────────────
      tabItem(tabName = "about",
        fluidRow(
          box(width = 12, title = "About This App", status = "info",
              solidHeader = TRUE,
              HTML("
                <h4>🏀 NBA Sports Analytics Dashboard</h4>
                <p>An interactive Shiny application to explore NBA player and team
                statistics.</p>
                <h5>Features</h5>
                <ul>
                  <li>Interactive scatter plots with custom axis selection</li>
                  <li>Searchable, sortable player stats table</li>
                  <li>Team standings by conference</li>
                  <li>Side-by-side player comparison</li>
                </ul>
                <h5>Data</h5>
                <p>Sample data based on the 2023-24 and 2022-23 NBA seasons.
                   Replace <code>data/nba_stats.csv</code> and
                   <code>data/nba_standings.csv</code> with live data from the
                   <a href='https://www.nba.com/stats' target='_blank'>NBA Stats API</a>
                   or the <code>hoopR</code> package.</p>
                <h5>Tech Stack</h5>
                <p>R · Shiny · shinydashboard · ggplot2 · plotly · DT · dplyr</p>
                <hr>
                <p><small>Built as an open-source sports analytics project.
                  Contributions welcome on GitHub!</small></p>
              ")
          )
        )
      )
    )
  )
)

# ── Server ──────────────────────────────────────────────────
server <- function(input, output, session) {

  # Reactive filtered data
  filtered_players <- reactive({
    df <- players |> filter(Season == input$season_filter,
                             Games  >= input$min_games)
    if (input$position_filter != "All")
      df <- df |> filter(Position == input$position_filter)
    df
  })

  # Value Boxes
  output$vb_top_scorer <- renderValueBox({
    top <- filtered_players() |> slice_max(Points, n = 1)
    valueBox(paste0(top$Points[1], " PPG"), top$Player[1],
             icon = icon("fire"), color = "red")
  })

  output$vb_top_assists <- renderValueBox({
    top <- filtered_players() |> slice_max(Assists, n = 1)
    valueBox(paste0(top$Assists[1], " APG"), top$Player[1],
             icon = icon("hands-helping"), color = "green")
  })

  output$vb_top_rebounder <- renderValueBox({
    top <- filtered_players() |> slice_max(Rebounds, n = 1)
    valueBox(paste0(top$Rebounds[1], " RPG"), top$Player[1],
             icon = icon("arrows-alt-v"), color = "blue")
  })

  # Scatter plot
  output$scatter_plot <- renderPlotly({
    df  <- filtered_players()
    x_col <- input$stat_x
    y_col <- input$stat_y

    p <- ggplot(df, aes(x = .data[[x_col]], y = .data[[y_col]],
                        color = Tier, text = paste0(Player, "\n", Team))) +
      geom_point(size = 3, alpha = 0.8) +
      scale_color_manual(values = c("Elite" = "#e63946", "All-Star" = "#f4a261",
                                     "Starter" = "#457b9d", "Bench" = "#a8dadc")) +
      labs(x = stat_labels[x_col], y = stat_labels[y_col], color = "Tier") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })

  # Player table
  output$player_table <- renderDT({
    filtered_players() |>
      select(Player, Team, Position, Games, Points, Assists, Rebounds,
             Steals, Blocks, FG_Pct, Score, Tier) |>
      datatable(rownames = FALSE, filter = "top",
                options = list(pageLength = 10, scrollX = TRUE)) |>
      formatRound(columns = c("FG_Pct", "Score"), digits = 2) |>
      formatStyle("Tier",
        backgroundColor = styleEqual(
          c("Elite", "All-Star", "Starter", "Bench"),
          c("#f8d7da", "#fff3cd", "#d1ecf1", "#e2e3e5")))
  })

  # Standings tables
  output$east_table <- renderDT({
    standings |>
      filter(Conference == "East") |>
      arrange(desc(Wins)) |>
      mutate(Rank = row_number()) |>
      select(Rank, Team, Wins, Losses, WinPct, PointsFor, PointsAgainst, Diff) |>
      datatable(rownames = FALSE, options = list(pageLength = 15, dom = "t")) |>
      formatRound(c("WinPct", "PointsFor", "PointsAgainst", "Diff"), 1)
  })

  output$west_table <- renderDT({
    standings |>
      filter(Conference == "West") |>
      arrange(desc(Wins)) |>
      mutate(Rank = row_number()) |>
      select(Rank, Team, Wins, Losses, WinPct, PointsFor, PointsAgainst, Diff) |>
      datatable(rownames = FALSE, options = list(pageLength = 15, dom = "t")) |>
      formatRound(c("WinPct", "PointsFor", "PointsAgainst", "Diff"), 1)
  })

  # Standings bar
  output$standings_bar <- renderPlotly({
    df <- standings |> arrange(desc(WinPct)) |>
      mutate(Team = factor(Team, levels = Team))

    p <- ggplot(df, aes(x = Team, y = WinPct, fill = Conference,
                         text = paste0(Team, "\n", Wins, "-", Losses))) +
      geom_col() +
      scale_fill_manual(values = conf_colours) +
      geom_hline(yintercept = 0.5, linetype = "dashed", color = "grey40") +
      coord_flip() +
      labs(x = NULL, y = "Win Percentage", fill = "Conference") +
      theme_minimal(base_size = 12)

    ggplotly(p, tooltip = "text")
  })

  # Comparison plot
  output$compare_plot <- renderPlotly({
    chosen <- c(input$player1, input$player2)
    if (input$player3 != "None") chosen <- c(chosen, input$player3)

    df <- players |>
      filter(Player %in% chosen) |>
      group_by(Player) |>
      summarise(across(c(Points, Assists, Rebounds, Steals, Blocks, FG_Pct),
                        mean, .names = "{.col}"), .groups = "drop") |>
      tidyr::pivot_longer(-Player, names_to = "Stat", values_to = "Value") |>
      mutate(Stat = factor(Stat, levels = c("Points","Assists","Rebounds",
                                             "Steals","Blocks","FG_Pct")))

    p <- ggplot(df, aes(x = Stat, y = Value, fill = Player,
                         text = paste0(Player, "\n", Stat, ": ", round(Value, 2)))) +
      geom_col(position = "dodge") +
      labs(x = NULL, y = "Per-Game Average", fill = "Player") +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")

    ggplotly(p, tooltip = "text")
  })
}

# ── Launch ──────────────────────────────────────────────────
shinyApp(ui = ui, server = server)
