#!/bin/bash

mkdir ./dist
dart compile exe ./bin/ehneko.dart -o ./dist/ehneko
cp -r ./rules ./dist/
cp ./run.sh ./dist/
