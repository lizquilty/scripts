#!/bin/bash
echo mencoder -idx $1 -ovc copy -oac copy -o $2
