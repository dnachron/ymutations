#!/bin/bash

# change working directory
cd "${0%/*}" || exit 1

# update database
git pull -f

# generate databse
if ! rm ymutations.sqlite3 -f; then
    exit 1
fi

sqlite3 ymutations.sqlite3 '''
CREATE TABLE "ymutation" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, 
  "name" varchar(25) NOT NULL, 
  "position" integer unsigned NOT NULL CHECK ("position" >= 0), 
  "mutation_type" varchar(5) NOT NULL, 
  "ancestral" varchar(100) NOT NULL, 
  "derived" varchar(100) NOT NULL, 
  "join_date" date NOT NULL, 
  "ycc_haplogroup" text NULL, 
  "isogg_haplogroup" text NULL, 
  "ref" text NULL, 
  "comment" text NULL, 
  "ybrowse_synced" bool NOT NULL, 
  CONSTRAINT "models_ymutations_unique_name" UNIQUE ("name")
);
CREATE INDEX "ymutation_positio_fef5ef_idx" ON "ymutation" ("position");
CREATE INDEX "ymutation_join_da_186260_idx" ON "ymutation" ("join_date");
CREATE TABLE "ymutation_error" (
  "id" integer NOT NULL PRIMARY KEY AUTOINCREMENT, 
  "name" varchar(25) NOT NULL, 
  "join_date" date NOT NULL, 
  CONSTRAINT "models_yerrormutation_unique_name" UNIQUE ("name")
);
CREATE INDEX "ymutation_e_name_bb292a_idx" ON "ymutation_error" ("name");
'''

for file_name in ./rawfile/ymutation??.csv; do
    sqlite3 ymutations.sqlite3 ".mode csv" ".import $file_name ymutation"
done

# update ybrowse_synced from text to bool
sqlite3 ymutations.sqlite3 "UPDATE ymutation SET ybrowse_synced = TRUE WHERE ybrowse_synced = 'True';"
sqlite3 ymutations.sqlite3 "UPDATE ymutation SET ybrowse_synced = FALSE WHERE ybrowse_synced = 'False';"

sqlite3 ymutations.sqlite3 ".mode csv" ".import ./rawfile/ymutation_error.csv ymutation_error"
