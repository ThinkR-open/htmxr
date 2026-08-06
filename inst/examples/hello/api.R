library(svglite)
library(htmxr)

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css",
  integrity = "sha384-sRIl4kxILFvY47J16cr9ZwB07vP4J8+LH7qKQnuqkuIAvNWLzeN8tE5YBujZqJLB",
  crossorigin = "anonymous"
)

generate_plot <- function(bins = 30) {
  svg_string <- xmlSVG(
    {
      x <- faithful[, 2]
      bins_seq <- seq(
        from = min(x),
        to = max(x),
        length.out = as.numeric(bins) + 1
      )
      hist(
        x,
        breaks = bins_seq,
        col = "darkgray",
        border = "white",
        xlab = "Waiting time to next eruption (in mins)",
        main = "Histogram of waiting times"
      )
    },
    width = 7,
    height = 5
  )

  svg_string
}

#* @get /
#* @parser none
#* @serializer htmx
function() {
  hx_page(
    hx_head(
      title = "Old Faithful Geyser Data",
      bootstrap_css
    ),
    tags$div(
      class = "container py-5",
      tags$div(
        class = "card shadow",
        tags$div(
          class = "card-body",
          tags$h1(
            class = "card-title border-bottom border-primary border-3 pb-2",
            "Old Faithful Geyser Data"
          ),
          tags$div(
            class = "row mt-4",

            ###
            # Slider
            tags$div(
              class = "col-md-3",
              tags$div(
                class = "bg-white p-3 rounded",
                hx_slider_input(
                  id = "bins",
                  label = "Number of bins:",
                  value = 30,
                  min = 1,
                  max = 50,
                  get = "/plot",
                  trigger = "input changed delay:300ms",
                  target = "#plot",
                  class = "form-range"
                )
              )
            ),

            ###
            # Plot
            tags$div(
              class = "col-md-9",
              tags$div(id = "plot", class = "text-center") |>
                hx_set(
                  get = "/plot",
                  trigger = "load",
                  target = "#plot",
                  swap = "innerHTML"
                )
            )
          )
        )
      )
    )
  )
}

#* @get /plot
#* @query bins:integer(30)
#* @parser none
#* @serializer none
function(query) {
  generate_plot(query$bins)
}
