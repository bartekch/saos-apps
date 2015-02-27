library("rgdal")
library("maptools")

library("RColorBrewer")
library("classInt")

# download file if necessary
if (!file.exists("NUTS_2010_03M_SH/")) {
  temp <- tempfile(fileext = ".zip")
  download.file("http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles/NUTS_2010_03M_SH.zip",
                temp)
  # now unzip the boundary data
  unzip(temp)
}

# read data
EU_NUTS <- readOGR(dsn = "./NUTS_2010_03M_SH/NUTS_2010_03M_SH//Data", layer = "NUTS_RG_03M_2010")


# subset NUTS 3 in Poland = regions
# NUTS 2 = voivodeships, which is useful, but appeal courts covers regions that
# are sometimes built from smaller regions, so we need to go one step lower
reg <- EU_NUTS[grep("^PL[[:alnum:]]{3}$", EU_NUTS@data$NUTS_ID), ]
plot(reg)


# NUTS classification for Poland
# it can't be too easy
# shapefiles are for prepared for old NUTS classification (from January 2015
# there is a new one, developed in 2013; we need 2010)
# it could be downloaded from here
# http://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=LST_CLS_DLD&StrNom=NUTS_22&StrLanguageCode=EN&StrLayoutCode=HIERARCHIC#
nuts <- read.csv("NUTS_22_20150226_204805.csv")
nuts <- nuts[match(reg@data$NUTS_ID, nuts$NUTS.Code), c("NUTS.Code", "Description")]
names(nuts) <- c("NUTS_ID", "NUTS_NAME")

cc <- readRDS("courts_hierarchy.RDS")

# 

# integrate with spPolygon
voiv@data <- merge(voiv@data, nuts)


# since some appeal courts covers more than one voivodeship we need to merge
# them by hand
# details of coverage are described here
# http://orka.sejm.gov.pl/proc7.nsf/ustawy/804_u.htm
# but it would be difficult to parse, it's quicker to do it by hand
reg <- voiv
plot(reg)
un <- unionSpatialPolygons(reg, )


# even NUTS 3 are not enough to reflect appeal coverages!!!!

