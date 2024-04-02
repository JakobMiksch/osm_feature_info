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

Then, create the necessary function for pg_featureserv to return features via API request:

```sh
docker compose exec db psql -f /data/query_function.sql
```

Then, download an OSM PBF dump file (using Bremen as an example):

```sh
wget -O data/sample.pbf https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf
```

Finally, run osm2pgsql to load the PBF into the database. Note how we:

* Specify slim mode to keep the "middle tables" so we can enable automatic updates [(relevant osm2pgsql docs)](https://osm2pgsql.org/doc/manual.html#middle)
* Specify output mode as "flex" so that we can use the flex output [(relevant osm2pgsql docs)](https://osm2pgsql.org/doc/manual.html#output-options)
* Use the flex style config file (`data/flex_syle.lua`) [(relevant osm2pgsql docs)](https://osm2pgsql.org/doc/manual.html#lua-library-for-flex-output)
* Specify "raw" as the prefix so that the tables being with `raw` [(relevant osm2pgsql docs)](https://osm2pgsql.org/doc/manual.html#database-layout)

```sh
docker compose run --rm osm2pgsql \
  --slim \
  --output=flex \
  --style=/data/flex_style.lua \
  --prefix=raw \
  /data/sample.pbf
```

Request the API with your browser (if you changed the `OSM_PG_FEATURESERV_API_SYSTEM_PORT` env variable, you must change
it accordingly below):

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
