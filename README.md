# Feature Info API for OpenStreetMap

Attempt to create an API to get information about OSM features around a location.

## Setup on Linux

The recommended way to get up and running is to use docker compose. First, copy the file `.env_template` to `.env` and
change the values from the default if you want. Then, run `./run.sh`:

```sh
cp .env_template .env
# Optionally change the values inside of .env
./run.sh https://download.geofabrik.de/europe/germany/bremen-latest.osm.pbf
```

The database and the server will start running as daemons. A specific OSM PBF file will be downloaded and loaded into
the database. You can make requests in the br

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
