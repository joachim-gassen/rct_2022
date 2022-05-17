library(dplyr)
library(tidyr)
library(ggplot2)
library(fixest)
library(stringr)

SIM_FNAME <- "data/permanent/did_teffect_sims.rds"

source("code/R/inject_tment.R")
base_smp <- readRDS("data/generated/base_sample.rds")
countries <- unique(base_smp$loc)
tcountries <- combn(countries, 6, simplify = FALSE)

sim_run <- function(
  smp = base_smp, model = "twfe", tyear = 2011, teffect = 0.03,
  winsorize = 0, cluster = "gvkey", treated_countries = NULL
) {
  if (! model %in% c("twfe", "classic")) stop("Wrong model string")
  
  smp <- inject_tment(
    smp, treated_countries = treated_countries, 
    tyear = tyear, teffect = teffect
  ) 
  smp$post <- smp$fyear >= tyear
  
  if (winsorize > 0) {
    smp <- smp %>% ExPanDaR::treat_outliers(percentile = winsorize)
  }
  
  cluster_str <- cluster
  if(str_detect(cluster, fixed("_"))) {
    cluster = as.vector(str_split_fixed(cluster, fixed("_"), 2))
  }
  if (model == "twfe") {
    didfe <- feols(ear ~ tment | gvkey + fyear, cluster = cluster, data = smp) 
  } else {
    didfe <- feols(ear ~ tment | tment_ctry + post, cluster = cluster, data = smp) 
  }
  cis = confint(didfe)

  run_count <<- run_count + 1
  if (run_count %% 10 == 0) message(
    sprintf("%s: Completed %d of %d sim runs", Sys.time(), run_count, total_runs))
  
  tibble(
    model = model,
    tyear = tyear, 
    teffect = teffect,
    cluster = cluster_str,
    winsorize = winsorize,
    lb = pull(cis[1]),
    est = unname(didfe$coefficients[1]),
    ub = pull(cis[2])
  )
}

sim_parms <- expand_grid(
  model = c("classic", "twfe"),
  treated_countries = tcountries,
  cluster = c("gvkey", "country", "country_fyear"),
  winsorize = c(0, 0.01),
  teffect = c(0.01, 0.02, 0.03, 0.04, 0.05),
  tyear = 2011
)

sim_runs <- NULL
run_count <- 0
total_runs <- nrow(sim_parms)
message(sprintf("%s: Starting %d sim runs", Sys.time(), total_runs))

for (i in seq_len(nrow(sim_parms))) {
  sim_runs <- bind_rows(
    sim_runs,
    sim_run(
      base_smp,
      treated_countries = unlist(sim_parms$treated_countries[i]),
      model = sim_parms$model[i],
      tyear = sim_parms$tyear[i], teffect = sim_parms$teffect[i],
      winsorize = sim_parms$winsorize[i], cluster = sim_parms$cluster[i]
    )
  )
}

saveRDS(sim_runs, SIM_FNAME)
