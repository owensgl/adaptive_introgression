library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)
library(patchwork)

#Measuring the ability to track the climate with migration or without migration

no_mig <- read_tsv("../june2019.delta_nomig.climate.out1.txt.gz") %>%
  mutate(type = "No migration")
mig <- read_tsv("../june2019.delta_mig.climate.out1.txt.gz") %>%
  mutate(type = "Migration")

pdf("../figures/Sept2019.adaptationlag.pdf",height=4,width=6)
mig %>% 
  rbind(.,no_mig) %>%
  filter(version == "test",gen == 10100) %>%
  mutate(lag = optimum - (p1mean +p2mean)/2,
         delta = optimum/100) %>%
  group_by(delta, type) %>%
  do(data.frame(t(quantile(.$lag, probs = c(0.025,0.50, 0.975))))) %>%
  rename(bottom = X2.5., mid = X50., top =X97.5.) %>%
  ggplot(.,aes()) + 
  geom_ribbon(aes(x=delta,ymin=bottom/(delta),ymax=top/(delta),fill=type),alpha=0.5) +
  geom_line(aes(x=delta,y=mid/(delta),linetype=type),alpha=0.4,size=0.7) +
  scale_fill_manual(values=c("light grey","dark grey"),name="Type") +
  scale_linetype_manual(values=c("solid","dotted"),name="Type") +
  
  theme_few() +
  ylab("Adaptation lag (generations)") +
  xlab("Rate of climate change")

dev.off()

# 
# mig %>% 
#   rbind(.,no_mig) %>%
#   filter(version == "test",gen == 10100) %>%
#   mutate(lag = optimum - (p1mean +p2mean)/2,
#          delta = optimum/100) %>%
#   ggplot(.,aes(x=delta,y=lag/(delta),color=type)) + geom_point(alpha=0.4,size=0.7) +
#   scale_color_brewer(palette = "Set2",name="Type") +
#   geom_smooth() +
#   theme_few() +
#   ylab("Adaptation lag (generations)") +
#   xlab("Rate of climate change")
