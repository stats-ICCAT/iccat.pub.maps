# See: https://stackoverflow.com/questions/23252231/r-data-table-breaks-in-exported-functions
.datatable.aware = TRUE

geometries_for = function(raw_geometries) {
  return(
    st_as_sf(
      raw_geometries,
      crs = 4326,
      wkt = "GEOMETRY_WKT"
    )
  )
}

#' TBD
#'
#' @param species_codes TBD
#' @param stock_codes TBD
#' @param base_map TBD
#' @param fill_areas TBD
#' @param add_labels TBD
#' @return TBD
#' @export
map.stocks = function(species_codes, stock_codes = NULL,
                      base_map = map.atlantic(),
                      fill_areas = TRUE, add_labels = TRUE) {

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

  stock_areas    = geometries_for(STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES[CODE %in% unique(selected_stocks$STOCK_CODE)])
  sampling_areas = geometries_for(STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES[CODE %in% unique(selected_stocks$SAMPLING_AREA_CODE)])

  SA_colors = SA_colors[SAMPLING_AREA_CODE %in% selected_stocks$SAMPLING_AREA_CODE]

  map = base_map

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

  return(
    map
  )
}
