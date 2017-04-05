library(shiny)
library(ggplot2)
library(RPostgreSQL)
library(sqldf)
library(formattable)
library(RColorBrewer)
library(shinydashboard)
library(DT)
library(plyr)
library(dplyr)
library(reshape)
library(lubridate)
library(scales)
library(anytime)
library(shinyjs)

#  ------------------------------------------------------------------------

#colours <- brewer.pal(12,"Paired")
colours <- c(hue_pal(h = c(0, 30000) + 360, c = 110, l = 65, h.start = 10,
                     direction = 1)(40))

#ajuste <- par(mar=c(1,4,3,1)+0.6)

drv <- dbDriver("PostgreSQL")
#con <- dbConnect(SQLite(), "~/Dropbox/Artigos/2015-OswaldoTrelles (1)/database/swift_provenance041.db")
#con <- dbConnect(SQLite(), "~/Dropbox/loss/prov/run001op2.db")
con <- dbConnect(SQLite(), "~/Dropbox/loss/swift_provenance.db")
#con <- dbConnect(SQLite(), "~/Dropbox/LNCC/Dissertação/Resultados/DB/swift_provenance.db")
#con <- dbConnect(SQLite(), "~/scriptsSwift/gecko_peerj.db")
#con <- dbConnect(drv, dbname = "swift_provenance",
#                 host = "localhost", port = 5432,user = "postgres", password = 'postgres')

script_names <- as.vector(dbGetQuery(con, "select distinct script_filename from script_run")[,1])
