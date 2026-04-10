#!/bin/bash

file_path=$1
destination_path=$2

destination_file_path=$(readlink -m "$destination_path/$file_path")

mkdir -p "$(dirname "$destination_file_path")" && cp "$file_path" "$destination_file_path"
