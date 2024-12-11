#!/bin/bash

find ./public -mindepth 1 ! -name CNAME -delete
hugo
