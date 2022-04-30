# --- Header -------------------------------------------------------------------
# See LICENSE file for details 
#
# Creates an earnings/cash flow/accrual/fiscal year returns sample based on
# Compustat Global sample
# ------------------------------------------------------------------------------
suppressMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
})

mleadlag <- function(x, n, ts_id) {
  pos <- match(as.numeric(ts_id) + n, as.numeric(ts_id))
  x[pos]
}

message("Preparing sample... ", appendLF = FALSE)

locs_euro <- read_csv(
  "data/external/eea_ctries_2021-01-01.csv", col_types = "cccclll"
) %>% select(loc = "iso3c", euro) %>% filter(euro)

fund <- readRDS("data/pulled/cstat_global_fund.rds") %>% 
  arrange(gvkey, fyr, fyear) %>%
  filter(at > 0, sale > 0)  %>%
  filter(curcd == "EUR") %>%
  left_join(locs_euro, by = "loc") %>% 
  filter(euro) %>% select(-euro)

fund %>%
  group_by(gvkey, datadate) %>%
  filter(n() > 1) -> dup_cases  

if (nrow(dup_cases) > 0) stop(
  "Compustat Global has duplicate financial data at the gvkey, datadate", 
  "level. Duplicates are stored in 'dup_cases'"
)

fund %>%
  group_by(gvkey, fyear, fyr) %>%
  filter(n() > 1) -> dup_cases  

if (nrow(dup_cases) > 0) stop(
  "Compustat Global has duplicate financial data at the gvkey, fyear, fyr level.",
  "Duplicates are stored in 'dup_cases'"
)

smp_raw <- fund %>%
  arrange(gvkey, fyr, fyear) %>%
  group_by(gvkey, fyr) %>%
  mutate(
    avg_at = 0.5*(at + mleadlag(at, -1, fyear)),
    ear = ib/avg_at,
    cfo = oancf/avg_at,
    sales = sale/avg_at
  ) %>%
  select(
    gvkey, fyear, fyr, conm, loc, sic, avg_at, sales, ear, cfo
  ) 

# Deal with 120 cases where we have duplicate gvkey, fyear observations 
# Choose the series with more firm observations, grouped by fye

smp_raw_distinct <- smp_raw %>%
  filter(!is.na(avg_at)) %>%
  group_by(gvkey, fyr) %>%
  mutate(nobs = n()) %>%
  group_by(gvkey, fyear) %>%
  filter(n() ==  1 | nobs == max(nobs)) %>%
  filter(row_number() == 1) %>%
  ungroup()

smp_raw_distinct %>%
  group_by(gvkey, fyear) %>%
  filter(n() > 1) -> dup_cases

if (nrow(dup_cases) > 0) stop(
  "Distinct sample has duplicate observations data at the gvkey,",
  "fyear level. This should not happen."
)

ff12 <- read_csv(
  "data/external/fama_french_12_industries.csv", col_types = "cc"
)

smp <- smp_raw_distinct %>%
  left_join(ff12, by = "sic") %>%
  mutate(country = countrycode::countrycode(loc, "iso3c", "country.name")) %>% 
  filter_at(vars(ear, cfo, sales), all_vars(!is.na(.))) %>%
  mutate(ln_ta = log(avg_at)) %>%
  select(
    loc, country, gvkey, conm, sic, ff12_ind, fyear, 
    avg_at, sales, ear, cfo
  ) %>%
  filter(fyear %in% 2001:2020) %>%
  group_by(country) %>%
  filter(length(unique(fyear)) == 20) %>%
  ungroup() %>%
  arrange(loc, gvkey, fyear)

smp %>%
  group_by(gvkey, fyear) %>%
  filter(n() > 1) -> dup_cases

if (nrow(dup_cases) > 0) stop(
  "Sample has duplicate observations data at the gvkey,",
  "fear level. Duplicates are stored in 'dup_cases'"
)

saveRDS(smp, "data/generated/base_sample.rds")
message("done")


