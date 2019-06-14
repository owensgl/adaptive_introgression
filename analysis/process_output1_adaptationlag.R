library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)

#Measuring the ability to track the climate with migration or without migration

no_mig <- read_tsv("../june2019.delta_nomig.climate.out1.txt.gz") %>%
  mutate(type = "No migration")
mig <- read_tsv("../june2019.delta_mig.climate.out1.txt.gz") %>%
  mutate(type = "Migration")

pdf("../figures/June2019.adaptationlag.pdf",height=3,width=6)
mig %>% 
  rbind(.,no_mig) %>%
  filter(version == "test",gen == 10100) %>%
  mutate(lag = optimum - (p1mean +p2mean)/2,
         delta = optimum/100) %>%
  ggplot(.,aes(x=delta,y=lag/(delta),color=type)) + geom_point(alpha=0.4,size=0.7) +
  scale_color_brewer(palette = "Set2",name="Type") +
  geom_smooth() +
  theme_few() +
  ylab("Adaptation lag") +
  xlab("Rate of climate change")
dev.off()
