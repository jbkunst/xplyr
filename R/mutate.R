describe_new_variable <- function(name, profile) {
  details <- c(
    profile$type,
    paste0(format_pct(profile$p_missing), " NA"),
    paste0(format_n(profile$n_unique), " distinct")
  )

  if (!is.null(profile$numeric)) {
    details <- c(
      details,
      paste0("median ", format_value(profile$numeric[["median"]])),
      paste0(
        "range ", format_value(profile$numeric[["min"]]),
        " to ", format_value(profile$numeric[["max"]])
      )
    )
  }

  paste0("New variable \"", name, "\": ", paste(details, collapse = ", "), ".")
}

compare_mutate <- function(before, after) {
  changes <- list()
  old_names <- names(before)
  new_names <- names(after)

  added <- setdiff(new_names, old_names)
  removed <- setdiff(old_names, new_names)
  common <- intersect(old_names, new_names)
  modified <- common[!vapply(common, function(name) identical(before[[name]], after[[name]]), logical(1))]

  for (name in added) {
    profile <- profile_variable(after[[name]])
    changes[[length(changes) + 1]] <- new_change(describe_new_variable(name, profile), 70)
  }

  for (name in removed) {
    changes[[length(changes) + 1]] <- new_change(
      paste0("Variable \"", name, "\" was removed."),
      100
    )
  }

  for (name in modified) {
    old <- profile_variable(before[[name]])
    new <- profile_variable(after[[name]])

    if (!identical(old$type, new$type)) {
      changes[[length(changes) + 1]] <- new_change(
        paste0(
          "\"", name, "\" changed type from ", old$type,
          " to ", new$type, "."
        ),
        100
      )
    }

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

    if (old$n_unique > 0 && new$n_unique < old$n_unique &&
        (new$n_unique <= 5 || new$n_unique / old$n_unique <= 0.5)) {
      changes[[length(changes) + 1]] <- new_change(
        paste0(
          "\"", name, "\" now has ", format_n(new$n_unique),
          " distinct values (was ", format_n(old$n_unique), ")."
        ),
        65
      )
    }
  }

  changes
}

#' Mutate columns and show notable consequences
#'
#' A lightweight wrapper around [dplyr::mutate()] used by the xplyr experiment.
#'
#' @param .data A data frame.
#' @param ... Arguments passed to [dplyr::mutate()].
#'
#' @return The same result as [dplyr::mutate()].
#' @export
mutate <- function(.data, ...) {
  if (!is.data.frame(.data)) return(dplyr::mutate(.data, ...))

  result <- dplyr::mutate(.data, ...)
  changes <- compare_mutate(.data, result)

  if (length(changes) > 0) {
    print_header("mutate")
    print_changes(changes)
  }

  result
}
