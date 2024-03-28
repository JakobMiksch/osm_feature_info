set -e

PBF_FILE=${1}

# launch application
docker compose down && docker compose up -d

# download sample data
wget -O data/sample.pbf ${PBF_FILE}

# add function to DB
docker compose exec db psql -f /data/query_function.sql

# load data into db
docker compose run --rm osm2pgsql \
  --slim \
  --output=flex \
  --style=/data/flex_style.lua \
  --prefix=raw \
  /data/sample.pbf
