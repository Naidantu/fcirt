//
// This Stan program defines a MUPP model with no covariates

data {

  int<lower=1> n_student;
  int<lower=1> n_item;
  int<lower=1> n_pair;
  int<lower=0> res[n_student, n_pair];
  int<lower=1> n_dimension;
  int<lower=0> p[n_pair, 2]; //p=pair specification map for the given pairs
  int<lower=0> d[n_item]; //d=dimension associated with each statement i

  // user-defined priors
  real ma;
  real va;
  real md;
  real vd;
  real mt;
  real vt;

}

parameters {

  matrix [n_student, n_dimension] theta;
  vector<lower=0, upper=4> [n_item] alpha;
  vector<lower=-5, upper=5> [n_item] delta;
  vector<lower=-5, upper=0> [n_item] tau;
  //vector [n_dimension] mu;
  //vector [n_dimension] sigma;

}

//transformed parameters {
//  cov_matrix[n_dimension] SigmaAB= diag_matrix(rep_vector(1, n_dimension));
//}

model {

   real response[n_student, n_pair];
   real spr[n_student, n_item];

   //for (j in 1:n_item){
    alpha ~ lognormal(ma,va);
    delta ~ normal(md,vd);
    tau ~ normal(mt,vt);
    //a ~ beta(1.5,1.5);
    //b ~ beta(2,2);
    //t ~ beta(2,2);;
    //(a-0.25)/(3-0.25) ~ beta(1.5,1.5);
    //(b+3)/(3+3) ~ beta(2,2);
    //(t+3)/(1+3) ~ beta(2,2);
   //}
  //theta ~ normal(0,1);
  //a ~ beta(1.5,1.5);
  //b ~ beta(2,2);
  //t ~ beta(2,2);
  //for (i in 1:n_student){
  //  theta[i][1:n_dimension] ~ multi_normal(rep_vector(0, n_dimension), SigmaAB);
  //}
  //to_vector(theta) ~ normal(0, 1);
  for (i in 1:n_dimension){
     theta[,i] ~ normal(0,1);
  }

  for (i in 1:n_student) {
    for (j in 1:n_item) {
      real thdim;
      real num0;
      real num1;
      real denominator;
      //real spr[n_student, n_item];

      thdim = theta[i,d[j]]; //d=dimension associated with each statement i
      num0 = 1 + exp(alpha[j]*(3*(thdim-delta[j])));
      num1 = exp(alpha[j]*((thdim-delta[j])-tau[j])) + exp(alpha[j]*((2*(thdim-delta[j]))-tau[j]));
      denominator = num0 + num1;
      spr[i,j] = num1/denominator;
    }
  }

  //spr = SSpr(a, b, t, theta);

  for (i in 1:n_student) {
    for(j in 1:n_pair){
      int s1;
      int t1;
      real pst;
      real pts;
      //real spr[n_student, n_item];
      //real response;
      //real var1;

      s1 = p[j,1];
      t1 = p[j,2];

      pst = spr[i,s1]*(1-spr[i,t1]); //10 #p=pair specification map for the given pairs
      pts = spr[i,t1]*(1-spr[i,s1]); //01

      //if (var1==1){
      response[i,j] = pst/(pst+pts); //NxJ matrix of MUPP P(s>t) probabilities for each pair
      //}
      //if (var1==2){
      //response[i,j,21] = pts[i,j]/(pst[i,j]+pts[i,j]); //NxJ matrix of MUPP P(s>t) probabilities for each pair
      //}

      //print("a = ", a, ", b = ", b, ", t = ", t, ", theta = ", theta);
      //res[i,j] ~ bernoulli(response);
      //if (is_finite(res[,])) {
       // print("res is", res);
         // print more stuff
      //}
    }
  }
  to_array_1d(res) ~ bernoulli(to_array_1d(response));
  // for (i in 1:n_student) {
  //   for(j in 1:n_pair){
  //     res[i,j] ~ MUPPpr(a[j], b[j], t[j], theta[i,j], n_student, n_item, n_dimension, n_pair);
  //   }
  // }
}
