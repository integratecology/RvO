# This script is used to quantify the impact of using range vs occurrence distributions to quantify home ranges
# It is written to run on HZDR's hemera cluster
# It first simulates OUF data, then estimates the UDs from the data, and finally creates a data frame of sizes

setwd("/home/alston92/scratch/RvO")

# Load in the requisite packages into the root environment
library(ctmm)
library(data.table)


## read job number from command line
args = commandArgs(trailingOnly=TRUE)
sim_no <- args[1]


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

# Sampling frequencies to quantify
samp <- c(0.5, 1, 2, 4, 8, 16, 32, 64, 128)

# Specify the desired number of replicates for each sampling interval
nRep <- rep(1, 9)

# Create an empty data.frame for saving results
name_df <- c("sim_no","samp_freq", "agde_area", "krige_area")
df_sims <- array(rep(NaN), dim = c(0, length(name_df)))
colnames(df_sims) <- name_df


# Record start time to monitor how long replicates take to compute
sTime <- Sys.time()
print(sTime)

  
# Loop over sampling frequencies (samp)
for(i in 1:length(samp)){
    
  # Specify variables to manipulate sampling frequency while holding duration constant
  nd <- 256 
  pd <- samp[i]
  
  # sampling times
  st <- 1:(nd*pd)*(ds/pd) 
  
  nReps <- nRep[i]
  

  #################################
    
  # cat("Fitting the first movement model \n")
    
  # Simulate from the movement model
  sim <- simulate(mod, t=st)
    
  # Fit the movement model to the simulated data
  fit <- ctmm.fit(sim, CTMM=mod, control=list(method="pNewton")) #
    
   
  #################################
  # Calculate the range area
  #################################
    
   # AGDE 95% area
   agdeRngArea <- -2*log(0.05)*pi*fit$sigma[1] / trueRngArea

   # OUF-Krige occurrence estimate
   krigeOccEst <- occurrence(sim, CTMM=fit) #, res.space = sres[i]
    
   # OUF-Krige 95% occurrence area
   krigeOccArea <- sum(krigeOccEst$CDF <= 0.95) * prod(krigeOccEst$dr) / trueRngArea
    
   #################################
   # Vector of results to return
   # x <- c(nd, agdeRngArea, akdeRngArea, krigeOccArea, bbOccArea)
   x <- data.frame(sim_no, pd, agdeRngArea, krigeOccArea)
  
   # Store results in data.frame
   write.table(x, 'sims_RvO_sf.csv', append=TRUE, row.names=FALSE, col.names=FALSE, sep=',') 
  
  
  # Print indicators of progress
  print(pd)
  cTime <- Sys.time()
  print(cTime)
  print(cTime - sTime)
  
}


