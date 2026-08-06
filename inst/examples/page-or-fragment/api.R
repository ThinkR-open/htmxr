library(htmxr)
library(dplyr)

# One route, two responses.
#
# A browser asking for `/` gets the whole page. htmx asking for the same URL
# gets only the table rows. `hx_is_htmx()` tells them apart by reading the
# `HX-Request` header that htmx sends with every request.
#
# Because the URL is the same in both cases, `push_url = "true"` gives real,
# shareable URLs: `/?cut=Ideal` filters the table when swapped by htmx *and*
# renders a fully filtered page on a hard reload. That is the whole point of
# collapsing page and fragment into a single route.

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

cut_choices <- c(
  "All" = "all",
  "Fair",
  "Good",
  "Very Good",
  "Premium",
  "Ideal"
)

table_columns <- c("cut", "color", "clarity", "price")

diamond_data <- function(cut_filter = "all") {
  data <- ggplot2::diamonds
  if (cut_filter != "all") {
    data <- filter(data, cut == cut_filter)
  }
  data |>
    slice_head(n = 20) |>
    mutate(price = paste0("$", price))
}

#* @get /
#* @query cut:string("all")
#* @parser none
#* @serializer html
function(request, query) {
  # htmx only needs the new rows — send them and stop here.
  # `as.character()` because the html serializer renders a `tagList` as-is
  # only once it has been turned into a string.
  if (hx_is_htmx(request)) {
    return(as.character(
      hx_table_rows(diamond_data(query$cut), columns = table_columns)
    ))
  }

  # A regular browser request gets the full page, already filtered.
  hx_page(
    hx_head(
      title = "Page or fragment",
      bootstrap_css
    ),
    tags$div(
      class = "container py-5",
      style = "max-width: 750px",
      tags$h1(class = "mb-1", "Page or Fragment"),
      tags$p(
        class = "text-muted mb-4",
        "A single route that answers browsers with a page and htmx with a fragment."
      ),
      tags$div(
        class = "card mb-4 border-primary",
        tags$div(
          class = "card-body",
          hx_select_input(
            id = "cut",
            label = "Filter by cut:",
            choices = cut_choices,
            selected = query$cut,
            class = "form-select",
            get = "/",
            trigger = "change",
            target = "#tbody",
            swap = "innerHTML",
            push_url = "true"
          ),
          tags$p(
            class = "form-text mb-0 mt-2",
            "Change the filter, then reload the page: the URL alone rebuilds
             the same view."
          )
        )
      ),
      tags$div(
        class = "card",
        tags$div(
          class = "card-body p-0",
          hx_table(
            data = diamond_data(query$cut),
            columns = table_columns,
            col_labels = c("Cut", "Color", "Clarity", "Price"),
            tbody_id = "tbody",
            class = "table table-striped table-hover mb-0",
            thead_class = "table-dark"
          )
        )
      )
    )
  )
}
