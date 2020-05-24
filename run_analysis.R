library(dplyr)

zipName="./data/getdata_dataset.zip"

if(!file.exists(zipName))
{ 
  print("file does not exists, downloading the file..")
  url="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url,destfile = "./data/getdata_dataset.zip")
  print("zip file is downloaded successfully!!")
}

fileName="./data/UCI HAR Dataset"
if(!file.exists(fileName))
{
  print("file is not unzipped, unzipping the file..")
  unzip(zipName, exdir = "./data")
  print("file is unzipped now!!")
}

print("reading data")
activities= read.table("./data/UCI HAR Dataset/activity_labels.txt",col.names = c("code","activity"))
features=read.table("./data/UCI HAR Dataset/features.txt",col.names = c("n","function"))

subject_test=read.table("./data/UCI HAR Dataset/test/subject_test.txt",col.names = "subject")
x_test=read.table("./data/UCI HAR Dataset/test/X_test.txt",col.names =features$function. )
y_test=read.table("./data/UCI HAR Dataset/test/y_test.txt",col.names = "code" )

subject_train=read.table("./data/UCI HAR Dataset/train/subject_train.txt",col.names = "subject")
x_train=read.table("./data/UCI HAR Dataset/train/X_train.txt",col.names =features$function. )
y_train=read.table("./data/UCI HAR Dataset/train/y_train.txt",col.names = "code" )

print("merging training and test data:")
X=rbind(x_test,x_train)
Y=rbind(y_test,y_train)
subject=rbind(subject_test,subject_train)
mergedData=cbind(subject,Y,X)

#Extracts only the measurements on the mean and standard deviation for each measurement
#filter=grepl("mean|std",names(mergedData))
#filteredData=cbind(subject,Y,mergedData[,filter])

print("filtering columns with mean and std..")
filteredData=select(mergedData, code, subject, contains("mean"),contains("std"))

#Uses descriptive activity names to name the activities in the data set
print("Giving descriptive column names..")
filteredData$code=activities[filteredData$code,2]

#Appropriately labels the data set with descriptive variable names.
names(filteredData)[1] = "activity"
names(filteredData)<-gsub("Acc", "Accelerometer", names(filteredData))
names(filteredData)<-gsub("Gyro", "Gyroscope", names(filteredData))
names(filteredData)<-gsub("BodyBody", "Body", names(filteredData))
names(filteredData)<-gsub("Mag", "Magnitude", names(filteredData))
names(filteredData)<-gsub("^t", "Time", names(filteredData))
names(filteredData)<-gsub("^f", "Frequency", names(filteredData))
names(filteredData)<-gsub("tBody", "TimeBody", names(filteredData))
names(filteredData)<-gsub("-mean()", "Mean", names(filteredData), ignore.case = TRUE)
names(filteredData)<-gsub("-std()", "STD", names(filteredData), ignore.case = TRUE)
names(filteredData)<-gsub("-freq()", "Frequency", names(filteredData), ignore.case = TRUE)
names(filteredData)<-gsub("angle", "Angle", names(filteredData))
names(filteredData)<-gsub("gravity", "Gravity", names(filteredData))

# independent tidy data set with the average of each variable for each activity and each subject.
#arrangedData=arrange(filteredData,subject)
#groupedData= group_by(arrangedData,subject,activity)

print("Grouping and summarizing all columns by mean..")
FinalData <- filteredData %>%  group_by(subject, activity) %>% summarise_all(funs(mean))

#or:
#arrangedData=arrange(filteredData,subject,activity)
#groupedData= group_by(arrangedData,subject,activity)
#FinalData=summarise_all(groupedData, funs(mean))

print("writing FinalData to FinalData.txt :)")
write.table(FinalData,file="./data/FinalData.txt",row.names = FALSE)




