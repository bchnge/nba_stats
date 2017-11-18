require(shiny)
require(data.table)
require(ggplot2)
require(stringr)

shinyServer(function(input, output) {
  
  # Sanitize player names  
  getFLastName <- function(name){
    x <- str_split(name, ' |\\.')[[1]]
    paste(substr(x[1],start = 1, stop = 1),'. ', x[length(x)], sep = '')
  }

  data <- fread('data/individual_performances.csv', stringsAsFactors = F)
  data[, player:= paste(index, ' (', team, ')', sep = '')]
  data[, shortName:= getFLastName(index), by = index]
 
  # Build reference table of metric names 
  reference_table <- data.frame(variable = c('fg3', 'pts', 'tov_pct', 'tov', 'ft_pct', 'pf', 'blk', 'fg3a', 'fg3_pct', 'stl', 'drb', 'orb', 'mp'),
                                variable_name = c('3-PT', 'Total points', 'Turnovers per 100 plays', 'Turnovers', 'Free-throw percentage', 'Personal fouls', 'Blocks', '3-PTs attempted', '3-PT percentage', 'Steals', 'Defensive rebounds', 'Offensive rebounds', 'Minutes played'))
  
  data <- merge(data, reference_table, by = 'variable')
  
  players <- sort(data[, unique(index)])
  metrics <- sort(data[, unique(variable_name)])
  
  # Present list of options for players given dataset
  output$selectPlayer <- renderUI({
    selectizeInput(inputId = 'selectedPlayer', label = 'Select player', choices = players, selected = list('Kevin Durant', 'Russell Westbrook', 'James Harden'), multiple = T, options = list(maxItems = 3))
  })
  
  # Present list of metrics given dataset
  output$selectMetric <- renderUI({
    selectInput(inputId = 'selectedMetric', label = 'Select performance metric', choices = metrics, selected = 'Total points', multiple = F)
  })
  
  # Generate comparative plot of distribution of performance
  output$distPlot <- renderPlot({
    ggplot(data[index %in% input$selectedPlayer & variable_name == input$selectedMetric], aes(x = shortName, y = value)) +  
      geom_violin(aes(fill = player), alpha = 0.5, size = 0) + 
      geom_boxplot(aes(fill = player), color = '#000000', outlier.shape = NA, alpha = 1, coef = 0, size = 0.1) +
      geom_jitter(size = 0.2, alpha = 1,width = 0.1,height = 0) + 
      theme(legend.position="hidden",
            legend.direction="vertical", 
            legend.title = element_blank(), 
            axis.ticks.x = element_blank(),
            panel.background = element_blank(), 
            strip.background = element_blank(),
            panel.grid.major.y = element_line(color = '#cccccc', linetype = 'dotted', size = 0.5)) +
      ylab(input$selectedMetric) +
      xlab('')+
      facet_wrap(~ season, ncol = 3, scales = 'free_x',drop = F)
  })
  
  # Generate time series plot of performance
  output$timePlot <- renderPlot({
    g <- ggplot(data[(index %in% input$selectedPlayer) & variable_name ==  input$selectedMetric],aes(x = as.Date(date), y = value, group = interaction(season, player), color = player)) + 
      geom_line(alpha = 0.2) +
      geom_point(size = 1, alpha = 0.2) + 
      geom_smooth(aes(fill = player)) + 
      
      xlab('') + ylab(input$selectedMetric) + title('Performance in most recent season') +
      theme(legend.position="top",
            legend.direction="horizontal", 
            legend.title = element_blank(), 
            panel.background = element_blank(), 
            panel.grid.major.y = element_line(color = '#cccccc', linetype = 'dotted', size = 0.5),
            strip.background = element_blank())
    g + facet_grid(~season, scales = 'free_x')
  })  
})

