# The `htmx` serializer

htmxr registers a plumber2 serializer named `htmx`, which sends any
[htmltools](https://rstudio.github.io/htmltools/reference/htmltools-package.html)
object as `text/html`. Use it on every route that returns markup built
with htmxr, whether that is a full page or a fragment:

## Details

    #* @get /rows
    #* @serializer htmx
    function(query) {
      hx_table_rows(diamonds, columns = c("cut", "price"))
    }

The serializer plumber2 ships as `html` only understands a bare string
or a single
[htmltools::tags](https://rstudio.github.io/htmltools/reference/builder.html)
element. A `tagList` — what
[`hx_table_rows()`](https://hyperverse-r.github.io/htmxr/reference/hx_table_rows.md)
and most fragment helpers return — matches neither, so it falls through
to plumber2's XML branch and is sent as unusable markup, with a `200`
status and no error. Reaching for `@serializer none` sidesteps that, but
labels the response `text/plain`.

`htmx` handles both, and always sets `text/html`:

- `tagList` and single tags (as returned by
  [`hx_page()`](https://hyperverse-r.github.io/htmxr/reference/hx_page.md),
  [`hx_table_rows()`](https://hyperverse-r.github.io/htmxr/reference/hx_table_rows.md))

- strings marked with
  [`htmltools::HTML()`](https://rstudio.github.io/htmltools/reference/HTML.html)

- plain character vectors, concatenated as-is

- `NULL`, sent as an empty body — useful for a swap that clears its
  target

Anything else is an error rather than malformed markup. Content that is
not htmltools output — an SVG device string, JSON — belongs on the
matching plumber2 serializer instead.

The serializer is registered when htmxr is loaded, so
[`library(htmxr)`](https://hyperverse-r.github.io/htmxr/) at the top of
your API file is enough to make `@serializer htmx` resolve.

## See also

[`hx_table_rows()`](https://hyperverse-r.github.io/htmxr/reference/hx_table_rows.md),
[`hx_page()`](https://hyperverse-r.github.io/htmxr/reference/hx_page.md)
