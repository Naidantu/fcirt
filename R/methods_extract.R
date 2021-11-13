#' @title results extraction
#' @description This function extracts estimation results.
#' @param x returned object
#' @param pars Names of extracted parameters. They can be "theta" (person trait estimates), "alpha" (statement discrimination parameters), "delta" (statement location parameters), "tau" (statement threshold parameters), data" (fcirt.Data), "fit" (the stanfit object), and "dimension" (the input column vector mapping each statement to each trait).
#' @return Selected results output
#' @examples
#' Data <- c(1,1,0,1)
#' Data <- matrix(Data,nrow = 2)
#' pairmap <- c(1,3,2,4)
#' pairmap <- matrix(pairmap,nrow = 2)
#' ind <- c(1,2,3,4)
#' ParInits <- c(1, 1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1)
#' ParInits <- matrix(ParInits, ncol = 3)
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,ParInits=ParInits,iter=5,chains=1)
#' alpha <- extract(mod, 'alpha')
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
                #cor=x[["Cor.est"]],
                #lambda=x[["Lamda.est"]],
                data=x[["Data"]],
                fit=x[["Fit"]],
                dimension=x[["Dimension"]])

  ret
}