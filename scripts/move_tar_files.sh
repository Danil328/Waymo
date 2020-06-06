#!/usr/bin/env bash

cd ../data/tar_files

mkdir training
mkdir validation
mkdir testing

mv training_00* training
mv validation_00* validation
mv testing_00* testing