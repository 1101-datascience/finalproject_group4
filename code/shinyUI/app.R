library(shiny)
library(ggplot2)
library(GGally)
library(corrplot)
#library(ggpubr)

data = read.csv(file = 'data/data.csv' , header = T)

#remove the column with only one unique numbers
which(apply(data, 2, var)==0)
data<-subset(data,select=-Net.Income.Flag)

ui <- fluidPage(
    plotOutput("plot"), 
    plotOutput("plot2"), 
    plotOutput("plot3")
)

server <- function(input, output) {
    output$plot <- renderPlot({
        cor.matrix <- as.matrix(cor(data))
        correlation <- sort(cor.matrix[2:95],decreasing = T)

        data1 <- data[,-95]
        correlationMatrix <- cor(data1[,1:94])

        hist1 = ggplot(data, aes(Bankrupt.,)) + geom_bar(fill = c("Green","Red")) + theme_bw() + ggtitle("Survive(0) VS Bankruptcy(1)") + theme(plot.title = element_text(hjust = 0.5)) + xlab("Survive(0)                              Bankruptcy(1)")
        corr1 = ggcorr(data[,1:20],size=2,hjust=1)+geom_point()+scale_alpha_manual()+guides()
        corr2 = corrplot(corr=correlationMatrix, tl.cex=0.1)
    })

    output$plot2 <- renderPlot({
        #### Pca visualization

        data.pca.scale <- prcomp(data[,2:95], center=T ,scale = TRUE)
        #biplot(data.pca.scale, cex = 0.5)

        # Extract the variance explained 
        tot.var <- sum(data.pca.scale$sdev^2)
        var.explained <- data.frame(pc = seq(1:94), var.explained  = data.pca.scale$sdev^2/tot.var ) 
        ggplot(var.explained, aes(pc, var.explained)) + geom_bar(stat = "identity") + ggtitle("Bankruptcy")
    })

    output$plot3 <- renderPlot({
        #### Pca visualization

        data.pca.scale <- prcomp(data[,2:95], center=T ,scale = TRUE)
        data.df <- data.frame(PC1 = data.pca.scale$x[,1], PC2 = data.pca.scale$x[,2], PC3 = data.pca.scale$x[,3], labels = as.factor(data$Bankrupt.))
        ggplot(data.df, aes(PC1, PC2, col = labels)) + geom_point()
    })
}


shinyApp(ui = ui, server = server)