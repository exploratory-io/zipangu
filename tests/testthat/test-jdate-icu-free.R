# exploratory-io/tam#39658: convert_jdate() must not use ICU date parsing.
# - An era-less value was read as a year of the current era (Reiwa), so
#   "2016-08-23" became "4034-08-23".
# - stringi's ICU date parsing SIGABRTs R on macOS 26.4+ (Apple Silicon).
# - The legacy path stopped the whole vector on one unparseable value.

test_that("convert_jdate() keeps era-less Western-year values in their year", {
  expect_equal(
    convert_jdate(c("2016\u5e748\u670823\u65e5", "2016-08-23", "2016/8/23")),
    as.Date(c("2016-08-23", "2016-08-23", "2016-08-23"))
  )
})

test_that("convert_jdate() returns Date and POSIXct input as dates", {
  expect_equal(
    convert_jdate(as.Date(c("2016-08-23", NA))),
    as.Date(c("2016-08-23", NA))
  )
  expect_equal(
    convert_jdate(as.POSIXct("2016-08-23 10:00:00", tz = "UTC")),
    as.Date("2016-08-23")
  )
})

test_that("convert_jdate() converts era dates in every supported notation", {
  expect_equal(
    convert_jdate(c(
      "\u4ee4\u548c3\u5e743\u67081\u65e5",
      "R3.3.1",
      "H28/8/23",
      "\u5e73\u6210\u5143\u5e741\u67088\u65e5",
      "\u662d\u548c64\u5e741\u67087\u65e5",
      "Heisei30-1-1"
    )),
    as.Date(c("2021-03-01", "2021-03-01", "2016-08-23",
              "1989-01-08", "1989-01-07", "2018-01-01"))
  )
})

test_that("convert_jdate() returns NA for unparseable values instead of failing", {
  expect_equal(
    convert_jdate(c(
      "\u4ee4\u548c3\u5e743\u67081\u65e5", "", NA, "\u4ee4\u548c3\u5e74",
      "\u3042\u3044\u3046", "R3.13.1"
    )),
    as.Date(c("2021-03-01", NA, NA, NA, NA, NA))
  )
  expect_equal(convert_jdate(character(0)), as.Date(character(0)))
  expect_equal(convert_jdate(NA), as.Date(NA))
})

test_that("convert_jdate() gives the same result for both legacy settings", {
  x <- c("\u4ee4\u548c4\u5e742\u670824\u65e5", "2023\u5e742\u670824\u65e5", "", NA)
  expect_equal(convert_jdate(x, legacy = TRUE), convert_jdate(x, legacy = FALSE))
})

test_that("convert_jdate() does not call ICU date parsing", {
  called <- FALSE
  testthat::local_mocked_bindings(
    stri_datetime_parse = function(...) {
      called <<- TRUE
      stop("ICU date parsing must not be used")
    },
    .package = "stringi"
  )
  convert_jdate(c("\u4ee4\u548c3\u5e743\u67081\u65e5", "2016-08-23"))
  expect_false(called)
})
