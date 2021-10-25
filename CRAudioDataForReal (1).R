#FIXES BRANCH- adjust or change the code here !
#Load AMMonitor 
#install.packages("AMMonitor")
library(AMMonitor)

help("AMMonitor")

getwd()
setwd("C:/Users/aschulz2/Dropbox/CR.AMMonitor2")
#List the functions in AMMonitor 
ls("package:AMMonitor")

#Create the AMMonitor directory structure 
ammCreateDirectories(
  amm.dir.name = "AMMonitor",
  file.path=getwd()
  )




library(AMModels)

# look at the AMModels help page
# help("AMModels")

# Create a  library called "activity"
activity <- AMModels::amModelLib(description = "This library stores models that predict species activity patterns.")

# Create a library called  classifiers 
classifiers <- AMModels::amModelLib(description = "This library stores classification models (machine learning models) that can be used to predict the probability that a detected signal is from a target species.")

# Create a  library called soundscape
soundscape <- AMModels::amModelLib(description = "This library stores results of a soundscape analysis.")

# Create a library called do_fp
do_fp <- AMModels::amModelLib(description = "This library stores results of dynamic occupancy analyses that can handle false positive detections.")

# Create a list of metadata to be added to each library
info <- list(PI = 'Annie S', 
             Organization = 'CHESS Lab')

# Add metadata to each library
ammlInfo(activity) <- info
ammlInfo(classifiers) <- info
ammlInfo(soundscape) <- info
ammlInfo(do_fp) <- info

# Look at one of the libraries
activity

# Save the libraries to the AMMonitor amml folder
saveRDS(object = activity, file = "ammls/activity.RDS")
saveRDS(object = classifiers, file = "ammls/classifiers.RDS")
saveRDS(object = soundscape, file = "ammls/soundscape.RDS")
saveRDS(object = do_fp, file = "ammls/do_fp.RDS")

#Create database 
dbCreate(db.name = "CRAudioDatabase",
               file.path = paste0(getwd(),"/AMMonitor/database"))

#Establish the database file path as db.path
db.path <- paste0(getwd(),'/AMMonitor/database/CRAudioDatabase')

# Connect to the database
conx <- RSQLite::dbConnect(drv = dbDriver('SQLite'), dbname = db.path)

# Turn the SQLite foreign constraints on
RSQLite::dbExecute(conn = conx, statement = 
                     "PRAGMA foreign_keys = ON;"
)

# Look at information about the people table
dbTables(db.path = db.path, table = "people")

# Look at the structure of the deployment table
dbTables(db.path = db.path, table = 'deployment')

# Return foreign key information for the deployment table
RSQLite::dbGetQuery(conn = conx, statement = "PRAGMA foreign_key_list(deployment);")



# Add a new column called StartDate
RSQLite::dbExecute(conn = conx, statement = 
                     "ALTER TABLE people ADD COLUMN startDate2 varchar;"
) 



##########################
#Chapter 3 - People Table#
##########################
{
# Look at information about the people table
dbTables(db.path = db.path, table = "people")
  
# Read the entire table and store as get.people
get.people <- RSQLite::dbReadTable(conn = conx, name = "people")
  
# Look at the entire table (printed as a tibble)
get.people

library(readxl)
library(dplyr)
add.people <- read_excel("People-AMMonitor.xlsx")
add.people<-as.data.frame(add.people)
add.people<-rename(add.people, personID=`person ID`)

View(People_AMMonitor)


# Bind new records to the people table of the database
RSQLite::dbWriteTable(conn = conx, name = 'people', value = add.people,
                      row.names = FALSE, overwrite = TRUE,
                      append = FALSE, header = FALSE)

# Check database to confirm new records were added
RSQLite::dbGetQuery(conn = conx, 
                    statement = 'SELECT * FROM people')
}

######################
#Ch 4 - Species Table#
######################
{
# Look at information about the species table
dbTables(db.path = db.path, table = "species")

# Read the entire table and store as get.species
get.species <- RSQLite::dbReadTable(conn = conx, name = "species")

add.species <- read_csv("Species-AMMonitor.csv")
add.species<-as.data.frame(add.species)

# Look at the entire table (printed as a tibble)
add.species

# Bind new records to the species table of the database
RSQLite::dbWriteTable(conn = conx, name = 'species', value = add.species,
                      row.names = FALSE, overwrite = TRUE,
                      append = FALSE, header = FALSE)

# Retrieve all columns and rows from the species table
RSQLite::dbGetQuery(conn = conx, statement = "SELECT * FROM species")

# Install the package taxize to link to the ITIS database
#install.packages(taxize)

# Load the taxize package
library(taxize)
}


###############################
#Ch 6 - Locations and Spatials#
###############################
{
# Look at information about the locations table
dbTables(db.path = db.path, table = "locations")

# Read the entire table and store as get.species
get.locations <- RSQLite::dbReadTable(conn = conx, name = "locations")  
  
add.locations <- read.csv("Locations-AMMonitor.csv")
add.locations <-as.data.frame(add.locations)
View(Locations_AMMonitor)  

# Look at the entire table (printed as a tibble)
add.locations

# Bind new records to the locations table of the database
RSQLite::dbWriteTable(conn = conx, name = 'locations', value = add.locations,
                      row.names = FALSE, overwrite = TRUE,
                      append = FALSE, header = FALSE)

# Return the records from the locations table (printed as a tibble)
RSQLite::dbGetQuery(conn = conx, statement = "SELECT * FROM locations")

# Return foreign key information for the locations table
RSQLite::dbGetQuery(conn = conx, statement = "PRAGMA foreign_key_list(locations);")

}  
  
##########################
#Ch 11 - Recordings Table#
##########################
{
  dbTables(db.path = db.path, table = 'recordings')
library("httpuv")
# Load the rdrop2 package
library(rdrop2)
?drop_auth
# Create a token that allows R to link to your Dropbox account
#token <- rdrop2::drop_auth(new_user = TRUE, 
#                           key = "8z6m615i9l8j485",
#                           #secret = "l8zeqqqgm1ne5z0", 
#                           cache = TRUE, 
#                           rdstoken = NA)

token <-drop_auth(new_user = TRUE)
token
library(rdrop2)

saveRDS(object = token, file = 'AMMonitor/settings/dropbox-token.RDS')

# Read in the token to R
token <- readRDS(file = 'AMMonitor/settings/dropbox-token.RDS')

# Confirm that your dropbox account is associated with the token
account_info <- rdrop2::drop_acc(dtoken = token)

# View a few items in the account_info object
account_info['name']
# Return the functions in rdrop2 as a data.frame
data.frame(ls("package:rdrop2"))
getwd()
meta <- dropboxMetadata(directory = 'CR.AMMonitor2/AMMonitor/recordings', 
                        token.path = 'AMMonitor/settings/dropbox-token.RDS') 

?dropboxMetadata
# Look at all rows of metadata, column 'path_display'
as.data.frame(meta[,'path_display'])

# Move files and insert metadata to the recordings database table
dropboxMoveBatch(db.path = db.path,
                 table = 'recordings', 
                 dir.from = 'CR.AMMonitor2/AMMonitor/recording_drop', 
                 dir.to = 'CR.AMMonitor2/AMMonitor/recordings', 
                 token.path = 'AMMonitor/settings/dropbox-token.RDS')



}

###########################
#Ch 13 - Soundscapes Table#
###########################
{
wav1 <- tuneR::readWave(filename = 'AMMonitor/recordings/ANG3_20120615_072700.wav')
getwd()
AMMonitor::soundscape(db.path = db.path,
                      recordingID = 'ANG3_20120615_072700.wav',
                      directory = 'AMMonitor/recordings', 
                      token.path = 'settings/dropbox-token.RDS', 
                      db.insert = TRUE)

}
