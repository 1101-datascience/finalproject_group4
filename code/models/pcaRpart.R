library('rpart')
library('dplyr')



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


#train pca
in_d <- res[["train"]]
in_d = in_d[,!colnames(in_d) %in% c('Net.Income.Flag','Bankrupt.')]
pca <- prcomp(in_d, center=TRUE, scale=TRUE)

#--- watch pc
std_dev <- pca$sdev 
pr_var <- std_dev^2
prop_varex <- pr_var/sum(pr_var)
prop_varex
plot(prop_varex, type = 'lines')

#--- built train data with Bankrupt and top 40 component
train.data <- data.frame(Bankrupt. = res[["train"]]$Bankrupt., pca$x)
train.data <- train.data[,1:41]
model <- rpart(Bankrupt. ~ .,data = train.data, method = "anova")

#--- built validation data with Bankrupt and top 40 component
val.data <- predict(pca, newdata = res[["validate"]]) 
val.data <- as.data.frame(val.data)
val.data <- val.data[,1:40]

val <- data.frame(truth = res[["validate"]]$Bankrupt.,
                  prediction = predict(model, val.data))
val <- mutate(val, result = ifelse(prediction > 0.5, 1, 0))

# confusion matrix of validation
cm <- table(val[,c(1,3)])

TP <- cm[2,2]
TN <- cm[1,1]
FP <- cm[1,2]
FN <- cm[2,1]

accuracy <- (TP+TN)/(TP+FP+FN+TN)
fallback <- TP/(TP+FN)
precision <- TP/(TP+FP)
NegativePrecision <- TN/(TN+FN)

print( accuracy )
print( fallback )
print( precision )
print( NegativePrecision )
