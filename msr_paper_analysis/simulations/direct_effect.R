library(simstudy)
library(brms)
library(bayesplot)
library(posterior)

set.seed(1990)

# Number of samples to generate
n <- 5000

# Generate data
#########################

# Defining variables, and the relationships between them
# Approximated counts to normal when mean of the variable is > 100
def <- defData(varname = "RefAge", dist = "normal", formula = 114, variance = 20)
def <- defData(def, varname = "DevRefExp", dist = "normal", formula = 1543, variance = 40) 
def <- defData(def, varname = "L_Locations", dist = "poisson", formula = 3.3, link = "log")
def <- defData(def, varname = "L_LOC", dist = "normal", formula = 640, variance = 40) 


def <- defData(def, varname = "DevRefComExp", dist = "normal", formula = "85 + 
               0.6*log(DevRefExp)", variance = 20) 

def <- defData(def, varname = "PrevRef", dist = "poisson", formula = "2 + 
               0.2*log(DevRefExp)", link = "log") 

def <- defData(def, varname = "SR", dist = "binary", formula = "-1 + 0.1*log(RefAge) +
               0.05*log(L_LOC) + 0.05*L_Locations + 0.15*log(PrevRef) + 
               0.1*log(DevRefComExp) + 0.05*log(DevRefExp)", link = "logit") 

def <- defData(def, varname = "NmbRef", dist = "poisson", formula = "2.6 + 0.2*SR", link = "log") 
def <- defData(def, varname = "NmbRefType_UQ", dist = "poisson", formula = "1.2 + 0.3*SR", link = "log") 
def <- defData(def, varname = "NmbCodeElem_UQ", dist = "poisson", formula = "1.4 + 0.2*SR", link = "log")

def <- defData(def, varname = "NmbFiles", dist = "poisson", formula = "1.1 + 0.1*SR + 
               0.2*log(NmbRef)", link = "log") 
def <- defData(def, varname = "AvgNmbFiles", dist = "normal", formula = "0.5 + 0.05*NmbRef", variance = 0.3)

def <- defData(def, varname = "TR", dist = "binary", formula = "-2.3 + 0.5*SR + 
               0.02*NmbRefType_UQ + 0.02*NmbCodeElem_UQ + 0.02*log(NmbRef) +
               0.02*log(PrevRef) + 0.02*log(L_LOC) + 0.02*L_Locations", link = "logit")

def <- defData(def, varname = "R_LOC", dist = "normal", formula = "620 + 2*SR + 2*TR", variance = 40)
def <- defData(def, varname = "R_Locations", dist = "poisson", formula = "1 + 0.3*SR + 
               0.3*TR + 0.08*AvgNmbFiles + 0.1*NmbRef + 0.08*NmbRefType_UQ", link = "log") 


dat <- genData(n, def)

# Checks of the generated data. The numbers inserted in above generations were verified by plotting histograms.
# It was made sure that the input values reflected the wanted behavior for the variable.
mu <- 620
sigma <- 40
lambda <- 30
  
hist(rnorm(n, mu, sigma))
hist(rpois(n, lambda))

# Standardize all features, not treatment and outcome
dlist_dir_standardized <- list(
  TR = dat$TR,
  RefAge = scale(dat$RefAge),
  DevRefExp = scale(dat$DevRefExp),
  L_Locations = scale(dat$L_Locations), 
  L_LOC = scale(dat$L_LOC),
  DevRefComExp = scale(dat$DevRefComExp),
  PrevRef = scale(dat$PrevRef), 
  SR = dat$SR,
  NmbRef = scale(dat$NmbRef),
  NmbRefType_UQ = scale(dat$NmbRefType_UQ),
  NmbCodeElem_UQ = scale(dat$NmbCodeElem_UQ),
  NmbFiles = scale(dat$NmbFiles),
  AvgNmbFiles = scale(dat$AvgNmbFiles), 
  R_Locations = scale(dat$R_Locations), 
  R_LOC = scale(dat$R_LOC) 
)


# Creating Models
#########################

# Without inclusion of collider
dir_no_collider <- brm(TR ~ SR + L_Locations + L_LOC + NmbFiles + NmbRef + NmbRefType_UQ + NmbCodeElem_UQ + AvgNmbFiles +
                         RefAge + DevRefExp + DevRefComExp + PrevRef, family = bernoulli, 
                       data = dlist_dir_standardized, cores = 4, chains = 4, iter = 10000,
                       prior = c(prior(normal(-1, 1), class = Intercept), 
                                 prior(normal(0, 0.5), class = b)))



# With inclusion of collider
dir_collider <- brm(TR ~ SR + L_Locations + L_LOC + NmbFiles + NmbRef + NmbRefType_UQ + NmbCodeElem_UQ + AvgNmbFiles +
                         RefAge + DevRefExp + DevRefComExp + PrevRef + R_LOC + R_Locations, family = bernoulli, 
                       data = dlist_dir_standardized, cores = 4, chains = 4, iter = 10000,
                       prior = c(prior(normal(-1, 1), class = Intercept), 
                                 prior(normal(0, 0.5), class = b)))

# Results
#########################
summary(dir_no_collider)
summary(dir_collider)

# Compare models using loo_compare
dir_no_collider <- add_criterion(dir_no_collider, criterion = "loo")
dir_collider <- add_criterion(dir_collider, criterion = "loo")

comparison <- loo_compare(dir_no_collider, dir_collider)
comparison

# Diagnostics: Traceplots
#########################
draws_dir_no_collider <- as_draws_df(dir_no_collider)
draws_dir_collider <- as_draws_df(dir_collider)

mcmc_trace(draws_dir_no_collider)
mcmc_trace(draws_dir_collider)

# Posterior Predictive Checks
#########################
pp_check(dir_no_collider, type = "bars", ndraws = 100)
pp_check(dir_collider, type = "bars", ndraws = 100)


# Prior predictive checks
#########################
m0_dir_no_collider <- brm(TR ~ SR + L_Locations + L_LOC + NmbFiles + NmbRef + NmbRefType_UQ + NmbCodeElem_UQ + AvgNmbFiles +
                            RefAge + DevRefExp + DevRefComExp + PrevRef, family = bernoulli, 
                          data = dlist_dir_standardized, cores = 4, chains = 4, iter = 10000,
                          prior = c(prior(normal(-1, 1), class = Intercept), 
                                    prior(normal(0, 0.5), class = b)), sample_prior = "only")


m0_dir_collider <- brm(TR ~ SR + L_Locations + L_LOC + NmbFiles + NmbRef + NmbRefType_UQ + NmbCodeElem_UQ + AvgNmbFiles +
                         RefAge + DevRefExp + DevRefComExp + PrevRef + R_LOC + R_Locations, family = bernoulli, 
                       data = dlist_dir_standardized, cores = 4, chains = 4, iter = 10000,
                       prior = c(prior(normal(-1, 1), class = Intercept), 
                                 prior(normal(0, 0.5), class = b)), sample_prior = "only")

# Extract prior samples from the models
priors_no_collider <- as_draws_df(m0_dir_no_collider)
priors_collider <- as_draws_df(m0_dir_collider)

# Taking the inverse logit, due to the logit link function is being utilized in the models
intercept_prior <- inv_logit(priors_no_collider$b_Intercept)
SR_prior <- inv_logit(priors_no_collider$b_SR)
R_LOC_prior <- inv_logit(priors_collider$b_R_LOC)
R_Locations_prior <- inv_logit(priors_collider$b_R_Locations)

# Create a 2x2 layout for the plots
par(mfrow = c(2, 2))

# Create density plots for prior samples
dens(intercept_prior, adj = 0.1, main = "Alpha ~ dnorm(-1, 0.5)")
dens(SR_prior, adj = 0.1, main = "b_SR ~ dnorm(0, 0.5)")
dens(R_LOC_prior, adj = 0.1, main = "b_R_LOC ~ dnorm(0, 0.5)")
dens(R_Locations_prior, adj = 0.1, main = "b_R_Locations ~ dnorm(0, 0.5)")



