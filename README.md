# saos-apps

Repository for applications and analyses using R [saos](https://github.com/bartekch/saos) package - an interface to [SAOS](https://saos-test.icm.edu.pl/) repository. 

## Files description

`cc_hierarchy_mapping.RData` data frames with relations between different levels
of common sourts

`cc_sp_appeal.RDS, cc_sp_region.RDS` 	Shapefiles with coverages of regional and
appeal courts

`common_courts_data.RDS` search results for common courts. Format - list, where each element is a search result for one court.

`courts_coords.RDS` coordinates of all common courts

`courts_hierarchy.RDS` 	Like dataset `courts` but with additional columns with information about structure

`map_court_district.csv` administrative counties assigned to regional courts


## Trends

Folder `app-trends` contains prototype for shiny app displaying trends in number
of judgments issued by common courts. Could be run with
```r
library("shiny")
runApp("app-trends/")
```
