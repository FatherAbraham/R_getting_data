##required libraries first
require(sqldf)

  
##read in data using read.table, no options required!
dataXtest <- read.table("test//X_test.txt")
dataYtest <- read.table("test//y_test.txt")
datasubjectest <- read.table("test//subject_test.txt")
dataXtrain <- read.table("train//X_train.txt")
dataYtrain <- read.table("train//y_train.txt")
datasubjectrain <- read.table("train//subject_train.txt")


##now we can start linking up the files.

## for each dataset (test and train)
##cbind the y data to the x data so we can find out what the activity type
fulltest <- cbind(dataXtest, dataYtest)

##cbind the subject data so we know who the subject was 
fulltest <- cbind(fulltest, datasubjectest)

##cbind the y data to the x data so we can find out what the activity type
fulltrain <- cbind(dataXtrain, dataYtrain)

##cbind the subject data so we know who the subject was 
fulltrain <- cbind(fulltrain, datasubjectrain)

##rbind the completed test and train datasets 

tidy_data_set <- rbind(fulltest, fulltrain)

##Now we have all the data and can start to tidy up:
##add columnnames 
##we'll use the features file to name the columns, read it in, take column 2 as a vector input to the names function

features <- read.table("features.txt")
columnnames <- features[,c(1, 2)]
columnnames <- as.vector(columnnames)

## add the columns
names(tidy_data_set) <- c(columnnames, "Activity Type", "Subject_ID")

## can we use this vector to determine the columns to fish out?  Yes we can, using subsetting:

grepcolumnnames <- features[,c(1, 2)]
names(grepcolumnnames) <- c("ID", "Feature")

##use sqldf as easy to use and read, selecting anything with "mean" or "std" in the columnname as not fully specified
relevant_cols <- sqldf("select ID from grepcolumnnames where Feature like '%mean%' or Feature like '%std%'")

##convert relevant_cols to a vector for use in subsetting 

relevant_cols <- as.vector(relevant_cols[,1])

##subset the data based on the column names we know we need, and include "Activity Type" and "Subject_ID"

reduced_tidy_data_set <- tidy_data_set[, c(relevant_cols, 562, 563)]

## we need to substitute the activity types as integers with human-friendly descriptions
## In light of recent privacy concerns I'm glad we don't have the subject names!
## we have a map of the activity types in activity_labels.txt

activities <- read.csv("activity_labels.txt", header=FALSE, sep = " ")

##tidy up using recommended best practices, i.e. use lower case and remove underscores

reduced_tidy_data_set[,87] <- gsub("1", "walking", reduced_tidy_data_set[,87]) 
reduced_tidy_data_set[,87] <- gsub("2", "walkingupstairs", reduced_tidy_data_set[,87]) 
reduced_tidy_data_set[,87] <- gsub("3", "walkingdownstairs", reduced_tidy_data_set[,87]) 
reduced_tidy_data_set[,87] <- gsub("4", "sitting", reduced_tidy_data_set[,87]) 
reduced_tidy_data_set[,87] <- gsub("5", "standing", reduced_tidy_data_set[,87]) 
reduced_tidy_data_set[,87] <- gsub("6", "laying", reduced_tidy_data_set[,87]) 


## Creates a second, independent tidy data set with the average of each variable for each activity and each subject (that's the order requested). 

finished_data <- aggregate(reduced_tidy_data_set, by=list(reduced_tidy_data_set[,87], reduced_tidy_data_set[,88]), FUN=mean)

##rename some columns and reduce a little more ...

names(finished_data)[1] <- c("Activity Type")
names(finished_data)[2] <- c("Subject_ID")
finished_data <- finished_data[,1:88]

##In R tidy up, drop stuff etc. 


##write out the file
write.table(finished_data, file = "Tidy Data Set.csv", sep = " ", eol = "\n", col.names = TRUE)

##let everyone know
print("Run Analyis script completed, file ready")



