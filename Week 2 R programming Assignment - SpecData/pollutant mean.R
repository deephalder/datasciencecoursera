pollutant_mean <- function(directory,pollutant,id= 1:332){
  #creating empty vector to save the filtered pollutant data together
  pollutants <- c()
  #getting the complete set of filenames in the directory
  filenames = list.files(directory)
  #incrementing through each id file , reading the data , storing it in pollutants table, and then finding out the mean 
  for (i in id) {
    filepath = paste(directory,"/",filenames[i], sep= '')
    data = read.csv(filepath, header = TRUE)
    pollutants <- c(pollutants,data[,pollutant])
  }
  polmean <- mean(pollutants,na.rm= TRUE)
  #retun the mean value 
  polmean
}
