output$alignmentRate <- renderValueBox({
  rate <- dbGetQuery(con, paste("select value from file_annot_numeric
                                natural join staged_out
                                where key like ' overall alignment rate'
                                and file_id like '%",input$inputPacient,"%'
                                and app_exec_id like '%",input$scriptId,"%'", sep=""))
  if (is.null(v$data))
    valueBox("0", "Overall Alignment Rate", icon = icon("line-chart"))
  else
    valueBox(rate, "Overall Alignment Rate", icon = icon("line-chart"))
  #dbDisconnect(con)
})
