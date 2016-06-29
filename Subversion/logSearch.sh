#!/bin/bash

svn log | grep -i -B3 -A1 crd-8 | grep -A 1 '\-\-\-\-' | grep -E 'r[0-9]{1,}' | cut -d" " -f1 | sort | paste -sd ','