# Feature Info API for OpenStreetMap

Attempt to create an API to get information about OSM features around a location.

## Setup on Linux

```sh
# download sample data
wget -O data/sample.pbf https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf

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

# load data into db
osm2pgsql \
  --slim \
  --output=flex \
  --style=data/flex_style.lua \
  --prefix=raw \
  data/sample.pbf

# add function to DB
cat data/query_function.sql | psql

# example query OSM features (geom omitted for display purposes)
psql -c "SELECT osm_id, osm_type, tags FROM postgisftw.osm_feature_info(53.112, 8.755, 10)"

# download and extract pg_featureserv
wget https://postgisftw.s3.amazonaws.com/pg_featureserv_latest_linux.zip
unzip -n pg_featureserv_latest_linux.zip -d tmp_zip
cp -r tmp_zip/pg_featureserv tmp_zip/assets/ tmp_zip/config/ .
rm -rf tmp_zip

export DATABASE_URL=postgres://${PGUSER}:${PGPASSWORD}@${PGHOST}/${PGDATABASE}
export PGFS_WEBSITE_BASEMAPURL="https://tile.openstreetmap.de/{z}/{x}/{y}.png"
./pg_featureserv
```

## Setup using Docker

Tested on Linux and WSL. Adapt for other operating systems.

```sh
cp .env_template .env
# Optionally change environment variables inside .env

# start services
docker compose up -d

# download sample data
wget -O data/sample.pbf https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf

# load data into db
docker compose run --rm osm2pgsql \
  --slim \
  --output=flex \
  --style=/data/flex_style.lua \
  --prefix=raw \
  /data/sample.pbf

# add function to DB
docker compose exec db psql -f /data/query_function.sql
```

## Request API

Request the API with your browser or any other tool:

- HTML: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.html?latitude=53.112&longitude=8.755&distance=50&limit=10000>
- JSON: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.json?latitude=53.112&longitude=8.755&distance=50&limit=10000>
