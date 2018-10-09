library(tidyverse)
library(ggthemes)
#Testing methods for calculating haldanes


test <- read_tsv("../output/sep24/output_delta_10_0_10000_2.19_100_0.009_2_0.01_1e-07_1000_1_100_0.9_1_97797325121_out1.txt.gz")



test %>%
  group_by(version) %>%
  mutate(., p1_pooled_sd = sqrt((999 *(p1sd^2)) +  (999 *(lag(p1sd)^2)) / 1998 ),
         p1_delta = p1mean - lag(p1mean),
         haldane_p1 = p1_delta/p1_pooled_sd) %>%   
  mutate(., p2_pooled_sd = sqrt((999 *(p2sd^2)) +  (999 *(lag(p2sd)^2)) / 1998 ),
         p2_delta = p2mean - lag(p2mean),
         haldane_p2 = p2_delta/p2_pooled_sd) %>%   
  filter(generation > 10000) %>%
  ggplot(.,aes(x=generation,y=haldane_p1,group=version,color=version)) +geom_line() +
  geom_line(aes(x=generation,y=haldane_p2))
  theme_few() + scale_color_brewer(palette = "Set1")


test %>%
  filter(generation > 10000) %>%
  ggplot(.,aes(x=generation,y=p1fit,group=version,color=version)) + geom_line()
