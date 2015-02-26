library("saos")
library("lubridate")
library("dplyr")

dat <- readRDS("common_courts_data.RDS")
judgments <- lapply(seq_along(dat), function(i) {
  date <- extract(dat[[i]], "judgmentDate")
  if (nrow(date) > 0) {
    date$court_id <- courts$id[i]
    date
  } else NULL
})
judgments <- bind_rows(judgments)

judgments %>%
  mutate(date = ymd(judgmentDate),
         month = floor_date(date, "month"),
         year = floor_date(date, "year")) -> judgments

# generate all months
all_months <-seq.POSIXt(min(judgments$month), max(judgments$month), by = "month")


# summarise number of judgments in court by month
judgments %>%
  group_by(court_id, month) %>%
  summarise(count = n())  %>% 
  ungroup() -> count_by_month

saveRDS(count_by_month, "app-trends/count_by_month.RDS")