compare_filter <- function(before, after) {
  changes <- list()
  common <- intersect(names(before$columns), names(after$columns))
  overall_retention <- if (before$n_rows > 0) after$n_rows / before$n_rows else NA_real_

  for (name in common) {
    old <- before$columns[[name]]
    new <- after$columns[[name]]

    if (is.finite(old$p_missing) && is.finite(new$p_missing)) {
      delta_na <- new$p_missing - old$p_missing

      if (abs(delta_na) >= 0.03) {
        changes[[length(changes) + 1]] <- new_change(
          paste0(
            "NA in \"", name, "\": ",
            format_pct(old$p_missing), " -> ", format_pct(new$p_missing), "."
          ),
          60 + 100 * abs(delta_na)
        )
      }
    }

    if (is.null(old$categories) || is.null(new$categories)) next

    old_cat <- old$categories
    new_cat <- new$categories
    disappeared <- setdiff(old_cat$value, new_cat$value)

    if (length(disappeared) == 1) {
      changes[[length(changes) + 1]] <- new_change(
        paste0("\"", disappeared, "\" disappeared from \"", name, "\"."),
        100
      )
    } else if (length(disappeared) > 1) {
      changes[[length(changes) + 1]] <- new_change(
        paste0(length(disappeared), " categories disappeared from \"", name, "\"."),
        100
      )
    }

    if (!is.finite(overall_retention) || overall_retention <= 0) next

    min_group_n <- max(5L, ceiling(before$n_rows * 0.01))
    eligible <- old_cat[old_cat$n >= min_group_n, , drop = FALSE]
    if (nrow(eligible) == 0) next

    after_n <- new_cat$n[match(eligible$value, new_cat$value)]
    after_n[is.na(after_n)] <- 0
    retention <- after_n / eligible$n
    relative_retention <- retention / overall_retention
    candidates <- which(retention > 0 & relative_retention <= 0.5)

    if (length(candidates) > 0) {
      i <- candidates[which.min(relative_retention[candidates])]
      changes[[length(changes) + 1]] <- new_change(
        paste0(
          "\"", eligible$value[i], "\" in \"", name, "\" retained ",
          format_pct(retention[i]), " of its observations (overall: ",
          format_pct(overall_retention), ")."
        ),
        70 + 20 * (1 - relative_retention[i])
      )
    }
  }

  changes
}

#' Filter rows and show notable consequences
#'
#' A lightweight wrapper around [dplyr::filter()] used by the xplyr experiment.
#'
#' @param .data A data frame.
#' @param ... Arguments passed to [dplyr::filter()].
#'
#' @return The same result as [dplyr::filter()].
#' @export
filter <- function(.data, ...) {
  if (!is.data.frame(.data)) return(dplyr::filter(.data, ...))

  before <- profile_data(.data)
  result <- dplyr::filter(.data, ...)
  after <- profile_data(result)
  changes <- compare_filter(before, after)

  if (before$n_rows != after$n_rows || length(changes) > 0) {
    print_header("filter")
    print_rows(before$n_rows, after$n_rows)
    print_changes(changes)
  }

  result
}
