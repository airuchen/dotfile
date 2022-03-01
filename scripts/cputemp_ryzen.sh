#!/bin/sh
sensors -A k10temp-pci-00c3 | awk 'FNR == 2 {print substr($2, 2)}'
