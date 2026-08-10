test_that("hx_is_htmx() returns TRUE for htmx request", {
  req <- list(headers = list(`hx-request` = "true"))
  expect_true(hx_is_htmx(req))
})

test_that("hx_is_htmx() returns FALSE without header", {
  req <- list(headers = list())
  expect_false(hx_is_htmx(req))
})

test_that("hx_is_htmx() returns FALSE for wrong header value", {
  req <- list(headers = list(`hx-request` = "false"))
  expect_false(hx_is_htmx(req))
})

test_that("hx_is_htmx() accepts the plumber2 snake_case header naming", {
  expect_true(hx_is_htmx(list(headers = list(hx_request = "true"))))
  expect_true(hx_is_htmx(list(headers = list(`hx-request` = "true"))))
  expect_false(hx_is_htmx(list(headers = list(hx_request = "false"))))
  expect_false(hx_is_htmx(list(headers = list())))
})

test_that("hx_is_htmx() works with a character vector of headers", {
  expect_true(hx_is_htmx(list(headers = c(hx_request = "true"))))
  expect_false(hx_is_htmx(list(headers = c(accept = "text/html"))))
})

# Regression test: the simulated lists above never caught the real bug, because
# a plumber2 request is a reqres::Request whose `headers` are snake_case and
# which is queried through `get_header()`.
test_that("hx_is_htmx() works with a real plumber2 request object", {
  skip_if_not_installed("reqres")
  skip_if_not_installed("fiery")

  htmx_req <- reqres::Request$new(
    fiery::fake_request(
      "http://127.0.0.1:8080/",
      headers = list(HTTP_HX_REQUEST = "true")
    )
  )
  expect_true(hx_is_htmx(htmx_req))

  plain_req <- reqres::Request$new(
    fiery::fake_request(
      "http://127.0.0.1:8080/",
      headers = list(HTTP_ACCEPT = "text/html")
    )
  )
  expect_false(hx_is_htmx(plain_req))
})
