#install.packages("rpart" ,repos='http://cran.us.r-project.org', force=FALSE)
library('rpart')
library('dplyr')

print("reading file")#######
data <- read.csv("data.csv")

data <- data[sample(1:nrow(data)), ]

spec = c(train = .6, test = .2, validate = .2)

g = sample(cut(
  seq(nrow(data)), 
  nrow(data)*cumsum(c(0,spec)),
  labels = names(spec)
))

res = split(data, g)
nrow(res[["train"]])
nrow(res[["validate"]])
nrow(res[["test"]])
names(res[["test"]])

model<- rpart( Bankrupt. ~ .,
              data=res[["train"]],
              control=rpart.control(maxdepth=20),
              method="class")


trainframe <- data.frame(truth=res[["train"]]$Bankrupt.,
                         pred=predict(model, type="class"))

TP.train<-nrow(filter(trainframe, truth == pred , truth == 1,))
TN.train<-nrow(filter(trainframe, truth == pred , truth == 0,))
FP.train<-nrow(filter(trainframe, truth != pred , truth == 0,))
FN.train<-nrow(filter(trainframe, truth != pred , truth == 1,))
accuracy.train<-(TP.train+TN.train)/nrow(trainframe)
fallback.train<-(TP.train)/(TP.train+FN.train)
precision.train<-(TP.train)/(TP.train+FP.train)
NegativePrecision.train<-(TN.train)/(TN.train+FN.train)
print(accuracy.train)
print(fallback.train)
print(precision.train)
print(NegativePrecision.train)




#write.csv(trainframe, file = "./trainPredict.csv", quote = F, row.names = F)
validframe <- data.frame(truth=res[["validate"]]$Bankrupt.,
                         pred=predict(model, newdata=res[["validate"]], type="class"))

validframe

TP.valid<-nrow(filter(validframe, truth == pred , truth == 1,))
TN.valid<-nrow(filter(validframe, truth == pred , truth == 0,))
FP.valid<-nrow(filter(validframe, truth != pred , truth == 0,))
FN.valid<-nrow(filter(validframe, truth != pred , truth == 1,))
accuracy.valid<-(TP.valid+TN.valid)/nrow(validframe)
fallback.valid<-(TP.valid)/(TP.valid+FN.valid)
precision.valid<-(TP.valid)/(TP.valid+FP.valid)
NegativePrecision.valid<-(TN.valid)/(TN.valid+FN.valid)
print(accuracy.valid)
print(fallback.valid)
print(precision.valid)
print(NegativePrecision.valid)


