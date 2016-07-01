###############################################################################
## "Data driven" analysis of Brexit asoociated results - FUNCTIONS
###############################################################################
## FunCalculateResult()
## FunBestPlot()
###############################################################################
## 0. preliminaries
require(tidyr)
require(dplyr)
###############################################################################

## function to calculate the result based on count and 3 rates:
###############################################################################
FunCalculateResult <- function(all.6age.groups, base="count") {
  if (base== "lexp") all.6age.groups$count <- all.6age.groups$years.left
  ## turount 
  all.6age.groups %>%
    mutate(registered.count = count*registered.prop,
           turnout.count =registered.count *turnout.prop,
           vote.remain = registered.prop*count*turnout.prop * remain.prop,
           vote.leave = registered.prop*count*turnout.prop * (1-remain.prop)) %>%
    summarise(count = sum(count), turnout.count = sum(turnout.count),
              registered.count = sum(registered.count),
              registered.prop = registered.count/count,
              turnout.prop = turnout.count/registered.count,
              remain.count = sum(vote.remain),
              leave.count = sum(vote.leave),
              remain.prop=remain.count/turnout.count,
              leave.prop = leave.count/turnout.count) ->    
    estimates.summary 
  return(as.data.frame(estimates.summary))
}




## FunBestPlot() - plots total voting behaviour with base:
## base == "count" - regular populatio
## base == "lexp"  - years of life left remaining
###############################################################################


col.yellow <- rgb(255, 192, 16, maxColorValue = 255)
col.blue <- rgb(1, 105, 178, maxColorValue = 255)
FunBestPlot <- function(all.6age.groups, base="count"){
  if (base == "lexp") {
    main.title <- "Votes by life expectancy - hypothetical EU referendum result"
    all.6age.groups$count <- all.6age.groups$years.left}
  if (base == "count") {
    main.title <- "Age disaggregated - actual EU referendum result"}
  all.6age.groups %>%
    mutate(turnout.abs = turnout.prop*registered.prop,
           turnout.count = count*turnout.abs,
           not.reg.count=(1-registered.prop)*count,
           unvoting.count = count-turnout.count,
           not.reg.prop.wasted = not.reg.count/unvoting.count) %>%
    select(age.group, unvoting.count, not.reg.prop.wasted,
           turnout.count, remain.prop) %>%
    gather( waste, prop, c(3,5))%>%
    mutate(prop.alt = 1-prop,
           denom = ifelse(waste=="remain.prop", turnout.count, unvoting.count),
           yellow=ifelse(waste=="remain.prop", prop, 0),
           blue = ifelse(waste=="remain.prop", prop.alt, 0),
           black = ifelse(waste=="not.reg.prop.wasted", prop, 0),
           gray = ifelse(waste=="not.reg.prop.wasted", prop.alt, 0))%>%
    select(age.group, waste, prop, prop.alt, denom, yellow, blue, black, gray) %>%
    arrange(age.group) -> all.6age.groups.best.plot2 
  
  par(xpd=TRUE)
  layout(matrix(1:2,1), widths=c(5,1))
  
  par(mar=c(2.1,3.6,2.6,0.1))
  mp <- barplot(t(as.matrix(all.6age.groups.best.plot2[,8:9])),
                width=all.6age.groups.best.plot2$denom, col=c("black", "gray"),
                horiz=TRUE, xlim=c(0,1), space=c(rep(c(1,0),6)), 
                density=20, main=main.title)
  data.frame( rep(1:6, each=2), mp, pair=rep(c(1,2),6)) %>% 
    spread(pair, mp) -> pos
  mp<- apply(pos[,2:3], 1, mean)
  
  barplot(t(as.matrix(all.6age.groups.best.plot2[,6:7])),
          width=all.6age.groups.best.plot2$denom, col=c(col.yellow, col.blue),
          horiz=TRUE, xlim=c(0,1), space=c(rep(c(1,0),6)), add=TRUE)
  text(-0.05, mp, unique(all.6age.groups.best.plot2$age.group))
  lines(c(0.5,0.5),c(0,  par("usr")[4]),  lwd=4, lty=3)
  
  par(mar=c(1.6,1.1,3.6,1.6))
  barplot(t(as.matrix(FunCalculateResult(all.6age.groups)[8:9])), 
          beside = FALSE, horiz = FALSE,xlim=c(0,1), axes=FALSE,
          col=c(col.yellow, col.blue), las=2)
  r <- 100*as.matrix(FunCalculateResult(all.6age.groups))[8]
  l <- 100*as.matrix(FunCalculateResult(all.6age.groups))[9]
  text(0.65, 0.25, round(r,2), col= ifelse(r>l, "red", "black"), cex=1)
  text(0.65, 0.75, round(l,2),col= ifelse(l>r, "red", "black"), cex=1)
  lines(c(0.15,1.35),c(0.5,0.5), col="black", lwd=4, lty=3)
}


