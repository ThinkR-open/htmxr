# Detect if a request comes from htmx

Checks whether the incoming HTTP request was made by htmx by inspecting
the `HX-Request` header. htmx sends this header with every AJAX request.

## Usage

``` r
hx_is_htmx(request)
```

## Arguments

- request:

  A request object, typically the `request` argument of a plumber2
  handler. Objects exposing a `get_header()` accessor (such as plumber2
  / `reqres` requests) are queried through it; otherwise the `headers`
  element is used — a named list or character vector of HTTP headers.

## Value

`TRUE` if the request was made by htmx, `FALSE` otherwise.

## Details

plumber2 requests are
[`reqres::Request`](https://reqres.data-imaginist.com/reference/Request.html)
objects, which normalise header names to lowercase **snake_case**:
`request$headers` holds `hx_request`, never `hx-request`. Their
`get_header()` accessor handles that normalisation itself and accepts
the original HTTP name, so it is used whenever it is available. When
falling back to `headers` — for hand-built lists in tests and examples —
both `hx-request` and `hx_request` are accepted.

## Examples

``` r
# Simulated htmx request
req <- list(headers = list(`hx-request` = "true"))
hx_is_htmx(req)
#> [1] TRUE

# Same request with the plumber2 header naming convention
req <- list(headers = list(hx_request = "true"))
hx_is_htmx(req)
#> [1] TRUE

# Regular request
req <- list(headers = list())
hx_is_htmx(req)
#> [1] FALSE
```
