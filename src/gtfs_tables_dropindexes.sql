drop index arr_time_index;
drop index dep_time_index;
drop index stop_seq_index;

ALTER TABLE gtfs_agency DROP CONSTRAINT agency_name_pkey CASCADE;
ALTER TABLE gtfs_stops DROP CONSTRAINT stops_id_pkey CASCADE;
ALTER TABLE gtfs_stops DROP CONSTRAINT stop_location_fkey CASCADE;
ALTER TABLE gtfs_stops DROP CONSTRAINT stop_parent_fkey CASCADE;
ALTER TABLE gtfs_routes DROP CONSTRAINT routes_id_pkey CASCADE;
ALTER TABLE gtfs_routes DROP CONSTRAINT routes_agency_fkey CASCADE;
ALTER TABLE gtfs_routes DROP CONSTRAINT routes_rtype_fkey CASCADE;
ALTER TABLE gtfs_calendar DROP CONSTRAINT calendar_sid_pkey CASCADE;
ALTER TABLE gtfs_calendar_dates DROP CONSTRAINT cal_sid_fkey CASCADE;
ALTER TABLE gtfs_fare_attributes DROP CONSTRAINT fare_id_pkey CASCADE;
ALTER TABLE gtfs_fare_attributes DROP CONSTRAINT fare_pay_fkey CASCADE;
ALTER TABLE gtfs_fare_attributes DROP CONSTRAINT fare_agency_fkey CASCADE;
ALTER TABLE gtfs_fare_rules DROP CONSTRAINT fare_rid_pkey CASCADE;
ALTER TABLE gtfs_fare_rules DROP CONSTRAINT fare_rid_fkey CASCADE;
ALTER TABLE gtfs_shapes DROP CONSTRAINT shape_shape_constr ;
ALTER TABLE gtfs_trips DROP CONSTRAINT trip_id_pkey CASCADE;
ALTER TABLE gtfs_trips DROP CONSTRAINT trip_rid_fkey CASCADE;
ALTER TABLE gtfs_trips DROP CONSTRAINT trip_sid_fkey CASCADE;
ALTER TABLE gtfs_trips DROP CONSTRAINT trip_did_fkey CASCADE;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_tid_fkey CASCADE;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_sid_fkey CASCADE;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_ptype_fkey CASCADE;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_dtype_fkey CASCADE;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_arrtime_check;
ALTER TABLE gtfs_stop_times DROP CONSTRAINT times_deptime_check;
ALTER TABLE gtfs_frequencies DROP CONSTRAINT freq_tid_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_fsid_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_tsid_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_xt_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_frid_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_trid_fkey CASCADE;
ALTER TABLE gtfs_transfers DROP CONSTRAINT xfer_sid_fkey CASCADE;


ALTER TABLE gtfs_agency 
      ALTER COLUMN agency_name DROP NOT NULL;
ALTER TABLE gtfs_agency 
      ALTER COLUMN agency_url DROP NOT NULL;
ALTER TABLE gtfs_agency 
      ALTER COLUMN agency_timezone DROP NOT NULL;
ALTER TABLE gtfs_stops 
      ALTER COLUMN stop_name DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN monday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN tuesday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN wednesday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN thursday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN friday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN saturday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN sunday DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN start_date DROP NOT NULL;
ALTER TABLE gtfs_calendar 
      ALTER COLUMN end_date DROP NOT NULL;
ALTER TABLE gtfs_fare_attributes 
      ALTER COLUMN price DROP NOT NULL;
ALTER TABLE gtfs_fare_attributes 
      ALTER COLUMN currency_type DROP NOT NULL;
ALTER TABLE gtfs_shapes  
      ALTER COLUMN shape_id DROP NOT NULL;
ALTER TABLE gtfs_shapes 
      ALTER COLUMN shape_pt_lat DROP NOT NULL;
ALTER TABLE gtfs_shapes 
      ALTER COLUMN shape_pt_lon DROP NOT NULL;
ALTER TABLE gtfs_shapes 
      ALTER COLUMN shape_pt_sequence DROP NOT NULL;
ALTER TABLE gtfs_trips
      ALTER COLUMN direction_id DROP NOT NULL;
ALTER TABLE gtfs_stop_times 
      ALTER COLUMN stop_sequence DROP NOT NULL;
ALTER TABLE gtfs_frequencies 
      ALTER COLUMN start_time DROP NOT NULL;
ALTER TABLE gtfs_frequencies 
      ALTER COLUMN end_time DROP NOT NULL;
ALTER TABLE gtfs_frequencies 
      ALTER COLUMN headway_secs DROP NOT NULL;

