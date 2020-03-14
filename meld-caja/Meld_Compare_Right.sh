#!/bin/bash

left_file=$(cat ~/.compare_left)

meld "$left_file" "$PWD/$1"