library(tidyverse)
library(ggthemes)
library(forcats)

###Calculating haldanes
output1 <- list.files("../output/sep24/", pattern = "out1") 

data <- data_frame(filename = output2) %>% # create a data frame
  mutate(file_contents = map(filename,          # read files into
                             ~ read_tsv(file.path("../output/sep24/", .)) %>% 
                               filter(version != "burn") %>%
                               select(generation,version,optimum,p1fit,p1mean,p1sd,
                                      p2fit,p2mean,p2sd) %>%
                               filter(generation >= 10001) %>%
                               group_by(version) %>%
                               mutate(., p1_pooled_sd = sqrt((999 *(p1sd^2)) +  (999 *(lag(p1sd)^2)) / 1998 ),
                                      p1_delta = p1mean - lag(p1mean),
                                      haldane_p1 = p1_delta/p1_pooled_sd) %>%   
                               mutate(., p2_pooled_sd = sqrt((999 *(p2sd^2)) +  (999 *(lag(p2sd)^2)) / 1998 ),
                                      p2_delta = p2mean - lag(p2mean),
                                      haldane_p2 = p2_delta/p2_pooled_sd) %>% 
                               mutate(mean_haldane = (haldane_p1 + haldane_p2)/2))# a new data column
  )  

parameters <- colnames(read_tsv("../parameter_file.txt"))
parameters <- c("blank","target_param",parameters,"tail")

unnest(data) %>%
  separate(.,filename,parameters,"_") ->output1

write_tsv(output1, "../sept24.out1.txt.gz")