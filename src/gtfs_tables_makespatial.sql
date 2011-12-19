-- Add spatial support for PostGIS databases only

-- Drop everything first
DROP TABLE gtfs_shape_geoms CASCADE;

BEGIN;
-- Add the_geom column to the gtfs_stops table - a 2D point geometry
SELECT AddGeometryColumn('gtfs_stops', 'the_geom', 4326, 'POINT', 2);

-- Update the the_geom column
UPDATE gtfs_stops SET the_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);

-- Create spatial index
CREATE INDEX "gtfs_stops_the_geom_gist" ON "gtfs_stops" using gist ("the_geom" gist_geometry_ops);

-- Create new table to store the shape geometries
CREATE TABLE gtfs_shape_geoms (
  shape_id    text
);

-- Add the_geom column to the gtfs_shape_geoms table - a 2D linestring geometry
SELECT AddGeometryColumn('gtfs_shape_geoms', 'the_geom', 4326, 'LINESTRING', 2);

-- Populate gtfs_shape_geoms
INSERT INTO gtfs_shape_geoms
SELECT shape.shape_id, ST_SetSRID(ST_MakeLine(shape.the_geom), 4326) As new_geom
  FROM (
    SELECT shape_id, ST_MakePoint(shape_pt_lon, shape_pt_lat) AS the_geom
    FROM gtfs_shapes 
    ORDER BY shape_id, shape_pt_sequence
  ) AS shape
GROUP BY shape.shape_id;

-- Create spatial index
CREATE INDEX "gtfs_shape_geoms_the_geom_gist" ON "gtfs_shape_geoms" using gist ("the_geom" gist_geometry_ops);

COMMIT;