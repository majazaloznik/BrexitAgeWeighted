###############################################################################
## "Data driven" analysis of Brexit asoociated results - FINAL PLOTS
###############################################################################
##
###############################################################################
## preliminaries
## Load data and funcitons
load("data/cleanData.Rdata")
source("scripts/03-Functions.R")
## 

## RECREATION OF ACTUAL REFERENDUM RESULTS:
###############################################################################
## Plot referendum result with one person-one vote system
FunBestPlot(all.6age.groups, base = "count")

## summary of results 
FunCalculateResult(all.6age.groups, base = "count")



## ALTERNATIVE VOTING SYSTEM 
###############################################################################
## plot referendum result with remaining life years as base:
FunBestPlot(all.6age.groups, base = "lexp")
## summary of results 
FunCalculateResult(all.6age.groups, base = "lexp")



