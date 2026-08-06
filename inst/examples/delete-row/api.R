library(htmxr)

# Demonstrates vals: each delete button embeds the row id as JSON via
# hx-vals — no form, no hidden input. The server reads the id from the
# query string, removes the row from the in-memory table, and returns
# the updated tbody fragment.

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

# In-memory state — closure pattern: .data lives in the function environment
# and persists for the lifetime of the server process.
db <- local({
  .data <- data.frame(
    id = 1:5,
    name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    role = c("Admin", "Editor", "Viewer", "Editor", "Admin"),
    stringsAsFactors = FALSE
  )
  list(
    get = function() .data,
    delete = function(id) .data <<- .data[.data$id != id, ]
  )
})

# Renders one <tr> per user, with a delete button that carries the row id
# via vals. On click: DELETE /rows?id=<id> → returns updated tbody.
make_rows <- function(data) {
  tagList(lapply(seq_len(nrow(data)), function(i) {
    id <- data$id[i]
    tags$tr(
      tags$td(data$name[i]),
      tags$td(data$role[i]),
      tags$td(
        hx_button(
          id = paste0("del-", id),
          label = "Delete",
          class = "btn btn-sm btn-danger",
          delete = "/rows",
          # vals embeds the row id directly in the button — no form needed.
          # htmx sends JSON-parsed vals as query params for DELETE requests.
          vals = paste0('{"id":', id, '}'),
          target = "#tbody",
          swap = "innerHTML"
        )
      )
    )
  }))
}

#* @get /
#* @parser none
#* @serializer html
function() {
  hx_page(
    hx_head(title = "Delete Row", bootstrap_css),
    tags$div(
      class = "container py-5",
      style = "max-width: 600px",
      tags$h1(class = "mb-4", "Users"),
      tags$table(
        class = "table table-bordered",
        tags$thead(
          class = "table-dark",
          tags$tr(
            tags$th("Name"),
            tags$th("Role"),
            tags$th("Actions")
          )
        ),
        # tbody is empty on load — rows are fetched immediately via trigger="load"
        tags$tbody(id = "tbody") |>
          hx_set(
            get = "/rows",
            trigger = "load",
            swap = "innerHTML"
          )
      )
    )
  )
}

#* @get /rows
#* @parser none
#* @serializer html
function() {
  # as.character() because the plumber2 html serializer renders a `shiny.tag`
  # but not a `tagList` — it would dump the latter as raw XML.
  as.character(make_rows(db$get()))
}

#* @delete /rows
#* @query id:integer
#* @parser none
#* @serializer html
function(query) {
  db$delete(query$id)
  as.character(make_rows(db$get()))
}
