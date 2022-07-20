###############################################################################
### ---------------------------  BICC entry --------------------------------###
###############################################################################

### ---------------------------  Libraries ---------------------------------###

library(forecast)
library(ggplot2)
library(prophet)

### -----------------------------  Intro -----------------------------------###

BICC <- read.csv("Data_BICC.csv", header = T, row.names=NULL, sep = ";")[,2]
ts.BICC <- ts(BICC, frequency = 12, start = c(2000, 12))

### -----------------------  Basic EDA/plotting ----------------------------###

y.label <- "KPI [million dollars]"

autoplot(ts.BICC) + labs(y = y.label)
ggtsdisplay(ts.BICC)
ts.BICC %>% mstl() %>% autoplot(ts.BICC) + labs(y = y.label)

ggseasonplot(ts.BICC) + labs(y = y.label)
ggseasonplot(ts.BICC, polar=TRUE) + labs(y = y.label)
ggsubseriesplot(ts.BICC) + labs(y = y.label)

gglagplot(ts.BICC) + labs(y = y.label)

###############################################################################
### --------------------------  Methodology -- -----------------------------###
###############################################################################

### ---------------  Dynamic harmonic regression vs. ARIMA  ----------------###

arima <- auto.arima(ts.BICC, lambda = "auto")
ARIMA <- arima %>% forecast(h =50)

dhr <- auto.arima(
  ts.BICC,
  lambda = "auto",
  xreg = fourier(ts.BICC, 6),
  seasonal = F
) 

DHR <- dhr %>% 
  forecast(h = 50, xreg = fourier(ts.BICC, 6, h = 50))

checkresiduals(arima, test = F)
checkresiduals(dhr, test = F)

autoplot(ts.BICC) +
  autolayer(DHR, series="DHR", PI=FALSE) +
  autolayer(ARIMA, series="ARIMA", PI=FALSE) + labs(y = y.label) 

### -------------------------------- ETS -----------------------------------###

ets <- ets(ts.BICC)
ETS <- ets %>% forecast(h = 50)

checkresiduals(ets, test=F)

autoplot(ts.BICC) +
  autolayer(ETS, series="ETS", PI=FALSE) + labs(y = y.label) 

STL <- stlf(ts.BICC, h = 50)

autoplot(ts.BICC) +
  autolayer(STL, series="STL + ETS", PI=FALSE) + labs(y = y.label)

autoplot(ts.BICC) +
  autolayer(STL, series="STL + ETS", PI=FALSE) + labs(y = y.label) +
  autolayer(ETS, series="ETS", PI=FALSE) + labs(y = y.label)
  
### -------------------------------- NNAR ----------------------------------###

nnar <- nnetar(ts.BICC, repeats = 100, size = 3)
NNAR <- nnar %>% forecast(h = 50)

checkresiduals(nnar, test=F)

autoplot(ts.BICC) +
  autolayer(NNAR, series="NNAR") + labs(y = y.label)

### ------------------------------ PROPHET ---------------------------------###

df.BICC <- data.frame(ds = zoo::as.Date(time(ts.BICC)), y = matrix(ts.BICC))
prophet <- prophet(df.BICC, seasonality.mode = 'multiplicative')
future <- make_future_dataframe(prophet, periods = 50, freq = 'month')
predict <- predict(prophet, future)
PROPHET <- ts(tail(predict[["yhat"]], 50), start = c(2017, 12), frequency = 12)

prophet_plot_components(prophet, predict)
plot(prophet, predict)

###############################################################################
### ------------------------------ Results ---------------------------------###
###############################################################################

COMBINATION <- (DHR[["mean"]] + NNAR[["mean"]] + 
                  ETS[["mean"]] + PROPHET + STL[["mean"]])/5

autoplot(ts.BICC) +
  autolayer(DHR, series="DHR", PI=FALSE) +
  autolayer(NNAR, series="NNAR", PI=FALSE) +
  autolayer(STL, series = "STL + ETS", PI=FALSE) +
  autolayer(COMBINATION, series="COMBINATION") +
  autolayer(PROPHET, series="PROPHET") +
  autolayer(ETS, series="ETS", PI=FALSE)

autoplot(ts.BICC) + autolayer(COMBINATION, series="COMBINATION")