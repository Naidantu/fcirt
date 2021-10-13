
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fcirt

<!-- badges: start -->

<!-- badges: end -->

The goal of fcirt is to estimate forced choice models using Bayesian
method. Specifically, the Multi-Unidimensional Pairwise Preference
(MUPP) model is estimated using the R package **rstan** that utilizes
the Hamiltonian Monte Carlo sampling algorithm.

## Installation

You can install the development version of fcirt from GitHub:

``` r
devtools::install_github("Naidantu/fcirt")
```

## Example

This is a basic example which shows you how to prepare data, fit the
model, extract and plot results:

``` r
library(fcirt)

## basic example code
## Step 1: Input data
# 1.1 Response data in wide format
fcirt.Data <- c(1,0,0,1,1,1,1,1,1,1,0,1,1,0,1,1,0,0,0,0,0,0,1,1,1,0,1,1,1,1,0,1,1,1,0,1,1,0,1,1)
fcirt.Data <- matrix(fcirt.Data,nrow = 10)

# 1.2 A two-column data matrix: the first column is the statement number for statement s; the second column is the statement number for statement t.
pairmap <- c(1,3,5,7,2,4,6,8)
pairmap <- matrix(pairmap,ncol = 2)

# 1.3 A column vector mapping each statement to each trait.
ind <- c(1,2,1,2,1,2,2,1)

# 1.4 A three-column matrix containing initial values for the three statement parameters (alpha, delta, tau) respectively. If using the direct MUPP estimation approach, 1 and -1 for alphas and taus are recommended and -1 or 1 for deltas are recommended depending on the signs of the statements. If using the two-step estimation approach, pre-estimated statement parameters are used as the initial values. The R package bmggum (Tu et al., 2021) can be used to estimate statement parameters for the two-step approach. 
ParInits <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1, -1, -1, -1, -1)
ParInits <- matrix(ParInits, ncol = 3)

## Step 2: Fit the MUPP model
mod <- fcirt(fcirt.Data=fcirt.Data, pairmap=pairmap, ind=ind, ParInits=ParInits, iter=1000)

## Step 3: Extract the estimated results 
# 3.1 Extract the theta estimates 
theta <- extract(x=mod, pars='theta')
# Turn the theta estimates into p*trait matrix where p equals sample size and trait equals the number of latent traits
theta <- theta[,1]
# nrow=trait
theta <- matrix(theta, nrow=2)  
theta <- t(theta)
# theta estimates in p*trait matrix format
theta
#>               [,1]         [,2]
#>  [1,]  0.031691057  0.046568218
#>  [2,] -0.073772791  0.043929525
#>  [3,] -0.029610641  0.008754898
#>  [4,] -0.020142885 -0.015084939
#>  [5,] -0.008128190 -0.024002590
#>  [6,] -0.027781033  0.002016315
#>  [7,]  0.024884600 -0.006782208
#>  [8,]  0.025812042 -0.034377790
#>  [9,]  0.029627509 -0.013221226
#> [10,]  0.003353149  0.016948932

## Step 4: Plottings
# 5.1 Obtain the density plots for alpha
bayesplot(x=mod, pars='alpha', plot='density', inc_warmup=FALSE)
```

<img src="man/figures/README-example-1.png" width="70%" />
