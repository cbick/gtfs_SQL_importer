drop table gtfs_agency cascade;
drop table gtfs_stops cascade;
drop table gtfs_routes cascade;
drop table gtfs_calendar cascade;
drop table gtfs_calendar_dates cascade;
drop table gtfs_fare_attributes cascade;
drop table gtfs_fare_rules cascade;
drop table gtfs_shapes cascade;
drop table gtfs_trips cascade;
drop table gtfs_stop_times cascade;
drop table gtfs_frequencies cascade;

drop table gtfs_transfers cascade;
drop table gtfs_feed_info cascade;

drop table gtfs_route_types cascade;
drop table gtfs_directions cascade;
drop table gtfs_pickup_dropoff_types cascade;
drop table gtfs_payment_methods cascade;

drop table gtfs_location_types cascade;
drop table gtfs_wheelchair_boardings cascade;
drop table gtfs_transfer_types cascade;

drop table service_combo_ids cascade;
drop table service_combinations cascade;

begin;

create table gtfs_agency (
  agency_id    text ,--PRIMARY KEY,
  agency_name  text ,--NOT NULL,
  agency_url   text ,--NOT NULL,
  agency_timezone    text ,--NOT NULL,
  agency_lang  text,
  agency_phone text,
  agency_fare_url text
);

--related to gtfs_stops(location_type)
create table gtfs_location_types (
  location_type int PRIMARY KEY,
  description text
);

insert into gtfs_location_types(location_type, description) 
       values (0,'stop');
insert into gtfs_location_types(location_type, description) 
       values (1,'station');
insert into gtfs_location_types(location_type, description) 
       values (2,'station entrance');

--related to gtf_stops(wheelchair_boarding)
create table gtfs_wheelchair_boardings (
  wheelchair_boarding int PRIMARY KEY,
  description text
);

insert into gtfs_wheelchair_boardings(wheelchair_boarding, description)
       values (0, 'No accessibility information available for the stop');
insert into gtfs_wheelchair_boardings(wheelchair_boarding, description)
       values (1, 'At least some vehicles at this stop can be boarded by a rider in a wheelchair');
insert into gtfs_wheelchair_boardings(wheelchair_boarding, description)
       values (2, 'Wheelchair boarding is not possible at this stop');


create table gtfs_stops (
  stop_id    text ,--PRIMARY KEY,
  stop_name  text , --NOT NULL,
  stop_desc  text,
  stop_lat   double precision,
  stop_lon   double precision,
  zone_id    text,
  stop_url   text,
  stop_code  text,

  -- new
  stop_street text,
  stop_city   text,
  stop_region text,
  stop_postcode text,
  stop_country text,

  -- unofficial features

  location_type int, --FOREIGN KEY REFERENCES gtfs_location_types(location_type)
  parent_station text, --FOREIGN KEY REFERENCES gtfs_stops(stop_id)
  stop_timezone text,
  wheelchair_boarding int --FOREIGN KEY REFERENCES gtfs_wheelchair_boardings(wheelchair_boarding)
  -- Unofficial fields
  ,
  direction text,
  position text
);

-- select AddGeometryColumn( 'gtfs_stops', 'location', #{WGS84_LATLONG_EPSG}, 'POINT', 2 );
-- CREATE INDEX gtfs_stops_location_ix ON gtfs_stops USING GIST ( location GIST_GEOMETRY_OPS );

create table gtfs_route_types (
  route_type int PRIMARY KEY,
  description text
);

insert into gtfs_route_types (route_type, description) values (0, 'Street Level Rail');
insert into gtfs_route_types (route_type, description) values (1, 'Underground Rail');
insert into gtfs_route_types (route_type, description) values (2, 'Intercity Rail');
insert into gtfs_route_types (route_type, description) values (3, 'Bus');
insert into gtfs_route_types (route_type, description) values (4, 'Ferry');
insert into gtfs_route_types (route_type, description) values (5, 'Cable Car');
insert into gtfs_route_types (route_type, description) values (6, 'Suspended Car');
insert into gtfs_route_types (route_type, description) values (7, 'Steep Incline Mode');


create table gtfs_routes (
  route_id    text ,--PRIMARY KEY,
  agency_id   text , --REFERENCES gtfs_agency(agency_id),
  route_short_name  text DEFAULT '',
  route_long_name   text DEFAULT '',
  route_desc  text,
  route_type  int , --REFERENCES gtfs_route_types(route_type),
  route_url   text,
  route_color text,
  route_text_color  text
);

create table gtfs_directions (
  direction_id int PRIMARY KEY,
  description text
);

insert into gtfs_directions (direction_id, description) values (0,'This way');
insert into gtfs_directions (direction_id, description) values (1,'That way');


create table gtfs_pickup_dropoff_types (
  type_id int PRIMARY KEY,
  description text
);

insert into gtfs_pickup_dropoff_types (type_id, description) values (0,'Regularly Scheduled');
insert into gtfs_pickup_dropoff_types (type_id, description) values (1,'Not available');
insert into gtfs_pickup_dropoff_types (type_id, description) values (2,'Phone arrangement only');
insert into gtfs_pickup_dropoff_types (type_id, description) values (3,'Driver arrangement only');



-- CREATE INDEX gst_trip_id_stop_sequence ON gtfs_stop_times (trip_id, stop_sequence);

create table gtfs_calendar (
  service_id   text ,--PRIMARY KEY,
  monday int , --NOT NULL,
  tuesday int , --NOT NULL,
  wednesday    int , --NOT NULL,
  thursday     int , --NOT NULL,
  friday int , --NOT NULL,
  saturday     int , --NOT NULL,
  sunday int , --NOT NULL,
  start_date   date , --NOT NULL,
  end_date     date  --NOT NULL
);

create table gtfs_calendar_dates (
  service_id     text , --REFERENCES gtfs_calendar(service_id),
  date     date , --NOT NULL,
  exception_type int  --NOT NULL
);

-- The following two tables are not in the spec, but they make dealing with dates and services easier
create table service_combo_ids
(
combination_id serial --primary key
);
create table service_combinations
(
combination_id int , --references service_combo_ids(combination_id),
service_id text --references gtfs_calendar(service_id)
);


create table gtfs_payment_methods (
  payment_method int PRIMARY KEY,
  description text
);

insert into gtfs_payment_methods (payment_method, description) values (0,'On Board');
insert into gtfs_payment_methods (payment_method, description) values (1,'Prepay');


create table gtfs_fare_attributes (
  fare_id     text ,--PRIMARY KEY,
  price double precision , --NOT NULL,
  currency_type     text , --NOT NULL,
  payment_method    int , --REFERENCES gtfs_payment_methods,
  transfers   int,
  transfer_duration int
  -- unofficial features
  ,
  agency_id text  --REFERENCES gtfs_agency(agency_id)
);

create table gtfs_fare_rules (
  fare_id     text , --REFERENCES gtfs_fare_attributes(fare_id),
  route_id    text , --REFERENCES gtfs_routes(route_id),
  origin_id   text ,
  destination_id text ,
  contains_id text 
  -- unofficial features
  ,
  service_id text -- REFERENCES gtfs_calendar(service_id) ?
);

create table gtfs_shapes (
  shape_id    text , --NOT NULL,
  shape_pt_lat double precision , --NOT NULL,
  shape_pt_lon double precision , --NOT NULL,
  shape_pt_sequence int , --NOT NULL,
  shape_dist_traveled double precision
);

create table gtfs_trips (
  route_id text , --REFERENCES gtfs_routes(route_id),
  service_id    text , --REFERENCES gtfs_calendar(service_id),
  trip_id text ,--PRIMARY KEY,
  trip_headsign text,
  direction_id  int , --REFERENCES gtfs_directions(direction_id),
  block_id text,
  shape_id text,  
  trip_short_name text,
  -- unofficial features
  trip_type text
);

create table gtfs_stop_times (
  trip_id text , --REFERENCES gtfs_trips(trip_id),
  arrival_time text, -- CHECK (arrival_time LIKE '__:__:__'),
  departure_time text, -- CHECK (departure_time LIKE '__:__:__'),
  stop_id text , --REFERENCES gtfs_stops(stop_id),
  stop_sequence int , --NOT NULL,
  stop_headsign text,
  pickup_type   int , --REFERENCES gtfs_pickup_dropoff_types(type_id),
  drop_off_type int , --REFERENCES gtfs_pickup_dropoff_types(type_id),
  shape_dist_traveled double precision

  -- unofficial features
  ,
  timepoint int

  -- the following are not in the spec
  ,
  arrival_time_seconds int, 
  departure_time_seconds int

);

--create index arr_time_index on gtfs_stop_times(arrival_time_seconds);
--create index dep_time_index on gtfs_stop_times(departure_time_seconds);

-- select AddGeometryColumn( 'gtfs_shapes', 'shape', #{WGS84_LATLONG_EPSG}, 'LINESTRING', 2 );

create table gtfs_frequencies (
  trip_id     text , --REFERENCES gtfs_trips(trip_id),
  start_time  text , --NOT NULL,
  end_time    text , --NOT NULL,
  headway_secs int , --NOT NULL
  exact_times int,
  start_time_seconds int,
  end_time_seconds int
);





create table gtfs_transfer_types (
  transfer_type int PRIMARY KEY,
  description text
);

insert into gtfs_transfer_types (transfer_type, description) 
       values (0,'Preferred transfer point');
insert into gtfs_transfer_types (transfer_type, description) 
       values (1,'Designated transfer point');
insert into gtfs_transfer_types (transfer_type, description) 
       values (2,'Transfer possible with min_transfer_time window');
insert into gtfs_transfer_types (transfer_type, description) 
       values (3,'Transfers forbidden');


create table gtfs_transfers (
  from_stop_id text, --REFERENCES gtfs_stops(stop_id)
  to_stop_id text, --REFERENCES gtfs_stops(stop_id)
  transfer_type int, --REFERENCES gtfs_transfer_types(transfer_type)
  min_transfer_time int,
  -- Unofficial fields
  from_route_id text, --REFERENCES gtfs_routes(route_id)
  to_route_id text, --REFERENCES gtfs_routes(route_id)
  service_id text --REFERENCES gtfs_calendar(service_id) ?
);


create table gtfs_feed_info (
  feed_publisher_name text,
  feed_publisher_url text,
  feed_timezone text,
  feed_lang text,
  feed_version text,
  feed_start_date text,
  feed_end_date text
);



commit;
