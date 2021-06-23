# This script is used to quantify the impact of using range vs occurrence distributions to quantify home ranges
# It is written to run on HZDR's hemera cluster
# It first simulates OUF data, then estimates the UDs from the data, and finally creates a data frame of sizes

setwd("/home/alston92/scratch/RvO")

# Load in the requisite packages into the root environment
library(ctmm)


######################################################################
################ Define the OUF model parameters #####################
######################################################################

# Length of a day in seconds
ds <- 86400

# Spatial variance in m^2
sig <- 100000

# True 95% range area
trueRngArea <- -2*log(0.05)*pi*sig

# Specify an OUF model for simulation
mod <- ctmm(tau=c(ds,ds-1), isotropic=TRUE, sigma=sig, mu=c(0,0))


######################################################################
############ Simulation that varies the sampling interval ############
######################################################################

# Record start time to monitor how long replicates take to compute
sTime <- Sys.time()
print(sTime)

  
# Specify variables to manipulate sampling frequency while holding duration constant
nd <- 100
pd <- 256
  
# sampling times
st <- 1:(nd*pd)*(ds/pd) 
  
# cat("Fitting the first movement model \n")
    
# Simulate from the movement model
sim <- simulate(mod, t=st)
    
# Fit the movement model to the simulated data
fit <- ctmm.fit(sim, CTMM=mod, control=list(method="pNewton")) #
    
# OUF-Krige occurrence estimate
krigeOccEst <- occurrence(sim, CTMM=fit) #, res.space = sres[i]



# Print indicators of progress
print(pd)
cTime <- Sys.time()
print(cTime)
print(cTime - sTime)

