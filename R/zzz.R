.onLoad <- function(libname, pkgname) {
  # Registered on load so that `library(htmxr)` at the top of an API file is
  # enough for plumber2 to resolve `@serializer htmx` when it builds routes.
  # `default = FALSE` keeps it out of content negotiation, where it would
  # collide with plumber2's own `text/html` serializer.
  plumber2::register_serializer(
    name = "htmx",
    fun = hx_format_htmx,
    mime_type = "text/html",
    default = FALSE
  )
  invisible()
}
