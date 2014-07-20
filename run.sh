#!/bin/bash

# Usage: ./run.sh <src dir>

find $1 -name "*.java" -print | xargs javac -cp "target/classes:target/dependency/*" -proc:only

