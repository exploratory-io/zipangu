test_that("convert_jyear legacy=TRUE: kansuji (kanji numeral) parity with arabic-digit input", {
  # exploratory-io patch: the legacy (non-ICU) path's wareki-year extraction
  # originally matched arabic digits only ("[0-9]{1,2}"), so a kansuji-written
  # era year (e.g. "令和三年", Reiwa written with the kanji
  # numeral for "three") silently returned NA. tam#36712.
  expect_equal(convert_jyear("令和3年", legacy = TRUE), 2021)
  expect_equal(convert_jyear("令和三年", legacy = TRUE), 2021)
  expect_equal(convert_jyear("平成元年", legacy = TRUE), 1989)
  expect_equal(convert_jyear("昭和64年", legacy = TRUE), 1989)
  # Double-digit kansuji (positional notation with the "ten" character).
  expect_equal(convert_jyear("令和十年", legacy = TRUE), 2028)
  expect_equal(convert_jyear("昭和六十四年", legacy = TRUE), 1989)
  expect_equal(convert_jyear("平成三十一年", legacy = TRUE), 2019)
  # Invalid input unaffected.
  expect_true(is.na(convert_jyear(NA_character_, legacy = TRUE)))
  expect_true(is.na(convert_jyear("abc", legacy = TRUE)))
  expect_warning(
    expect_equal(convert_jyear("文久3年", legacy = TRUE), NA_real_)
  )
  # Vectorized mixed ascii + kansuji input.
  expect_equal(
    convert_jyear(c("令和3年", "令和三年", "昭和10年", NA), legacy = TRUE),
    c(2021, 2021, 1935, NA)
  )
})
