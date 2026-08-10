# Run an htmxr example

Launches an example API that demonstrates htmxr features. Call
`hx_run_example()` without arguments to list available examples.

## Usage

``` r
hx_run_example(example = NULL, port = 8080)
```

## Arguments

- example:

  name of the example to run. If `NULL`, lists available examples.

- port:

  port to run the API on.

## Value

Called for side effects. When `example` is `NULL`, returns the available
example names invisibly. Otherwise does not return (the server blocks).

## Examples

``` r
hx_run_example() # list available examples
#> Available examples: delete-row, hello, infinity-scroll, json-endpoint, multi-select, page-or-fragment, reactive-values, select-input, toast-notification
#> Run one with: hx_run_example("hello")
if (interactive()) {
  hx_run_example("hello") # run the hello example
}
```
