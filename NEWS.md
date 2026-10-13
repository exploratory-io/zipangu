# zipangu 0.3.3.2 (exploratory-io fork)

## Fix

- `convert_jdate()` no longer uses ICU date parsing (exploratory-io/tam#39658).
  - An era-less value was read as a year of the current era, so "2016-08-23"
    and "2016年8月23日" became "4034-08-23". They now keep their year.
  - ICU date parsing in stringi SIGABRTs R on macOS 26.4+ (Apple Silicon).
  - `Date` and `POSIXct` input is returned as a date.
  - An unparseable value ("", "令和3年", "R3.13.1") becomes `NA` instead of
    stopping the whole vector.
  - `legacy` is kept for backward compatibility; both settings use the same
    pure-R converter.

# zipangu 0.3.3.1 (exploratory-io fork)

## Fix

- `convert_jyear(..., legacy = TRUE)` now correctly parses kansuji (kanji
  numeral) era years, e.g. "令和三年" (previously only arabic-digit era years
  like "令和3年" were recognized by the legacy path; the ICU-backed default
  path already supported both forms). Adds a kansuji-numeral extraction
  fallback in `convert_jyear_impl1()`, reusing the package's own
  `kansuji2arabic_num()`. exploratory-io/tam#36712.

# zipangu 0.3.3

## Fix

- Class mismatch in specification of argument legacy in `convert_jdate()` (#55).

# zipangu 0.3.2

# zipangu 0.3.1

## New Features

- `convert_prefecture()`: New functions for converting prefecture names between Roman and Kanji (@Doubt-0KB, #48).
- `convert_prefecture_from_kana()`: New functions for converting prefecture names from kana to Kanji (@Doubt-0KB, #48).

## Enhancement

- Re-factoring `convert_jyear()` and `convert_jdate()` (@paithiov909, #50).

# zipangu 0.3.0

## New Features

- `kana()`: New function for create kana vector (#43).
- `harmonize_prefecture_name()`: New function for processing prefectural strings (#37).
    - Determine if the string is a prefecture string by `is_prefecture()`. 
- `str_jnormalize`: New function for pre-processing Japanese characters following the rules of 'neologd' (@paithiov909, #36).

## Fix

- Fix the behaviors of `jholiday_spec()` when any NAs, NULL, and empty strings are supplied (@paithiov909, #38).
- `is_jholiday()` fails if the date argument contains NA (@hidekoji, #39).
- `is_jholiday()` returns incorrect result if `lubridate.week.start` option is set to other than Sunday (@hidekoji, #40).

## Enhancement

- `jholiday_spec()` is now memoised internally. This change makes its second and later calls faster. Also, multiple values of `name` are now acceptable. (@paithiov909, #38).

# zipangu 0.2.3

## Fix

- Determination of substitute holidays due to forgetting to update raw data (#31).

# zipangu 0.2.2

## New Features

* Added functions to convert Kansuji to Arabic numbers (@indenkun #23).
    * `kansuji2arabic_num()` converts Kansuji that containing kansuji for positions (e.g. `Hyaku`, `Sen`, etc) to Arabic numerals with the numbers represented by Kansuji (Fix #8).
    * `kansuji2arabic_str()` converts Kansuji in the string to Arabic numerals with the numbers they represent.
* Added functions to graph labels to handle Kansuji (@indenkun #4).
    * `label_kansuji()` and `label_kansuji_suffix()` converts the label value to either Kansuji value or mixture of Arabic numerals and the Kansuji Scales.

## Enhancement

- Holiday determination now reflects the 2021 calendar (@zettsu-t #28).
- `convert_jyear()` supports strict representation of the Japanese imperial year (#30).

# zipangu 0.2.1

## New Features

* `convert_jdate()` can converts the Japanese date format to as a date object.

## Enhancement

* `find_date_by_wday()`, `jholiday_spec()`, `jholiday()`, and `is_jholiday()`
  are now vectorized and accept multiple `year`s (@yutannihilation, #15).
* `separate_address()` also now vectorized.

# zipangu 0.2.0

* Added several functions to handle postal code data.
    * `read_zipcode()` to read Japan post's zip-code file and `dl_zipcode_file()` for raw file download.
    * `is_zipcode()` test zip-code. Only supports 7-digit numbers or characters.
    * `zipcode_spacer()` insert and remove zip-code connect character.
* `str_jconv()` and `str_conv_*()` converts the kind of string used as Japanese people.
* Added some functions related to Japanese holidays.
    * `jholiday_spec()` to find date from corresponding year and holiday name and `jholiday()` is used to look up a list of holidays for the year.
    * `is_jholiday()` whether the day is a holiday.
* Find out the date of the specific month and weekday (`find_date_by_wday()`)

# zipangu 0.1.0

* Added a `NEWS.md` file to track changes to the package.
