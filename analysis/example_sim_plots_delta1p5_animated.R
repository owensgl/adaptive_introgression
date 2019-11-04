#Example sim delta1p5 but with animated plots
library(tidyverse)
library(RColorBrewer)
library(ggthemes)
library(grid)
library(gridExtra)
library(gganimate)
out3 <- read_tsv("../example/example_sim_jun19_delta1p5_test_out3.txt",
                 col_names = c("spacer","version","type", "gen","pop","mut_pos",
                               "mutID","mut_popID","mut_freq","mut_sel")) %>%
  filter(gen > 1)



out2 <- read_tsv("../example/example_sim_jun19_delta1p5_test_out2.txt",
                 col_names = c("spacer","version","gen","p1_home","p2_home",
                               "p1_home_count","p2_home_count","fit_dif")) %>%
  filter(gen > 1)

#Sample fitness
out4 <- read_tsv("../example/example_sim_jun19_delta1p5_test_out4.txt",
                 col_names = c("spacer","version","gen","pop","id","fitness","spacer2"))

#Gene identities
out3 %>%
  filter(type == "M1") %>%
  select(mutID, mut_popID, mut_sel) %>% unique() %>%
  rename(mut_ID = mutID)-> QTL_loci

mut_s  <- read_tsv("../example/example_sim_jun19_delta1p5_test_mutS.txt")

#pop_colors <- brewer.pal(5,"Set1")[c(3,5)]
pop_colors <- c("#4DAF4A","#C4519E")

plot_RI_test <- out2 %>%
  filter(gen != 1) %>%
  gather(pop,percent, p1_home:p2_home) %>% 
  ggplot(aes(x=gen,y=1-percent,color=pop)) + geom_line(size=2) +
  geom_line(aes(x=gen,y=fit_dif/max(fit_dif)),color="black",linetype="solid",size=1) +
  theme_bw() + 
  scale_color_manual(values=pop_colors,name="Population",
                     labels=c("Pop_1", "Pop_2")) +
  xlab("Generation") +
  ylab("Introgressed ancestry") +
  theme(legend.position="bottom",
        text = element_text(size=20)) +
  scale_y_continuous(sec.axis = sec_axis(~.,name="Reproductive isolation")) +
  labs(tag = "A") +
  scale_x_continuous(breaks=c(10001, 10020,10040,10060,10080,10100)) +
  transition_reveal(gen)

animate(
  plot_RI_test,
  width = 600, height = 400
)
anim_save("../figures/example_sim_delta1p5.RI.anim.gif")


plot_introgression_test <- out3 %>%
  filter(type != "M1") %>% 
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(pop == "Pop_1" ) %>%
  ggplot(.) + geom_bar(aes(x=mut_pos,y=mut_freq,fill=as.factor(mut_popID)),stat="identity",position="stack") +
  geom_bar(data=out3 %>%
             filter(type != "M1") %>% 
             mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                           pop == "p2" & mut_popID == "2" ~ "Native",
                                           TRUE ~ "Introgressed")) %>%
             mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
             mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                                    TRUE ~ "Pop_2")) %>%
             filter(pop == "Pop_2" ) %>%
             mutate(mut_popID = fct_rev(as.factor(mut_popID))),
           aes(x=mut_pos,y=-mut_freq,fill=as.factor(mut_popID)),stat="identity",position="stack") +
  theme_few() + scale_fill_manual(values = pop_colors,name="Neutral allele origin",
                                  labels=c("Pop_1", "Pop_2")) +
  geom_hline(yintercept=0) +
  ylab("Neutral allele frequency") +
  xlab("Position") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        legend.position="bottom",
        text = element_text(size=20)) +
  transition_time(gen) +
  labs(title = 'Generation: {frame_time}')

animate(
  plot_introgression_test,
  width = 900, height = 600
)
anim_save("../figures/example_sim_delta1p5.ancestry.anim.gif")



plot_qtl_test <- out3 %>%
  full_join(.,mut_s) %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  mutate(qtl_category = case_when(mut_sel < 0 ~"Negative",
                                  mut_sel > 2 ~ "Strongly Positive",
                                  mut_sel > 0 ~ "Positive",
                                  TRUE ~ "NA")) %>%
  filter(mut_origin == "Introgressed") %>%
  group_by(mutID, pop) %>%
  mutate(meanfitness = mean(rel_fitness,na.rm=T)) %>%
  ggplot(.,aes(x=gen,y=mut_freq,group=mutID,color=qtl_category)) + 
  geom_line(alpha=0.7,size=1) +
  theme_few() + 
  scale_color_manual(name="QTL direction",values=c("#377EB8", "#FF7575","#B30C0C")) +
  facet_grid(pop~.) +
  ylab("Climate QTL allele frequency") + 
  xlab("Generation") +
  theme(legend.position="bottom",
        text = element_text(size=20)) +
  labs(tag = "B") +
  coord_cartesian(ylim=c(0,1)) +
  transition_reveal(gen)

animate(
  plot_qtl_test,
  width = 900, height = 600
)
anim_save("../figures/example_sim_delta1p5.qtl.anim.gif")

