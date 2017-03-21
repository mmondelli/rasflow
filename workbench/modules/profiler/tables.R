#Summary
output$summaryPlot <- renderPrint({
  if (is.null(v$data)) return()
  summary(v$data)
})

#Table Query
output$tableQuery <- renderFormattable({
  if (is.null(v$data)) return()
  df <- data.frame(v$data[1:9])
  formattable(data.frame(df), list(app = 
                                     formatter("span", style = x ~ style(color = colours[1: length(v$data)]))))
  #print(data.frame(v$data))
})