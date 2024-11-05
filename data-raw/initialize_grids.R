library(iccat.dev.base)

GRIDS_5x5_RAW_GEOMETRIES =
  tabular_query(
    DB_GIS(), "
      SELECT
        CODE,
        TYPE_CODE,
        CENTER_LAT,
        CENTER_LON,
      (GEOMETRY_CUT.MakeValid()).STAsText() AS GEOMETRY_WKT
      FROM
        [AREAS]
      WHERE
        CODE LIKE '6%' AND
        SURFACE_IN_ICCAT_AREA > 0
    "
    # The [GEOMETRY] column shall be included as last in the list of SELECTed columns to avoid an
    # issue (possibly due to a bug) that results in:
    #
    # Error: nanodbc/nanodbc.cpp:3170: 07009
    # [Microsoft][ODBC SQL Server Driver]Invalid Descriptor Index
    # Warning message:
    # In dbClearResult(rs) : Result already cleared
  )

usethis::use_data(GRIDS_5x5_RAW_GEOMETRIES, overwrite = TRUE, compress = "gzip")
