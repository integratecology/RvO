# This script is used to quantify the impact of using range vs occurrence distributions to quantify home ranges
# It is written to run on HZDR's hemera cluster
# It first simulates OUF data, then estimates the UDs from the data, and finally creates a data frame of sizes

setwd("/home/alston92/scratch/RvO")

# Load in the requisite packages into the root environment
library(ctmm)
library(foreach)
library(doParallel)
# library(R.utils)

## read job number from command line
args = commandArgs(trailingOnly=TRUE)


######################################################################
############### Set up the cores for the parallelisation #############
######################################################################

# Register multiple cores for DoParallel
# This will vary based on how many you ask for in the .job file
nCores <- 4
# as.integer(Sys.getenv("NSLOTS"))

registerDoParallel(nCores)

# Check that it's setup correctly (should match what you've asked for)
getDoParWorkers()


# Now register 1 core to be used by the optimiser
# Need to do this to avoid problems with nested paralellisation
# This works because mclapply() and foreach() have different ways of registering the number of cores

Sys.setenv(MC_CORES=1) # Set the number of cores to one 
Sys.getenv("MC_CORES") # Check that it worked (should be 1)


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
samp <- c(0.5, 1, 2, 4, 8, 16, 32, 64, 128, 256)

# Specify the desired number of replicates for each sampling interval
nRep <- rep(4, 10)

# Create an empty list for saving the results
res <- list()

# Record start time to monitor how long replicates take to compute
sTime <- Sys.time()
print(sTime)

  
# Loop over sampling frequencies (samp)
for(i in 1:length(samp)){
    
  # Specify variables to manipulate sampling frequency while holding duration constant
  nd <- 50
  pd <- samp[i]
  
  # sampling times
  st <- 1:(nd*pd)*(ds/pd) 
  
  nReps <- nRep[i]
  

  # This is a parallelized loop that distributes each rep to a particular core.
  # Syntax is a bit weird, but it takes a vector of results defined at the end of the loop
  # and combines them via rbind into a matrix, here called "x".
  
  x <- foreach(j=1:nReps,
               .combine='rbind',
               .packages = c('ctmm'),
               .export = c("ds", "sig", "mod", "nReps", "st", "nd", "trueRngArea")) %dopar% { #
    
    
    # Load in the requisite packages into the clustered environment
    # library(ctmm)

    
    
    #################################
    
    # cat("Fitting the first movement model \n")
    
    # Simulate from the movement model
    sim <- simulate(mod, t=st)
    
    # Fit the movement model to the simulated data
    fit <- ctmm.fit(sim, CTMM=mod, control=list(method="pNewton")) #
    
    # Fit the Brownian motion model to the data, even though it is mis-specified here
    # fitBB <- ctmm.fit(sim, CTMM=ctmm(tau=Inf), control=list(method="Nelder-Mead")) # method="pNewton", zero=TRUE)

    
    
    #################################
    #Calculate the range area
    #################################
    
    # AGDE 95% area
    agdeRngArea <- -2*log(0.05)*pi*fit$sigma[1] / trueRngArea

    
    # AKDE range estimate
    # akdeRngEst <- akde(sim, CTMM=fit)
    
    # AKDE 95% area
    # akdeRngArea <- sum(akdeRngEst$CDF <= 0.95) * prod(akdeRngEst$dr) / trueRngArea
    
    
    # OUF-Krige occurrence estimate
    krigeOccEst <- occurrence(sim, CTMM=fit) #, res.space = sres[i]
    
    # OUF-Krige 95% occurrence area
    krigeOccArea <- sum(krigeOccEst$CDF <= 0.95) * prod(krigeOccEst$dr) / trueRngArea
    
    
    # Brownian bridge occurrence estimate
    # bbOccEst <- occurrence(sim, CTMM=fitBB) #, res.space = sres[i]
    
    # Brownian bridge 95% occurrence area
    # bbOccArea <- sum(bbOccEst$CDF <= 0.95) * prod(bbOccEst$dr) / trueRngArea
    
    
    
    #################################
    # Vector of results to return
    # x <- c(nd, agdeRngArea, akdeRngArea, krigeOccArea, bbOccArea)
    x <- c(pd, agdeRngArea, krigeOccArea)
  }
  
  
  # Store results in a list
  res[[i]] <- x
  
  
  # Print indicators of progress
  print(pd)
  cTime <- Sys.time()
  print(cTime)
  print(cTime - sTime)
  
  # Save the results as they come out (in case of crashes)
  write.csv(res, paste0("RvO_sims_sf_initial_job",args[1],".csv"))
  
}

# Once all the simulations have been computed, bind everything together as a df
res <- do.call(rbind, res)

res <- data.frame("samp_freq" = res[,1], "agde_area" = res[,2], "krige_area" = res[,3])

# Then save the output
save(res, file = paste0("RvO_sims_sf_test_job",args[1],".rda"))
write.csv(res, paste0("RvO_sims_sf_final",args[1],".csv"))



