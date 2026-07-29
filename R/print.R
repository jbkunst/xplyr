xplyr_max_changes <- function() {
  value <- getOption("xplyr.max_changes", 3)

  if (!is.numeric(value) || length(value) != 1 || is.na(value) || value < 0) return(3)

  value
}

format_pct <- function(x) {
  sprintf("%.1f%%", 100 * x)
}

format_n <- function(x) {
  format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
}

format_value <- function(x) {
  format(signif(x, 4), big.mark = ",", scientific = FALSE, trim = TRUE)
}

new_change <- function(text, score) {
  list(text = text, score = score)
}

rank_changes <- function(changes) {
  if (length(changes) == 0) return(changes)

  scores <- vapply(changes, function(x) x$score, numeric(1))
  changes <- changes[order(scores, decreasing = TRUE)]
  max_changes <- xplyr_max_changes()

  if (is.infinite(max_changes)) return(changes)
  if (max_changes == 0) return(list())

  utils::head(changes, as.integer(max_changes))
}

print_header <- function(verb) {
  cli::cli_h2(paste0(verb, "()"))
}

print_rows <- function(before, after) {
  change <- if (before == 0) NA_real_ else after / before - 1
  text <- paste0(format_n(before), " -> ", format_n(after))

  if (is.finite(change)) {
    text <- paste0(text, " (", sprintf("%+.1f%%", 100 * change), ")")
  }

  cli::cli_text("Rows:")
  cli::cli_text(text)
}

print_changes <- function(changes) {
  changes <- rank_changes(changes)
  if (length(changes) == 0) return(invisible())

  cli::cli_text("Notable changes:")
  cli::cli_ul(vapply(changes, function(x) x$text, character(1)))
  invisible()
}
