library(ggplot2)
library(rstan)
library(bayesplot) # Must also have the 'hexbin' package installed

# Read the data
input.df <- read.csv("sim_data.csv", header = TRUE,
                     colClasses = c('Date', 'integer', 'integer', 'integer', 'integer', 'numeric', 'numeric'))
head(input.df)

# Make the initial plot of click rates over time
plot.df <- cbind(rep(input.df$time, 2), stack(input.df, select = c(APct, BPct)))
colnames(plot.df) <- c('Date', 'clickPct', 'Group')
p <- ggplot(data = plot.df, aes(x = Date, y = clickPct, group = Group))
p + geom_line(aes(color = Group))+
  geom_point(aes(color = Group))+
  scale_color_manual(values=c('darkred', 'cornflowerblue'))+
  ylab("Click Rate")+
  ggtitle("Click Rates By Group Over Time")

# Define the model from file
ABmodel <- stan_model('ABmodel.stan')
# Fit a model to the 01-02-2020 data
beg.fit <- sampling(ABmodel, 
                    data = list(K = 2, 
                                N = as.numeric(input.df[1,4:5]), 
                                y = as.numeric(input.df[1,2:3])),
                    warmup = 2000,
                    iter = 10000)
# Fit a model to the data up to 01-12-2020
mid.fit <- sampling(ABmodel, 
                    data = list(K = 2, 
                                N = as.numeric(input.df[11,4:5]), 
                                y = as.numeric(input.df[11,2:3])),
                    warmup = 2000,
                    iter = 10000)
# Fit a model to the data up to 01-24-2020
end.fit <- sampling(ABmodel, 
                    data = list(K = 2, 
                                N = as.numeric(input.df[23,4:5]), 
                                y = as.numeric(input.df[23,2:3])),
                    warmup = 2000,
                    iter = 10000)

# Plots of the posterior distribution at various stages in the test
beg.posterior <- as.array(beg.fit)
mid.posterior <- as.array(mid.fit)
end.posterior <- as.array(end.fit)
mcmc_hex(beg.posterior, pars = c("theta[1]", "theta[2]"))+
  xlim(0.10,0.15)+
  ylim(0.10,0.15)+
  geom_abline(slope = 1, intercept = 0)+
  xlab("Group A Click Prob")+
  ylab("Group B Click Prob")+
  ggtitle("Posterior Density Using Data Up to 01-02-2020")
mcmc_hex(mid.posterior, pars = c("theta[1]", "theta[2]"))+
  xlim(0.10,0.14)+
  ylim(0.10,0.14)+
  geom_abline(slope = 1, intercept = 0)+
  xlab("Group A Click Prob")+
  ylab("Group B Click Prob")+
  ggtitle("Posterior Density Using Data Up to 01-12-2020")
mcmc_hex(end.posterior, pars = c("theta[1]", "theta[2]"))+
  xlim(0.10,0.14)+
  ylim(0.10,0.14)+
  geom_abline(slope = 1, intercept = 0)+
  xlab("Group A Click Prob")+
  ylab("Group B Click Prob")+
  ggtitle("Posterior Density Using Data Up to 01-24-2020")

# Find the percent of click rates that are larger in the control group 
posterior.mat <- as.matrix(end.fit)
sum(posterior.mat[,1]>posterior.mat[,2])/nrow(posterior.mat)

# Define and calculate the loss functions
lossA <- function(theta.vec){
  if (theta.vec[2]-theta.vec[1] > 0) return(theta.vec[2]-theta.vec[1])
  else return(0)
}
lossB <- function(theta.vec){
  if (theta.vec[1]-theta.vec[2] > 0) return(theta.vec[1]-theta.vec[2])
  else return(0)
}
loss.dist.B <- apply(posterior.mat[,1:2], 1, lossB)
loss.dist.A <- apply(posterior.mat[,1:2], 1, lossA)

loss.df <- stack(data.frame(groupA = loss.dist.A, groupB = loss.dist.B))
gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

# Plot the distribution of loss and calculate expected loss
ggplot(loss.df[loss.df$ind == 'groupA',], aes(x=values)) +
  geom_histogram(color="#F8766D", fill="#F8766D", alpha=0.25, position="identity")+
  ggtitle("Estimated Losses: Variation A")

ggplot(loss.df[loss.df$ind == 'groupB',], aes(x=values)) +
  geom_histogram(color="#00BFC4", fill="#00BFC4", alpha=0.25, position="identity")+
  ggtitle("Estimated Losses: Variation B")

ggplot(loss.df, aes(x=values, color=ind, fill=ind)) +
  geom_histogram(alpha=0.25, position="identity")+
  ggtitle("Estimated Losses: Both Variations")+
  scale_fill_discrete(name = "", labels = c("Variation A", "Variation B"))+
  scale_color_discrete(name = "", labels = c("Variation A", "Variation B"))

mean(loss.dist.A)
mean(loss.dist.B)