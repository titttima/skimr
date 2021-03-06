#' Extract summary statistics for vector. Should work regardless of type.
#'
#' This enables consistent returns for a variety of functions that generate
#' summary statistics. The only difference between the different skim_v methods
#' is the functions that they access.
#' 
#' We can't use the typical S3 dispatch because we cannot enumerate all possible
#' input types in advance.
#'
#' @param x A vector
#' @param FUNS A length-one character vector that specifies which group of funs
#'   to grab for summarizing.
#' @return A tall tbl, containing the vector's name, type, potential levels
#'   and a series of summary statistics.
#' @keywords internal
#' @export

skim_v <- function(x, FUNS = class(x)) {
  funs <- get_funs(FUNS)

  if (is.null(funs)) {
    msg <- paste0("Skim does not know how to summarize of vector of class: ",
      class(x), ". Coercing to numeric")
    warning(msg, call. = FALSE)
    funs <- get_funs("numeric")
    x <- as.numeric(x)
  }
  
  # Compute the summary statistic; allow for variable length
  values <- purrr::map(funs, ~.x(x))
  values_out <- purrr::flatten_dbl(values)
  
  # Get the name of the computed statistic and a corresponding level
  lens <- purrr::map_int(values, length)
  stats <- purrr::map2(names(funs), lens, rep)
  nms <- purrr::map(values, ~names(.x))
  level <- purrr::map_if(nms, is.null, ~".all")
  
  # Produce output
  tibble::tibble(type = get_fun_names(FUNS), 
    stat = purrr::flatten_chr(stats),
    level = purrr::flatten_chr(level), 
    value = unname(values_out))
}
