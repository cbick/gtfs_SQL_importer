#!/usr/bin/env python

# Copyright (c) 2010 Colin Bick, Robert Damphousse

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import csv
import sys

class SpecialHandler(object):
  """
  A SpecialHandler does a little extra special work for a particular
  database table.
  """
  def handleCols(self,columns):
    return columns

  def handleVals(self,row,header):
    return row

class AgencyHandler(SpecialHandler):
  def handleCols(self, columns):
    # Column name was originally proposed as fare_url
    if 'fare_url' in columns:
      colIdx = columns.index('fare_url');
      columns[colIdx] = 'agency_fare_url';

    if not 'agency_id' in columns:
      self.appendId = True
      self.ix = 0
      columns = columns + ['agency_id',]
    else:
      self.appendId = False

    return columns

  def handleVals(self, row, cols):
    if self.appendId:
      row.append(str(self.ix))
      self.ix += 1
    return row

class TripsHandler(SpecialHandler):
  def handleCols(self,columns):
    if not 'direction_id' in columns:
      self.appendDir = True;
      return columns+['direction_id',]

    self.appendDir = False;
    return columns;

  def handleVals(self,row,cols):
    if self.appendDir:
      row.append("0");
    else:
      dirIdx = cols.index('direction_id');
      if not row[dirIdx]:
        row[dirIdx] = "0"
    return row;


class StopTimesHandler(SpecialHandler):
  @staticmethod
  def timeToSeconds(text):
    h,m,s = map(int,text.split(":"))
    return h*60*60 + m*60 + s

  @staticmethod
  def secsToTime(s):
    h,m = divmod(s,60*60)
    m,s = divmod(m,60)
    return "%2.2d:%2.2d:%2.2d" % (h,m,s)

  def handleCols(self,cols):
    return cols+['arrival_time_seconds','departure_time_seconds']

  def handleVals(self,row,cols):
    arrIdx = cols.index('arrival_time')
    depIdx = cols.index('departure_time')

    # Arrival/departure times are only required for time points. Stops that
    # aren't time points have an empty string as the time, so just keep those
    # field values the same, and set the {arr,dep}_secs fields to the empty
    # string, which will get replaced with NULL during SQL generation.
    arr_secs = dep_secs = ""

    if row[arrIdx]:
      arr_secs = self.timeToSeconds(row[arrIdx])
      row[arrIdx] = self.secsToTime(arr_secs)

    if row[depIdx]:
      dep_secs = self.timeToSeconds(row[depIdx]);
      row[depIdx] = self.secsToTime(dep_secs)

    return row+[str(arr_secs), str(dep_secs)]


class FrequenciesHandler(SpecialHandler):
  def handleCols(self,cols):
    return cols+['start_time_seconds','end_time_seconds']

  def handleVals(self,row,cols):
    startIdx = cols.index('start_time')
    endIdx = cols.index('end_time')

    start_secs = StopTimesHandler.timeToSeconds(row[startIdx]);
    end_secs = StopTimesHandler.timeToSeconds(row[endIdx]);

    row[startIdx] = StopTimesHandler.secsToTime(start_secs);
    row[endIdx] = StopTimesHandler.secsToTime(end_secs);

    return row+[str(start_secs), str(end_secs)]






def import_file(fname, tablename, handler, COPY=True):
  """Returns SQL statement iterator"""
  try:
    f = open(fname,'r');
  except:
    yield "-- file %s doesn't exist" % fname
    return

  if not handler:
    handler = SpecialHandler()

  reader = csv.reader(f,dialect=csv.excel);
  header = handler.handleCols([c.strip() for c in reader.next()]);
  cols = ",".join(header);

  defaultVal = 'NULL';

  if not COPY:  
    delim = ","
    insertSQL = "INSERT INTO " + tablename + " (" + cols + ") VALUES (%s);"
    func = lambda v: ((v and ("'"+v.replace("'","''")+"'")) or defaultVal)
  else:
    delim = "|"
    copySQL = "COPY " + tablename + " (" + cols + ") FROM STDIN WITH NULL AS 'NULL' DELIMITER AS '" + delim + "';";
    yield copySQL;
    insertSQL = "%s"
    func = lambda v: str.strip(v) or defaultVal

  for row in reader:
    vals = handler.handleVals(row,header);
    yield insertSQL % delim.join(map(func,vals))

  if COPY:
    yield "\\.\n"
  

    






if __name__ == "__main__":
  fnames = [
      "agency" ,
      "stops" ,
      "routes" ,
      "calendar" ,
      "calendar_dates" ,
      "fare_attributes" ,
      "fare_rules" ,
      "shapes" ,
      "trips" ,
      "stop_times" ,
      "frequencies" ,
      "transfers" ,
      "feed_info" ,
      ];

  handlers = dict.fromkeys(fnames);
  handlers['agency'] = AgencyHandler();
  handlers['stop_times'] = StopTimesHandler();
  handlers['trips'] = TripsHandler();
  handlers['frequencies'] = FrequenciesHandler();

  if len(sys.argv) not in (2,3):
    print "Usage: %s gtfs_data_dir [nocopy]" % sys.argv[0]
    print "  If nocopy is present, then uses INSERT instead of COPY."
    sys.exit()

  dirname = sys.argv[1]
  useCopy = True;


  useCopy = not ("nocopy" in sys.argv[2:])

  print "begin;"

  for fname in fnames:
    for statement in import_file(dirname+"/"+fname+".txt","gtfs_"+fname,
                                 handlers[fname],useCopy):
      print statement;

  print "commit;"
