profile_type <- function(x) {
  if (is.ordered(x)) return("ordered factor")
  if (is.factor(x)) return("factor")
  if (inherits(x, "Date")) return("date")
  if (inherits(x, c("POSIXct", "POSIXlt"))) return("datetime")

  typeof(x)
}

profile_variable <- function(x) {
  n <- length(x)
  n_missing <- sum(is.na(x))
  non_missing <- x[!is.na(x)]
  n_unique <- length(unique(non_missing))

  out <- list(
    type = profile_type(x),
    n = n,
    n_missing = n_missing,
    p_missing = if (n > 0) n_missing / n else NA_real_,
    n_unique = n_unique,
    numeric = NULL,
    categories = NULL
  )

  if (is.numeric(x) && !is.logical(x)) {
    values <- x[is.finite(x)]

    if (length(values) > 0) {
      qs <- stats::quantile(values, probs = c(0, 0.25, 0.5, 0.75, 1), names = FALSE)
      out$numeric <- stats::setNames(as.numeric(qs), c("min", "q25", "median", "q75", "max"))
    }
  }

  if ((is.character(x) || is.factor(x) || is.logical(x)) && n_unique <= 20) {
    counts <- sort(table(as.character(non_missing)), decreasing = TRUE)

    out$categories <- data.frame(
      value = names(counts),
      n = as.integer(counts),
      p = if (length(non_missing) > 0) as.numeric(counts) / length(non_missing) else numeric(),
      stringsAsFactors = FALSE
    )
  }

  out
}

profile_data <- function(data) {
  list(
    n_rows = nrow(data),
    n_cols = ncol(data),
    columns = stats::setNames(lapply(data, profile_variable), names(data))
  )
}
