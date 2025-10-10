#!/usr/bin/env Rscript

start_time <- proc.time()

options(
  repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"),
  pak.upgrade = TRUE
)

install.packages('pak')
pak::pkg_install(c(
  'ragg', 'tidyverse', 'gt', 'ggtext', 'ggsci', 'here','devtools',
  'drc', 'kable'
))

pak::pak(c('shubhamdutta26/sdtools'))

end_time <- proc.time()
elapsed <- end_time - start_time
cat(
  sprintf(
    "Elapsed time: %02d:%02d:%02.1f (h:m:s)\n",
    as.integer(elapsed[3] %/% 3600),
    as.integer((elapsed[3] %% 3600) %/% 60),
    elapsed[3] %% 60
  )
)
