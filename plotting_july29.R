library(tidyverse)
setwd("/home/owens/working/adaptive_introgression")

#####July 29nd, 2018


data <- read_delim("processed/sim_summary_2017-08-29.txt.gz",delim="\t")
pdf("July_29_testing_single_factors.pdf")


##delta

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(treatment=="test") %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(delta), y=burn_in_purity)  )+
  coord_cartesian(ylim=c(0.5,1)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Burn-in purity") +
  xlab("Optimum shift per generation")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(delta), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Optimum shift per generation")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_point(aes(x=log(delta), y=shift,color=treatment))  +
  geom_smooth(aes(x=log(delta), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Optimum shift per generation")

###qtl_sd

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(treatment=="test") %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(qtl_sd), y=burn_in_purity)  )+
  coord_cartesian(ylim=c(0.5,1)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Burn-in purity") +
  xlab("QTL variation")


data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(qtl_sd), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("QTL variation")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, mutation_rate == 0.000000100, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_point(aes(x=log(qtl_sd), y=shift,color=treatment))  +
  geom_smooth(aes(x=log(qtl_sd), y=shift,color=treatment)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("QTL variation")

#mutation_rate

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(treatment=="test") %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(mutation_rate), y=burn_in_purity)  )+
  coord_cartesian(ylim=c(0.5,1)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Burn-in purity") +
  xlab("Mutation rate")


data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(mutation_rate), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Mutation rate")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, div_sel_n == 100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_point(aes(x=log(mutation_rate), y=shift,color=treatment))  +
  geom_smooth(aes(x=log(mutation_rate), y=shift,color=treatment)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Mutation rate")

##div_sel_n
data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, fitness_sd == 2.0 ) %>% 
  filter(treatment=="test") %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(div_sel_n), y=burn_in_purity)  )+
  coord_cartesian(ylim=c(0.5,1)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Burn-in purity") +
  xlab("Divergently selected alleles")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(div_sel_n), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Divergently selected alleles")


data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2) %>% 
  mutate(shift = burn_in_purity - purity) %>% 
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, fitness_sd == 2.0 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_point(aes(x=log(div_sel_n), y=shift,color=treatment))  +
  geom_smooth(aes(x=log(div_sel_n), y=shift,color=treatment)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Log Divergently selected alleles")


###fitness_sd
data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2 ) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100 ) %>% 
  filter(treatment=="test") %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(fitness_sd), y=burn_in_purity)  )+
  coord_cartesian(ylim=c(0.5,1)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Burn-in purity") +
  xlab("Fitness landscape variation") 



data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2 ) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_boxplot(aes(x=as.factor(fitness_sd), y=shift,color=treatment))  +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Fitness landscape variation")

data %>% 
  group_by(seed, delta, qtl_sd, mutation_rate, div_sel_n,fitness_sd) %>%
  mutate(burn_in_purity = (p1_home_percent[which(phase == "burn_in")] + p2_home_percent[which(phase == "burn_in")])/2) %>% 
  filter(phase != "burn_in") %>%
  mutate(purity = (p1_home_percent + p2_home_percent)/2 ) %>% 
  mutate(shift = burn_in_purity - purity) %>%
  filter(delta == 1, qtl_sd == 1, mutation_rate == 0.000000100, div_sel_n == 100 ) %>% 
  filter(burn_in_purity > 0.8) %>%
  ggplot(.) + geom_point(aes(x=log(fitness_sd), y=shift,color=treatment))  +
  geom_smooth(aes(x=log(fitness_sd), y=shift,color=treatment)) +
  scale_color_brewer(palette = "Set1") +
  ylab("Admixture after burn-in") +
  xlab("Log Fitness landscape variation")


dev.off()


