################################################################################
###
###   Data processing for UNHRC engagement project
###
###   Authors: Brad Smith, Gleason Judd
###   Created: 11/21/2014
###   Modified: 11/21/2014
###
###   Purpose: Transforms Rstan MCMC output to a usable form
###   
###
################################################################################

rm(list=ls())
require(foreign)
require(rstan)
### Set WD, load in Rstan results
setwd("~/Google Drive/Research/IO_latent.engage")
load("Output/UNHRCfit.RData")
load("Data/engagement_v3.RData")

### Load in full dataset to extract ID information (e.g. year, COW code)
UNHRCfit <- extract(fit)
data <- read.dta("Data/IOfull.dta")
eng <- as.data.frame(cbind(data[,c("Country",
                                   "Year",
                                   "COWid")]))
ID.data <- unique(eng[c("Country","Year","COWid")])
ID.data$EngID <- ID.data$Year*1000+ID.data$COWid

# Bind means from estimation to Engagement ID values
thetas <- UNHRCfit$theta
theta <- colMeans(thetas,dims=1)
theta95pct <- apply(thetas,
                     2,
                     quantile,
                     probs = c(0.025, 0.975))
theta95pct <- as.data.frame(cbind(theta95pct[1,], theta95pct[2,]))
names(theta95pct) <- c("theta95lower", "theta95upper")
theta80pct <- apply(thetas,
                    2,
                    quantile,
                    probs = c(0.1, 0.9))
theta80pct <- as.data.frame(cbind(theta80pct[1,], theta80pct[2,]))
names(theta80pct) <- c("theta80lower", "theta80upper")
thetas <- as.data.frame(cbind(EngID,
                              theta,
                              theta95pct,
                              theta80pct))

# Merge the full data with the theta means
output.data <- merge(ID.data,
                     thetas,
                     by = intersect(names(ID.data),names(thetas)))

# Now extract the alpha and Beta terms
Beta_posterior <- as.data.frame(UNHRCfit[["B"]])
alpha_posterior <- as.data.frame(UNHRCfit[["alpha"]])
Beta_means <- colMeans(Beta_posterior)
alpha_means <- colMeans(alpha_posterior)

Beta_quant_80 <- apply(Beta_posterior,
                       2,
                       quantile,
                       probs = c(.1, .9))
Beta_quant_95 <- apply(Beta_posterior,
                       2,
                       quantile,
                       probs = c(0.025, 0.975))

alpha_quant_80 <- apply(alpha_posterior,
                        2,
                        quantile,
                        probs = c(0.1, 0.9))

alpha_quant_95 <- apply(alpha_posterior,
                        2,
                        quantile,
                        probs = c(0.025, 0.975))

Betas <- rbind(Beta_means, Beta_quant_80, Beta_quant_95)

Betas <- as.data.frame(Betas)

alphas <- rbind(alpha_means, alpha_quant_80, alpha_quant_95)
alphas <- as.data.frame(alphas)

rm(list=setdiff(ls(),c("output.data", "alphas", "Betas")))
save.image("~/Google Drive/Research/IO_latent.engage/Output/output.data.RData")



