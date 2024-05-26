library(simstudy)
library(brms)
library(bayesplot)
library(posterior)

set.seed(42)

# Number of samples to generate
n <- 5000

# Generate data
#########################
def <- defData(varname = "SR", dist = "binary", formula = 0.85)
def <- defData(def, varname = "TR", dist = "binary", formula = "-1.8 + SR*0.8", link = "logit")
def <- defData(def, varname = "R_LOC", dist = "normal", formula = "620 + 2*SR + 2*TR", variance = 100)
def <- defData(def, varname = "R_Locations", dist = "poisson", formula = "2.5 + 0.8*TR + 0.8*SR", link = "log")

dat = genData(n, def)

dlist_tot_standardized <- list(
  SR = dat$SR,
  TR = dat$TR,
  R_LOC = standardize(dat$R_LOC),
  R_Locations = standardize(dat$R_Locations)
)

# Creating Models
#########################

# Without inclusion of collider
tot_no_collider <- brm(TR ~ SR, family = bernoulli, 
          data = dlist_tot_standardized, cores = 4, chains = 4, iter = 10000,
          prior = c(prior(normal(-1, 1), class = Intercept), 
                    prior(normal(0, 0.5), class = b)))



# With inclusion of collider
tot_collider <- brm(TR ~ SR + R_LOC + R_Locations, 
                        family = bernoulli, data = dlist_tot_standardized, cores = 4, chains = 4, iter = 10000,
                        prior = c(prior(normal(-1, 1), class = Intercept), 
                                  prior(normal(0, 0.5), class = b)))


# Resulting Estimates
#########################
summary(tot_no_collider)
summary(tot_collider)


# Diagnostics: Traceplots
#########################
draws_tot_no_collider <- as_draws_df(tot_no_collider)
draws_tot_collider <- as_draws_df(tot_collider)

mcmc_trace(draws_tot_no_collider)
mcmc_trace(draws_tot_collider)


# Posterior Predictive Checks
#########################
pp_check(tot_no_collider, type = "bars", ndraws = 100)
pp_check(tot_collider, type = "bars", ndraws = 100)


# Prior predictive checks
#########################
m0_tot_no_collider <- brm(TR ~ SR, family = bernoulli, 
                           data = dlist_tot_standardized, cores = 4, chains = 4, iter = 10000,
                           prior = c(prior(normal(-1, 1), class = Intercept), 
                                     prior(normal(0, 0.5), class = b)), sample_prior = "only")

m0_tot_collider <- brm(TR ~ SR + R_LOC + R_Locations, 
                        family = bernoulli, data = dlist_tot_standardized, cores = 4, chains = 4, iter = 10000,
                        prior = c(prior(normal(-1, 1), class = Intercept), 
                                  prior(normal(0, 0.5), class = b)), sample_prior = "only")

# Extract prior samples from the models
priors_no_collider <- as_draws_df(m0_tot_no_collider)
priors_collider <- as_draws_df(m0_tot_collider)

# Taking the inverse logit, due to the logit link function is being utilized in the models
intercept_prior <- inv_logit(priors_no_collider$b_Intercept)
SR_prior <- inv_logit(priors_no_collider$b_SR)
R_LOC_prior <- inv_logit(priors_collider$b_R_LOC)
R_Locations_prior <- inv_logit(priors_collider$b_R_Locations)

# Create a 2x2 layout for the plots
par(mfrow = c(2, 2))

# Create density plots for the prior samples
dens(intercept_prior, adj = 0.1, main = "Alpha ~ dnorm(-1, 0.5)")
dens(SR_prior, adj = 0.1, main = "b_SR ~ dnorm(0, 0.5)")
dens(R_LOC_prior, adj = 0.1, main = "b_R_LOC ~ dnorm(0, 0.5)")
dens(R_Locations_prior, adj = 0.1, main = "b_R_Locations ~ dnorm(0, 0.5)")






