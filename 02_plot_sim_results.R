# plot simulation output

library("tidyverse")

#

# read in simulation summaries
summary_df <- read.table("processed/sim_summary.txt.gz", h = T)

summary_df %>%
  filter(phase != "burn_in") %>%
  group_by(ne, m, div_sel_n, div_sel_s, mu, delta, seed)  %>%
  tally
  


# summarise the summaries (!)
sum_df <- summary_df  %>%
  filter(phase != "burn_in") %>%
  group_by(ne, m, div_sel_n, div_sel_s, mu, delta, seed, rep) %>%
  summarise(p1_home_percent_diff = p1_home_percent[1] - p1_home_percent[2],
            p2_home_percent_diff = p2_home_percent[1] - p2_home_percent[2],
            fit_dif_diff = fit_dif[1] - fit_dif[2])

View(summary_df)

summary_df %>%
  ggplot(aes(y = div_sel_s, x = ndelta, col = ))+
  geom_
  facet_grid(ne ~ m)