# If you are new to Makefiles: https://makefiletutorial.com

DID_BASE_DATA := data/generated/base_sample.rds

DID_TREATED_DATA := data/generated/treated_sample.rds \
	data/generated/treated_sample.csv data/generated/treated_sample.xlsx

TARGETS :=  $(DID_BASE_DATA) $(DID_TREATED_DATA)

WRDS_DATA := data/pulled/cstat_global_fund.rds

RSCRIPT := Rscript --encoding=UTF-8

.phony: all clean very-clean dist-clean

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

very-clean: clean
	rm -f $(WRDS_DATA)

dist-clean: very-clean
	rm config.csv
	
config.csv:
	@echo "To start, you need to copy _config.csv to config.csv and edit it"
	@false
	
$(WRDS_DATA): code/R/pull_wrds_data.R code/R/read_config.R config.csv
	$(RSCRIPT) code/R/pull_wrds_data.R

$(DID_BASE_DATA): $(WRDS_DATA) code/R/create_base_sample.R
	$(RSCRIPT) code/R/create_base_sample.R

$(DID_TREATED_DATA)&:	$(DID_BASE_DATA) code/R/inject_tment.R code/R/create_treated_sample.R
	$(RSCRIPT) code/R/create_treated_sample.R
	