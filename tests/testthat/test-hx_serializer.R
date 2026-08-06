test_that("the htmx serializer is registered with plumber2 on load", {
  registered <- plumber2::show_registered_serializers()
  row <- registered[registered$name == "htmx", ]

  expect_equal(nrow(row), 1L)
  expect_equal(row$mime_type, "text/html")
  # Kept out of content negotiation, where it would collide with `html`.
  expect_false(row$default)
})

test_that("plumber2 gets a unary function from the factory", {
  expect_length(formals(hx_format_htmx()), 1L)
})

test_that("htmx serializer renders a tagList — the case `html` gets wrong", {
  fmt <- hx_format_htmx()
  out <- fmt(tagList(tags$tr(tags$td("a")), tags$tr(tags$td("b"))))

  expect_type(out, "character")
  expect_length(out, 1L)
  expect_match(out, "<tr>", fixed = TRUE)
  expect_match(out, "<td>a</td>", fixed = TRUE)
  expect_match(out, "<td>b</td>", fixed = TRUE)
  # The plumber2 `html` serializer would emit an <html> wrapper and the
  # internal structure of the tags here.
  expect_no_match(out, "shiny.tag", fixed = TRUE)
})

test_that("htmx serializer renders hx_table_rows() output", {
  fmt <- hx_format_htmx()
  rows <- hx_table_rows(head(iris, 2), columns = c("Species", "Sepal.Length"))

  expect_match(fmt(rows), "<td>setosa</td>", fixed = TRUE)
})

test_that("htmx serializer renders a single tag and a full page", {
  fmt <- hx_format_htmx()

  expect_equal(fmt(tags$p("hi")), "<p>hi</p>")
  expect_match(
    fmt(hx_page(hx_head(title = "t"))),
    "<!DOCTYPE html>",
    fixed = TRUE
  )
})

test_that("htmx serializer passes strings through without escaping", {
  fmt <- hx_format_htmx()

  expect_equal(fmt("<p>hi</p>"), "<p>hi</p>")
  expect_equal(fmt(htmltools::HTML("<p>hi</p>")), "<p>hi</p>")
  expect_equal(fmt(c("<p>a</p>", "<p>b</p>")), "<p>a</p><p>b</p>")
})

test_that("htmx serializer sends NULL as an empty body", {
  expect_equal(hx_format_htmx()(NULL), "")
})

test_that("htmx serializer renders a bare list of tags", {
  fmt <- hx_format_htmx()

  expect_match(
    fmt(list(tags$li("a"), tags$li("b"))),
    "<li>a</li>",
    fixed = TRUE
  )
})

test_that("htmx serializer errors rather than emitting broken markup", {
  fmt <- hx_format_htmx()

  expect_error(fmt(1:3), "cannot render an object of class")
  expect_error(fmt(1:3), "integer")
})
