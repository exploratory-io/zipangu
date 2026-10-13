#' Convert Japanese imperial year to Anno Domini
#' @description
#' \Sexpr[results=rd, stage=render]{lifecycle::badge("maturing")}
#' @param jyear Japanese imperial year (jyear). Kanji or Roman character
#' @param legacy A logical to switch converter. If `TRUE` supplied, use the legacy
#' converter instead of 'ICU' implementation.
#' @section Examples:
#' ```{r, child = "man/rmd/setup.Rmd"}
#' ```
#'
#' ```{r}
#' convert_jyear("R1")
#' convert_jyear("Heisei2")
#' convert_jyear("\u5e73\u6210\u5143\u5e74")
#' convert_jyear(c("\u662d\u548c10\u5e74", "\u5e73\u621014\u5e74"))
#' convert_jyear(kansuji2arabic_all("\u5e73\u6210\u4e09\u5e74"))
#' ```
#' @export
convert_jyear <- function(jyear, legacy = FALSE) {
  if (legacy) {
    convert_jyear_impl1(jyear)
  } else {
    convert_jyear_impl2(jyear)
  }
}

#' Convert Japanese date format to date object
#' @description
#' \Sexpr[results=rd, stage=render]{lifecycle::badge("maturing")}
#'
#' Era dates ("R3.3.1", "H28/8/23") and era-less
#' Western-year dates ("2016-08-23") are both converted. A value that cannot be
#' parsed becomes `NA`. `Date` and `POSIXct` input is returned as a date.
#' @param date A character object.
#' @param legacy Kept for backward compatibility. Both settings use the same
#' converter, which does not use 'ICU' date parsing (exploratory-io/tam#39658).
#' @section Examples:
#' ```{r, child = "man/rmd/setup.Rmd"}
#' ```
#'
#' ```{r}
#' convert_jdate("R3/2/27")
#' convert_jdate("\u4ee4\u548c2\u5e747\u67086\u65e5")
#' ```
#' @export
convert_jdate <- function(date, legacy = FALSE) {
  # The ICU path (convert_jdate_impl2) read an era-less year as a year of the
  # current era ("2016-08-23" -> "4034-08-23"), and ICU date parsing SIGABRTs
  # R on macOS 26.4+. Both settings now use the pure-R converter.
  if (inherits(date, "Date")) {
    return(date)
  }
  if (inherits(date, "POSIXt")) {
    return(lubridate::as_date(date))
  }
  convert_jdate_safe(date)
}

# Converts each distinct value once with the pure-R converter.
# An unparseable value becomes NA instead of stopping the whole vector.
convert_jdate_safe <- function(date) {
  date <- as.character(date)
  uniq <- unique(date)
  converted <- vapply(uniq, convert_jdate_one, numeric(1), USE.NAMES = FALSE)
  as.Date(converted[match(date, uniq)], origin = "1970-01-01")
}

# Converts one value. Returns the date as a number of days, or NA.
convert_jdate_one <- function(x) {
  if (is.na(x) || !nzchar(trimws(x))) {
    return(NA_real_)
  }
  res <- tryCatch(
    suppressWarnings(convert_jdate_impl1(x)),
    error = function(e) NULL
  )
  if (length(res) != 1 || !inherits(res, "Date")) {
    return(NA_real_)
  }
  as.numeric(res)
}

convert_jyear_impl2 <- function(jyear) {
  jyear <- stringi::stri_trim(jyear) %>%
    stringi::stri_trans_nfkc()

  dplyr::if_else(
    stringi::stri_detect_regex(jyear, "[:number:]{3,}"),
    {
      stringi::stri_datetime_parse(
        jyear,
        format = "yy\u5e74"
      ) %>%
        lubridate::year()
    },
    {
      stringi::stri_datetime_parse(
        format_jdate(jyear),
        format = "Gy\u5e74",
        locale = "ja-JP-u-ca-japanese"
      ) %>%
        lubridate::year()
    }
  )
}

convert_jdate_impl2 <- function(jdate) {
  jdate <- stringi::stri_trim(jdate) %>%
    stringi::stri_trans_nfkc() %>%
    format_jdate()

  sp <- stringi::stri_split_regex(
    jdate,
    "(\u5e74|\u6708|\u65e5)|(\\.)|(\\-)|(\\/)",
  ) %>%
    purrr::map_chr(~ paste0(.[1], "\u5e74", .[2], "\u6708", .[3], "\u65e5"))

  stringi::stri_datetime_parse(
    sp,
    format = "Gy\u5e74M\u6708d\u65e5",
    locale = "ja-JP-u-ca-japanese"
  ) %>%
    lubridate::as_date()
}

format_jdate <- function(jdate) {
  stringi::stri_trans_tolower(jdate) %>%
    stringi::stri_replace_all_regex(
      c("meiji", "taisyo|taisho|taisyou", "syouwa|showa", "heisei", "reiwa"),
      c("m", "t", "s", "h", "r"),
      vectorise_all = FALSE
    ) %>%
    stringi::stri_replace_all_regex(
      c("m|\u660e(?!\u6cbb)", "t|\u5927(?!\u6b63)", "s|\u662d(?!\u548c)", "h|\u5e73(?!\u6210)", "r|\u4ee4(?!\u548c)"),
      c("\u660e\u6cbb", "\u5927\u6b63", "\u662d\u548c", "\u5e73\u6210", "\u4ee4\u548c"),
      vectorise_all = FALSE
    )
}
