library('dplyr')

data <- read.csv("../../data/data.csv")

#input
args = commandArgs(trailingOnly=TRUE)
ts <- args[1]


accuracy <- 0
recall <- 0
precision <- 0
NegativePrecision <- 0 
max <- 0


i <- 1
while(i < 10){
	data <- data[sample(1:nrow(data)), ]

	spec = c(train = .8, validate = .2)

	g = sample(cut(
				   seq(nrow(data)), 
				   nrow(data)*cumsum(c(0,spec)),
				   labels = names(spec)
				   ))

	res = split(data, g)

	#train pca
	in_d <- res[["train"]]
	in_d = in_d[,!colnames(in_d) %in% c('Net.Income.Flag','Bankrupt.')]
	pca <- prcomp(in_d, center=TRUE, scale=TRUE)

	#--- built train data with Bankrupt and top 40 component
	train.data <- data.frame(Bankrupt. = res[["train"]]$Bankrupt., pca$x)

	train.data <- train.data[,1:41]

	# model using glm
	model <- glm(formula = Bankrupt. ~ . ,
				 family = binomial(link='probit'),
				 epsilon = 1e-14,
				 data = train.data)

	# val data
	val.data <- predict(pca, newdata = res[["validate"]]) 
	val.data <- as.data.frame(val.data)
	val.data <- val.data[,1:40]


	# data frame of val
	val <- data.frame(truth = res[["validate"]]$Bankrupt.,
					  prediction = predict(model, val.data))
	val <- mutate(val, pred = ifelse(prediction > ts, 1, 0))

	# confusion matrix of validation
	cm <- table(val[,c(1,3)])


	TP <- cm[2,2]
	TN <- cm[1,1]
	FP <- cm[1,2]
	FN <- cm[2,1]

	r <- TP/(TP+FN)

	if(r > max){
		max <- r
		accuracy <- (TP+TN)/(TP+FP+FN+TN)
		recall <- TP/(TP+FN)
		precision <- TP/(TP+FP)
		NegativePrecision <- TN/(TN+FN)

		final_cm <- data.frame(cm)
	}
	i = i + 1
}

result <- c("accuracy" = accuracy,
			"recall" = recall,
			"precision" = precision,
			"NegativePrecision" = NegativePrecision)
res <- as.matrix(result)
cm <- data.frame(final_cm)

dir.create("LogisticRegression", recursive = TRUE ,showWarnings = FALSE)
setwd("LogisticRegression")

write.csv(cm, file = "output.csv", quote = F, row.names = F)
write.table(res, file = "output.csv", sep=",", quote = F, append=TRUE, col.names=FALSE, row.names = TRUE)


