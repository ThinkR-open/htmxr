# Table rows fragment

Converts a data frame into a `tagList` of `<tr>` elements, one per row.
Designed to be used as a fragment endpoint response — the output
replaces a `<tbody>` via htmx swap.

## Usage

``` r
hx_table_rows(data, columns = NULL, col_classes = NULL)
```

## Arguments

- data:

  A data frame.

- columns:

  Character vector of column names to include (and their order). If
  `NULL`, all columns are used.

- col_classes:

  Named list of CSS classes to add to `<td>` elements, keyed by column
  name. Example: `list(price = "text-end fw-bold")`.

## Value

A
[htmltools::tagList](https://rstudio.github.io/htmltools/reference/tagList.html)
of `<tr>` tags.

## Serving the fragment

Annotate the route with `@serializer htmx`. plumber2's own `html`
serializer does not understand a `tagList` and would send unusable
markup. See
[htmx-serializer](https://hyperverse-r.github.io/htmxr/reference/htmx-serializer.md).

## See also

[htmx-serializer](https://hyperverse-r.github.io/htmxr/reference/htmx-serializer.md)

## Examples

``` r
df <- data.frame(cut = c("Fair", "Good"), price = c(326L, 400L))
hx_table_rows(df, columns = c("cut", "price"))
#> <tr>
#>   <td>Fair</td>
#>   <td>326</td>
#> </tr>
#> <tr>
#>   <td>Good</td>
#>   <td>400</td>
#> </tr>

# With CSS classes on specific columns
hx_table_rows(df, col_classes = list(price = "text-end fw-bold"))
#> <tr>
#>   <td>Fair</td>
#>   <td class="text-end fw-bold">326</td>
#> </tr>
#> <tr>
#>   <td>Good</td>
#>   <td class="text-end fw-bold">400</td>
#> </tr>
```
