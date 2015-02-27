library("saos")
library("dplyr")

data(courts)

# create hierarchical structure of courts
courts$appeal <- substr(courts$code, 3, 4)
courts$region <- substr(courts$code, 3, 6)

appeal_names <- data.frame(appeal = with(courts, appeal[type == "APPEAL"]),
                           appeal_name = paste("Apelacja", c("wrocławska",
                                                             "białostocka",
                                                             "gdańska",
                                                             "katowicka",
                                                             "krakowska",
                                                             "łódzka",
                                                             "lubelska",
                                                             "poznańska",
                                                             "rzeszowska",
                                                             "szczecińska",
                                                             "warszawska")),
                           stringsAsFactors = FALSE)

region_names <- data.frame(region = with(courts, region[type == "REGIONAL"]),
                           region_name = paste("Okręg", c("bolesławiecki",
                                                          "legnicki",
                                                          "opolski",
                                                          "świdnicki",
                                                          "wrocławski",
                                                          "białostocki",
                                                          "łomżyński",
                                                          "olsztyński",
                                                          "suwalski",
                                                          "ostrołęcki",
                                                          "bydgoski",
                                                          "elbląski",
                                                          "gdański",
                                                          "słupski",
                                                          "toruński",
                                                          "włocławski",
                                                          "bielski",
                                                          "częstochowski",
                                                          "gliwicki",
                                                          "katowicki",
                                                          "kielecki",
                                                          "krakowski",
                                                          "nowosądecki",
                                                          "tarnowski",
                                                          "kaliski",
                                                          "łódzki",
                                                          "piotrkowski",
                                                          "sieradzki",
                                                          "płocki",
                                                          "lubelski",
                                                          "radomski",
                                                          "siedlecki",
                                                          "zamojski",
                                                          "koniński",
                                                          "poznański",
                                                          "zielonogórski",
                                                          "krośnieński",
                                                          "rzeszowski",
                                                          "tarnobrzeski",
                                                          "przemyski",
                                                          "gorzowski",
                                                          "koszaliński",
                                                          "szczeciński",
                                                          "warszawski",
                                                          "warszawski Warszawa-Praga")),
                           stringsAsFactors = FALSE)

courts <- left_join(courts, appeal_names, by = "appeal")
courts <- left_join(courts, region_names, by = "region")

# drop divisions
courts$divisions <- NULL

saveRDS(courts, "courts_hierarchy.RDS")

# create and save ready-to-use maps betweene various levels of hierarchy
courts %>%
  filter(type == "DISTRICT") %>%
  select(code, region, region_name) -> map_district_region

courts %>%
  filter(type == "DISTRICT") %>%
  select(code, appeal, appeal_name) -> map_district_appeal

courts %>%
  filter(type == "REGIONAL") %>%
  select(region, region_name, appeal, appeal_name) -> map_regional_appeal

courts %>%
  filter(type == "APPEAL") %>%
  select(appeal, appeal_name) -> map_appeal

save(map_district_appeal, map_district_region, map_regional_appeal, map_appeal,
     file = "cc_hierarchy_mapping.RData")
