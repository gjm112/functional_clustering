
data {
  int<lower=0> N;
  int<lower=0> K;
  int<lower=0> T;
  int<lower=0> W;
  matrix[N,K] probs;
  int sched[N,2];
}

parameters {
  vector[K] beta_0;
  matrix[W,K] beta_week;
  matrix[T,K] beta_year;
  vector<lower=0>[K] sigma_week;
  vector<lower=0>[K] sigma_year;
}

transformed parameters {
  matrix[N,K] alpha;
  for (k in 1:K) {
    for (i in 1:N) {
      alpha[i,k] = exp(beta_0[k] + beta_year[sched[i,2],k] + beta_week[sched[i,1],k]);
    }
  }
}

model {
  for (i in 1:N) {
    to_vector(probs[i,]) ~ dirichlet(alpha[i,]);
  }
  
  beta_0 ~ normal(0,100);
  sigma_week ~ normal(0,100);
  sigma_year ~ normal(0,100);
  for (k in 1:K){
    for (w in 1:W){
      beta_week[w,k] ~ normal(0,sigma_week[k]);
    }
    for (t in 1:T){
      beta_year[t,k] ~ normal(0,sigma_year[k]);  
    }
  }
}

