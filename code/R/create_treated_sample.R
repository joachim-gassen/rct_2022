source("code/R/inject_tment.R")

smp <- readRDS("data/generated/base_sample.rds")
teffect_sample <- inject_tment(smp, teffect = 0.03, seed = 123)
saveRDS(teffect_sample, "data/generated/treated_sample.rds")
writexl::write_xlsx(teffect_sample, "data/generated/treated_sample.xlsx")
readr::write_csv(teffect_sample, "data/generated/treated_sample.csv")

