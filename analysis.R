  library(plyr)
  library(reshape2)



  setwd("C:/coursera/gettingcleaningdata/project")

# file locations
  TestFile <- "test/X_test.txt"
  TrainFile <- "train/X_train.txt"
  FeaturesFile <- "features.txt"
  ActivityLabelsFile <- "activity_labels.txt"
  TestActivitiesFile <- "test/y_test.txt"
  TrainActivitiesFile <- "train/y_train.txt"
  SubjectTestFile <- "test/subject_test.txt"
  SubjectTrainFile <- "train/subject_train.txt"


# read and bind
  test <- read.table(TestFile)
  training <- read.table(TrainFile)
  testAndTraining <- rbind(test,training)

# feature names as column names
  featureNames <- read.table(FeaturesFile,stringsAsFactors=FALSE)[[2]]
  colnames(testAndTraining) <- featureNames

# only select the columns that have mean, std or activityLabel in their name
  testAndTraining <- testAndTraining[,grep("mean|std|activityLabel",featureNames)]

# rename variable names to more readable form. There is a lot so I decided to use
# grep substitute. Furthermore I have no clue as what names could be meaningfull so I decided
# just to remove strange characters b/c i need the rest to still have them unique
  meaningFullNames <- names(testAndTraining)
  meaningFullNames <- gsub(pattern="^t",replacement="time",x=meaningFullNames)
  meaningFullNames <- gsub(pattern="^f",replacement="freq",x=meaningFullNames)
  meaningFullNames <- gsub(pattern="-?mean[(][)]-?",replacement="Mean",x=meaningFullNames)
  meaningFullNames <- gsub(pattern="-?std[()][)]-?",replacement="Std",x=meaningFullNames)
  meaningFullNames <- gsub(pattern="-?meanFreq[()][)]-?",replacement="MeanFreq",x=meaningFullNames)
  meaningFullNames <- gsub(pattern="BodyBody",replacement="Body",x=meaningFullNames)
  names(testAndTraining) <- meaningFullNames

# get activities and label these and add to testAndTraining
  testActivities <- read.table(TestActivitiesFile,stringsAsFactors=FALSE)
  trainingActivities <- read.table(TrainActivitiesFile,stringsAsFactors=FALSE)
  activities <- rbind(testActivities,trainingActivities)

  activityLabels <- read.table(ActivityLabelsFile,stringsAsFactors=FALSE)
  colnames(activityLabels) <- c("iD","Label")

  colnames(activities)[1] <- "iD"
  activities <- join(activities,activityLabels,by="iD")
  testAndTraining <- cbind(activity=activities[,"Label"],testAndTraining)

# add subjects to testandtraining
  testSubjects <- read.table(SubjectTestFile,stringsAsFactors=FALSE)
  trainingSubjects <- read.table(SubjectTrainFile,stringsAsFactors=FALSE)
  subjects <- rbind(testSubjects,trainingSubjects)
  colnames(subjects) <- "subject"
  testAndTraining <- cbind(subjects,testAndTraining)

# create dataset two
  helper <- melt(testAndTraining,id.vars= c("subject","activity"))
  dataset2 <- dcast(helper, subject+activity ~ variable, fun.aggregate=mean)

  write.table(dataset2, file = "upload.txt", col.name=FALSE)


