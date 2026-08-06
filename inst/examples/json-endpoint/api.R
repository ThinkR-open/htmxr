library(htmxr)
library(ggplot2)
library(dplyr)

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

# Shared data function used by both endpoints
diamond_data <- function(cut_filter = "all") {
  data <- if (cut_filter == "all") {
    diamonds |>
      slice_head(n = 20)
  } else {
    diamonds |>
      filter(cut == cut_filter) |>
      slice_head(n = 20)
  }
  data |>
    mutate(price = paste0("$", price))
}

# ── JSON endpoint (classic API) ────────────────────────────────────────────────
#* @get /api/rows
#* @query cut:string("all")
#* @serializer json
function(query) {
  diamond_data(query$cut)
}

# ── HTML page ──────────────────────────────────────────────────────────────────
#* @get /
#* @parser none
#* @serializer htmx
function() {
  hx_page(
    hx_head(
      title = "JSON endpoint",
      bootstrap_css
    ),
    tags$div(
      class = "container py-5",
      style = "max-width: 750px",
      tags$h1(class = "mb-1", "Diamonds Explorer"),
      tags$p(
        class = "text-muted mb-4",
        "The same data is served as JSON (",
        tags$code("GET /api/rows"),
        ") and as HTML for htmx (",
        tags$code("GET /rows"),
        ")."
      ),
      tags$div(
        class = "card mb-4 border-primary",
        tags$div(
          class = "card-body",
          hx_select_input(
            id = "cut",
            label = "Filter by cut:",
            choices = c(
              "All" = "all",
              "Fair",
              "Good",
              "Very Good",
              "Premium",
              "Ideal"
            ),
            selected = "all",
            class = "form-select",
            get = "/rows",
            trigger = "change",
            target = "#tbody"
          )
        )
      ),
      tags$div(
        class = "card",
        tags$div(
          class = "card-body p-0",
          hx_table(
            columns = c("cut", "color", "clarity", "price"),
            col_labels = c("Cut", "Color", "Clarity", "Price"),
            tbody_id = "tbody",
            class = "table table-striped table-hover mb-0",
            thead_class = "table-dark",
            get = "/rows",
            trigger = "load",
            swap = "innerHTML"
          )
        )
      )
    )
  )
}

# ── HTML fragment endpoint (for htmx) ─────────────────────────────────────────
#* @get /rows
#* @query cut:string("all")
#* @parser none
#* @serializer htmx
function(query) {
  hx_table_rows(
    diamond_data(query$cut),
    columns = c("cut", "color", "clarity", "price")
  )
}
