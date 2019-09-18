library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)

###Measuring introgression
iteration <- "june2019"
#Not run divseln
parameter <- "delta"
parameters_tested <- c("qtlsd","delta","m","mutationrate", "proportionbdm","recombinationrate","rimax","totaldivbdmn")



plots <- list()
plots_RI <- list()
for (n in 1:length(parameters_tested)){
  parameter <- parameters_tested[n]
  parameters <- colnames(read_tsv("../parameter_file.txt"))
  parameters <- c("blank","target_param",parameters,"tail")
  parameter_full <- parameter
  parameter_full <- gsub("totaldivdbmn","total_div_bdm_n",parameter_full)
  parameter_full <- gsub("mutationrate","mutation_rate",parameter_full)
  parameter_full <- gsub("qtlsd","qtl_sd",parameter_full)
  parameter_full <- gsub("proportionbdm","proportion_bdm",parameter_full)
  parameter_full <- gsub("recombinationrate","recombination_rate",parameter_full)
  parameter_full <- gsub("rimax","ri_max",parameter_full)
  
  parameter_print <- parameter
  parameter_print <- gsub("totaldivbdmn","Total RI loci",parameter_print)
  parameter_print <- gsub("mutationrate","Mutation rate",parameter_print)
  parameter_print <- gsub("qtlsd","Climate QTL Stdev",parameter_print)
  parameter_print <- gsub("divseln","RI loci",parameter_print)
  parameter_print <- gsub("delta","Delta",parameter_print)
  parameter_print <- gsub("\\bm\\b","Migration rate",parameter_print)
  parameter_print <- gsub("proportionbdm","Proportion BDM loci",parameter_print)
  parameter_print <- gsub("recombinationrate","Recombination rate",parameter_print)
  parameter_print <- gsub("rimax","RI fitness effect",parameter_print)
  
  #system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output2.pl | gzip > ../../../",iteration,".",parameter,".out2.txt.gz; cd ../../../analysis",sep=""))
  
  output2_purity <- read_tsv(paste("../",iteration,".",parameter,".out2.txt.gz",sep="")) %>%
    filter(stat == "purity") %>%
    group_by(filename) %>%
    summarize(starting_purity = score[which(version == "start")],
              control_purity_change =  score[which(version == "control")] -  score[which(version == "start")],
              test_purity_change =  score[which(version == "test")] -  score[which(version == "start")],
              control_purity = score[which(version == "control")],
              test_purity = score[which(version == "test")]) %>%
    separate(.,filename,parameters,"_",remove=F) %>% 
    group_by(.dots=parameter) %>% 
    top_n(.,(100),seed) 
    
  output2_ri<- read_tsv(paste("../",iteration,".",parameter,".out2.txt.gz",sep="")) %>%
    filter(stat == "div_count" | stat == "bdm_count") %>%
    group_by(filename, version,type) %>%
    summarize(ri_count =  sum(score)) %>%
    separate(.,filename,parameters,"_",remove=F) %>% 
    mutate(fitness_effect = (1-as.numeric(rimax)/as.numeric(totaldivbdmn))^ri_count) %>%
    group_by(filename, version) %>%
    summarize(rel_fitness = ((fitness_effect[which(type == "home")])/
                            fitness_effect[which(type == "away")])) %>%
    group_by(filename) %>% 
    summarize(rel_fitness_change_control = (rel_fitness[which(version == "control")]-1)/(rel_fitness[which(version == "start")]-1),
              rel_fitness_change_test = (rel_fitness[which(version == "test")]-1)/(rel_fitness[which(version == "start")]-1),
              rel_fitness_control = rel_fitness[which(version == "control")],
              rel_fitness_test = rel_fitness[which(version == "test")]) %>%
    separate(.,filename,parameters,"_",remove=F) %>%
    group_by(.dots=parameter) %>% 
    top_n(.,(100),seed)
    
    

  #pdf( paste("../",iteration,".",parameter,".out2.pdf",sep=""))

  plot_dot <- output2_purity %>% 
    mutate_("parameter_chosen" = parameter) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    gather(., condition, introgression, control_purity_change:test_purity, factor_key=TRUE)  %>%
    filter(condition != "control_purity_change", condition != "test_purity_change") %>%
    droplevels(.$condition) %>%
    group_by(parameter_chosen,condition) %>%
    do(data.frame(t(quantile(.$introgression, probs = c(0.025,0.50, 0.975))))) %>%
    rename(bottom = X2.5., mid = X50., top =X97.5.) %>%    
    ggplot(.,aes()) + 
    geom_ribbon(aes(x=parameter_chosen,ymin=(1-bottom),ymax=(1-top),fill=condition),alpha=0.5) +
    geom_line(aes(x=parameter_chosen,y=(1-mid),linetype=condition),alpha=0.4,size=0.7) +
    scale_fill_manual(values=c("light grey","dark grey"),
                      name = "Treatment", labels = c("Control","Climate change")) +
    scale_linetype_manual(values=c("solid","dotted"),name = "Treatment", labels = c("Control","Climate change")) +

    theme_few() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
    xlab(parameter_print) +
    ylab("Introgression") +
    labs(tag = letters[n]) + 
    geom_hline(yintercept=0.5,linetype="dashed") 
  
  plots[[n]] <- plot_dot
  
  plot_dot_RI <- output2_ri %>% 
    mutate_("parameter_chosen" = parameter) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    gather(., condition, RI_retained, rel_fitness_change_control:rel_fitness_test, factor_key=TRUE)  %>%
    filter(condition != "rel_fitness_change_control", condition != "rel_fitness_change_test") %>% 
    droplevels(.$condition) %>%
    mutate(starting_RI_loci = (as.numeric(totaldivbdmn)*(1-as.numeric(proportionbdm)))+
             (as.numeric(totaldivbdmn)*as.numeric(proportionbdm)),
           starting_RI_away = (1-(as.numeric(rimax)/as.numeric(totaldivbdmn)))^starting_RI_loci,
           starting_RI = 1/starting_RI_away) %>% 
    group_by(parameter_chosen,condition,starting_RI) %>%
    do(data.frame(t(quantile(.$RI_retained, probs = c(0.025,0.50, 0.975))))) %>%
    rename(bottom = X2.5., mid = X50., top =X97.5.)  %>%
      ggplot(.,aes()) + 
      geom_ribbon(aes(x=parameter_chosen,ymin=bottom,ymax=top,fill=condition),alpha=0.5) +
      geom_line(aes(x=parameter_chosen,y=mid,linetype=condition),alpha=0.4,size=0.7) +
      scale_fill_manual(values=c("light grey","dark grey"),
                        name = "Treatment", labels = c("Control","Climate change")) +
      scale_linetype_manual(values=c("solid","dotted"),name = "Treatment", labels = c("Control","Climate change"))  +
      
    geom_line(aes(x=parameter_chosen,y=starting_RI),color="black",size=0.5,linetype="dashed") +
      theme_few() +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
    xlab(parameter_print) +
    ylab("RI") +
    labs(tag = letters[n]) 
    #coord_cartesian(ylim=c(1,6))
  
  plots_RI[[n]] <- plot_dot_RI
  
  
  
}

# extract the legend
# modified from stackoverflow
grid_arrange_shared_legend <- function(plots) {
  
  g <- ggplotGrob(plots[[1]] + theme(legend.position = "bottom"))$grobs
  
  legend <- g[[which(sapply(g, function(x) x$name) == "guide-box")]]
  lheight <- sum(legend$height)
  
  grid.arrange(
    do.call(arrangeGrob, lapply(plots, function(x)
      x + theme(legend.position = "none"))),
    legend,
    ncol = 1,
    heights = unit.c(unit(1, "npc") - lheight, lheight))
  
}


pdf(paste("../figures/",iteration,".points.out2.pdf",sep=""),width=9,height=9)

grid_arrange_shared_legend(plots)

dev.off()

pdf(paste("../figures/",iteration,".points.out2RI.pdf",sep=""),width=9,height=9)

grid_arrange_shared_legend(plots_RI)

dev.off()
  