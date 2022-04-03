//
// This Stan program defines a MUPP model with no covariates

functions {

  real MUPP(int y, real theta1, real theta2, real alpha1, real alpha2, real delta1, real delta2, real tau1, real tau2) {

    vector[2] prob;
    real num01;
    real num11;
    real denominator1;
    real spr1;
    real num02;
    real num12;
    real denominator2;
    real spr2;
    real pst;
    real pts;

    num01 = 1 + exp(alpha1*(3*(theta1-delta1)));

    num11 = exp(alpha1*((theta1-delta1)-tau1)) + exp(alpha1*((2*(theta1-delta1))-tau1));

    denominator1 = num01 + num11;

    spr1 = num11/denominator1;

    num02 = 1 + exp(alpha2*(3*(theta2-delta2)));

    num12 = exp(alpha2*((theta2-delta2)-tau2)) + exp(alpha2*((2*(theta2-delta2))-tau2));

    denominator2 = num02 + num12;

    spr2 = num12/denominator2;

    pst = spr1*(1-spr2); //10 #p=pair specification map for the given pairs

    pts = spr2*(1-spr1); //01

    prob[1] = pst/(pst+pts);

    prob[2] = pts/(pst+pts);

    //return categorical_lpmf(y|prob);

    return categorical_lpmf(y|prob);
  }
}

data {

  int<lower=1> n_student;
  int<lower=1> n_item;
  int<lower=1> n_pair;
  int<lower=1> N;
  int<lower=1> n_dimension;
  int<lower=1, upper=2> y[N];
  int<lower=1> I1;
  int<lower=1> J1;
  int<lower=1, upper=I1> II[N];
  int<lower=1, upper=J1> JJ[N];

  // user-defined priors
  real ma;
  real va;
  real md;
  real vd;
  real mt;
  real vt;

  int<lower=1> ind[2*N];  //pairs: 2*N  triplets: 3*N
  vector[n_dimension] theta_mu;
}

parameters {

  vector[n_dimension] theta[n_student];
  //matrix [n_student, n_dimension] theta;
  vector<lower=0, upper=4> [n_item] alpha;
  vector<lower=-5, upper=5> [n_item] delta;
  vector<lower=-5, upper=0> [n_item] tau;

  //vector[trait] theta[J];
  cholesky_factor_corr[n_dimension] L_Omega;

}

model {

  alpha ~ lognormal(ma,va);
  delta ~ normal(md,vd);
  tau ~ normal(mt,vt);
  L_Omega  ~ lkj_corr_cholesky(1);

  theta~ multi_normal_cholesky(theta_mu,L_Omega);

  for (n in 1:N){

    target += MUPP(y[n],theta[JJ[n],ind[2*n-1]],theta[JJ[n],ind[2*n]],alpha[2*II[n]-1],alpha[2*II[n]],delta[2*II[n]-1],delta[2*II[n]],tau[2*II[n]-1],tau[2*II[n]]);

  }
}

generated quantities{
  matrix[n_dimension,n_dimension] Cor;
  vector[N] log_lik;

  Cor=multiply_lower_tri_self_transpose(L_Omega);

  for (n in 1:N) {
    log_lik[n] = MUPP(y[n],theta[JJ[n],ind[2*n-1]],theta[JJ[n],ind[2*n]],alpha[2*II[n]-1],alpha[2*II[n]],delta[2*II[n]-1],delta[2*II[n]],tau[2*II[n]-1],tau[2*II[n]]);
  }
}
