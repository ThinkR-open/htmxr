#' Run an htmxr example
#'
#' Launches an example API that demonstrates htmxr features.
#' Call `hx_run_example()` without arguments to list available examples.
#'
#' @param example name of the example to run. If `NULL`, lists available
#'   examples.
#' @param port port to run the API on.
#'
#' @importFrom plumber2 api
#'
#' @return Called for side effects. When `example` is `NULL`, returns the
#'   available example names invisibly. Otherwise does not return (the server
#'   blocks).
#'
#' @examples
#' hx_run_example() # list available examples
#' if (interactive()) {
#'   hx_run_example("hello") # run the hello example
#' }
#'
#' @export
hx_run_example <- function(example = NULL, port = 8080) {
  examples_dir <- system.file("examples", package = "htmxr")
  available <- basename(list.dirs(examples_dir, recursive = FALSE))

  if (is.null(example)) {
    message("Available examples: ", paste(available, collapse = ", "))
    message('Run one with: hx_run_example("hello")')
    return(invisible(available))
  }

  example_path <- system.file("examples", example, package = "htmxr")
  if (!nzchar(example_path)) {
    stop(
      "Example '",
      example,
      "' not found. ",
      "Available: ",
      paste(available, collapse = ", "),
      call. = FALSE
    )
  }

  api_file <- file.path(example_path, "api.R")
  pr <- api(api_file, port = port, doc_type = "") |>
    hx_serve_assets()

  message("Running example '", example, "' on http://127.0.0.1:", port)
  pr$ignite(block = TRUE)
}
