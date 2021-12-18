#' @title mfc item and test information
#' @description This function calculates mfc item and test information.
#' @param x returned object
#' @param approach Estimation approaches used for parameters. They can be 1, which is direct approach, and 2, which is two step approach. The default is 1.
#' @param information Types of information.They can be 1, which is overall item information, and 2, which is overall test information. The default is 1.
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
#' mod <- fcirt(fcirt.Data=Data,pairmap=pairmap,ind=ind,ParInits=ParInits,iter=5,chains=1)
#' information(mod, approach=1, information=1, items=1)
#' @export
information <- function(x, approach, information, items){
  UseMethod("information")
}


#' @export
#' @method information fcirt
information.fcirt <- function(x, approach=1, information=1, items=NULL){

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

  if (approach==1){
    alpha <- extract(x, 'alpha')
    alpha <- alpha[,1]
    S <- length(alpha)
    delta <- extract(x, 'delta')
    delta <- delta[,1]
    tau <- extract(x, 'tau')
    tau <- tau[,1]
  }
  if (approach==2){
    ParInits <- extract(x, 'ParInits')
    alpha <- ParInits[,1]
    S <- length(alpha)
    delta <- ParInits[,2]
    tau <- ParInits[,3]
  }

    dimension <- extract(x, 'dimension')
    pairmap <- extract(x, 'pairmap')
    theta <- extract(x, 'theta')
    theta <- theta[,1]
    theta <- matrix(theta, nrow=max(dimension))
    theta <- t(theta)
    N <- nrow(theta)
    thdim <- matrix(0,nrow=N,S)
    iteminfo <- matrix(NA, N, S/2)
      for (i in 1:N) {
        for (j in 1:S) {
          thdim[i,j] <- theta[i,dimension[j]] #d=dimension associated with each statement i
        }
      }
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
      iteminfoavrg <- colMeans(iteminfo)
      if (information==1){
        if (is.null(items)){
          iteminfo <- iteminfoavrg
        }
        else{
          iteminfo <- iteminfoavrg[items]
        }
        ret <- iteminfo
      }else{
        testinfo <- sum(iteminfoavrg)
        ret <- testinfo
      }
  ret
}