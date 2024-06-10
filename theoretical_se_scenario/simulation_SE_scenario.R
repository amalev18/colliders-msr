library(simstudy)
library(brms)
library(bayesplot)
library(posterior)

set.seed(42)

# Number of samples
n <- 8000

# Generate data with Simstudy
#########################
def <- defData(varname = "DevExp", dist = "poisson", formula = 5) 
def <- defData(def, varname = "LOC", dist = "normal", formula = "70 - 
               0.95*DevExp", variance = 15) #approx normal
def <- defData(def, varname = "Bugs", dist = "poisson", formula = "-5 + 0.08*LOC -
               0.40*DevExp", link = "log") 

dat = genData(n, def)

# Verification of simulated data
#########################
hist(dat$Bugs, xlab = "Number of Bugs")
max(dat$Bugs)
hist(dat$LOC, xlab = "LOC")
hist(dat$DevExp, xlab = "DevExp")

# Fit two models
#########################
no_collider <- brm(LOC ~ DevExp, family = gaussian, 
                           data = dat, cores = 4, chains = 4, iter = 10000,
                           prior = c(prior(normal(70, 5), class = Intercept), 
                                     prior(normal(0, 0.5), class = b),
                                     prior(exponential(1), class = sigma)))

collider <- brm(LOC ~ DevExp + Bugs, family = gaussian, 
                   data = dat, cores = 4, chains = 4, iter = 10000,
                   prior = c(prior(normal(70, 5), class = Intercept), 
                             prior(normal(0, 0.5), class = b),
                             prior(exponential(1), class = sigma)))

# Resulting Estimates
#########################
summary(no_collider) 
summary(collider)


# Diagnostics: Traceplots
#########################
draws_no_collider <- as_draws_df(no_collider)
draws_collider <- as_draws_df(collider)

# Generate the plots
mcmc_trace(draws_no_collider)
mcmc_trace(draws_collider)


# Posterior Predictive Checks
#########################
pp_check(no_collider, ndraws = 30)
pp_check(collider, ndraws = 30)


# Prior Predictive Checks
#########################
# Run both models using only the priors
m0_no_collider <- brm(LOC ~ DevExp, family = gaussian, 
                   data = dat, cores = 4, chains = 4, iter = 10000,
                   prior = c(prior(normal(70, 5), class = Intercept), 
                             prior(normal(0, 0.5), class = b)), sample_prior = "only")

m0_collider <- brm(LOC ~ DevExp + Bugs, family = gaussian, 
                data = dat, cores = 4, chains = 4, iter = 10000,
                prior = c(prior(normal(70, 5), class = Intercept), 
                          prior(normal(0, 0.5), class = b)), sample_prior = "only")

# Extract prior samples from the models
priors_no_collider <- as_draws_df(m0_no_collider)
priors_collider <- as_draws_df(m0_collider)

# Create desnity plots for the prior samples
mcmc_dens(priors_no_collider, pars = c("b_Intercept", "b_DevExp"))
mcmc_dens(priors_collider, pars = c("b_Intercept", "b_DevExp", "b_Bugs"))



