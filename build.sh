#!/bin/bash

# change working directory
cd "${0%/*}" || exit 1

# update database
git pull -f

# generate databse
if ! rm ymutations.sqlite3 -f; then
    exit 1
fi

sqlite3 ymutations.sqlite3 'CREATE TABLE ymutation (
        id               INTEGER            NOT NULL
                                            PRIMARY KEY AUTOINCREMENT,
        name             VARCHAR (25)       NOT NULL,
        position         [INTEGER UNSIGNED] NOT NULL
                                            CHECK ("position" >= 0),
        mutation_type    VARCHAR (5)        NOT NULL,
        ancestral        VARCHAR (100)      NOT NULL,
        derived          VARCHAR (100)      NOT NULL,
        join_date        DATE               NOT NULL,
        ycc_haplogroup   TEXT,
        isogg_haplogroup TEXT,
        ref              TEXT,
        comment          TEXT,
        CONSTRAINT models_ymutations_unique_name UNIQUE (
            name
        )
    );' \
    "CREATE UNIQUE INDEX ymutation_name_ded686_idx ON ymutation(name);" \
    "CREATE INDEX ymutation_positio_fef5ef_idx ON ymutation(position);" \
    "CREATE TABLE ymutation_error (
        id        INTEGER      NOT NULL
                            PRIMARY KEY AUTOINCREMENT,
        name      VARCHAR (25) NOT NULL,
        join_date DATE         NOT NULL,
        CONSTRAINT models_yerrormutation_unique_name UNIQUE (
            name
        )
    );" \
    "CREATE UNIQUE INDEX ymutation_e_name_bb292a_idx ON ymutation_error(name);"

for file_name in ./ymutation/ymutation??.csv; do
    sqlite3 ymutations.sqlite3 ".mode csv" ".import $file_name ymutation"
done
sqlite3 ymutations.sqlite3 ".mode csv" ".import ./ymutation/ymutation_error.csv ymutation_error"
