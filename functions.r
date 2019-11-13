columnmean <- function(y){
  nc <- ncol(y)
  means <- numeric(nc)
  for (i in 1:nc){
    means[i] <- mean(y[,i])
  }
  means
}

make.power <-function(n){
  pow<- function(x){
    x^n
  }
}
sq