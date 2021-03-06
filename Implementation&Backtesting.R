### Packages and Scripts ###

library(fGarch) #garchFit
library(tseries) #arma
library(PerformanceAnalytics) #chart.TimeSeries #zoo (underlying zoo package)

setwd("C:/Users/David/BootstrapRisk")
source("Methods.R") #FHS #HS #PRR #USB #empiricalDist #risk
source("Backtests.R") #exceptions #LRcc #LRind #LRuc #accuracy #qlf #rlf #sStatistic #compareVaR

### Implementation ###

#ret0912, ret13 and ret13Dates are obtained by running the script Data&Sample

#Run Methods
PRRdensities = empiricalDist(ret0912, ret13, 1000, 253, PRR)
USBdensities = empiricalDist(ret0912, ret13, 1000, 253, USB)
FHSdensities = empiricalDist(ret0912, ret13, 1000, 253, FHS)
HSdensities = empiricalDist(ret0912, ret13, length(ret0912), 253, HS)
rm(ret0912, FHS, HS, PRR, USB, empiricalDist)

#Estimate VaR and ES
PRRrisk = risk(PRRdensities, 0.01, "PRR")
USBrisk = risk(USBdensities, 0.01, "USB")
FHSrisk = risk(FHSdensities, 0.01, "FHS")
HSrisk = risk(HSdensities, 0.01, "HS")

#Build zoo object with risk matrix for the 4 methods
PRRriskzoo = zoo(PRRrisk, ret13Dates)
USBriskzoo = zoo(USBrisk, ret13Dates)
FHSriskzoo = zoo(FHSrisk, ret13Dates)
HSriskzoo = zoo(HSrisk, ret13Dates)

rm(ret13Dates, PRRrisk, USBrisk, FHSrisk, HSrisk, risk)

#Plots of the risk measures
par(mfrow=c(2,1))
par(mar=c(3,4,2,2))
chart.TimeSeries(PRRriskzoo, lwd = 1.5, ylab = "(a)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(2,5.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(USBriskzoo, lwd = 1.5, ylab = "(b)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(2,5.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(FHSriskzoo, lwd = 1.5, ylab = "(a)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(1,4.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(HSriskzoo, lwd = 1.5, ylab = "(b)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(1,4.5),lty = c("solid", "dotted"), col=c("black","black"))


### Backtesting ###

#VaR Accuracy Backtests
par(mfrow=c(2,1))
par(mar=c(3,4,2,2))
chart.TimeSeries(cbind(ret13,PRRriskzoo[,1]), lwd = 1.5, ylab = "(a)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(-3.5,4.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(cbind(ret13,USBriskzoo[,1]), lwd = 1.5, ylab = "(b)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(-3.5,4.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(cbind(ret13,FHSriskzoo[,1]), lwd = 1.5, ylab = "(a)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(-3.5,4.5),lty = c("solid", "dotted"), col=c("black","black"))
chart.TimeSeries(cbind(ret13,HSriskzoo[,1]), lwd = 1.5, ylab = "(b)", xlab = "", main = "", date.format = "%Y-%m-%d" , font.main = 1, ylim = c(-3.5,4.5),lty = c("solid", "dotted"), col=c("black","black"))

accuracyVaR(PRRriskzoo[,1], ret13, 0.01)
accuracyVaR(USBriskzoo[,1], ret13, 0.01)
accuracyVaR(FHSriskzoo[,1], ret13, 0.01)
accuracyVaR(HSriskzoo[,1], ret13, 0.01)
rm(LRuc, LRind, LRcc, accuracyVaR)

#VaR Performance Comparison
varList = list(PRRriskzoo[,1], USBriskzoo[,1], FHSriskzoo[,1], HSriskzoo[,1])
methodsNames = c("PRR", "USB", "FHS", "HS")
compareVaR(varList, ret13, rlf, methodsNames, 0.01)
compareVaR(varList, ret13, qlf, methodsNames, 0.01)
rm(varList, methodsNames, qlf, rlf, sStatistic, compareVaR)

#Expected Shortfall Accuracy Backtesting
RCtest(PRRriskzoo, PRRdensities, ret13, 0.01)
USBempirical = apply(rbind(-sqrt(USBdensities), sqrt(USBdensities)), 2, sort)
RCtest(USBriskzoo, USBempirical, ret13, 0.01)
RCtest(FHSriskzoo, FHSdensities, ret13, 0.01)
RCtest(HSriskzoo, HSdensities, ret13, 0.01)
rm(USBempirical, exceptions, RCtest)