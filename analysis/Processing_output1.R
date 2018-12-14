library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)

###Measuring introgression
iteration <- "nov20"
#Not run divseln
parameter <- "qtlsd"
parameters_tested <- c("totaldiv","delta","mutationrate","qtlsd","m","divseln")

plots <- list()
for (n in 1:length(parameters_tested)){
  parameter <- parameters_tested[n]
  parameters <- colnames(read_tsv("../parameter_file.txt"))
  parameters <- c("blank","target_param",parameters,"tail")
  parameter_full <- parameter
  parameter_full <- gsub("totaldiv","total_div",parameter_full)
  parameter_full <- gsub("mutationrate","mutation_rate",parameter_full)
  parameter_full <- gsub("qtlsd","qtl_sd",parameter_full)
  parameter_full <- gsub("divseln","div_sel_n",parameter_full)
  
  parameter_print <- parameter
  parameter_print <- gsub("totaldiv","Total divergent selection",parameter_print)
  parameter_print <- gsub("mutationrate","Mutation rate",parameter_print)
  parameter_print <- gsub("qtlsd","QTL Stdev",parameter_print)
  parameter_print <- gsub("divseln","RI loci",parameter_print)
  parameter_print <- gsub("delta","Delta",parameter_print)
  parameter_print <- gsub("m","Migration rate",parameter_print)
  
  
  #system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output1.pl | gzip > ../../../",iteration,".",parameter,".out1.txt.gz; cd ../../../analysis",sep=""))
  
  output1 <- read_tsv(paste("../",iteration,".",parameter,".out1.txt.gz",sep="")) %>%
    separate(.,filename,parameters,"_") %>%  
    group_by(.dots=parameter_full) %>% 
    top_n(.,(198*100),seed)
  
  #pdf( paste("../",iteration,".",parameter,".out1.pdf",sep=""))

    plot_curve <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter_full) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
      group_by(parameter_chosen,gen) %>%
      summarize(mean_mean_haldane = mean(mean_haldane)) %>% 
      ggplot(.,aes(x=gen,y=mean_mean_haldane,group=parameter_chosen,color=as.numeric(parameter_chosen))) + 
      geom_line(alpha=0.5,size=2) + theme_few() + 
      scale_color_distiller(palette = "Spectral",name=paste(parameter_print)) +
      ylab("Average Haldanes") + xlab("Generation")   +
      theme(legend.position="bottom") +
      labs(tag = LETTERS[n])

    
    plots[[2*n-1]] <- plot_curve

    plot_point <- output1 %>% 
      filter(version == "test") %>%
      mutate_("parameter_chosen" = parameter_full) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
      group_by(seed, parameter_chosen) %>%
      summarize(mean_haldane = mean(mean_haldane)) %>%
      ggplot(.,aes(x=as.numeric(parameter_chosen),y=mean_haldane)) + 
      geom_point(alpha=0.2) + theme_few() + 
      ylab("Average Haldanes") + xlab(paste(parameter_print)) +
      labs(tag = LETTERS[n])
    
    plots[[2*n]] <- plot_point
  
  #dev.off()
  
}

pdf(paste("../figures/",iteration,".haldanecurves.out1.pdf",sep=""),width=12,height=6)
grid.arrange( plots[[1]],plots[[3]],
              plots[[5]],plots[[7]],
              plots[[9]],plots[[11]],
             # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,2,3),
                                    c(4,5,6)))
dev.off()

pdf(paste("../figures/",iteration,".haldanepoint.out1.pdf",sep=""),width=12,height=6)

grid.arrange( plots[[2]],plots[[4]],
              plots[[6]],plots[[8]],
              plots[[10]],plots[[12]],
              # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,2,3),
                                    c(4,5,6)))
dev.off()
