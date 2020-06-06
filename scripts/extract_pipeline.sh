#!/usr/bin/env bash


mkdir ../data/training
mkdir ../data/validation
mkdir ../data/testing

bash extract_tar_files.sh ../data/tar_files/training/ ../data/training/
bash extract_tar_files.sh ../data/tar_files/validation/ ../data/validation/
bash extract_tar_files.sh ../data/tar_files/testing/ ../data/testing/