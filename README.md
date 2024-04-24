# SMALLER-shiny

## Description

This repo contains the front-end for the SMALLER dashboard to be run on Pivot's AWS Shiny-Server at https://smaller.pivot-dashboard.org.

## System Requirements

- R v. 4.3.1 or above
- 16 GB of RAM
- 20 MB of hard-drive space

The following R packages are required:

```
c('leaflet', 'lubridate', 'dplyr', 'attempt', 'DT', 'glue', 'golem', 'htmltools', 'pkgload', 'plotly', 'scales', 'sf', 'shinyWidgets', 'stringr', 'tidyr', 'rmarkdown', 'reactable', "shiny")
```

If you would like to to deploy this shiny app, rather than running it locally, you can follow the [instructions here](https://shiny.posit.co/r/articles/share/deployment-web/) for installing `shiny-server` or using another type of deployment.

The AWS server hosting the SMALLER dashboard has the following specifications:

```
OS : Ubuntu 20.04.6 LTS
Processor : Intel(R) Xeon(R) Platinum 8259 CL CPU @ 2.50 GHz
Number of Physical Processors : 1
Cores : 4
Threads : 8
RAM : 32387624 KB (30 Gb)
Motherboard : Amazon EC2 m5.2xlarge
```

And the following R version:

```
platform       x86_64-pc-linux-gnu         
arch           x86_64                      
os             linux-gnu                   
system         x86_64, linux-gnu           
status                                     
major          4                           
minor          0.4                         
year           2021                        
month          02                          
day            15                          
svn rev        80002                       
language       R                           
version.string R version 4.0.4 (2021-02-15)
nickname       Lost Library Book     
```

## Installation Guide

The repo can be installed via cloning. The required R packages can be installed via the command line:

```
sudo su - \
        -c "R -e \"install.packages(c('shiny', 'leaflet', 'lubridate', 'dplyr', 'attempt', 'DT', 'glue', 'golem', 'htmltools', 'pkgload', 'plotly', 'scales', 'sf', 'shinyWidgets', 'stringr', 'tidyr', 'rmarkdown', 'reactable'), repos='http://cran.rstudio.com/')\""
```

## Usage

There are several ways to launch the shiny app:

### Via R Studio

Open either the `server.R` or `ui.R` files in RStudio. Click the 'Run App' button or type `shiny::runApp()` in the console. The app will be hosted at `127.0.0.1` and a window with the app will automatically open.

### Via the command line

From within the `smaller-shiny` directory, run the following:

```
R -e 'shiny::runApp()'
```

This will open R and launch the app. The console will print the port at which the app is available, such as `127.0.0.1:6354`. Copy this address and paste it into a web browser (such as Firefox) to view the app.


## Monthly Update

### Updating the Data

The disease predictions come from a repo that contains the service for the backend. It is located at `https://gitlab.com/pivot-sci-apps/smaller-backend`. Currently the data located in the `output` folder needs to be copied and moved into the `data/dynamic` folder in this repo. The static data does not need to be updated and is located in the `data/static` folder.

If both repos are in the same parent directory, the following code will copy the backend output to this repo (to be run within the `smaller-shiny` working directory): 

`cp -rv ../smaller-backend/output/. data/dynamic`

### Updating the data on AWS server via gilab commits

1. Log-into server. Shiny app is located at `/srv/shiny-server/smaller`
2. Pull changes into this github repo
3. Test locally by going to `IP Address:3838/smaller` in the browser. Logs are printed into `/var/log/shiny-server`
4. If it doesn't work, revert to prior commit.

## Support

Contact [Michelle Evans](mailto:mv.evans.phd@gmail.com) with questions.

## License

GPL-3+