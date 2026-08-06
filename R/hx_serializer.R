#' The `htmx` serializer
#'
#' htmxr registers a plumber2 serializer named `htmx`, which sends any
#' [htmltools] object as `text/html`. Use it on every route that returns
#' markup built with htmxr, whether that is a full page or a fragment:
#'
#' ```r
#' #* @get /rows
#' #* @serializer htmx
#' function(query) {
#'   hx_table_rows(diamonds, columns = c("cut", "price"))
#' }
#' ```
#'
#' @details
#' The serializer plumber2 ships as `html` only understands a bare string or a
#' single [htmltools::tags] element. A `tagList` — what [hx_table_rows()] and
#' most fragment helpers return — matches neither, so it falls through to
#' plumber2's XML branch and is sent as unusable markup, with a `200` status
#' and no error. Reaching for `@serializer none` sidesteps that, but labels the
#' response `text/plain`.
#'
#' `htmx` handles both, and always sets `text/html`:
#'
#' * `tagList` and single tags (as returned by [hx_page()], [hx_table_rows()])
#' * strings marked with [htmltools::HTML()]
#' * plain character vectors, concatenated as-is
#' * `NULL`, sent as an empty body — useful for a swap that clears its target
#'
#' Anything else is an error rather than malformed markup. Content that is not
#' htmltools output — an SVG device string, JSON — belongs on the matching
#' plumber2 serializer instead.
#'
#' The serializer is registered when htmxr is loaded, so `library(htmxr)` at
#' the top of your API file is enough to make `@serializer htmx` resolve.
#'
#' @seealso [hx_table_rows()], [hx_page()]
#' @name htmx-serializer
NULL

# Factory handed to plumber2::register_serializer(). plumber2 calls it with the
# arguments given on the @serializer line and expects a unary function back.
#' @noRd
hx_format_htmx <- function(...) {
  function(x) {
    if (is.null(x)) return("")
    if (inherits(x, c("shiny.tag", "shiny.tag.list", "html"))) {
      return(as.character(x))
    }
    if (is.character(x)) return(paste0(x, collapse = ""))
    if (is.list(x)) return(as.character(do.call(htmltools::tagList, x)))
    stop(
      "The `htmx` serializer cannot render an object of class ",
      paste(class(x), collapse = "/"),
      ". Return htmltools output, or pick the plumber2 serializer that ",
      "matches your content.",
      call. = FALSE
    )
  }
}
