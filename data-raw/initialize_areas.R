library(iccat.dev.base)

raw_geometries_for = function(area_codes, connection = DB_GIS()) {
  return(
    tabular_query(
      connection,
      paste0("
        SELECT
          CODE,
          TYPE_CODE,
          NAME_EN,
          NAME_ES,
          NAME_FR,
          SURFACE_IN_ICCAT_AREA,
         (GEOMETRY_CUT.MakeValid()).STAsText() AS GEOMETRY_WKT
        FROM
          [AREAS]
        WHERE
          CODE IN (", paste(shQuote(area_codes, type = "sh"), collapse=", "), ")"
      )
    )
  )
}

SPECIES_TO_AREAS_MAPPINGS =
  tabular_query(
    DB_GIS(), "
    SELECT
      S.SPECIES_CODE,
      SA.STOCK_CODE,
      SA.SAMPLING_AREA_CODE
    FROM
      STOCKS S
    INNER JOIN
      STOCKS_TO_SAMPLING_AREAS SA
    ON
      S.CODE = SA.STOCK_CODE"
  )

usethis::use_data(SPECIES_TO_AREAS_MAPPINGS, overwrite = TRUE, compress = "gzip")

### Stock and sampling areas

STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES =
  raw_geometries_for(
    unique(
      c(SPECIES_TO_AREAS_MAPPINGS$STOCK_CODE, SPECIES_TO_AREAS_MAPPINGS$SAMPLING_AREA_CODE)
    )
  )

usethis::use_data(STOCK_AND_SAMPLING_AREAS_RAW_GEOMETRIES, overwrite = TRUE, compress = "gzip")

### Atlantic Ocean (ICCAT)

ATLANTIC_OCEAN_RAW_GEOMETRY = raw_geometries_for("ICCAT")

usethis::use_data(ATLANTIC_OCEAN_RAW_GEOMETRY, overwrite = TRUE, compress = "gzip")
