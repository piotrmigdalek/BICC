# Business Inteligence Case Challenge
Goal of the competition was to forecast KPI of the monthly revenue from retail sales of electricity. My work was based on custom ensemble method prepared in <tt>R</tt> using <tt>forecast</tt> and <tt>prophet</tt> libraries. Combination consisted of:
Model | Description
-------------| -------------
Dynamic harmonic regression | Regression model constructed using dummy fourier variables (in order to model seasonality) with (non-seasonal) ARIMA errors.
ETS | ETS(M, Ad, M) model with multiplicative errors and seasonality with additive
 damped trend chosen by minimalizing AICc criterion.
ETS + STL | ETS(M, N, N) model (simple exponential smoothing with multiplicative errors) with extrapolated trend and seasonality estimated by STL.
NNAR | NNAR(2,1,3)[12] model which is ANN iniciated with autoregression inputs; network has 3-3-1 structure with 3 neurons in the hidden layer.
Prophet | Monthly state space model with multiplicative seasonality estimated using bayesian method for changepoint detection and trend estimation.

Forecasts from different models were aggragated by simple arithmetic average, which often grants the best results (as a aggregator) when it comes to forecast accuracy. This simple trick provides a little bit of bias to composition of models prone to overfitting, which often results in better forecast accuracy. That was the case in my work, which scored lowest root of theil's criterion (best accuracy); on top of that it was highly viewed from the methodological standpoint, which added up to final best result in the competition.

<img width="1000" alt="wycinek_BICC" src="https://github.com/piotrmigdalek/BICC/assets/101133937/071e7109-da7f-4ad1-9e8e-ef56330119fa">

File *BICC.pdf* is original competition submission (in Polish), *BICC.R* includes source code and *Data_BICC.csv* features competition data.
