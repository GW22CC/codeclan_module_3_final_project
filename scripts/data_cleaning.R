# setup

library(tidyverse)
library(janitor)

# supplied core data files

dist_blue_green <- read_csv("../raw_data/shs_dist_to_blue_or_green_space.csv") %>% clean_names()
neighbourhood_rating <- read_csv("../raw_data/shs_neighbourhood_raiting.csv") %>% clean_names()
comm_belong <- read_csv("../raw_data/shs_community_belonging.csv") %>% clean_names()
shs_aggregate_responses <- read_csv("../raw_data/shs_aggregate_responses.csv")

# supplementary data files

data_zones <- read_csv("../raw_data/DataZone2011lookup_2022-05-05.csv") %>% clean_names() # geography lookup tables 
derelict_urb_vacant <- read_csv("../raw_data/shs_derelict_and_urban_vacant_land.csv") %>% clean_names()
proximity_to_derelict <- read_csv("../raw_data/shs_population_living_in_close_proximity_to_a_derelict_site.csv") %>% clean_names()

# harmonising datasets in prep. for joining

dist_blue_green <- dist_blue_green %>% 
  rename("walking_time_to_nearest_green_or_blue_space" = "distance_to_nearest_green_or_blue_space") %>% 
  filter(measurement == "Percent")

neighbourhood_rating <- neighbourhood_rating %>% 
  rename("walking_time_to_nearest_green_or_blue_space" = "walking_distance_to_nearest_greenspace") %>% 
  filter(measurement == "Percent")

comm_belong <- comm_belong %>% 
  rename("walking_time_to_nearest_green_or_blue_space" = "walking_distance_to_nearest_greenspace") %>% 
  filter(measurement == "Percent")

shs_aggregate_responses_data <- shs_aggregate_responses %>% 
  rename("walking_time_to_nearest_green_or_blue_space" = "distance_to_nearest_green_space") 

shs_proportions_data_join <- dist_blue_green %>% 
  full_join(neighbourhood_rating) %>% 
  full_join(comm_belong) %>% 
  select(-c(units)) %>%
  rename("year" = "date_code")

# joining with data zones table by la_code to incl. Local Authority names

data_zones_trim <- data_zones %>% 
  select(la_code, la_name) %>% 
  distinct()

shs_data_la_join <- shs_proportions_data_join %>% 
  left_join(data_zones_trim, by = c("feature_code" = "la_code")) %>% 
  mutate(la_name = if_else(feature_code == "S92000003", "Scotland", la_name)) 

shs_proportions_data_clean <- shs_data_la_join # re-assigning cleaned data to explicit object

shs_aggregate_responses_data_clean <- shs_aggregate_responses_data

# writing clean data to file

write_csv(shs_proportions_data_clean, "../clean_data/shs_proportions_data_clean.csv")
write_csv(shs_aggregate_responses_data_clean, "../clean_data/shs_aggregate_responses_data_clean.csv")