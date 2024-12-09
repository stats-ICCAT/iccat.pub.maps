#' Creates a \code{\link{coord_sf}} object with the specified characteristics
#'
#' @param xlim the vector with the two latitude limits (min - max)
#' @param ylim the vector with the two longitude limits (min - max)
#' @param source_crs the source Coordinate Reference System
#' @param target_crs the target Coordinate Reference System
#' @return a \code{\link{coord_sf}} object that can be used to force the proper displaying of a map
#' @export
map.coordinates_sf = function(xlim = NULL, ylim = NULL, source_crs = CRS_WGS84, target_crs = CRS_EQUIDISTANT) {
  coords_to_return =
    coord_sf(
      xlim = xlim,
      ylim = ylim,
      crs = target_crs,
      default_crs = sf::st_crs(source_crs), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  coords_to_return$default = TRUE

  return(
    coords_to_return
  )
}

#' Provides a base empty map for the Atlantic and Mediterranean areas
#'
#' @param xlim a vector specifying the range (min - max) of longitudes to include in the map
#' @param x_breaks_every the distance between two consecutive breaks on the X axis
#' @param ylim a vector specifying the range (min - max) of latitudes to include in the map
#' @param y_breaks_every the distance between two consecutive breaks on the X axis
#' @param axis_font_size the axis font size
#' @param fill_color the color used to fill the land areas on the map
#' @param border_color the color used for the border of the land areas
#' @param border_line_width the line width for the border of the land areas
#' @param force_show_all_atlantic to ensure that the entire Atlantic ocean / ICCAT area is always displayed in full on the map
#' @param crs the target Coordinate Reference System used to plot the map. Defaults to \code{\link{CRS_EQUIDISTANT}}
#' @param background_plot_function an optional function used to initialize the background layer of the map
#' @return a base empty map for the Atlantic and Mediterranean areas
#' @export
map.atlantic = function(xlim = DEFAULT_XLIM, x_breaks_every = 10,
                        ylim = DEFAULT_YLIM, y_breaks_every = 10,
                        axis_font_size = DEFAULT_AXIS_FONT_SIZE,
                        fill_color = DEFAULT_FILL_COLOR, border_color = DEFAULT_BORDER_COLOR,
                        border_line_width = DEFAULT_BORDER_LINE_WIDTH,
                        force_show_all_atlantic = FALSE,
                        crs = CRS_EQUIDISTANT,
                        background_plot_function = NULL) {

  world = map_data("world")
  world = world[world$long <= 180, ] # Removes 'offending' areas that might cause "bleeding"... See: https://www.riinu.me/2022/02/world-map-ggplot2/

  coordz =
    coord_sf(
      xlim = xlim,
      ylim = ylim,
      crs = crs,
      default_crs = sf::st_crs(CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  coords = map.coordinates_sf(xlim, ylim, source_crs = sf::st_crs(CRS_WGS84), target_crs = crs)

  coords$default = TRUE

  map =
    ggplot()

  if(!is.null(background_plot_function)) {
    map = background_plot_function(map)

    map = map +
      new_scale_fill() +
      new_scale_colour()
  }

  map = map +
    geom_map(data = world,
             map = world,
             aes(map_id = region),
             fill  = fill_color,
             color = border_color,
             linewidth = border_line_width)

  map = map +
    scale_x_continuous(breaks = seq(DEFAULT_XLIM[1] - x_breaks_every, DEFAULT_XLIM[2] + x_breaks_every, x_breaks_every), guide = guide_axis(n.dodge = 2)) +
    scale_y_continuous(breaks = seq(DEFAULT_YLIM[1] - y_breaks_every, DEFAULT_YLIM[2] + y_breaks_every, y_breaks_every)) +

    theme_bw() +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text    = element_text(size = axis_font_size)
    )


  if(force_show_all_atlantic) {
    # Creates the SF for the Atlantic Ocean and converts it to the target CRS if needed
    sf_atlantic_ocean = geometries_for(ATLANTIC_OCEAN_RAW_GEOMETRY,
                                       source_crs = CRS_WGS84,
                                       target_crs = crs)

    map =  map +
      geom_sf(data  = sf_atlantic_ocean,
              fill  = "transparent",
              color = "transparent")
  }

  return(map + coords)
}
