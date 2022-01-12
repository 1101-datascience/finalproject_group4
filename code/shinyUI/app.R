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
    navbarPage("Bankrutcy Prediciton",
        tabPanel("All data", fluid = TRUE, icon = icon("globe-americas"),
            #dataTableOutput(outputId="dataTable")
            div(dataTableOutput("dataTable"), style = "font-size: 75%; width: 100%")
        ),
        tabPanel("Correlation Analysis", fluid = TRUE, icon = icon("globe-americas"),
            sidebarLayout(
                sidebarPanel(
                    numericInput(
                        inputId = "num1",
                        label = "from",
                        value = 0,
                        min = 0,
                        max = 96,
                        step = NA,
                        width = NULL
                    ), 
                    numericInput(
                        inputId = "num2",
                        label = "to",
                        value = 94,
                        min = 1,
                        max = 94,
                        step = NA,
                        width = NULL
                    )
                ),
                mainPanel(
                    plotOutput("plot", width = "100%"), 
                )
            )
        ),
        tabPanel("Variable explain", fluid = TRUE, icon = icon("globe-americas"),
            plotOutput("plot2")
        ),
        tabPanel("PC Analysis", fluid = TRUE, icon = icon("globe-americas"),
            sidebarLayout(
                sidebarPanel(
                    selectInput(inputId = "PC_x",
                                label = "Select PC",
                                choices = c("PC1", "PC2", "PC3"),
                                selected = "PC1",
                                width = "220px"
                                ),
                    selectInput(inputId = "PC_y",
                                label = "Select PC",
                                choices = c("PC1", "PC2", "PC3"),
                                selected = "PC2",
                                width = "220px"
                                ),
                ),
                mainPanel(
                    plotOutput("plot3"),
                )
            )
        ),
        tabPanel("Scatter plot", fluid = TRUE, icon = icon("globe-americas"),
            sidebarLayout(
                sidebarPanel(
                    selectInput(
                        inputId = "scat_x",
                        label = "x",
                        choices = c(colnames(data)),
                        selected = colnames(data),
                    ),
                ),
                mainPanel(
                    plotOutput("scat_plot"), 
                    #plotOutput("box_plot", width = "100%"), 
                )
            )
        ),
        tabPanel("Survive&Bankruptcy", fluid = TRUE, icon = icon("globe-americas"),
            plotOutput("survive_bankrupt")
        )
    )
)

server <- function(input, output) {
    output$plot <- renderPlot({
        cor.matrix <- as.matrix(cor(data))
        correlation <- sort(cor.matrix[2:95],decreasing = T)

        data1 <- data[,-95]
        correlationMatrix <- cor(data1[,input$num1:input$num2])

        hist1 = ggplot(data, aes(Bankrupt.,)) + geom_bar(fill = c("Green","Red")) + theme_bw() + ggtitle("Survive(0) VS Bankruptcy(1)") + theme(plot.title = element_text(hjust = 0.5)) + xlab("Survive(0)                              Bankruptcy(1)")
        corr1 = ggcorr(data[,1:20],size=2,hjust=1)+geom_point()+scale_alpha_manual()+guides()
        corr2 = corrplot(corr=correlationMatrix, tl.cex=0.1)
        # This plot shows the correlation of each features.The deeper the color the more correlation for the features.

        #hist1
        #corr1
        corr2
    }, height = 700)

    output$plot2 <- renderPlot({
        #### Pca visualization

        data.pca.scale <- prcomp(data[,2:95], center=T ,scale = TRUE)
        #biplot(data.pca.scale, cex = 0.5)

        # Extract the variance explained 
        tot.var <- sum(data.pca.scale$sdev^2)
        var.explained <- data.frame(pc = seq(1:94), var.explained  = data.pca.scale$sdev^2/tot.var ) 
        ggplot(var.explained, aes(pc, var.explained)) + geom_bar(stat = "identity") + ggtitle("Bankruptcy")
        # shows how many variances explained by each PCs. From the first plot we can see around 40 PCs explained more than 90% of variances. 
    })

    output$plot3 <- renderPlot({
        #### Pca visualization
        data.pca.scale <- prcomp(data[,2:95], center=T ,scale = TRUE)
        data.df <- data.frame(PC1 = data.pca.scale$x[,1], PC2 = data.pca.scale$x[,2], PC3 = data.pca.scale$x[,3], labels = as.factor(data$Bankrupt.))
        if((input$PC_x == "PC1" && input$PC_y == "PC2") || (input$PC_x == "PC2" && input$PC_y == "PC1"))
            ggplot(data.df, aes(PC1, PC2, col = labels)) + geom_point()
        else if((input$PC_x == "PC2" && input$PC_y == "PC3") || (input$PC_x == "PC3" && input$PC_y == "PC2"))
            ggplot(data.df, aes(PC2, PC3, col = labels)) + geom_point()
        else if((input$PC_x == "PC1" && input$PC_y == "PC3") || (input$PC_x == "PC3" && input$PC_y == "PC1"))
            ggplot(data.df, aes(PC1, PC3, col = labels)) + geom_point()
    }, height = 700)

    output$survive_bankrupt <- renderPlot({
        #### number of classes,220 bankruptcy vs 6599 survive companies
        hist1 = ggplot(data, aes(Bankrupt.,)) + geom_bar(fill = c("Green","Red")) + theme_bw() + ggtitle("Survive(0) VS Bankruptcy(1)") + theme(plot.title = element_text(hjust = 0.5)) + xlab("Survive(0)                              Bankruptcy(1)")
        hist1
    }, height = 700)

    output$dataTable <- renderDataTable(data)

    output$scat_plot <- renderPlot({
        ggplot(data, aes_string(x = input$scat_x, y = 'Bankrupt.')) + 
        geom_point(aes(col = data$'Net Income Flag'), size=3) + 
        scale_color_discrete(name = 'Net Income Flag') + 
        geom_smooth(aes(group = data$'Net Income Flag', color = data$'Net Income Flag'), method='lm')
    }, height=500)

}

shinyApp(ui = ui, server = server)