library("rgdal")
library("maptools")
library("rgeos")

# download file if necessary
if (!file.exists("powiaty/")) {
  temp <- tempfile(fileext = ".zip")
  download.file("http://www.gis-support.pl/downloads/powiaty.zip",
                temp)
  # now unzip the boundary data
  unzip(temp)
}


# regions
shp <- readShapePoly("powiaty/powiaty.shp")
# dropping unused attributes
shp <- shp[, c("jpt_kod_je", "jpt_nazwa_")]
names(shp@data) <- c("kod", "nazwa")
# remove factors
shp@data <- mutate(shp@data, kod = as.character(kod), nazwa = as.character(kod))

# coordinates system transformation
proj4string(shp) <- CRS("+init=epsg:2180")
shp <- spTransform(shp, CRS("+proj=longlat +datum=WGS84"))

# map between coverage of regional courts and administrative regions
# based on 
# http://orka.sejm.gov.pl/proc7.nsf/ustawy/804_u.htm#_ftn1
# it is not binding regulation, but serves well as first approximation
# official regulation:
# http://isap.sejm.gov.pl/DetailsServlet?id=WDU20120001121

map_court_district <- read.csv("map_court_district.csv", colClasses = "character")
# add id for convenience
region_id <- data.frame(id = seq_along(unique(map_court_district$region)),
                        region = unique(map_court_district$region),
                        stringsAsFactors = FALSE)

load("cc_hierarchy_mapping.RData")
# combine districts within the same region using appropiate map
# WARNING - the order of polygons is based on row.names !!!!!!
tmp_map <- match(shp@data$kod, map_court_district$kod)
regions <- unionSpatialPolygons(shp, map_court_district$region[tmp_map])

# add data frame so it would be easy to add variables
tmp_map <- match(row.names(regions), map_regional_appeal$region)
tmp_data <- data.frame(region = row.names(regions),
                       region_name = map_regional_appeal$region_name[tmp_map],
                       row.names = row.names(regions),
                       stringsAsFactors = FALSE)
regions <- SpatialPolygonsDataFrame(regions, tmp_data)
saveRDS(regions, file = "cc_sp_region.RDS")

# combine regions within the same appeal area
# we need map from region to appeal
tmp_map <- match(row.names(regions), map_regional_appeal$region)
appeals <- unionSpatialPolygons(regions, map_regional_appeal$appeal[tmp_map])

# add data frame so it would be easy to add variables
tmp_data <- map_appeal[order(map_appeal$appeal),]
row.names(tmp_data) <- tmp_data$appeal
appeals <- SpatialPolygonsDataFrame(appeals, tmp_data)
saveRDS(appeals, file = "cc_sp_appeal.RDS")

# a few regions are mismatched - for example gmina tarczyn and warsaw districts


appeals$var <- rnorm(length(appeals), 0, 10)

spplot(appeals, zcol = "var", col.regions = heat.colors(30))
