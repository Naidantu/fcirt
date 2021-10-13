#' @title bayesian convergence diagnosis plotting function
#' @description This function provides plots including density plots, trace plots, and auto-correlation plots to aid model convergence diagnosis.
#' @param x returned object
#' @param pars Names of plotted parameters. They can be "theta", "alpha", "delta", "tau", or a subset of parameters. See vignette for fcirt for more details.
#' @param plot Types of plots.They can be "density", "trace", or "autocorrelation".
#' @param inc_warmup Whether to include warmup iterations or not when plotting. The default is FALSE.
#' @return Selected plots for selected parameters
#' @examples
#' Data <- c(1,1,0,1)
#' Data <- matrix(Data,nrow = 2)
#' pairmap <- c(1,3,2,4)
#' pairmap <- matrix(pairmap,nrow = 2)
#' ind <- c(1,2,3,4)
#' ParInits <- c(1, 1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1)
#' ParInits <- matrix(ParInits, ncol = 3)
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,ParInits=ParInits,iter=5,chains=1)
#' bayesplot(mod, 'alpha', 'density', inc_warmup=FALSE)
#' @export
bayesplot <- function(x, pars, plot, inc_warmup=FALSE){
  UseMethod("bayesplot")
}


#' @export
#' @method bayesplot fcirt
bayesplot.fcirt <- function(x, pars, plot, inc_warmup=FALSE){

  x <- extract(x, 'fit')
  if (plot=="trace"){

    ret <- rstan::stan_trace(x, pars, inc_warmup = inc_warmup)

  }
  if (plot=="density"){

    ret <- rstan::stan_dens(x, pars, inc_warmup = inc_warmup)

  }
  if (plot=="autocorrelation"){

    ret <- rstan::stan_ac(x, pars, inc_warmup = inc_warmup)

  }
  ret
}
