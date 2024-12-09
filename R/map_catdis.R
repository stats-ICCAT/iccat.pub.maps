# See: https://stackoverflow.com/questions/23252231/r-data-table-breaks-in-exported-functions
.datatable.aware = TRUE

#' Produces a pie map chart of CATDIS catch data using gears as categories
#'
#' @param base_map the base map to use
#' @param catdis_data the CATDIS data
#' @param gears_to_keep a vector of gears to keep in the final map. All gears with codes other than those provided will collapse in a generic _Other gears_ category
#' @param default_radius the default radius of each pie
#' @param max_catch the maximum catch value to use as a reference when scaling up / down each single pie
#' @param center_pies to place the pie center in the grid centroid, or in the grid exact center (regardless of the available ocean area within the grid)
#' @param legend.x the x position of the legend
#' @param legend.y the y position of the legend
#' @param crs the Coordinate Reference System to use
#' @return a CATDIS piemap showing catches by gear and 5x5 grid
#' @export
map.pie.catdis.gear = function(base_map = map.atlantic(crs = iccat.pub.maps::CRS_EQUIDISTANT), catdis_data, gears_to_keep = NULL, default_radius = pi, max_catch = NA, center_pies = TRUE, legend.x = -90, legend.y = -25, crs = iccat.pub.maps::CRS_EQUIDISTANT) {
  if(is.null(catdis_data) | nrow(catdis_data) == 0) stop("No catdis data provided!")

  if(!is.null(gears_to_keep)) {
    catdis_data[!GearGrp %in% gears_to_keep, GearGrp := 'OT']
  }

  if(center_pies) {
    catdis_data =
      merge(catdis_data, iccat.pub.maps::GRIDS_5x5_RAW_GEOMETRIES,
            by.x = "CWPCode", by.y = "CODE",
            all.x = TRUE)

    catdis_data = catdis_data[, .(CATCH = as.numeric(sum(Catch_t, na.rm = TRUE))), keyby = .(LON = CENTER_LON, LAT = CENTER_LAT, GEAR = GearGrp)]
  } else
    catdis_data = catdis_data[, .(CATCH = as.numeric(sum(Catch_t, na.rm = TRUE))), keyby = .(LON = xLon5ctoid, LAT = yLat5ctoid, GEAR = GearGrp)]

  all_gears = unique(catdis_data$GEAR)

  if(length(all_gears) == 1) {
    # Otherwise, for datasets with only one gear, the geom_scatterpie function will yield an error...
    catdis_data = rbind(catdis_data, data.table(LON = 0, LAT = 0, GEAR = ifelse(all_gears[1] != "OT", "OT", "foo"), CATCH = 0))
  }

  catdis_data_W =
    dcast.data.table(
      catdis_data,
      LON + LAT ~ GEAR,
      fun.aggregate = sum,
      value.var = "CATCH"
    )

  catdis_data_W[, RADIUS     := rowSums(catdis_data_W[, 3:ncol(catdis_data_W)])]
  catdis_data_W[, RADIUS_REL := default_radius * sqrt(RADIUS / ifelse(is.na(max_catch), max(RADIUS), max_catch))]

  fill_colors = REF_GEAR_GROUPS_COLORS[GEAR_GROUP_CODE %in% unique(catdis_data$GEAR)][order(GEAR_GROUP_CODE)]$FILL #brewer.pal(n = length(unique(catdis_data$GEAR)), name = "Set2")

  coords =
    coord_sf(
      crs = crs,
      default_crs = sf::st_crs(CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  return(
    base_map +

      geom_scatterpie(
        data = catdis_data_W,
        aes(x = LON,
            y = LAT,
            r = RADIUS_REL
        ),
        linewidth = .3,
        alpha = .7,
        cols = as.character(sort(unique(catdis_data$GEAR))),
        long_format = FALSE
      ) +

      geom_scatterpie_legend(
        catdis_data_W$RADIUS_REL,
        x = legend.x,
        y = legend.y,
        labeller = function(x) {
          paste(prettyNum(round((x / default_radius) ^ 2 * ifelse(is.na(max_catch), max(catdis_data_W$RADIUS), max_catch)), big.mark = ","), " t")
        },
        breaks = c(0, default_radius / sqrt(2), default_radius),
        size = 2
      ) +

      scale_fill_manual("Gear group", values = fill_colors) +
      guides(
        fill = guide_legend(
          position = "bottom"
        )
      ) +

      coords
  )
}

#' Produces a pie map chart of CATDIS catch data using school types as categories
#'
#' @param base_map the base map to use
#' @param catdis_data the CATDIS data
#' @param default_radius the default radius of each pie
#' @param max_catch the maximum catch value to use as a reference when scaling up / down each single pie
#' @param center_pies to place the pie center in the grid centroid, or in the grid exact center (regardless of the available ocean area within the grid)
#' @param legend.x the x position of the legend
#' @param legend.y the y position of the legend
#' @param crs the Coordinate Reference System to use
#' @return a CATDIS pie map showing catches by gear and 5x5 grid
#' @export
map.pie.catdis.schooltype = function(base_map = map.atlantic(crs = iccat.pub.maps::CRS_EQUIDISTANT), catdis_data, default_radius = pi, max_catch = NA, center_pies = TRUE, legend.x = -90, legend.y = -25, crs = iccat.pub.maps::CRS_EQUIDISTANT) {
  if(is.null(catdis_data) | nrow(catdis_data) == 0) stop("No catdis data provided!")

  catdis_data[!SchoolType %in% c("FAD", "FSC"), SchoolType := "UNK"]
  catdis_data$SchoolType =
    factor(
      catdis_data$SchoolType,
      levels = c("FAD", "FSC", "UNK"),
      labels = c("FAD", "FSC", "UNK"),
      ordered = TRUE
    )

  if(center_pies) {
    catdis_data =
      merge(catdis_data, iccat.pub.maps::GRIDS_5x5_RAW_GEOMETRIES,
            by.x = "CWPCode", by.y = "CODE",
            all.x = TRUE)

    catdis_data = catdis_data[, .(CATCH = as.numeric(sum(Catch_t, na.rm = TRUE))), keyby = .(LON = CENTER_LON, LAT = CENTER_LAT, SCHOOL_TYPE = SchoolType)]
  } else
    catdis_data = catdis_data[, .(CATCH = as.numeric(sum(Catch_t, na.rm = TRUE))), keyby = .(LON = xLon5ctoid, LAT = yLat5ctoid, SCHOOL_TYPE = SchoolType)]

  all_school_types = unique(catdis_data$SCHOOL_TYPE)

  if(length(all_school_types) == 1) {
    # Otherwise, for datasets with only one school type, the geom_scatterpie function will yield an error...
    catdis_data = rbind(catdis_data, data.table(LON = 0, LAT = 0, SCHOOL_TYPE = ifelse(all_school_types[1] != "UNK", "UNK", "foo"), CATCH = 0))
  }

  catdis_data_W =
    dcast.data.table(
      catdis_data,
      LON + LAT ~ SCHOOL_TYPE,
      fun.aggregate = sum,
      value.var = "CATCH"
    )

  catdis_data_W[, RADIUS     := rowSums(catdis_data_W[, 3:ncol(catdis_data_W)])]
  catdis_data_W[, RADIUS_REL := default_radius * sqrt(RADIUS / ifelse(is.na(max_catch), max(RADIUS), max_catch))]

  fill_colors = data.table(
    SCHOOL_TYPE_CODE = c("FAD", "FSC", "UNK"),
    FILL             = c("yellow", "red", "gray")
  )

  fill_colors[, COLOR := darken(FILL, amount = 0.2)]

  fill_colors = fill_colors[SCHOOL_TYPE_CODE %in% unique(catdis_data$SCHOOL_TYPE)][order(SCHOOL_TYPE_CODE)]$FILL

  coords =
    coord_sf(
      crs = crs,
      default_crs = sf::st_crs(CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  return(
    base_map +

      geom_scatterpie(
        data = catdis_data_W,
        aes(x = LON,
            y = LAT,
            r = RADIUS_REL
        ),
        linewidth = .3,
        alpha = .7,
        cols = as.character(sort(unique(catdis_data$SCHOOL_TYPE))),
        long_format = FALSE
      ) +

      geom_scatterpie_legend(
        catdis_data_W$RADIUS_REL,
        x = legend.x,
        y = legend.y,
        labeller = function(x) {
          paste(prettyNum(round((x / default_radius) ^ 2 * ifelse(is.na(max_catch), max(catdis_data_W$RADIUS), max_catch)), big.mark = ","), " t")
        },
        breaks = c(0, default_radius / sqrt(2), default_radius),
        size = 2
      ) +

      scale_fill_manual("School types", values = fill_colors) +
      guides(
        fill = guide_legend(
          position = "bottom"
        )
      ) +

      coords
  )
}

catdis_breaks = function(values, num_intervals) {
  dp = 1.0 / num_intervals

  return(unique(quantile(values, probs = seq(0, 1, dp), na.rm = TRUE, type = 6)))
}

catdis_breaks_uniform = function(values, num_intervals) {
  max_value = max(values)

  return(
    seq(0, max_value, max_value * 1.0 / num_intervals - 1)
  )
}

catdis_labels_for_breaks = function(breaks) {
  labels = c()

  for(v in c(1:(length(breaks) - 1)))
    labels =
      append(
        labels,
        paste("(", prettyNum(round(breaks[v  ][[1]]), big.mark = ","),
              "-", prettyNum(round(breaks[v+1][[1]]), big.mark = ","),
              "]")
      )

  return(labels)
}

#' Produces a heatmap chart of CATDIS catch data by 5x5 grid
#'
#' @param base_map the base map to use
#' @param catdis_data the CATDIS data
#' @param gears_to_keep a vector of gears to keep in the final map. All gears with codes other than those provided will collapse in a generic _Other gears_ category
#' @param gear the gear whose CATDIS catch data should be used to produce the heatmap
#' @param num_breaks the number of breaks for the heatmap catch scale
#' @param crs the Coordinate Reference System to use
#' @return a CATDIS heatmap showing catches of a given gear by magnitude and 5x5 grid
#' @export
map.heat.catdis = function(base_map = map.atlantic(crs = iccat.pub.maps::CRS_EQUIDISTANT), catdis_data, gears_to_keep = NULL, gear, num_breaks = 5, crs = iccat.pub.maps::CRS_EQUIDISTANT) {
  if(is.null(catdis_data) | nrow(catdis_data) == 0) stop("No catdis data provided!")

  if(!is.null(gears_to_keep)) {
    catdis_data[!GearGrp %in% gears_to_keep, GearGrp := 'OT']
  }

  catdis_data = catdis_data[, .(CATCH = as.numeric(sum(Catch_t, na.rm = TRUE))), keyby = .(GEAR = GearGrp, CWP_CODE = CWPCode)]

  break_values = catdis_breaks(catdis_data$CATCH, num_breaks)
  break_labels = catdis_labels_for_breaks(break_values)

  catdis_data = catdis_data[GEAR == gear]

  if(nrow(catdis_data) == 0) stop(paste0("No catdis data available for gear ", gear, "!"))

  catdis_data = merge(
    geometries_for(
      iccat.pub.maps::GRIDS_5x5_RAW_GEOMETRIES,
      source_crs = iccat.pub.maps::CRS_WGS84,
      target_crs = crs
    ),
    catdis_data,
    by.y = "CWP_CODE", by.x = "CODE",
    all.y = TRUE
  )

  # Unused
  catdis_data$FILL =
    cut(
      catdis_data$CATCH,
      include.lowest = TRUE,
      right = FALSE,
      breaks = break_values,
      labels = break_labels,
      extend = TRUE
    )

  coords =
    coord_sf(
      crs = crs,
      default_crs = sf::st_crs(CRS_WGS84), # The world map uses the EPSG:4326 projection
      label_axes = "--EN"
    )

  return(
    base_map +

      geom_sf(
        data = catdis_data,
        aes(alpha = CATCH),
        fill  = REF_GEAR_GROUPS_COLORS[GEAR_GROUP_CODE == gear]$FILL,
        color = "transparent"
      ) +

      scale_alpha_continuous(
        #breaks = seq(0, max(catdis_data$CATCH), max(catdis_data$CATCH) / num_breaks),
        labels = scales::comma
      ) +

      guides(
        alpha = guide_legend(
          title = paste0(gear, " catches (t)"),
          position = "bottom"
        )
      ) +

      coords
  )
}
