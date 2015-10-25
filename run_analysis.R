#create "data" directory
if(!file.exists("./data")){dir.create("./data")}
#name the source file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
#download source file to directory
download.file(fileUrl,destfile="./data/Dataset.zip")
#unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")
#See the list of files
path_rf <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path_rf, recursive=TRUE)
files
#Assign variable names to the activity files data
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
#Assign variable names to the subject files data
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
#Assign variable names to the features files data
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
#review the features of each variable created above
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)
#rbind the Subject data tables
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
#rbind the Activity data tables
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
#rbind the Features data tables
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)
#Assign names to the r-bound data tables created above
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
#cbind the dataSubject and dataActivity tables
dataCombine <- cbind(dataSubject, dataActivity)
#cbind dataFeatures and dataCombine
Data <- cbind(dataFeatures, dataCombine)
#Subset "dataFeaturesNames by measurements on the mean and standard deviation
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
#Subset the Data data frame by seleted names of Features
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
#Revew the structures of the Data data frame
str(Data)
#Read in descriptive activity names from "activity_labels.txt"
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
#Factorize variable "activity" in DF "Data" using descriptive activity names
Data$activity<-factor(Data$activity)
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))
#Check it
head(Data$activity,30)
#Appropriately label the data set with descriptive variable names, 
#replacing the one-letter in the lable with the full word it represents
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
#Check it
names(Data)
#Create a second,independent tidy data set with the average of each variable 
#for each activity and each subject
library(plyr)
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.averages.txt",row.name=FALSE)

