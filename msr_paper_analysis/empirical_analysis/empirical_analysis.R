library(simstudy)
library(brms)
library(bayesplot)
library(posterior)
library(dplyr)

# Loading Data 
#########################
script_dir <- dirname(rstudioapi::getActiveDocumentContext()$path)
setwd(script_dir)
dataset <- read.csv('data/commit_level_features_w_test_transformed_small.csv')
dataset

# Number of samples
n <- 8000

# Retrieve the number of samples wanted from the empirical data
sampled_data <- dataset %>% 
  sample_n(n, replace = FALSE)


dlist_emp_standardized <- list(
  TR = sampled_data$TR,
  SR = sampled_data$SR,
  R_LOC = scale(sampled_data$rightLocationDiff),
  R_Locations = scale(sampled_data$rightLocationCount)
)


# Creating Models
#########################

# Without inclusion of collider
emp_no_collider <- brm(TR ~ SR, family = bernoulli, 
                       data = dlist_emp_standardized, cores = 4, chains = 4, iter = 10000,
                       prior = c(prior(normal(-1, 1), class = Intercept), 
                                 prior(normal(0, 0.05), class = b)))



# With inclusion of collider
emp_collider <- brm(TR ~ SR + R_LOC + R_Locations, 
                    family = bernoulli, data = dlist_emp_standardized, cores = 4, chains = 4, iter = 10000,
                    prior = c(prior(normal(-1, 1), class = Intercept), 
                              prior(normal(0, 0.05), class = b)))


# Resulting Estimates
#########################
summary(emp_no_collider)
summary(emp_collider)

# Diagnostics: Traceplots
#########################
draws_emp_no_collider <- as_draws_df(emp_no_collider)
draws_emp_collider <- as_draws_df(emp_collider)

mcmc_trace(draws_emp_no_collider)
mcmc_trace(draws_emp_collider)


# Posterior Predictive Checks
#########################
pp_check(emp_no_collider, type = "bars", ndraws = 100)
pp_check(emp_collider, type = "bars", ndraws = 100)
