# ICCAT `maps` `public` library

A set of reference data and functions to produce geospatial maps of the Atlantic and Mediterranean area, with the possibility of producing pie charts and heatmap plots for CATDIS data.  

This library is meant for public usage, and for this reason it does not have dependencies from the (development) ICCAT libraries that provide access to the databases.
Nevertheless, the script (not exported with the library) that updates the reference data tables comes indeed with a direct dependency from the [iccat.dev.base](https://github.com/stats-ICCAT/iccat.dev.base) library. 

## Artifacts that can be produced using the map-specific functions provided by the library

1) Default *dataless* Atlantic maps
  + [Base maps](#default-empty-atlantic-map)
  + Species' [stock maps](#albacore-tuna-stocks-map)
  + Species' [sampling area maps](albacore-tuna-stocks-and-sampling-areas-map)
     
2) CATDIS maps
  + Pie chart maps of [catch data categorised by gear](#albacore-catdis-data-piemap-by-gear-1993-2022-with-iccat-convention-area-boundaries)
  + Pie chart maps of [catch data categorised by school type]()
  + Heatmaps of [catch data magnitude](#albacore-baitboat-catdis-data-heatmap-1993-2022-with-iccat-convention-area-boundaries)
    
## Reference data artifacts exported by the library <a name="reference_data"></a>

Each of the following artifacts (hereby referenced by their object name) represents the content (as an R `data.table`) of a reference data table included in one of the ICCAT databases (generally, `DATABASE_T1`) with standardized column names.

+ `SPECIES_TO_AREAS_MAPPINGS`
+ `STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES`
+ `ATLANTIC_OCEAN_RAW_GEOMETRY`
+ `GRIDS_5x5_RAW_GEOMETRIES`

All these objects should be properly described within the [`R\data.R`](https://github.com/stats-ICCAT/iccat.pub.maps/blob/main/R/data.R) file and explicitly exported to be visible to the library consumers.

E.g.,: 

![image](https://github.com/user-attachments/assets/0fa2d514-ba2f-432d-8df9-ba8fc49c7b3a)

> See each exported item for its description and structure

## External dependencies (CRAN) <a name="external_deps"></a>
+ `ggplot2`
+ `ggnewscale`
+ `colorspace`
+ `scales`
+ `sf`
+ `maps`
+ `mapdata`
+ `mapplotsr`
+ `scatterpie`

### Installation
```R
install.packages(c("ggplot2", "ggthemes", "ggnewscale", "colorspace", "scales", "sf", "maps", "mapdata", "mapplots", "scatterpie"))
```

## Internal dependencies <a name="internal_deps"></a>
+ [iccat.pub.data](https://github.com/stats-ICCAT/iccat.pub.data)
+ [iccat.pub.aes](https://github.com/stats-ICCAT/iccat.pub.aes)
+ [iccat.dev.base](https://github.com/stats-ICCAT/iccat.dev.base) [`OPTIONAL`]
+ [iccat.dev.data](https://github.com/stats-ICCAT/iccat.dev.data) [`OPTIONAL`]

The optional dependency is only required if we need to update the reference data. In this case, please ensure to follow the steps for the installation of all internal / external requirements for the `iccat.dev.data` and `iccat.dev.base` libraries as available [here](https://github.com/stats-ICCAT/iccat.dev.data/?tab=readme-ov-file#external-dependencies-cran-).

# Updating the reference data

This repository also includes a script ([`data-raw\initialize_reference_data.R`](https://github.com/stats-ICCAT/iccat.pub.maps/blob/main/data-raw/initialize_reference_data.R)) which takes care - when explicitly executed - of extracting reference data from the standard ICCAT databases and update the exported [reference data objects](#reference_data).
The script is **not** exported with the library, requires loading the `iccat.dev.base` library, and can be run only by users that have read access to the ICCAT databases.

This script needs to be extended every time a new reference data is added to the list, and the [`R\data.R`](https://github.com/stats-ICCAT/iccat.pub.data/blob/main/R/data.R) script should then be updated accordingly, to include the new object to be exported, and describe its content.

Updates to the reference data shall be performed *before* building the library, otherwise the updated artifacts will not be included in the package.

# Installing the library from GitHub
1) Ensure that all dependencies (both [external](#external_deps) and [internal](#internal_deps)) are installed
2) Ensure that the `devtools` package is installed, if not, execute the following:
```R
install.packages("devtools")
```
3) Once `devtools` is available, execute the following:
```R
library(devtools)

install_github("stats-ICCAT/iccat.pub.maps", dependencies = FALSE)
```

# Building the library
Assuming that all [external](#external_deps) and [internal](#internal_deps) dependencies are already installed in the R environment, and that the `devtools` package and [RTools](https://cran.r-project.org/bin/windows/Rtools/) are both available, the building process can be either started within R studio by selecting the Build > Build Source Package menu entry:

![image](https://github.com/user-attachments/assets/f209d8d4-568c-4200-bcf2-fb1fa0e1d2ef)

or by executing the following statement:

```R
devtools::document(roclets = c('rd', 'collate', 'namespace'))
```

## Usage examples

### Loading the library

For the examples to work, the following statement should be executed once per session:
```R
library(iccat.pub.maps)
```

### *Dataless* Atlantic maps

#### Default empty Atlantic map
```R
map.atlamtic()
```
![image](https://github.com/user-attachments/assets/760c8a30-2e78-4939-be77-a615072b8577)

#### Default empty Atlantic map zoomed on the Mediterranean
```R
map.atlantic(xlim = c(-5, 40), ylim = c(25, 50))
```
![image](https://github.com/user-attachments/assets/418d3848-0c36-4c0a-8f54-bc03566ce94d)

#### Default empty Atlantic map showing the ICCAT area of competence 
```R
ATLANTIC_OCEAN_SF = geometries_for(ATLANTIC_OCEAN_RAW_GEOMETRY, target_crs = CRS_EQUIDISTANT)

map.atlantic() +       # Initialises the base map
  geom_sf(             # Adds the ICCAT convention area simple feature
    ATLANTIC_OCEAN_SF, 
    mapping = aes(),   # with no data-specific aesthetics
    fill = "azure"     # and a azure fill color
  ) +
  map.coordinates_sf(target_crs = CRS_EQUIDISTANT) # Forces the coordinate system to CRS to ensure all layers are displayed
```
![image](https://github.com/user-attachments/assets/48d8fc3d-64fc-453e-9d9f-20aad0640947)

#### Default empty Atlantic map showing all 5x5 grids within the ICCAT area of competence 
```R
GRIDS_5x5_SF = geometries_for(GRIDS_5x5_RAW_GEOMETRIES, target_crs = CRS_EQUIDISTANT)

map.atlantic() +           # Initialises the base map
  geom_sf(                 # Adds the 5x5 grids simple features
    GRIDS_5x5_SF, 
    mapping = aes(),       # with no data-specific aesthetics
    fill = "transparent",  # a transparent fill color
    color = "blue"         # and a blue outline color
  ) +
  map.coordinates_sf(target_crs = CRS_EQUIDISTANT) # Forces the coordinate system to CRS to ensure all layers are displayed
```
![image](https://github.com/user-attachments/assets/6ee08861-0b4e-435b-b530-249f75445135)

#### Albacore tuna stocks map
```R
map.stocks("ALB")
```
![image](https://github.com/user-attachments/assets/12f497ab-103f-42e1-b895-c9f95d49e61d)

#### Albacore tuna stocks and sampling areas map
```R
map.stocks("ALB", stock_codes = c("ALB-N", "ALB-M", "ALB-S"))
```
![image](https://github.com/user-attachments/assets/0e196449-0d9c-47a5-9946-c7d39846a9cc)

#### Albacore tuna stocks and sampling areas map (contours only, no labels)
```R
map.stocks("ALB", stock_codes = c("ALB-N", "ALB-M", "ALB-S"), fill_areas = FALSE, add_labels = FALSE)
```
![image](https://github.com/user-attachments/assets/66be1f35-6893-4693-afc1-16ae5cc3ef36)

### CATDIS maps

> To run these examples we assume that the `CATDIS_current` object contains all CATDIS data as retrieved using the `iccat.dev.data::catdis` function.

#### Albacore CATDIS data piemap by gear (1993-2022) with ICCAT convention area boundaries
```R
# CATDIS_current = catdis() # Requires access to the iccat.dev.data library

ATLANTIC_OCEAN_SF = geometries_for(ATLANTIC_OCEAN_RAW_GEOMETRY, target_crs = CRS_EQUIDISTANT)

ICCAT_AREA =
  map.atlantic() +        # Initialises the base map
  geom_sf(                # Adds the ICCAT competence area simple feature
    ATLANTIC_OCEAN_SF,    
    mapping = aes(),      # with no data-specific aesthetics
    fill = "transparent", # a transparent fill color
    color = "darkgrey"    # and a dark grey outline color
  ) + 
  map.coordinates_sf(target_crs = CRS_EQUIDISTANT) # Forces the coordinate system to CRS to ensure all layers are displayed

map.pie.catdis.gear(catdis_data = CATDIS_current[SpeciesCode == "ALB" & YearC >= 1993], base_map = ICCAT_AREA)
```
![image](https://github.com/user-attachments/assets/1c949340-6919-4165-9642-f99e5518f615)

#### Albacore CATDIS data piemap by gear (1993-2022) limited to `LL` and `BB`
```R
# CATDIS_current = catdis() # Requires access to the iccat.dev.data library

map.pie.catdis.gear(catdis_data = CATDIS_current[SpeciesCode == "ALB" & YearC >= 1993], gears_to_keep = c("LL", "BB"))
```
![image](https://github.com/user-attachments/assets/e802ec85-8f41-4f2a-9eed-73f04df5f230)

#### Tropical tunas CATDIS data piemap by school type (1993-2022)
```R
# CATDIS_current = catdis() # Requires access to the iccat.dev.data library

map.pie.catdis.schooltype(catdis_data = CATDIS_current[SpeciesCode %in% c("BET", "SKJ", "YFT") & YearC >= 1993])
```
![image](https://github.com/user-attachments/assets/de9cc4a0-8e5c-47d3-a5f9-b0e6a24da1bc)

#### Albacore baitboat CATDIS data heatmap (1993-2022) with ICCAT convention area boundaries
```R
ATLANTIC_OCEAN_SF = geometries_for(ATLANTIC_OCEAN_RAW_GEOMETRY, target_crs = CRS_EQUIDISTANT)

ICCAT_AREA =
  map.atlantic() +        # Initializes the base map
  geom_sf(                # Adds the ICCAT competence area simple feature
    ATLANTIC_OCEAN_SF,       
    mapping = aes(),      # with no data-specific aesthetics
    fill = "transparent", # a transparent fill color
    color = "darkgrey"    # and a dark grey outline color
  ) + 
  map.coordinates_sf(target_crs = CRS_EQUIDISTANT) # Forces the coordinate system to CRS to ensure all layers are displayed

map.heat.catdis(catdis_data = CATDIS_current[SpeciesCode == "ALB" & YearC >= 1993], gear = "BB", base_map = ICCAT_AREA)
```
![image](https://github.com/user-attachments/assets/2e3fa54e-6766-434a-92e2-7d21fcf96aba)

## Future extensions
+ [ ] improve the way in which additional `geom_sf` layers are included in the map outputs
+ [ ] standardize functions' signatures for CATDIS piemaps and heatmaps  
