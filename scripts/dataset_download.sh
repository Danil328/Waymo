#!/usr/bin/env bash
cd ../data/
mkdir tar_files
cd tar_files
wget --load-cookies ../cookies.txt -i ../url.txt -nc