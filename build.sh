#!/bin/bash

cd ./public
find . -mindepth 1 ! -name CNAME -delete
cd ../

git submodule update --init --recursive
hugo
