DEFAULT_XLIM = c(-100, 40) # The default longitudes' interval for the base map
DEFAULT_YLIM = c( -60, 70) # The default latitudes' interval for the base map

DEFAULT_AXIS_FONT_SIZE = 7 # The default font size for axis labels

DEFAULT_FILL_COLOR   = "grey" # The default fill color
DEFAULT_BORDER_COLOR = "grey" # The default border color

DEFAULT_BORDER_LINE_WIDTH = .2 # The default polygon border width

DEFAULT_DARKENING_FACTOR = .2 # The default darkening factor used to derive border colors from fill colors
DEFAULT_AREA_FILL_ALPHA  = .7 # The default alpha channel value for the area fill colors

# The World Equidistant Cylindrical coordinate reference system.
# Ensures that regular grids maintain the same shape and pixel area regardless of their latitude, and for
# this reason is particularly useful when producing _static_ maps
# See also: \link{https://epsg.io/4087}
#' @export
CRS_EQUIDISTANT = 4087

# The World Geodetic System 1984 coordinate reference system.
# It is used as the base for all geometry polygons stored in the ICCAT \code{\link{DATABASE_GIS}}
# See also: \link{https://epsg.io/4326}
#' @export
CRS_WGS84       = 4326

#' Converts into simple features a set of raw geometries as described (in _Well-Known-Text_ format, i.e., _WKT_) by their \code{GEOMETRY_WKT} column).
#' If required performs a coordinate reference system conversion before returning the simple features.
#'
#' @param raw_geometries a set of raw geometries with a \code{GEOMETRY_WKT} column storing the geometry definition in WKT format
#' @param source_crs a source CRS (defaults to \code{\link{CRS_WGS84}})
#' @param target_crs a target CRS (defaults to \code{\link{CRS_EQUIDISTANT}})
#' @return a set of Simple Features built from the original raw geometries converted in the target CRS
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
