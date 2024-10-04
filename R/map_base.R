#' TBD
#'
#' @param xlim TBD
#' @param x_breaks_every TBD
#' @param ylim TBD
#' @param y_breaks_every TBD
#' @param axis_font_size TBD
#' @param fill_color TBD
#' @param border_color TBD
#' @param border_line_width TBD
#' @param force_show_all_atlantic TBD
#' @param crs TBD
#' @param background_plot_function TBD
#' @return TBD
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

  coords =
    coord_sf(
      xlim = xlim,
      ylim = ylim,
      crs = crs,
      default_crs = sf::st_crs(CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

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
    coords +

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
              color = "transparent") +
      coords
  }

  return(map)
}
