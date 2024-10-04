DEFAULT_XLIM = c(-100, 40)
DEFAULT_YLIM = c( -60, 70)

DEFAULT_AXIS_FONT_SIZE = 7

DEFAULT_FILL_COLOR   = "grey"
DEFAULT_BORDER_COLOR = "grey"

DEFAULT_BORDER_LINE_WIDTH = .2

DEFAULT_DARKENING_FACTOR = .2
DEFAULT_AREA_FILL_ALPHA  = .7

#' @export
CRS_EQUIDISTANT = 4087

#' @export
CRS_WGS84       = 4326

#' TBD
#'
#' @param raw_geometries TBD
#' @param source_crs TBD
#' @param target_crs TBD
#' @return TBD
#' @export
geometries_for = function(raw_geometries, source_crs = CRS_WGS84, target_crs = CRS_EQUIDISTANT) {
  geometry =
    st_as_sf(
      raw_geometries,
      crs = source_crs,
      wkt = "GEOMETRY_WKT"
    )

  if(source_crs != target_crs)
    geometry = st_transform(geometry, target_crs)

  return(
    geometry
  )
}
