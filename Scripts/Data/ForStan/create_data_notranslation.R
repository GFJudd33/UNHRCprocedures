################################################################################
###
###
###   Code to create data object for use in Stan code.
###   Authors: Gleason Judd, Brad Smith
###
###   Created: 11/12/2014
###   Last modified: March 9, 2016
###   
###
###   Purpose: This script removes all observations in which the response
###            is coded as "in translation"
###            
###
################################################################################



rm(list=ls())
library(foreign)
setwd("~/Google Drive/Research/IO_latent.engage")

load("Data/FullUnique.Rdata")

data <- full.uniq
cyear <- read.dta("Data/CtryYearIO.dta")

####### Subset full.uniq  to physical integrity violations #####
data <- full.uniq[full.uniq$ResponseScore %in% c("TOR",
                                                 "SUMX",
                                                 "SALE",
                                                 "TRAF"),]

####### Build Dataset ########

# Subset full data to include only needed Variables in engagement dataset
eng <- as.data.frame(cbind(data[,c("Country",
                                   "Year",
                                   "COWid",
                                   "QualCode")]))

# Remove all observations for which QualCode = 6, indicating in translation
eng <- eng[eng$QualCode !=6,]

# Generate country year ID, sort data by this
#eng$ID <- eng$Year*1000+eng$COWid

# Change this script to just have a country identifier
eng$ID <- eng$COWid
order.eng <- eng[order(eng$ID),]



# Pull out identifier for the loop
EngID <- sort(unique(eng$ID))

X <- matrix(0,length(EngID),max(cyear$CompCount))


for (i in 1:length(EngID)){
  
  # Subset original matrix for the given ID variable
  sub <- eng[eng$ID==EngID[i],]
  
  # Fill in rows of X object with corresponding Quality Scores
  for(j in 1:length(sub$QualCode)){
    X[i,j] <- sub$QualCode[j]
  }
}

# Now generate a count of responses for each country year
A <- rep(0,nrow(X))
for (i in 1:nrow(X)){
  A[i] <- sum(as.numeric(as.logical(X[i,]>0)))
}

# Now generate complaint counts for each country year
# This is for use in the poisson, not needed for stan_v4

cyear$ID <- cyear$Year*1000+cyear$COWid
Z <- as.data.frame(cyear[,c("ID",
                            "CompCount")])

CountID <- Z$ID

Z <- Z$CompCount

# Clear Workspace, save data object
rm(list=setdiff(ls(),c("X","Z","EngID", "CountID","A")))

# Save this as object engagement.R
save.image("~/Google Drive/Research/IO_latent.engage/Data/engagement_v5_noit.Rdata")




