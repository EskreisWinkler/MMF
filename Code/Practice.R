gauss_ker = function(x,y,sigma){
  A = 1/sqrt(2*pi*sigma^2)
  B = exp(-(x-y)^2/(2*sigma^2))
  return(A*B)
}
sigma=0.5
clump1 = rnorm(5,1,sigma)
clump2 = rnorm(5,-1,sigma)
data = c(clump1,clump2)
hist(data)
n=length(data)
K = numeric(n*n); dim(K)=c(n,n)
for(i in 1:n){
  for (j in i:n) {
    K[i,j] = gauss_ker(data[i],data[j],1)
    K[j,i] = K[i,j]
  }
}
E =eigen(K)
plot(E$values)
# Make a HODLR matrix
n=8
A=matrix(0, nrow = n, ncol = n)
diag(A) = rbinom(n = n, size = 20, prob = 0.5 )
u = rnorm(1:(n/4),0,1)
v = rnorm(1:(n/4),0,1)
A[(n/2) + 1:(n/4), (n/2)+(n/4)+1:(n/4)] =  u%*%t(v)
A[(n/2)+ (n/4)+1:(n/4), (n/2) + 1:(n/4)] =  t(u%*%t(v))
E = eigen(A)
plot(E$values)
S = svd(A)