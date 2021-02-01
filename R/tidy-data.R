#' Cleans up case / deaths data from the New York Times dataset
#'
#' Note the slice(1) which gets the latest info
#'
#'
#' @export

tidy_nyt <- function(data_nyt = covid_nyt, crop_to_last_day = TRUE) {
  data_nyt <-
    data_nyt %>%
    dplyr::filter(county != "Unknown") %>%
    dplyr::arrange(state, county, desc(date)) %>%
    dplyr::group_by(state, county)

  if (crop_to_last_day)
    data_nyt <- data_nyt %>% dplyr::slice(1)

  data_nyt %>%
    dplyr::ungroup() %>%
    dplyr::mutate(county = dplyr::if_else(county == "New York City", "New York", county))
}

#' Behind the scenes function to convert raw data from census to a tibble
#'
#' Works for each of the tidy_census functions

tibblefy_census_html <- function(html) {

  dens_matrix <- jsonlite::fromJSON(html %>% rvest::html_text())

  colnames(dens_matrix) <- dens_matrix[1,]

  dens_matrix <- dens_matrix[-1,]

  dens_matrix %>%
    dplyr::as_tibble() %>%
    rename_all(tolower)
}

#' Density info
#'
#'
#' @export

tidy_census_dens <- function(html_census) {

  dens_tbl <- tibblefy_census_html(html_census)

  dens_tbl <-
    dens_tbl %>%
    dplyr::rename(
      state_num = state
      ) %>%
    dplyr::mutate(
      density = as.numeric(density),
      pop = as.numeric(pop)
    ) %>%
    dplyr::filter(date_code == 12) %>% # 2019 data
    dplyr::mutate(
      state  = stringr::word(name, -1, sep = ", "),
      county = stringr::word(name, 1, sep = " County,")
    )

  dens_tbl
}

#' Converts raw data from Census to a tidy df
#'
#' Cleans up some variables
#'
#' To do: make df wide?
#'
#' @export

tidy_census_demo <- function(census_demo) {

  demo_tbl <- tibblefy_census_html(census_demo)

  demo_tbl <-
    demo_tbl %>%
    dplyr::rename(
      state_num = state,
      county_num = county
    ) %>%
    dplyr::mutate(
      pop = as.numeric(pop)
    ) %>%
    dplyr::mutate(
      state  = stringr::word(name, -1, sep = ", "),
      county = stringr::word(name,  1, sep = " County,")
    )

  demo_tbl
}


#' Converts raw data from census into a tidy df.
#' Adjusts colnames, converts char to numeric, tidies county info
#'
#' @export

tidy_census_income <- function(census_income) {

  income_tbl <- tibblefy_census_html(census_income)

  # Instead of state names,
  # this API call includes state abbreviations (stabrev), so use
  # state.abb and state.name vectors from builtin {datasets} package

  state_abb_lookup <- dplyr::tibble(state.name, state.abb)

  income_tbl <-
    income_tbl %>%
    dplyr::rename(
      state_num = state,
      state.abb = stabrev,
      county_num = county,
      ppl_in_pov = saepovall_pt,
      median_income = saemhi_pt
    ) %>%
    dplyr::mutate(
      ppl_in_pov = as.numeric(ppl_in_pov),
      median_income = as.numeric(median_income)
    ) %>%
    dplyr::mutate(
      county = stringr::word(name,  1, sep = " County")
    ) %>%
    dplyr::inner_join(state_abb_lookup) %>%
    rename(state = state.name)

  income_tbl
}
