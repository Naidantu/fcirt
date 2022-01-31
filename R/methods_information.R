#' @title mfc item and test information
#' @description This function calculates mfc item and test information.
#' @param x returned object
#' @param approach Estimation approaches used for parameters. They can be "direct", which is direct approach, and "two step", which is two step approach. The default is direct approach.
#' @param theta Type of theta values used. They can be "quadrature", which is -3, -2.9, -2.8, -2.7...2.9, 3, and "estimated", which is estimated theta values. The default is quadrature.
#' @param information Types of information.They can be "item", which is overall item information, and "test", which is overall test information. The default is overall item information.
#' @param items The items of which information to be calculated. The default is all the items.
#' @return Selected item information or overall test information
#' @examples
#' Data <- c(1,1,0,1)
#' Data <- matrix(Data,nrow = 2)
#' pairmap <- c(1,3,2,4)
#' pairmap <- matrix(pairmap,nrow = 2)
#' ind <- c(1,2,3,4)
#' ParInits <- c(1, 1, 1, 1, 1, -1, 1, 1, -1, -1, -1, -1)
#' ParInits <- matrix(ParInits, ncol = 3)
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,ParInits=ParInits,iter=4,chains=1)
#' information(mod, approach="direct", theta="quadrature", information="item", items=1)
#' @export
information <- function(x, approach, theta, information, items){
  UseMethod("information")
}


#' @export
#' @method information fcirt
information.fcirt <- function(x, approach="direct", theta="quadrature", information="item", items=NULL){

  #unidimensional pairs
  pair.info1 <- function(alpha1,delta1,tau1,theta1,alpha2,delta2,tau2){

    ggum <- function(a,d,t,th){
      tmp1=exp(a*(1*(th-d)-t))
      tmp2=exp(a*(2*(th-d)-t))
      tmp3=exp(a*(3*(th-d)))
      prob=(tmp1+tmp2)/(1+tmp1+tmp2+tmp3)
      return(prob)
    }

    mupp <- function(par){
      th1=par[1]
      a1=par[2]
      d1=par[3]
      t1=par[4]
      #th2=par[1]
      a2=par[5]
      d2=par[6]
      t2=par[7]
      p1=ggum(a1,d1,t1,th1)
      p2=ggum(a2,d2,t2,th1)
      q1=1-p1
      q2=1-p2
      pp=(p1*q2)/(p1*q2+q1*p2)
      return(pp)
    }

    pars <- c(theta1,alpha1,delta1,tau1,alpha2,delta2,tau2)
    prob <- mupp(pars)
    dp <- numDeriv::grad(mupp,pars)
    dpsqr <- dp^2
    info <- dpsqr/(prob*(1-prob))
    info <- info[1]
    #mgrad <- matrix(dp[c(1,5)],2,1)%*%matrix(dp[c(1,5)],1,2)
    #info_mat <- diag(mgrad)/(prob*(1-prob))
    #info <- sum(diag(mgrad))/(prob*(1-prob))
    #return(list(infomat=info_mat,info=info))
    return(info)
  }

  #multidimensional pairs
  pair.info2 <- function(alpha1,delta1,tau1,theta1,alpha2,delta2,tau2,theta2){

    ggum <- function(a,d,t,th){
      tmp1=exp(a*(1*(th-d)-t))
      tmp2=exp(a*(2*(th-d)-t))
      tmp3=exp(a*(3*(th-d)))
      prob=(tmp1+tmp2)/(1+tmp1+tmp2+tmp3)
      return(prob)
    }

    mupp <- function(par){
      th1=par[1]
      a1=par[2]
      d1=par[3]
      t1=par[4]
      th2=par[5]
      a2=par[6]
      d2=par[7]
      t2=par[8]
      p1=ggum(a1,d1,t1,th1)
      p2=ggum(a2,d2,t2,th2)
      q1=1-p1
      q2=1-p2
      pp=(p1*q2)/(p1*q2+q1*p2)
      return(pp)
    }

    pars <- c(theta1,alpha1,delta1,tau1,theta2,alpha2,delta2,tau2)
    prob <- mupp(pars)
    dp <- numDeriv::grad(mupp,pars)
    mgrad <- matrix(dp[c(1,5)],2,1)%*%matrix(dp[c(1,5)],1,2)
    info_mat <- diag(mgrad)/(prob*(1-prob))
    info <- sum(diag(mgrad))/(prob*(1-prob))
    #return(list(infomat=info_mat,info=info))
    #return(t(info_mat))
    return(info)
  }

  if (approach=="direct"){
    alpha <- extract(x, 'alpha')
    alpha <- alpha[,1]
    S <- length(alpha)
    delta <- extract(x, 'delta')
    delta <- delta[,1]
    tau <- extract(x, 'tau')
    tau <- tau[,1]
  } else if (approach=="two step"){
    ParInits <- extract(x, 'ParInits')
    alpha <- ParInits[,1]
    S <- length(alpha)
    delta <- ParInits[,2]
    tau <- ParInits[,3]
  }

  dimension <- extract(x, 'dimension')
  pairmap <- extract(x, 'pairmap')

  if (theta=="quadrature"){

    theta <- t(t(seq(-3,3,.1)))
    thetas <- t(t(theta[rep(1:nrow(theta),each=nrow(theta)),]))
    thetat <- theta[rep(1:nrow(theta),nrow(theta)),]
    theta <- cbind(thetas, thetat)
    N <- nrow(theta)
    iteminfo <- matrix(NA, N, S/2)
    for (j in 1:N){
      for (i in 1:(S/2)){
        if (dimension[(2*i-1)]!=dimension[2*i]){
          iteminfo[j, i] <- pair.info2(alpha[(2*i-1)], delta[(2*i-1)], tau[(2*i-1)], theta[j, 1],
                                       alpha[2*i], delta[2*i], tau[2*i], theta[j, 2])
        }
        if (dimension[(2*i-1)]==dimension[2*i]){
          iteminfo[j, i] <- pair.info1(alpha[(2*i-1)], delta[(2*i-1)], tau[(2*i-1)], theta[j, 1],
                                       alpha[2*i], delta[2*i], tau[2*i])
        }
      }
    }
  } else if (theta=="estimated"){
    theta <- extract(x, 'theta')
    theta <- theta[,1]
    theta <- matrix(theta, nrow=max(dimension))
    theta <- t(theta)
    N <- nrow(theta)
    thdim <- matrix(0,nrow=N,S)
    for (i in 1:N) {
      for (j in 1:S) {
        thdim[i,j] <- theta[i,dimension[j]] #d=dimension associated with each statement i
      }
    }
    iteminfo <- matrix(NA, N, S/2)
    for (j in 1:N){
      for (i in 1:(S/2)){
        if (dimension[(2*i-1)]!=dimension[2*i]){
          iteminfo[j, i] <- pair.info2(alpha[(2*i-1)], delta[(2*i-1)], tau[(2*i-1)], thdim[j, (2*i-1)],
                                       alpha[2*i], delta[2*i], tau[2*i], thdim[j, 2*i])
        }
        if (dimension[(2*i-1)]==dimension[2*i]){
          iteminfo[j, i] <- pair.info1(alpha[(2*i-1)], delta[(2*i-1)], tau[(2*i-1)], thdim[j, (2*i-1)],
                                       alpha[2*i], delta[2*i], tau[2*i])
        }
      }
    }
  }

  iteminfoavrg <- colMeans(iteminfo)
  if (information=="item"){
        if (is.null(items)){
          iteminfo <- iteminfoavrg
        }
        else{
          iteminfo <- iteminfoavrg[items]
        }
        ret <- iteminfo
      } else if (information=="test"){
        testinfo <- sum(iteminfoavrg)
        ret <- testinfo
      }
  ret
}
