-- Nodes

ALTER TABLE geom_nodes
ADD COLUMN geog geography(Geometry, 4326);
UPDATE geom_nodes
SET geog = ST_GeogFromText(ST_AsText(geom));

CREATE INDEX idx_nodes_geog
ON geom_nodes
USING GIST(geog);

-- Ways

ALTER TABLE geom_ways
ADD COLUMN geog geography(Geometry, 4326);

UPDATE geom_ways
SET geog = ST_GeogFromText(ST_AsText(geom));

CREATE INDEX idx_ways_geog
ON geom_ways
USING GIST(geog);

-- Rels

ALTER TABLE geom_rels
ADD COLUMN geog geography(Geometry, 4326);

UPDATE geom_rels
SET geog = ST_GeogFromText(ST_AsText(geom));

CREATE INDEX idx_rels_geog
ON geom_rels
USING GIST(geog);
