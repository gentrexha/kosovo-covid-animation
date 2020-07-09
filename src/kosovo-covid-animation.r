library(gifski)
library(readr)
library(dplyr)
library(rgdal)
library(ggplot2)
library(maps)
library(ggthemes)
library(gganimate)
library(hablar)
library(mapproj)
library(scales)
library(RColorBrewer)
library(ggmap)
library(transformr)
library(magick)

# set wd
setwd("C:/Projects/Personal/kosovo-covid-data/src/")

# Load data
url_csv <- "../data/covid-komunat.csv"
ks_pop <- read_csv(url_csv)

# Set map
shapefile <- readOGR(dsn = path.expand("../data/kosovo-shapefile"), 
    "XK_EA_2018", use_iconv = TRUE, encoding = "UTF-8")

# Next the shapefile has to be converted to a dataframe for
# use in ggplot2
shapefile_df <- fortify(shapefile, name = "XK_NAME")

# Adding id to each row
#id_map <- data.frame(id = c(0:39), komuna = shapefile$XK_NAME, 
#    stringsAsFactors = FALSE)
#write.csv(id_map, "id_map.csv")

# Add id to ks_pop, right?
merged_df <- merge(shapefile_df, ks_pop, by = "id", all.x = TRUE)
final_df <- merged_df[order(merged_df$order), ]

# aggregate data to get mean latitude and mean longitude for
# each state
cnames <- aggregate(cbind(long, lat) ~ komuna, data = final_df, 
    FUN = function(x) mean(range(x)))

# modify some lats for better text placement
# Gjilan
cnames$lat[7] = 42.40343 + 0.05
# Viti
cnames$lat[34] = 42.33861 - 0.04
# Lipjan
cnames$lat[17] = 42.53470 - 0.03

# new cpalette
#getPalette = colorRampPalette(brewer.pal(9, "Greens"))

# custom palette
new.levels <- c(-1, 0,   10,   20,   30,  40,   50, 60, 70, 80, 90)
#new.levels <- c(90,80,70,60,50,40,30,20,10,0,-1)
new.labels <- c('0', '1 - 10',    '10 - 20',   '20 - 30',   '30 - 40',
                      '40 - 50', '50 - 60', '60 - 70', '70 - 80',
                      '80 - 90')
#new.labels <- c('90-80', '80-70', '70-60','60-50',   '50-40',   '40-30',
#                '30-20', '20-10', '10-1', '0')
colfunc <- colorRampPalette(c('#ffffff', '#fee0d2','#fc9272', '#de2d26'))
colfunc <- colorRampPalette(c('#fff5f0','#fee0d2','#fcbba1','#fc9272','#fb6a4a','#ef3b2c','#cb181d','#a50f15','#67000d'))
new.colors <- colfunc(10)
names(new.colors) <- new.labels
final_df$new.fc <- factor(
    cut(final_df$new, new.levels),
    labels = new.labels
)

# test plot
ggplot() + 
    geom_polygon(data = final_df[which(final_df$date == "2020-07-08"), ], 
                 aes(x = long, y = lat, group = group, fill = new.fc), 
                 color = "black", size = 0.4) + 
    coord_map() + 
    labs(title = "Raste të reja të COVID-19 (08.07.2020)",
         caption = "Burimi: Gent Rexha | Te Dhenat: IKSHPK",
         subtitle = "Sipas komunave në Kosovë") + 
    scale_fill_manual(element_blank(),
                      values = new.colors, drop=FALSE) + 
    geom_text(data = cnames, aes(long, lat, label = komuna), size = 3, fontface = "bold") + 
    theme_void() +
    theme(text=element_text(family='Rubik'),
          plot.title=element_text(face='bold'),
          plot.subtitle=element_text(size=8),
          plot.caption=element_text(size=6, hjust = 1.3),
          legend.margin=margin(t=-0.6, r=0, b=-0, l=0, unit='cm'))

ggplot2::ggsave("../figures/test/yesterday.png", dpi=120)

# basic plot
ggplot() + 
    geom_polygon(data = final_df[which(final_df$date == "2020-07-08"), ], 
                 aes(x = long, y = lat, group = group, fill = new), 
                 color = "#4c4c4c", size = 0.4) + 
    coord_map() + 
    labs(title = "Raste të reja të COVID-19 (08.07.2020)",
         caption = "Burimi: Gent Rexha © Te Dhenat: IKSHPK",
         subtitle = "Sipas komunave në Kosovë") + 
    scale_fill_distiller(name = "Rastë te reja", palette = "Reds", 
                         direction = 1, breaks = pretty_breaks(n = 7), 
                         limits = c(min(final_df$new, na.rm = TRUE), max(final_df$new, na.rm = TRUE))) + 
    geom_text(data = cnames, aes(long, lat, label = komuna), size = 3, fontface = "bold") + 
    theme_void() +
    theme(text=element_text(family='Rubik'),
          plot.title=element_text(face='bold'),
          plot.subtitle=element_text(size=8),
          plot.caption=element_text(size=6),
          legend.margin=margin(t=-0.6, r=0, b=-0, l=0, unit='cm'))
    

# Final plots
dates <- seq(as.Date("2020-06-18"), as.Date("2020-07-08"), 'days')

for (today in dates) {
    format(mean.Date(today), "%d.%m.%Y")
}

i <- 0
for (today in dates) {
    int_plot <- ggplot() + 
        geom_polygon(data = final_df[which(final_df$date == today), ], 
                     aes(x = long, y = lat, group = group, fill = new.fc), 
                     color = "black", size = 0.4) + 
        coord_map() + 
        labs(title = paste("Raste të reja të COVID-19 (", format(mean.Date(today), "%d.%m.%Y"), ")"),
             caption = "Burimi: Gent Rexha | Te Dhenat: IKSHPK",
             subtitle = "Sipas komunave në Kosovë") + 
        scale_fill_manual(element_blank(),
                          values = new.colors, drop=FALSE) + 
        geom_text(data = cnames, aes(long, lat, label = komuna), size = 3, fontface = "bold") + 
        theme_void() +
        theme(text=element_text(family='Rubik'),
              plot.title=element_text(face='bold'),
              plot.subtitle=element_text(size=8),
              plot.caption=element_text(size=6, hjust = 1.3),
              legend.margin=margin(t=-0.6, r=0, b=-0, l=0, unit='cm'))
        
    
    ggsave(sprintf("../figures/animation/%s_covid_%s.png", i, format(mean.Date(today), "%d.%m.%Y")), plot = int_plot, dpi=120)
    i <- i + 1
}


