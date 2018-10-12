library(tidyverse)
library(ggthemes)
#Testing methods for calculating haldanes


test <- read_tsv("../output/sep24/output_total-div_10_0_10000_1_100_0.00990000000000001_2_0.01_1e-07_1000_1_100_0.990000000000001_1_99082716794_out1.txt.gz")



test %>%
  group_by(version) %>%
  mutate(., p1_pooled_sd = sqrt((999 *(p1sd^2)) +  (999 *(lag(p1sd)^2)) / 1998 ),
         p1_delta = p1mean - lag(p1mean),
         haldane_p1 = p1_delta/p1_pooled_sd) %>%   
  mutate(., p2_pooled_sd = sqrt((999 *(p2sd^2)) +  (999 *(lag(p2sd)^2)) / 1998 ),
         p2_delta = p2mean - lag(p2mean),
         haldane_p2 = p2_delta/p2_pooled_sd) %>%   
  filter(generation > 10002) %>%
  ggplot(.,aes(x=generation,y=haldane_p1,group=version,color=version)) +geom_line() +
  geom_line(aes(x=generation,y=haldane_p2))
  theme_few() + scale_color_brewer(palette = "Set1")


test %>%
  filter(generation > 10002) %>%
  ggplot(.,aes(x=generation,y=p1fit,group=version,color=version)) + geom_line()

###
output2 <- list.files("../output/sep24/", pattern = "out1") 

data_mut <- data_frame(filename = output2[grepl("delta",output1)]) %>% # create a data frame
  mutate(file_contents = map(filename,          # read files into
                             ~ read_tsv(file.path("../output/sep24/", .)) %>% 
                               filter(version != "burn") %>%
                               select(generation,version,optimum,p1fit,p1mean,p1sd,
                                      p2fit,p2mean,p2sd) %>%
                               filter(generation > 10002) %>%
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

unnest(data_mut) %>%
  separate(.,filename,parameters,"_") ->output1_delta


output1_mut %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  group_by(seed) %>%
  mutate(., p1_pooled_sd = sqrt((999 *(p1sd^2)) +  (999 *(lag(p1sd)^2)) / 1998 ),
         p1_delta = p1mean - lag(p1mean),
         haldane_p1 = p1_delta/p1_pooled_sd) %>%   
  mutate(., p2_pooled_sd = sqrt((999 *(p2sd^2)) +  (999 *(lag(p2sd)^2)) / 1998 ),
         p2_delta = p2mean - lag(p2mean),
         haldane_p2 = p2_delta/p2_pooled_sd) %>% 
  mutate(mean_haldane = (haldane_p1 + haldane_p2)/2) %>%
  filter(!is.na(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(mutation_rate))) + 
  geom_line(alpha=0.1) + theme_few() + scale_color_distiller(palette = "Spectral")


