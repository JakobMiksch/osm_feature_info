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

# download and extract pg_featureserv
wget https://postgisftw.s3.amazonaws.com/pg_featureserv_latest_linux.zip
unzip -n pg_featureserv_latest_linux.zip
rm -rf LICENSE.md config/

export DATABASE_URL=postgres://${PGUSER}:${PGPASSWORD}@${PGHOST}/${PGDATABASE}
export PGFS_WEBSITE_BASEMAPURL="https://tile.openstreetmap.de/{z}/{x}/{y}.png"
./pg_featureserv
```

Request the API with your browser:
    - HTML: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.html?latitude=53.112&longitude=8.755&distance=50&limit=10000>
    - JSON: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.json?latitude=53.112&longitude=8.755&distance=50&limit=10000>


## Problems

`pg_featureserv` stringifies the `tags` column:

```json
{
    "type": "Feature",
    "geometry": {
        "type": "Point",
        "coordinates": [
            8.7551143,
            53.1193666
        ]
    },
    "properties": {
        "osm_id": 3681752122,
        "osm_type": "N",
        "tags": "{\"railway\": \"level_crossing\", \"crossing:barrier\": \"no\"}"
    }
}
```

It would be desired to have the tags also as normal JSON object. Related issue: <https://github.com/CrunchyData/pg_featureserv/issues/155>.
