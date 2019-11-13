complete <- function(directory,id= 1:332){
  total_obs <- matrix(ncol = 2, nrow = 0)
  x <- c("id","nobs")
  colnames(total_obs) <- x
  filenames = list.files(directory)
  for (i in id) {
    filepath = paste(directory,"/",filenames[i], sep= '')
    data = read.csv(filepath, header = TRUE)
    total_obs <- rbind(total_obs, c(i,sum(complete.cases(data))))
  }
  total_obs
}

