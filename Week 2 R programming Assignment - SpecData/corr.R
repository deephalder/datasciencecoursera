source("complete.R")
corr <- function(directory, threshold = 0){
  
  completes = complete(directory, 1:332)
  completes_above_threshold = subset(completes, nobs > threshold )
  
  ## Initialize empty vector variable
  correlations <- vector()
  
  ## Get a list of filenames
  filenames = list.files(directory)
  
  ## For each .csv file in id
  for(i in completes_above_threshold$id){
    
    ## Concatinate the directory and filename
    ## e.g. directory = "C:/folder", filenames = vector("001.csv", "002.csv", ...), filepath="C:/folder/001.csv"
    filepath=paste(directory,"/" ,filenames[i], sep="")
    
    ## read in each file and store it in data
    data = read.csv(filepath, header = TRUE)
    
    ## Calculate and store the number of completed cases
    completeCases = data[complete.cases(data),]
    count = nrow(completeCases)
    
    ## Calculate and store the count of complete cases
    ## if threshhold is reached
    if( count >= threshold ) {
      correlations = c(correlations, cor(completeCases$nitrate, completeCases$sulfate) )
    }
  }
  correlations
}