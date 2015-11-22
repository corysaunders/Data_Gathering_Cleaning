library(plyr)
library(data.table)

## Download and unzip the dataset:
filename <- "./getdata-projectfiles-dataset.zip"
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("./UCI HAR Dataset")) { 
  unzip(filename) 
}

## Merge the training and test datasets to create single datasets
data_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
data_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
data_samples <- rbind(data_train, data_test)

## Subset the mean and standard deviation for each measurement
all_features <- read.table("./UCI HAR Dataset/features.txt")
mean_std_features <- grep("mean\\(\\)|std\\(\\)", all_features[, 2])
data_samples <- data_samples[,mean_std_features]

## Name activities in the samples data
act_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(act_labels) <- c("actID","Activity")

## Merge the training and test activity data
act_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
act_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
act_data <- rbind(act_train, act_test)

## Label the activity columns
colnames(act_data) <- "actID"
activities <- join(act_data,act_labels,by="actID")

## Merge the training and tests subject data
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_data <- rbind(subject_train, subject_test)
colnames(subject_data) <- "Subject"

## Change variable names for readability
names(data_samples) <- all_features[mean_std_features, 2]
names(data_samples) <- gsub('-mean', 'Mean', names(data_samples))
names(data_samples) <- gsub('-std', 'Std', names(data_samples))
names(data_samples) <- gsub('[-()]', '', names(data_samples))
names(data_samples) <- gsub("\\(\\)", "", names(data_samples))

## Aggregate data by Subject, Activity
tidy_data <- data.table(cbind(subject_data, activities, data_samples))[, lapply(.SD, mean), by=c("Subject","Activity")]

## Write the tidy data set to a file
write.table(tidy_data, "tidy.txt")
