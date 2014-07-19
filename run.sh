#!/bin/bash

# -proc:{none,only}          Control whether annotation processing and/or compilation is done.
# -processor <class1>[,<class2>,<class3>...] Names of the annotation processors to run; bypasses default discovery process
# -processorpath <path>      Specify where to find annotation processors

javac -cp "target/classes:target/dependency/*" -proc:only src/test/java/cucumber/examples/java/calculator/*
