#' Gets latest case / death counts from NYT Github repository
#'
#' @export

fetch_nyt <- function() {
  readr::read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")
}

#' Census API call: pop, pop density by county
#'
#' @export

fetch_census_dens <- function() {
  xml2::read_html("https://api.census.gov/data/2019/pep/population?get=DATE_CODE,DATE_DESC,DENSITY,POP,NAME&for=county:*")
}

#' Census API call: demographics by county
#'
#' info on race variable here https://api.census.gov/data/2019/pep/charagegroups/variables/RACE.json
#'
#' @export

fetch_census_demo <- function() {
  xml2::read_html("https://api.census.gov/data/2019/pep/charagegroups?get=NAME,POP,RACE&for=county:*&in=state:*")
}

#' Census API call: median income & pct in poverty by county
#'
#' @export

fetch_census_income <- function() {
  xml2::read_html("https://api.census.gov/data/timeseries/poverty/saipe?get=SAEPOVALL_PT,SAEMHI_PT,NAME,YEAR,STABREV&for=county:*&YEAR=2018")
}

