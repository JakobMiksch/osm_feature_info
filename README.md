# Feature Info API for OpenStreetMap

Attempt to create an API to get information about OSM features around a location.

## Setup on Linux

The recommended way to get up and running is to use docker compose. First, copy the file `.env_template` to `.env` and
change the values from the default if you want:

```sh
cp .env_template .env
# Optionally change environment variables inside .env
```

Launch the services defined in the docker-compose file:

```sh
docker compose up -d
```

Then, download an OSM PBF dump file (using Bremen as an example):

```sh
wget -O data/sample.pbf https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf
```

Run osm2pgsql to load the PBF into the database.

```sh
docker compose run --rm osm2pgsql \
  --slim \
  --output=flex \
  --style=/data/flex_style.lua \
  --prefix=raw \
  /data/sample.pbf
```

Create the necessary function for pg_featureserv to return features via API request:

```sh
docker compose exec db psql -f /data/query_function.sql
```

Request the API with your browser (if you changed the `OSM_PG_FEATURESERV_API_SYSTEM_PORT` env variable, you must change
it accordingly below):

- HTML: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.html?latitude=53.112&longitude=8.755&distance=50&limit=10000>
- JSON: <http://localhost:9000/functions/postgisftw.osm_feature_info/items.json?latitude=53.112&longitude=8.755&distance=50&limit=10000>
