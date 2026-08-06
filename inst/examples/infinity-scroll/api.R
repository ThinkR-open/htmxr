library(ggplot2)
library(dplyr)
library(purrr)
library(htmxr)

PAGE_SIZE <- 6
TOTAL <- nrow(diamonds)

bootstrap_css <- tags$link(
  rel = "stylesheet",
  href = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
)

custom_css <- tags$style(
  "
  /* -- Cards grid -- */
  .cards-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 16px;
  }

  /* -- Diamond card -- */
  .diamond-card {
    background: white;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    transition: transform 0.15s, box-shadow 0.15s;
    animation: fadeInUp 0.4s ease both;
  }
  @keyframes fadeInUp {
    from { opacity: 0; transform: translateY(16px); }
    to   { opacity: 1; transform: translateY(0); }
  }
  .diamond-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 16px rgba(0,0,0,0.12);
  }
  .diamond-card .card-number {
    font-size: 10px;
    color: #bbb;
    letter-spacing: 0.08em;
    margin-bottom: 6px;
  }
  .diamond-card .cut-badge {
    display: inline-block;
    font-size: 11px;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    padding: 3px 10px;
    border-radius: 20px;
    margin-bottom: 12px;
  }
  .diamond-card .price {
    font-size: 22px;
    font-weight: 700;
    color: #1a1a2e;
  }
  .diamond-card .meta {
    font-size: 12px;
    color: #888;
    margin-top: 6px;
  }
  .diamond-card .emoji {
    font-size: 28px;
    margin-bottom: 8px;
  }

  /* Colors by cut */
  .cut-Fair     { background: #fff0eb; color: #E8582A; }
  .cut-Good     { background: #e8f4fd; color: #2AACE2; }
  .cut-VeryGood { background: #f0faf0; color: #2e7d32; }
  .cut-Premium  { background: #faf0ff; color: #7b1fa2; }
  .cut-Ideal    { background: #fff8e1; color: #f57f17; }

  /* -- Scroll sentinel -- */
  .sentinel {
    grid-column: 1 / -1;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #aaa;
    font-size: 13px;
    gap: 8px;
  }
  .sentinel .spinner-border {
    width: 16px;
    height: 16px;
    border-width: 2px;
  }

  /* -- Scroll hint (sticky bottom) -- */
  .scroll-hint {
    position: sticky;
    bottom: 20px;
    text-align: center;
    pointer-events: none;
  }
  .scroll-hint span {
    background: rgba(0,0,0,0.6);
    color: white;
    font-size: 12px;
    padding: 6px 14px;
    border-radius: 20px;
    letter-spacing: 0.05em;
  }
"
)

cut_class <- function(cut) paste0("cut-", gsub(" ", "", as.character(cut)))

cut_emoji <- function(cut) {
  switch(
    as.character(cut),
    "Fair" = "\U1f48e",
    "Good" = "\u2728",
    "Very Good" = "\u2b50",
    "Premium" = "\U1f537",
    "Ideal" = "\U1f451",
    "\U1f48e"
  )
}

diamond_cards <- function(page = 1) {
  offset <- (page - 1) * PAGE_SIZE
  data <- diamonds |> slice(seq(offset + 1, min(offset + PAGE_SIZE, TOTAL)))
  has_next <- (page * PAGE_SIZE) < TOTAL

  cards <- pmap(
    list(
      seq(offset + 1, offset + nrow(data)),
      data$cut,
      data$color,
      data$clarity,
      data$carat,
      data$price
    ),
    function(n, cut, color, clarity, carat, price) {
      tags$div(
        class = "diamond-card",
        tags$div(
          class = "card-number",
          paste0("#", n, " / ", format(TOTAL, big.mark = ","))
        ),
        tags$div(class = "emoji", cut_emoji(cut)),
        tags$div(class = paste("cut-badge", cut_class(cut)), as.character(cut)),
        tags$div(class = "price", paste0("$", format(price, big.mark = ","))),
        tags$div(
          class = "meta",
          paste0(
            carat,
            " ct \u00b7 ",
            as.character(color),
            " \u00b7 ",
            as.character(clarity)
          )
        )
      )
    }
  )

  sentinel <- if (has_next) {
    tags$div(
      class = "sentinel",
      tags$div(class = "spinner-border text-secondary"),
      paste0(
        "Loading diamonds ",
        offset + PAGE_SIZE + 1,
        " to ",
        min(offset + PAGE_SIZE * 2, TOTAL),
        "..."
      )
    ) |>
      hx_set(
        get = paste0("/cards?p=", page + 1),
        trigger = "revealed",
        swap = "outerHTML"
      )
  } else {
    tags$div(
      class = "sentinel",
      paste0(
        "\u2705 All ",
        format(TOTAL, big.mark = ","),
        " diamonds loaded"
      )
    )
  }

  tagList(cards, sentinel)
}

#* @get /
#* @parser none
#* @serializer htmx
function() {
  hx_page(
    hx_head(
      bootstrap_css,
      custom_css,
      title = "Infinite scroll"
    ),
    tags$div(
      class = "container py-5",
      tags$h1(class = "mb-1", "Diamonds"),
      tags$p(
        class = "text-muted mb-4",
        paste0(
          format(TOTAL, big.mark = ","),
          " diamonds \u00b7 scroll down to load more \u2193"
        )
      ),
      tags$div(
        class = "cards-grid",
        diamond_cards(1)
      ),
      tags$div(
        class = "scroll-hint mt-4",
        tags$span("\u2193 Scroll to load more")
      )
    )
  )
}

#* @get /cards
#* @query p:integer
#* @parser none
#* @serializer htmx
function(query) {
  diamond_cards(query$p)
}
