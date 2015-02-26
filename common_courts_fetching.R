library("saos")

# trends in number of judgments for every common court

data(courts)

dat <- vector("list", 291)
for (i in 1:291) {
  dat[[i]] <- search_judgments(ccCourtId = courts$id[i], 
                               judgmentDateTo = Sys.Date(),
                               limit = NULL, force = TRUE)
}
# problems with judgments
# 52387
# 31382
# looks like fixed 
saveRDS(dat, file = "common_courts_data.RDS")