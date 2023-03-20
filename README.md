
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dePlzMap

<!-- badges: start -->
<!-- badges: end -->

The `dePlzMap` R package is a tool for visualizing data on a map of
Germany, using postal code (PLZ) boundaries as geographic units. It
provides a simple and flexible interface for creating [choropleth
maps](https://en.wikipedia.org/wiki/Choropleth_map) of PLZ regions in
Germany with continuous color scales, allowing users to explore spatial
patterns and relationships in data. The package includes the possibility
to normalize the input values by population per PLZ region to show
population-relative values. The package leverages the `ggplot2` and
`ggmap` libraries for generating the plots. The plots can be created via
the function `dePlzMap` which users can quickly generate informative
maps that highlight patterns in via R.

## Data

The population data is based on the data from the [“Registerzensus
2011”](https://www.zensus2011.de/DE/Home/Aktuelles/DemografischeGrunddaten.html?nn=559100)
of the Statistisches Bundesamt in Deutschland and was obtained from the
web site
[https://www.suche-postleitzahl.org](https://www.suche-postleitzahl.org/downloads).

The shape files that describe the borders of the PLZ regions have also
been drawn from
[https://www.suche-postleitzahl.org](https://www.suche-postleitzahl.org/downloads).

The shape data for the borders of the German states is from
<https://public.opendatasoft.com/>.

## Licensing

The geographic data used by the package is derived from
[OpenStreetMap](https://www.openstreetmap.org/) and uses the [Open
Database License](https://opendatacommons.org/licenses/odbl/) (©
OpenStreetMap contributors).

The population data is copyrighted by Statistisches Bundesamt 2014,
which allows the distribution, also in parts, if the source is
specified.

Apart from the data, the package is licensed under the MIT license (©
Stefan Lenz 2023).

## Installation

You can install the `dePlzMap` package from
[GitHub](https://github.com/) in R via:

``` r
# install.packages("devtools")
devtools::install_github("stefan-m-lenz/dePlzMap")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(dePlzMap)
## basic example code
```

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.