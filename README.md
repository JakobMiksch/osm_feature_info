# Feature Info API for OpenStreetMap

Attempt to create an API to get information about OSM features around a location.

## Setup on Linux

```sh
# download sample data
wget -O sample.pbf https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf

# define env variables for DB connection
export PGDATABASE=osm
export PGUSER=postgres
export PGPASSWORD=postgres
export PGHOST=localhost

# start DB with docker or somehow else
docker run \
    -e POSTGRES_DBNAME=${PGDATABASE} \
    -e POSTGRES_USER=${PGUSER} \
    -e POSTGRES_PASS=${PGPASSWORD} \
    -e POSTGRES_MULTIPLE_EXTENSIONS=postgis \
    -p 5432:5432 \
    -d \
    kartoza/postgis:16-3.4

# add function to DB
cat query_function.sql | psql

# load data into db
osm2pgsql \
  --slim \
  --output=flex \
  --style=flex_style.lua \
  --prefix=raw \
  sample.pbf

# example query OSM features (geom omitted for display purposes)
psql -c "SELECT osm_id, osm_type, tags FROM postgisftw.osm_feature_info(53.112, 8.755, 10)"
```
