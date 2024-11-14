# See: https://stackoverflow.com/questions/23252231/r-data-table-breaks-in-exported-functions
.datatable.aware = TRUE

#' Produces a map of a given species' stocks / sampling areas.
#'
#' If only species codes are provided, the result will be a map of all stock areas for the selected species.
#' If species codes *and* stock codes are provided, the result will be a map of the selected stock areas and of all sampling areas within them (for the selected species)
#'
#' @param species_codes a list of species codes
#' @param stock_codes a list of stock codes
#' @param base_map the base map to use
#' @param fill_areas whether or not stocks / sampling areas should be filled with their default color
#' @param add_labels whether or labels should be added to stocks / sampling areas
#' @param crs the Coordinate Reference System to use
#' @param background_plot_function an optional function used to initialize the background layer of the map
#' @return a map of the given species' stocks and / or sampling areas, depending on the provided parameters
#' @export
map.stocks = function(species_codes, stock_codes = NULL,
                      base_map = map.atlantic(),
                      fill_areas = TRUE, add_labels = TRUE,
                      crs = iccat.pub.maps::CRS_EQUIDISTANT,
                      background_plot_function = NULL) {

  show_sampling_areas = !is.null(stock_codes) & length(stock_codes) > 0

  stocks_for_species = SPECIES_TO_AREAS_MAPPINGS[SPECIES_CODE %in% species_codes]

  if(nrow(stocks_for_species) == 0)
    stop(paste0("Unable to identify any stock for [ ",
                paste(shQuote(species_codes, type = "sh"), collapse=", "), " / ",
                paste(shQuote(stock_codes,   type = "sh"), collapse=", "), " ]"))

  SA_colors =
    data.table(
      SAMPLING_AREA_CODE = unique(stocks_for_species[order(STOCK_CODE, SAMPLING_AREA_CODE)]$SAMPLING_AREA_CODE)
    )

  SA_colors$COLOR = hue_pal()(nrow(SA_colors))

  ST_colors =
    data.table(
      STOCK_AREA_CODE = unique(stocks_for_species[order(STOCK_CODE, SAMPLING_AREA_CODE)]$STOCK_CODE)
    )

  ST_colors$COLOR = hue_pal()(nrow(ST_colors))

  selected_stocks = stocks_for_species

  if(!is.null(stock_codes) & length(stock_codes) > 0) selected_stocks = stocks_for_species[STOCK_CODE %in% stock_codes]

  stock_areas    = geometries_for(STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES[CODE %in% unique(selected_stocks$STOCK_CODE)],
                                  target_crs = crs)
  sampling_areas = geometries_for(STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES[CODE %in% unique(selected_stocks$SAMPLING_AREA_CODE)],
                                  target_crs = crs)

  SA_colors = SA_colors[SAMPLING_AREA_CODE %in% selected_stocks$SAMPLING_AREA_CODE]

  map = base_map

  if(!is.null(background_plot_function)) {
    map = background_plot_function(map)

    map = map +
      new_scale_fill() +
      new_scale_colour()
  }

  if(show_sampling_areas) { # When showing sampling areas for a given stock
    if(fill_areas) map = map + geom_sf(data = sampling_areas, aes(fill = CODE, color = CODE), alpha = DEFAULT_AREA_FILL_ALPHA, linewidth = DEFAULT_BORDER_LINE_WIDTH) + scale_fill_manual(values = SA_colors$COLOR)
    else           map = map + geom_sf(data = sampling_areas, aes(             color = CODE), fill = "transparent",            linewidth = DEFAULT_BORDER_LINE_WIDTH)

    map = map + scale_color_manual(values = darken(SA_colors$COLOR, amount = DEFAULT_DARKENING_FACTOR)) +
      guides(
        fill  = guide_legend(title = "Sampling area", position = "top"),
        color = guide_legend(title = "Sampling area", position = "top")
      )

    if(add_labels)
      map = map + geom_sf_label(data = sampling_areas, mapping = aes(label = CODE, color = CODE), fill = "white", alpha = .7)
  } else { # When showing stock areas for a given species
    if(fill_areas) map = map + geom_sf(data = stock_areas, aes(fill = CODE, color = CODE), alpha = DEFAULT_AREA_FILL_ALPHA, linewidth = DEFAULT_BORDER_LINE_WIDTH) + scale_fill_manual(values = ST_colors$COLOR)
    else           map = map + geom_sf(data = stock_areas, aes(             color = CODE), fill = "transparent",            linewidth = DEFAULT_BORDER_LINE_WIDTH)

    map = map + scale_color_manual(values = darken(ST_colors$COLOR, amount = DEFAULT_DARKENING_FACTOR)) +
      guides(
        fill  = guide_legend(title = "Stock area", position = "top"),
        color = guide_legend(title = "Stock area", position = "top")
      )

    if(add_labels)
      map = map + geom_sf_label(data = stock_areas, mapping = aes(label = CODE, color = CODE), fill = "white", alpha = .7, size = 5)
  }

  map = map + theme(legend.position = "right")

  if(add_labels == TRUE ) map = map + guides(fill = "none", color = "none")
  if(fill_areas == FALSE) map = map + guides(fill = "none")
  else                    map = map + new_scale_fill()

  # Needed to ensure that the base map is displayed...
  coords =
    coord_sf(
      crs = crs,
      default_crs = sf::st_crs(iccat.pub.maps::CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  coords$default = TRUE

  return(
    map + coords
  )
}
