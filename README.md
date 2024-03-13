# SMALLER-shiny

Front-end for SMALLER dashboard to be run on Pivot's AWS Shiny-Server at https://smaller.pivot-dashboard.org

Currently contains only the results of the statistical model, but will eventually also have the dynamic model as well.

## Set-up

### Shiny server

The packages needed for this application must be on the server that contains the shiny app. Eventually, I'd like this to work using docker and renv, but this is our workaround for now.

Code to install packages on shiny-server:

```
sudo su - \
        -c "R -e \"install.packages(c('leaflet', 'lubridate', 'dplyr', 'attempt', 'DT', 'glue', 'golem', 'htmltools', 'pkgload', 'plotly', 'scales', 'sf', 'shinyWidgets', 'stringr', 'tidyr', 'rmarkdown', 'reactable'), repos='http://cran.rstudio.com/')\""
```

### Data

The disease predictions come from a repo that contains the service for the backend. It is located at `https://gitlab.com/pivot-sci-apps/smaller-backend`. Currently the data located in the `output` folder needs to be copied and moved into the `data/dynamic` folder in this repo. The static data does not need to be updated and is located in the `data/static` folder.

Code to do this given the current folder architecture to be run within the `smaller-shiny` wd.

`cp -rv ../smaller-backend/output/. data/dynamic`

### Migration to Server

1. Log-into server. Shiny app is located at `/srv/shiny-server/smaller`
2. Pull changes into this github repo
3. Test locally by going to `IP Address:3838/smaller` in the browser. Logs are printed into `/var/log/shiny-server`
4. If it doesn't work, revert to prior commit.

# Contact

Contact [Michelle Evans](mailto:mv.evans.phd@gmail.com) with questions.

# License

GPL-3+