#' Detect if a request comes from htmx
#'
#' Checks whether the incoming HTTP request was made by htmx by inspecting
#' the `HX-Request` header. htmx sends this header with every AJAX request.
#'
#' @param request A request object, typically the `request` argument of a
#'   plumber2 handler. Objects exposing a `get_header()` accessor (such as
#'   plumber2 / `reqres` requests) are queried through it; otherwise the
#'   `headers` element is used — a named list or character vector of HTTP
#'   headers.
#'
#' @details
#' plumber2 requests are `reqres::Request` objects, which normalise header
#' names to lowercase **snake_case**: `request$headers` holds `hx_request`,
#' never `hx-request`. Their `get_header()` accessor handles that
#' normalisation itself and accepts the original HTTP name, so it is used
#' whenever it is available. When falling back to `headers` — for hand-built
#' lists in tests and examples — both `hx-request` and `hx_request` are
#' accepted.
#'
#' @return `TRUE` if the request was made by htmx, `FALSE` otherwise.
#'
#' @examples
#' # Simulated htmx request
#' req <- list(headers = list(`hx-request` = "true"))
#' hx_is_htmx(req)
#'
#' # Same request with the plumber2 header naming convention
#' req <- list(headers = list(hx_request = "true"))
#' hx_is_htmx(req)
#'
#' # Regular request
#' req <- list(headers = list())
#' hx_is_htmx(req)
#'
#' @export
hx_is_htmx <- function(request) {
  if (is.function(request$get_header)) {
    return(identical(request$get_header("hx-request"), "true"))
  }
  headers <- request$headers
  identical(.hx_header(headers, "hx-request"), "true") ||
    identical(.hx_header(headers, "hx_request"), "true")
}

# Look up a header by exact name in a named list or character vector,
# returning NULL when absent (unlike `[[` on a character vector).
#' @noRd
.hx_header <- function(headers, name) {
  idx <- match(name, names(headers))
  if (is.na(idx)) return(NULL)
  headers[[idx]]
}
