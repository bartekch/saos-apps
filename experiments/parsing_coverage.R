library("rgdal")
library("maptools")
library("rgeos")
library("stringi")
library("dplyr")

# pdf parsed to txt with linux command tool "pdftotext"
ln <- readLines("D20121223.txt")
par <- grep("\u00A7", ln)

# we need lowest level, so paragraph 3
ln <- ln[par[3]:(par[4] - 1)]

# first line is just a description
ln <- ln[-1]

# remove page numbers
ln <- ln[!grepl("\u2013 [[:digit:]]{1,2} \u2013", ln)]

# remove lines with information about act
ln <- ln[!grepl("(Dziennik Ustaw|Poz. 1223)", ln)]

# remove empty lines
ln <- ln[!grepl("^(|\\f)$", ln)]
ln <- ln[!grepl("\f", ln)]

# remove \a
ln <- gsub("\a", "", ln)

splitAt <- function(x, pos) unname(split(x, cumsum(seq_along(x) %in% pos)))

# split on regions
tmp <- grep("[[:digit:]]{1,2})", ln)
regions <- splitAt(ln, tmp)
regions <- lapply(regions, function(x) x[-1])

tmp <- ln[tmp]
tmp <- gsub(".* właściwości ", "", tmp)
tmp <- gsub("Sądu Okręgowego", "Sąd Okręgowy", tmp)
tmp <- gsub(":", "", tmp)
names(regions) <- tmp

## split regions on districts
districts <- lapply(regions, function(r) {
  d <- splitAt(r, grep("^[[:lower:]]{1})", r))
  d <- sapply(d, paste, collapse = " ")
  d
})

# join regions together so it will be easier to manipulate
# afterwards split them again
d_length <- sapply(districts, length)
districts <- unlist(districts)
names(districts) <- NULL
# processing names of regional courts
d_names <- stri_extract_first_regex(districts, "^[a-z]{1}.{1,70} (–|dla) ")
# removing list markers (a), b), etc.), hyphens and "dla"
d_names <- gsub("^[a-z]) ", "", d_names,)
d_names <- gsub(" dla $", "", d_names,)
d_names <- gsub(" \u2013", "", d_names,)
# drop excessive spaces
d_names <- stri_replace_all_regex(d_names, "[\\p{WHITE_SPACE}]+", " ")

# remove names of districts from coverage lists
for (i in seq_along(districts)) {
  districts[i] <- gsub("^[a-z]{1}.{1,70} (–|dla) ", "", districts[i])
}

# first extract ordinary districts
tmp <- grep("(oraz )?gmin(:|y| )", districts)
# 101 102 must be treated extraordinary
districts2 <- strsplit(districts, "(oraz )?gmin(:|y| )")
districts2[101] <- strsplit(districts[101], "oraz gmin: ")
districts2[102] <- strsplit(districts[102], "oraz dla gmin ")

districts2[tmp] <- lapply(districts2[tmp], function(x) {
  gminy <- tail(x, 1)
  gminy <- stri_split_regex(gminy, "(,\\p{WHITE_SPACE}|\\p{WHITE_SPACE}i\\p{WHITE_SPACE})")[[1]]
  gminy <- stri_trim_both(gminy)
  gminy <- gsub("(,|;|\\.)", "", gminy)
  if (nchar(x[1]) == 0) {
    list(gminy = gminy)
  } else {
    list(miasta = x[1], gminy = gminy)
  }
})
districts2[-tmp] <- lapply(districts2[-tmp], function(x) {
  list(miasta = x)
})

# the same procedure woth cities, however we have to exclude parts of bigger
# cities
districts2 <- lapply(districts2, function(x) {
  miasta <- x$miasta
  if (is.null(miasta)) {
    return(x)
  }
  if (grepl("częś(ć|ci) miast", miasta)) {
    return(x)
  }
  miasta <- stri_replace_all_regex(miasta, "miast(:|a)?\\p{WHITE_SPACE}", "")
  miasta <- stri_split_regex(miasta, "(,\\p{WHITE_SPACE}|\\p{WHITE_SPACE}i\\p{WHITE_SPACE})")[[1]]
  miasta <- stri_trim_both(miasta)
  miasta <- gsub("(,|;|\\.)", "", miasta)
  x$miasta <- miasta
  x
})



shp <- readShapePoly("gminy//gminy.shp")
# dropping unused attributes
shp <- shp[, c("jpt_kod_je", "jpt_nazwa_")]
names(shp@data) <- c("kod", "nazwa")
# remove factors
shp@data  <- mutate(shp@data, kod = as.character(kod), nazwa = as.character(nazwa))
  
gminy <- shp@data  
gminy <- unique(gminy)

# coordinates system transformation
proj4string(shp) <- CRS("+init=epsg:2180")
shp <- spTransform(shp, CRS("+proj=longlat +datum=WGS84"))

shp2 <- readShapePoly("powiaty//powiaty.shp")



shp3 <- readShapePoly("~/Pobrane/PRG_jednostki_administracyjne_v8/jednostki_ewidencyjne.shp")
shp3@data$jpt_nazwa_ <- stri_encode(shp3@data$jpt_nazwa_,
                                    from = "windows-1250", to = "UTF-8")

shp4 <- shp3[which(substr(shp3@data$jpt_kod_je, 8,8)==8), ]
