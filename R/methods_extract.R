#' @title results extraction
#' @description This function extracts estimation results.
#' @param x returned object
#' @param pars Names of extracted parameters. They can be "theta" (person trait estimates), "alpha" (statement discrimination parameters), "delta" (statement location parameters), "tau" (statement threshold parameters), data" (fcirt.Data), "fit" (the stanfit object), "dimension" (the input column vector mapping each statement to each trait), "pairmap" (A two-column data matrix: the first column is the statement number for statement s; the second column is the statement number for statement t), and "ParInits" (A three-column matrix containing initial values for the three statement parameters. If using the direct MUPP estimation approach, 1 and -1 for alphas and taus are recommended and -1 or 1 for deltas are recommended depending on the signs of the statements. If using the two-step estimation approach, pre-estimated statement parameters are used as the initial values. The R package bmggum can be used to estimate statement parameters for the two-step approach).
#' @return Selected results output
#' @examples
#' \donttest{
#' # long running time
#' Data <- c(1,2,2,1,1,1,1,1,NA,1,2,1,1,2,1,1,2,2,NA,2,2,2,1,1,1,2,1,1,1,1,2,1,1,1,2,1,1,2,1,1)
#' Data <- matrix(Data,nrow = 10)
#' pairmap <- c(1,3,5,7,2,4,6,8)
#' pairmap <- matrix(pairmap,ncol = 2)
#' ind <- c(1,2,1,2,1,2,2,1)
#' ParInits <- c(1, 1, 1, 1, 1, 1, 1, 1, 1, -1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1, -1, -1, -1, -1)
#' ParInits <- matrix(ParInits, ncol = 3)
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,
#' ParInits=ParInits,iter=1000,warmup=500,chains=2)
#' alpha <- extract(mod, 'alpha')}
#' @export
extract <- function(x, pars){
  UseMethod("extract")
}


#' @export
#' @method extract fcirt
extract.fcirt <- function(x, pars){

  ret <- switch(pars,
                theta=x[["Theta.est"]],
                alpha=as.matrix(x[["Alpha.est"]]),
                delta=x[["Delta.est"]],
                tau=x[["Tau.est"]],
                cor=x[["Cor.est"]],
                #lambda=x[["Lamda.est"]],
                data=x[["Data"]],
                fit=x[["Fit"]],
                dimension=x[["Dimension"]],
                pairmap=x[["Pairmap"]],
                ParInits=x[["ParInits"]])

  ret
}
