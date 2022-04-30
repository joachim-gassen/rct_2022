## Course Repo for Research on Corporate Transparency: Summer Term 2022

In this repo we will store code and materials that we use in class. You do not need to deep-dive into it but it might be helpful for those of you that are interested in improving their data analysis skills.

### The Diff-in-diff assignment

As discussed in class, we want you to gather first-hand experience in how to estimate a treatment effect on firm-year panel data when treatment is administered at the country level. This research design is the most common approach to estimating regulatory effects. As most of our cases that we will discuss throughout the course are located in Europe, our assignment is based on European data. To make the estimation and its interpretation straight-forward, we want you to estimate an "artificial" treatment effect that we "injected" into the profitability data of European firms.

### Data

As the data is commercially licensed, it is provided to you on Moodle. **Please note that you are not allowed to share the data with anybody outside of this class.** The code that we used to collect and prepare the data is included in this repository for your reference.

All data files contain the same data so use whatever suits you best. The data comprises treatment information as well as profitability and average total assets data for a sample of publicly listed firms from 12 European countries. It covers the fiscal years 2001 to 2020. The data has been collected via WRDS/Standard & Poor's Compustat Global. The data items are defined as follows:

- `loc`: An ISO 3-letter code indicating the country where the respective firm is headquartered
- `country`: The country name to the ISO code
- `tment_ctry`: Indicator whether the respective country was 'treated' with a regulatory reform
- `tment`: Indicator whether a certain firm-year was subject to the new regulatory regime
- `time_to_treat`: For firm-years in countries that are subject to the regulatory reform: The time distance in years to the year where the reform went into effect. Zero for all firm-years that belong to countries that are not subject to the reform.
- `gvkey`: The global company key, a unique six-digit number key assigned to each company in the Standard & Poor's data universe
- `fyear`: The fiscal year of the firm-year observation
- `conm`: A company name
- `ear`: Accounting profitability, defined as income before extraordinary items, divided by average total assets, including our injected treatment effect
- `avg_ta`: Average total assets, meaning the total assets of the beginning of the fiscal year plus the total assets at the end of the fiscal year, divided by two.


### Your task

Starting from the original data, I injected a treatment effect to the data by adding a constant amount to the `ear` variable of all firms-years where `treat` is `TRUE`. Your job is to provide an estimate and its 95%-confidence interval for this constant. Ideally, this estimate should be unbiased and efficient. But watch out: confidence intervals can also be too narrow, meaning that they in expectation lead to rejections of the Null hypothesis too often. 

If you need a starting point for your analysis, take a look at [the chapter on Difference-in-Differences in Cunningham (2021) ](https://mixtape.scunning.com/difference-in-differences.html). While it also covers more advanced topics, it provides the general intuition as well as R, Python and Stata code. Use it as an inspiration to set up a regression model for estimating the treatment effect. 

When done, please upload your estimate and its confidence interval on Moodle. If you have been working as a team on the assignment, each member should submit their results separately. The deadline for the assignment is Friday, May 13. As you know, completing the assignment is voluntary but --- pretty please --- do it regardless. It will help you to understand the empirical analyses that we will discuss throughout the course. 


### Some remarks on how to use the materials in this repo

If you are new to scientific computing, we suggest that you also pick up a reference from the list below and browse through it. The [Gentzkow and Shapiro (2014) paper](https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf) is a particularly easy and also useful read. 

Then browse around the repository and familiarize yourself with its folders. You will quickly see that there are three folders that have files in them:

- `code`: This directory holds program scripts that are being called to download data from WRDS, prepare the student sample explained above and some additional analyses that we have discussed in class.

- `data`: A directory where data is stored. You will see that it again contains sub-directories and a README file that explains their purpose. You will also see that in the `external` sub-directory there are some data files. Again, the README file explains their content.

You also see an `output` directory but it is empty. Why? Because you will create the output locally on your computer, if you want.


### Getting WRDS access

The data we use on class is obtained via the API of the Wharton Research Data Services (WRDS). If you are a Humboldt student, you can get WRDS access by going to https://wrds-www.wharton.upenn.edu/register/. Please make sure that you use the following data when registering

- Email address: your official HU email address 
- Subscriber: "Humboldt-Universität zu Berlin"
- User type: "Students (Masters/Undergrad)"
- Department: "School of Business and Economics/Finance"

No worries if you are not a Humboldt student. You do not need access to WRDS to participate in the course.


### Running the code to reproduce the data

Assuming that you have WRDS access, RStudio and make/Rtools installed, this should be relatively straightforward. If you don't but want to, [this blog post and the linked Youtube videos](https://joachim-gassen.github.io/2021/03/get-a-treat/) might get you started. It explains how to use the `treat` repository, a template repository that this repository is built on.

After setting up your computing environment, these are the next steps:

1. Download, clone or fork the repository to your local computing environment.
2. Before building everything you most likely need to install additional packages. This repository follows the established principle not to install any packages automatically. This is your computing environment. You decide what you want to install. See the code below for installing the packages.
3. Copy the file _config.csv to config.csv in the project main directory. Edit it by adding your WRDS credentials. 
4. Run 'make all' either via the console or by identifying the 'Build All' button in the 'Build' tab (normally in the upper right quadrant of the RStudio screen). 
5. Eventually, you will be greeted with some new files in `data/pulled` and `data/generated` and, at later stages of the class, in `output`.  Congratulations! You have successfully used an open science resource and reproduced our analysis. Now modify it and make it your own project!

If you do not see 'Build' tab this is most likely because you do not have 'make' installed on your system. 
  - For Windows: Install Rtools: https://cran.r-project.org/bin/windows/Rtools/
  - For MacOS: You need to install the Mac OS developer tools. Open a terminal and run `xcode-select --install` Follow the instructions
  - On Linux: I have never seen a Unix environment without 'make'. 

```
# Code to install packages to your system
install_package_if_missing <- function(pkg) {
  if (! pkg %in% installed.packages()[, "Package"]) install.packages(pkg)
}
install_package_if_missing("RPostgres")
install_package_if_missing("tidyverse")
install_package_if_missing("DBI")
install_package_if_missing("fixest")
install_package_if_missing("ExPanDaR")
```


### References

These are some very helpful texts discussing collaborative workflows for scientific computing:

- Christensen, Freese and Miguel (2019): Transparent and Reproducible Social Science Research, Chapter 11: https://www.ucpress.edu/book/9780520296954/transparent-and-reproducible-social-science-research
- Gentzkow and Shapiro (2014): Code and data for the social sciences:
a practitioner’s guide, https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf
- Wilson, Bryan, Cranston, Kitzes, Nederbragt and Teal (2017): Good enough practices in scientific computing, PLOS Computational Biology 13(6): 1-20, https://doi.org/10.1371/journal.pcbi.1005510

This repository was built based on the ['treat' template for reproducible research](https://github.com/trr266/treat).
