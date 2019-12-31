// This code is used as the framework for fitting a model for binomial A/B tests
// The traditional A/B test uses a control and one variate, but this model is 
// flexible enough to accomodate other scenarios

// The input data is a vector of integer 'y' values of length 'K'.
// We need a vector of total number of observations 'N' of length 'K'
// 'K' is the number of groups in the A/B test
data {
  int<lower=0> K;
  int<lower=0> N[K];
  int<lower=0> y[K];
}

// Define the parameters for each group
parameters {
  real<lower=0,upper=1> theta[K];
}

// We are going to model 'y' in each group as binomial
// We assign a beta prior to the parameters that favors lower rates. This can be modified
model {
  for (i in 1:K){
    theta[i] ~ beta(0.75,1);
  }
  for (i in 1:K){
    y[i] ~ binomial(N[i],theta[i]);
  }
}