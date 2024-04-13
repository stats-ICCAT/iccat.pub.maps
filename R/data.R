#' All areas (stock and sampling) associated to a given species by species code
#'
#' @format
#' \describe{
#'   \item{SPECIES_CODE}{The species code}
#'   \item{STOCK_CODE}{The stock area code}
#'   \item{SAMPLING_AREA_CODE}{The sampling area code}
#' }
#' @export
"SPECIES_TO_AREAS_MAPPINGS"

#' The core data for all stock and sampling areas
#'
#' @format
#' \describe{
#'   \item{CODE}{The area code}
#'   \item{NAME_EN}{The area English name}
#'   \item{NAME_ES}{The area Spanish name}
#'   \item{NAME_FR}{The area French name}
#'   \item{ICCAT_AREA_INTERSECTION}{The extent of the intersection between the area and the ICCAT area}
#'   \item{GEOMETRY_WKT}{The geometry of the area}
#' }
#' @export
"STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES"

#' The core data for the ICCAT Atlantic Ocean area
#'
#' @format
#' \describe{
#'   \item{CODE}{The area code}
#'   \item{NAME_EN}{The area English name}
#'   \item{NAME_ES}{The area Spanish name}
#'   \item{NAME_FR}{The area French name}
#'   \item{ICCAT_AREA_INTERSECTION}{The extent of the intersection between the area and the ICCAT area}
#'   \item{GEOMETRY_WKT}{The geometry of the area}
#' }
#' @export
"ATLANTIC_OCEAN_RAW_GEOMETRY"

#' The core data for all 5x5 grids within the ICCAT area of competence
#'
#' @format
#' \describe{
#'   \item{CODE}{The area code}
#'   \item{NAME_EN}{The area English name}
#'   \item{NAME_ES}{The area Spanish name}
#'   \item{NAME_FR}{The area French name}
#'   \item{ICCAT_AREA_INTERSECTION}{The extent of the intersection between the area and the ICCAT area}
#'   \item{GEOMETRY_WKT}{The geometry of the area}
#' }
#' @export
"GRIDS_5x5_RAW_GEOMETRIES"
