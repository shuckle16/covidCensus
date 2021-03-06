
<!-- README.md is generated from README.Rmd. Please edit that file -->

# covidCensus

The goal of covidCensus is to easily join county level COVID-19 case and
death data with other information from the census (eg income,
demographic statistics, population density). The purpose of its creation
was educational. I had been exploring COVID-19 data for awhile and
wanted to observe patterns between health outcomes and other social
markers.

Note: I am not a professional researcher, just a hobbyist. Any findings
from this study should be taken with a grain of salt.

## Installation

covidCensus is not on CRAN, but this is how to install it from Github.

``` r
devtools::install_github("shuckle16/covidCensus")
```

## Package Structure

Currently there are 4 `fetch_*` functions for retrieving the data you
want. Each of them returns the raw response from an http request.

  - `fetch_nyt`
  - `fetch_census_dens`
  - `fetch_census_demo`
  - `fetch_census_income`

There are also 4 corresponding `tidy_*` functions to clean up the above
data so they can be joined together. Each of them returns a tidy
dataframe (tibble) where each row represents a county.

  - `tidy_nyt`
  - `tidy_census_dens`
  - `tidy_census_demo`
  - `tidy_census_income`

## Example

Some sample code which uses the package to plot the correlation between
median income and virus deaths per capita.

``` r
library(dplyr)
library(ggplot2)
library(covidCensus)

tidied_nyt <- fetch_nyt() %>% tidy_nyt()

tidied_census_dens <- fetch_census_dens() %>% tidy_census_dens()

tidied_census_income <- fetch_census_income() %>% tidy_census_income()

join_datasets <- function() {
  tidied_census_income %>%
    inner_join(tidied_census_dens, by = c("county", "state")) %>% 
    inner_join(tidied_nyt)
}

joined_data <- join_datasets() 

joined_data %>%   
  filter(county != "New York") %>% 
  ggplot(aes(x = median_income, y = (deaths / pop) * 100000)) + 
  geom_point(alpha = 0.7) + 
  scale_x_continuous(labels = scales::comma) +
  xlab("Median Annual Income ($)") + 
  ylab("Deaths per 100k") + 
  ggtitle(
    "COVID-19 Death rate in the USA versus median income", 
    subtitle = paste("Each dot is a county. Deaths data from", max(tidied_nyt$date))
    )
```

<img src="man/figures/README-example-1.png" width="100%" />

## To do list

  - Consider using {[polite](https://github.com/dmi3kno/polite)} package
    instead of xml2. There might be a nicer way to make the census api
    calls, too. Suggestions welcome
  - Find other interesting county-level variables
  - Add tests? consistent names from the `tidy` functions, etc
  - Add a vignette or two
  - Fix the warnings in `tidy_census_income`
