library(htmxr)
library(ggplot2)
library(dplyr)

# Demonstrates plumber2's api_datastore — the built-in equivalent of Shiny's
# reactiveValues. Two scopes injected as the `datastore` argument on each
# route:
#
#   datastore$session : per-user state, survives refresh via session cookie,
#                       isolated from other users
#   datastore$global  : shared across all users
#
# Open the page in two private windows: each window remembers its own filter
# (session-scoped), but both see the same visitor count (global-scoped).
#
# Swap storr::driver_environment() for driver_rds()/driver_redis() to persist
# across server restarts or share across workers.

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

diamond_data <- function(cut_filter = "all") {
  data <- if (cut_filter == "all") {
    diamonds |> slice_head(n = 20)
  } else {
    diamonds |>
      filter(cut == cut_filter) |>
      slice_head(n = 20)
  }
  data |> mutate(price = paste0("$", price))
}

# In-memory store — every restart wipes both $session and $global.
# Swap for storr::driver_rds("./cache/sessions") to persist.
#* @datastore
storr::driver_environment()

#* @get /
#* @parser none
#* @serializer htmx
function(datastore) {
  last_cut <- datastore$session$last_cut %||% "all"

  # Count each unique session exactly once (not every page view).
  if (is.null(datastore$session$counted)) {
    datastore$global$visits <- (datastore$global$visits %||% 0L) + 1L
    datastore$session$counted <- TRUE
  }

  hx_page(
    hx_head(title = "reactiveValues -> datastore", bootstrap_css),
    tags$div(
      class = "container py-5",
      style = "max-width: 750px",
      tags$h1(class = "mb-1", "Diamonds Explorer"),
      tags$p(
        class = "text-muted mb-1",
        "Per-user filter (session) + shared visitor counter (global)."
      ),
      tags$p(
        class = "small text-muted mb-4",
        sprintf("Total unique visitors: %d", datastore$global$visits)
      ),

      tags$div(
        class = "card mb-4 border-primary",
        tags$div(
          class = "card-body",
          hx_select_input(
            id = "cut",
            label = "Filter by cut (remembered per user):",
            choices = c(
              "All" = "all",
              "Fair",
              "Good",
              "Very Good",
              "Premium",
              "Ideal"
            ),
            selected = last_cut,
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
            # On load, pre-fetch the rows for the user's remembered filter.
            get = paste0("/rows?cut=", last_cut),
            trigger = "load",
            swap = "innerHTML"
          )
        )
      )
    )
  )
}

#* @get /rows
#* @query cut:string("all")
#* @parser none
#* @serializer htmx
function(query, datastore) {
  # Persist the user's choice — pre-fills the dropdown on next visit.
  datastore$session$last_cut <- query$cut
  hx_table_rows(
    diamond_data(query$cut),
    columns = c("cut", "color", "clarity", "price")
  )
}
