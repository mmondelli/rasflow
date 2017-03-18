#Carregar os pacotes
#Banco
library(DBI)
library("RSQLite")
#Gráfico
library(ggplot2)
library(reshape2)

colours <- brewer.pal(12,"Paired")

con <- dbConnect(SQLite(), dbname="~/Dropbox/Artigos/2015-OswaldoTrelles (1)/database/swift_provenance041.db")

data <- dbGetQuery(con, paste("SELECT app_name, 
                                    100*sum(kernel_secs)/(sum(kernel_secs)+sum(user_secs)) as sys_percent, 
                                    100*sum(user_secs)/(sum(kernel_secs)+sum(user_secs)) as user_percent 
                                    from app_exec natural join resource_usage
                                    where script_run_id='allvsall-old-run030-1610601135'
                                    group by app_name;",sep=""))

subset <- t(data.frame(data$sys_percent, data$user_percent))

barplot(subset, names.arg=1:10, legend = c("sys_percent", "user_percent"),
        beside=TRUE, ylim=c(0,100),
        col=c(colours[1:2]),
        ylab = "Percentage of use", xlab = "Activity (see Legend box above)")

round(2.68547895, digits = 2)

#Uteis
df.long<-melt(data)
ggplot(df.long,aes(block,value,fill=variable))+
  geom_bar(stat="identity",position="dodge")

df <- data.frame(letters = LETTERS[1:5], numbers = 1:5, stringsAsFactors=FALSE)
paste(df$numbers, df$letters, sep=". ")

