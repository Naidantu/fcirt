#' @title forced choice model estimation
#' @description This function implements full Bayesian estimation of forced choice models using rstan
#' @param fcirt.Data Response data in wide format
#' @param pairmap A two-column data matrix: the first column is the statement number for statement s; the second column is the statement number for statement t.
#' @param ind A column vector mapping each statement to each trait. For example, c(1, 1, 1, 2, 2, 2) means that the first 3 statements belong to trait 1 and the last 3 statements belong to trait 2.
#' @param ParInits A three-column matrix containing initial values for the three statement parameters. If using the direct MUPP estimation approach, 1 and -1 for alphas and taus are recommended and -1 or 1 for deltas are recommended depending on the signs of the statements. If using the two-step estimation approach, pre-estimated statement parameters are used as the initial values. The R package bmggum can be used to estimate statement parameters for the two-step approach. See documentation for bmggum for more details.
#' @param model Models fitted. They can be "MUPP". The default is MUPP (Multi-Unidimensional Pairwise Preference) model.
#' @param covariate An p*c person covariate matrix where p equals sample size and c equals the number of covariates. The default is NULL, meaning no person covariate.
#' @param iter The number of iterations. The default value is 3000. See documentation for rstan for more details.
#' @param chains The number of chains. The default value is 3. See documentation for rstan for more details.
#' @param warmup The number of warmups to discard. The default value is 0.5*iterations. See documentation for rstan for more details.
#' @param adapt_delta Target average proposal acceptance probability during Stan's adaptation period. The default value is 0.90. See documentation for rstan for more details.
#' @param max_treedepth Cap on the depth of the trees evaluated during each iteration. The default value is 15. See documentation for rstan for more details.
#' @param thin Thinning. The default value is 1. See documentation for rstan for more details.
#' @param cores The number of computer cores used for parallel computing. The default value is 2.
#' @param ma Mean of the prior distribution for alphas, which follows a lognormal distribution. The default value is 0.
#' @param va Standard deviation of the prior distribution for alpha. The default value is 0.5.
#' @param md Mean of the prior distribution for deltas, which follows a normal distribution. The default value is 0.
#' @param vd Standard deviation of the prior distribution for deltas. The default value is 1.
#' @param mt Means of the prior distributions for taus, which follows a normal distribution. The default values is 0.
#' @param vt Standard deviation of the prior distribution for taus. The default value is 2.
#' @return Result object that stores information including the (1) stanfit object, (2) estimated item parameters, (3) estimated person parameters, (4) response data, and (5) the input column vector mapping each statement to each trait.
#' @examples
#' Data <- c(1)
#' Data <- matrix(Data,nrow = 1)
#' pairmap <- c(1,2)
#' pairmap <- matrix(pairmap,nrow = 1)
#' ind <- c(1,2)
#' ParInits <- c(1, 1, 1, -1, -1, -1)
#' ParInits <- matrix(ParInits, ncol = 3)
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,ParInits=ParInits,iter=3,warmup=1,chains=1)
#' @export
fcirt <- function(fcirt.Data, pairmap, ind, ParInits, model="MUPP", covariate=NULL, iter=3000, chains=3,
                   warmup=floor(iter/2), adapt_delta=0.90, max_treedepth=15, thin=1, cores=2,
                   ma=0, va=0.5, md=0, vd=1, mt=0, vt=2){

  dimension <- NULL
  dimension <- ind

  if (model=="MUPP"){

    if (is.null(covariate)){

      #sample size
      I <- nrow(fcirt.Data)
      #number of pairs
      J <- nrow(pairmap)
      S <- J*2
      D <- max(ind)

      #initial values
      init_fun <- function() {
        list(alpha=ParInits[,1], delta=ParInits[,2], tau=ParInits[,3], theta=matrix(0,nrow=I,ncol=D))
      }

      data_list<-list(n_student = I, n_item=S, n_pair=J, n_dimension=D, p=pairmap, d=ind, res=fcirt.Data,
        ma=ma,
        va=va,
        md=md,
        vd=vd,
        mt=mt,
        vt=vt)

      ##################################################
      #       Input response data estimation        #
      ##################################################

      rstan::rstan_options(auto_write = TRUE,javascript = FALSE)

      fcirt<-rstan::sampling(stanmodels$muppnocov,data=data_list,
                                 iter=iter, chains=chains,cores=cores, warmup=warmup,
                                 init=init_fun, thin=thin,
                                 control=list(adapt_delta=adapt_delta,max_treedepth=max_treedepth))

      #####Extract some parameters
      THETA<-rstan::summary(fcirt, pars = c("theta"), probs = c(0.025,0.5,0.975))$summary
      Alpha_ES<-rstan::summary(fcirt, pars = c("alpha"), probs = c(0.025,0.5,0.975))$summary
      Delta_ES<-rstan::summary(fcirt, pars = c("delta"), probs = c(0.025, 0.5,0.975))$summary
      Tau_ES<-rstan::summary(fcirt, pars = c("tau"), probs = c(0.025, 0.5,0.975))$summary
      #Cor_ES<-rstan::summary(fcirt, pars = c("Cor"), probs = c(0.025, 0.5,0.975))$summary

      #####save estimated parameters to an R object
      fcirt.summary<-list(Theta.est=THETA,
                          Alpha.est=Alpha_ES,
                          Delta.est=Delta_ES,
                          Tau.est=Tau_ES,
                          #Cor.est=Cor_ES,
                          Data=fcirt.Data,
                          Fit=fcirt,
                          Dimension=dimension,
                          Pairmap=pairmap,
                          ParInits=ParInits)
    }
  }

  class(fcirt.summary) <- "fcirt"
  return(fcirt.summary)
}
