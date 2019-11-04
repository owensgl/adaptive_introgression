library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)

###Measuring introgression
iteration <- "june2019"
#Not run divseln
parameter <- "qtlsd"
parameters_tested <- c("qtlsd","delta","m","mutationrate", "proportionbdm","recombinationrate","rimax","totaldivbdmn")

plots <- list()
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
  parameter_print <- gsub("qtlsd","Climate QTL s.d.",parameter_print)
  parameter_print <- gsub("divseln","RI loci",parameter_print)
  parameter_print <- gsub("delta","Delta",parameter_print)
  parameter_print <- gsub("\\bm\\b","Migration rate",parameter_print)
  parameter_print <- gsub("proportionbdm","Proportion BDM loci",parameter_print)
  parameter_print <- gsub("recombinationrate","Recombination rate",parameter_print)
  parameter_print <- gsub("rimax","RI fitness effect",parameter_print)
  
  
  
  #system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output1.pl | gzip > ../../../",iteration,".",parameter,".out1.txt.gz; cd ../../../analysis",sep=""))
  
  output1 <- read_tsv(paste("../",iteration,".",parameter,".out1.txt.gz",sep="")) %>%
    separate(.,filename,parameters,"_") %>%  
    group_by(.dots=parameter) %>% 
    top_n(.,(198*100),seed)
  
  #pdf( paste("../",iteration,".",parameter,".out1.pdf",sep=""))
  
  if (parameter == "rimax"){
    plot_curve <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)/as.numeric(totaldivbdmn)) %>%
      group_by(parameter_chosen,gen) %>%
      summarize(mean_mean_haldane = mean(mean_haldane)) %>% 
      ggplot(.,aes(x=gen,y=mean_mean_haldane,group=parameter_chosen,color=as.numeric(parameter_chosen))) + 
      geom_line(alpha=0.5,size=2) + theme_few() + 
      scale_color_distiller(palette = "Spectral",name=paste(parameter_print)) +
      ylab("Average Haldanes") + xlab("Generation")   +
      theme(legend.position="bottom") +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
      labs(tag = LETTERS[n])
  }
  plot_curve <- output1 %>% 
    filter(version == "test") %>%
    mutate_("parameter_chosen" = parameter) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    group_by(parameter_chosen,gen) %>%
    summarize(mean_mean_haldane = mean(mean_haldane)) %>% 
    ggplot(.,aes(x=gen,y=mean_mean_haldane,group=parameter_chosen,color=as.numeric(parameter_chosen))) + 
    geom_line(alpha=0.5,size=2) + theme_few() + 
    scale_color_distiller(palette = "Spectral",name=paste(parameter_print)) +
    ylab("Average Haldanes") + xlab("Generation")   +
    theme(legend.position="bottom") +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
    labs(tag = LETTERS[n])
  
  
  plots[[2*n-1]] <- plot_curve
  if (parameter == "rimax"){
    plot_point <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)/as.numeric(totaldivbdmn)) %>%
      group_by(seed, parameter_chosen) %>%
      summarize(mean_haldane = mean(mean_haldane)) %>%
      group_by(parameter_chosen) %>%
      do(data.frame(t(quantile(.$mean_haldane, probs = c(0.025,0.50, 0.975))))) %>%
      rename(bottom = X2.5., mid = X50., top =X97.5.) %>%
      ggplot(.,aes()) + 
      geom_ribbon(aes(x=parameter_chosen,ymin=bottom,ymax=top),alpha=0.5) +
      geom_line(aes(x=parameter_chosen,y=mid),alpha=0.4,size=0.7) +
      theme_few() +
      ylab("Average Haldanes") + xlab(paste(parameter_print)) +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
      labs(tag = letters[n])
  }else if (parameter == "mutationrate"){
    plot_point <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)*10^7) %>%
      group_by(seed, parameter_chosen) %>%
      summarize(mean_haldane = mean(mean_haldane)) %>%
      group_by(parameter_chosen) %>%
      do(data.frame(t(quantile(.$mean_haldane, probs = c(0.025,0.50, 0.975))))) %>%
      rename(bottom = X2.5., mid = X50., top =X97.5.) %>%
      ggplot(.,aes()) + 
      geom_ribbon(aes(x=parameter_chosen,ymin=bottom,ymax=top),alpha=0.5) +
      geom_line(aes(x=parameter_chosen,y=mid),alpha=0.4,size=0.7) +
      theme_few() +
      ylab("Average Haldanes") + 
      xlab(bquote('Mutation rate ('*x~ 10^-7*')')) +
      labs(tag = letters[n])
  }else if (parameter == "recombinationrate"){
    plot_point <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)*10^5) %>%
      group_by(seed, parameter_chosen) %>%
      summarize(mean_haldane = mean(mean_haldane)) %>%
      group_by(parameter_chosen) %>%
      do(data.frame(t(quantile(.$mean_haldane, probs = c(0.025,0.50, 0.975))))) %>%
      rename(bottom = X2.5., mid = X50., top =X97.5.) %>%
      ggplot(.,aes()) + 
      geom_ribbon(aes(x=parameter_chosen,ymin=bottom,ymax=top),alpha=0.5) +
      geom_line(aes(x=parameter_chosen,y=mid),alpha=0.4,size=0.7) +
      theme_few() +
      ylab("Average Haldanes") + 
      xlab(bquote('Recombination rate ('*x~ 10^-5*')')) +
      labs(tag = letters[n])
  }else{
    plot_point <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
      group_by(seed, parameter_chosen) %>%
      summarize(mean_haldane = mean(mean_haldane)) %>%
      group_by(parameter_chosen) %>%
      do(data.frame(t(quantile(.$mean_haldane, probs = c(0.025,0.50, 0.975))))) %>%
      rename(bottom = X2.5., mid = X50., top =X97.5.) %>%
      ggplot(.,aes()) + 
      geom_ribbon(aes(x=parameter_chosen,ymin=bottom,ymax=top),alpha=0.5) +
      geom_line(aes(x=parameter_chosen,y=mid),alpha=0.4,size=0.7) +
      theme_few() +
      ylab("Average Haldanes") + xlab(paste(parameter_print)) +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1)) +
      labs(tag = letters[n])
  }
  
  plots[[2*n]] <- plot_point
  
  #dev.off()
  
}

pdf(paste("../figures/",iteration,".haldanecurves.out1.pdf",sep=""),width=12,height=12)
grid.arrange( plots[[1]],plots[[3]],
              plots[[5]],plots[[7]],
              plots[[9]],plots[[11]],
              plots[[13]],plots[[15]],
             # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
             layout_matrix = rbind(c(1,2),
                                   c(3,4),
                                   c(5,6),
                                   c(7,8)))
dev.off()

pdf(paste("../figures/",iteration,".haldanepoint.out1.pdf",sep=""),width=9,height=9)

grid.arrange( plots[[2]],plots[[4]],
              plots[[6]],plots[[8]],
              plots[[10]],plots[[12]],
              plots[[14]],plots[[16]],
              # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,2,3),
                                    c(4,5,6),
                                    c(7,8,NA)))
dev.off()
