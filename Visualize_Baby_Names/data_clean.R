setwd("~/namesbystate")
library(plyr)
require(ggmap)
require(maptools)
listOfFiles <- list.files(pattern= ".TXT") 
# Read in all txt files.
d <- do.call(rbind, lapply(listOfFiles, read.table, sep = ",", 
                           col.names=c("State", "Sex", "Year", "Name", "Number"), 
                           fill=FALSE, strip.white=TRUE)) 

# Sub set the d by extracting only the d from 2002 to 2012.
sub_d <- subset(d, Year >= 2002)

states <- data.frame(state.name, state.abb, state.division)
colnames(states) <- c("region", "State", "Division")
sub_d <- merge(states, sub_d, by = 'State')
sub_d$region <- tolower(sub_d$region)

us_state_map <- map_data('state')
map_d <- merge(sub_d, us_state_map, by = 'region')

write.csv(sub_d, file = "NamesOf50States.csv")
