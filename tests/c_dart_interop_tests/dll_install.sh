#!/bin/bash

# atchops
cmake -S atchops -B atchops
sudo cmake --build atchops

# srv
cmake -S srv -B srv
sudo cmake --build srv
