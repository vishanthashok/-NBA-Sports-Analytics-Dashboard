# ============================================================
# helpers.R — Utility functions for Sports Analytics App
# ============================================================

#' Compute a composite performance score (0–100)
compute_score <- function(pts, ast, reb, stl, blk, fg_pct) {
  score <- (pts * 0.35) + (ast * 0.20) + (reb * 0.20) +
    (stl * 0.10) + (blk * 0.10) + (fg_pct * 10 * 0.05)
  round(pmin(score, 100), 1)
}

#' Label efficiency tier
efficiency_label <- function(score) {
  dplyr::case_when(
    score >= 20 ~ "Elite",
    score >= 15 ~ "All-Star",
    score >= 10 ~ "Starter",
    TRUE        ~ "Bench"
  )
}

#' Colour palette for teams (conference)
conf_colours <- c("East" = "#1d428a", "West" = "#c8102e")

#' Stat display names
stat_labels <- c(
  Points    = "Points",
  Assists   = "Assists",
  Rebounds  = "Rebounds",
  Steals    = "Steals",
  Blocks    = "Blocks",
  FG_Pct    = "FG %",
  ThreePt_Pct = "3PT %",
  FT_Pct    = "FT %"
)
