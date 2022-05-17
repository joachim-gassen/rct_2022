library(dplyr)

inject_tment <- function(
  smp, treated_countries = NULL, tyear = 2011, teffect = 0.0, 
  seed = sample(seq_len(1e4), 1)
) {
  countries <- unique(smp$loc)
  if (exists(".Random.seed", envir = .GlobalEnv)) {
    old_seed <- get(".Random.seed", .GlobalEnv)
  } 
  set.seed(seed)
  if (is.null(treated_countries)) {
    treated_countries <- sample(countries)[1:(length(countries)/2)]
  }
  if (exists("old_seed")) assign(".Randon.seed", old_seed, .GlobalEnv)
  
  smp_effect <- smp %>%
    mutate(
      tment_ctry = loc %in% treated_countries,
      tment_year = ifelse(loc %in% treated_countries, tyear, NA),
      tment = !is.na(tment_year) & fyear >= tment_year,
      time_to_treat = ifelse(!is.na(tment_year), fyear - tment_year, 0),
      ear = ifelse(tment, ear + teffect, ear)
    ) 
  
  smp_effect %>%
    select(
      loc, country, tment_ctry, tment, time_to_treat, 
      gvkey, conm, fyear, ear, avg_at
    )
}
