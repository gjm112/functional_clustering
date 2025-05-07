data {
  int<lower=0> N;
  int<lower=0> K;
  int<lower=0> T;
  int<lower=0> W;
  matrix[N,K] probs;
  matrix[N,T-1] X_year;
  matrix[N,W-1] X_week;
  matrix[T,T-1] contr_year;
  matrix[W,W-1] contr_week;
}

parameters {
  vector[K] beta_0;
  matrix[W-1,K] b_week;
  matrix[T-1,K] b_year;
}

transformed parameters {
  matrix[N,K] alpha;
  for (k in 1:K) {
    alpha[,k] = exp(beta_0[k] + X_year * b_year[,k] + X_week * b_week[,k]);
  }
  matrix[T,K] beta_year = contr_year * b_year;
  matrix[W,K] beta_week = contr_week * b_week;
}

model {
  for (i in 1:N) {
    to_vector(probs[i,]) ~ dirichlet(alpha[i,]);
  }
  
  beta_0 ~ normal(0,10);
  to_vector(b_week) ~ normal(0,10);
  to_vector(b_year) ~ normal(0,10);
}

