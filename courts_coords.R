library("saos")
library("ggmap")
library("maptools")
library("plotGoogleMaps")
library("dplyr")

# load data about courts
data(courts)

# random counts of judgments for testing purposes
dat <- expand.grid(id = courts$id, year = 2000:2014)
dat$count <- sample(100:2000, nrow(dat), replace = TRUE)


# coordinates of courts
coords <- lapply(courts$name, function(court) {
  res <- geocode(court)
  if (any(is.na(res))) res <- geocode(strsplit(court, " (w|we) ")[[1]][2])
  if (any(is.na(res))) res <- getGeoCode(court)
  if (any(is.na(res))) res <- getGeoCode(strsplit(court, " (w|we) ")[[1]][2])
  Sys.sleep(runif(1) + 0.2)
  res
})
coords <- lapply(coords, function(x) {
  if (is.numeric(x)) {
    data.frame(lon = x["lon"], lat = x["lat"])
  } else x
})
coords <- bind_rows(coords)
coords$name <- courts$name
coords <- as.data.frame(coords)

# add hierarchy
coords$type <- courts$type
saveRDS(coords, file = "courts_coords.RDS")

# test if it looks OK
coordinates(coords) <- ~lon+lat
proj4string(coords) <- CRS("+proj=longlat +datum=WGS84")
plotGoogleMaps(coords, zcol = "type", mapTypeId = "ROADMAP", legend = FALSE)
# looks good
