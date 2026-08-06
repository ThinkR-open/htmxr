# Multi-select example
#
# Demonstrates how to wire a group of checkboxes so that every toggle
# fires a single htmx request including ALL currently checked values.
#
# The non-obvious bit is the `hx-include` selector: use a document-wide
# attribute selector (e.g. `[name='cut']:checked`) — NOT `find <selector>`,
# which only returns the FIRST matching descendant of the trigger.
#
# Run with:
#   hx_run_example("multi-select")

library(htmxr)
library(ggplot2)
library(dplyr)

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

CUTS <- c("Fair", "Good", "Very Good", "Premium", "Ideal")

diamond_rows <- function(cuts) {
  data <- if (length(cuts) == 0) {
    diamonds[0, ]
  } else {
    diamonds |>
      filter(cut %in% cuts) |>
      slice_head(n = 20)
  }
  data |> mutate(price = paste0("$", price))
}

#* @get /
#* @parser none
#* @serializer htmx
function() {
  hx_page(
    hx_head(title = "Multi-select example", bootstrap_css),
    tags$div(
      class = "container py-5",
      style = "max-width: 750px",
      tags$h1(class = "mb-1", "Multi-select"),
      tags$p(
        class = "text-muted mb-4",
        "Tick several cuts — every toggle re-fetches with the full list of checked values."
      ),

      # ── Checkbox group ────────────────────────────────────────────────
      # All checkboxes share the same `name="cut"`. They are wrapped in a
      # <div> that fires htmx on any `change` event bubbling up from a
      # child checkbox.
      #
      # Pitfall to avoid:
      #   `hx-include = "find input[type='checkbox']:checked"`
      # The `find` modifier returns only the FIRST descendant matching —
      # so the server would only ever receive one `cut=…` parameter.
      #
      # Use a document-wide attribute selector instead. It matches every
      # checked checkbox with the same name, and htmx serialises them as
      # `?cut=Fair&cut=Ideal&…`, which plumber2 surfaces as `query$cut`
      # being a character vector.
      tags$div(
        class = "card mb-4 border-primary",
        tags$div(
          class = "card-body",
          tags$label(class = "form-label fw-semibold", "Filter by cut(s):"),
          tags$div(
            class = "d-flex flex-wrap gap-3",
            `hx-get` = "/rows",
            `hx-trigger` = "change",
            `hx-target` = "#tbody",
            `hx-swap` = "innerHTML",
            `hx-include` = "[name='cut']:checked", # ← global, NOT `find`
            lapply(CUTS, function(c) {
              args <- list(
                class = "form-check-input me-1",
                type = "checkbox",
                name = "cut",
                value = c,
                id = paste0("cut-", tolower(gsub(" ", "-", c)))
              )
              if (c == "Ideal") args$checked <- ""
              tags$label(
                class = "form-check d-flex align-items-center",
                do.call(tags$input, args),
                tags$span(class = "form-check-label", c)
              )
            })
          )
        )
      ),

      # ── Results table ────────────────────────────────────────────────
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
            include = "[name='cut']:checked",
            trigger = "load",
            swap = "innerHTML"
          )
        )
      )
    )
  )
}

#* @get /rows
#* @parser none
#* @serializer htmx
function(query) {
  # `query$cut` is NULL when no box is checked, otherwise a character vector
  cuts <- query$cut
  if (is.null(cuts)) cuts <- character(0)
  hx_table_rows(
    diamond_rows(cuts),
    columns = c("cut", "color", "clarity", "price")
  )
}
