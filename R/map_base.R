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
#' @return TBD
#' @export
map.atlantic = function(xlim = DEFAULT_XLIM, x_breaks_every = 10,
                        ylim = DEFAULT_YLIM, y_breaks_every = 10,
                        axis_font_size = DEFAULT_AXIS_FONT_SIZE,
                        fill_color = DEFAULT_FILL_COLOR, border_color = DEFAULT_BORDER_COLOR,
                        border_line_width = DEFAULT_BORDER_LINE_WIDTH) {

  world = map_data("world")

  c_sf = coord_sf(xlim = xlim,
                  ylim = ylim,
                  default_crs = sf::st_crs(4326),
                  label_axes = "--EN")

  c_sf$default = TRUE

  map =
    ggplot() +
    geom_map(data = world,
             map = world,
             aes(map_id = region),
             fill  = fill_color,
             color = border_color,
             linewidth = border_line_width) +

    # Necessary to add a SF object (in this case a transparent IATTC area) to see the hemisphere showing in the labels
    geom_sf(data = st_as_sf(ATLANTIC_OCEAN_RAW_GEOMETRY, crs = 4326, wkt = "GEOMETRY_WKT"),
            fill = "transparent", color = "transparent") +

    c_sf +

    scale_x_continuous(breaks = seq(xlim[1] - x_breaks_every, xlim[2] + x_breaks_every, x_breaks_every), guide = guide_axis(n.dodge = 2)) +
    scale_y_continuous(breaks = seq(ylim[1] - y_breaks_every, ylim[2] + y_breaks_every, y_breaks_every)) +

    theme_bw() +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      axis.text    = element_text(size = axis_font_size)
    )

  return(map)
}
