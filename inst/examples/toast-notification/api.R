library(htmxr)

# Demonstrates hx_trigger(): submitting a form swaps the result area AND fires
# a "notified" event that causes a toast notification to appear at the top —
# two independent zones updated from a single POST.

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

#* @get /
#* @parser none
#* @serializer htmx
function() {
  hx_page(
    hx_head(title = "Toast Notification", bootstrap_css),
    div(
      class = "container py-5",
      style = "max-width: 500px",
      # Listener: fetches GET /toast whenever the "notified" event bubbles
      # through <body>. "from:body" is required because the event fires on the
      # button, not on this div — so we listen at the body level.
      div(id = "toast") |>
        hx_set(
          get = "/toast",
          trigger = "notified from:body",
          swap = "innerHTML"
        ),
      tags$h1(class = "h3 mb-4", "Submit an action"),
      div(id = "result", class = "mb-3"),
      hx_button(
        "submit-btn",
        "Submit",
        class = "btn btn-primary",
        post = "/submit",
        target = "#result",
        swap = "innerHTML"
      )
    )
  )
}

#* @post /submit
#* @parser none
#* @serializer htmx
function(response) {
  # Fires the "notified" event in the browser — the toast div above catches it
  # and makes its own GET /toast request.
  # No HTML is sent by hx_trigger() itself.
  hx_trigger(response, "notified")
  tags$p(class = "text-success fw-bold", "Action completed.")
}

#* @get /toast
#* @parser none
#* @serializer htmx
function() {
  # Returns the toast HTML fragment — called by the toast div when it receives
  # the "notified" event, not directly by the button POST.
  # The CSS animation fades the toast out after 3s — no JS required.
  tagList(
    tags$style(
      "
      @keyframes fadeOut {
        0%, 70% { opacity: 1; }
        100%     { opacity: 0; }
      }
      .toast-auto { animation: fadeOut 3s ease forwards; }
    "
    ),
    tags$div(
      class = "alert alert-success mb-4 toast-auto",
      tags$strong("Done!"),
      paste(" Triggered at", format(Sys.time(), "%H:%M:%S"), ".")
    )
  )
}
