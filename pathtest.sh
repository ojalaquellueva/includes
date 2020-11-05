#!/bin/bash


####################################################
# Source or run this file to test different methods
# detecting file path
####################################################


method1=($_)
method2=$(pwd)
method3=${BASH_SOURCE[0]}
method4=$(dirname ${BASH_SOURCE[0]})
method5=${method2}"/${method4#.}"
method6=${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}



echo "-----------------------------------------------------"
echo "Test of methods of determining path of current script"
echo "-----------------------------------------------------"
echo ""
echo "method1: '"$method1"'"
echo "method2: '"$method2"'"
echo "method3: '"$method3"'"
echo "method4: '"$method4"'"
echo "method5: '"$method5"'"
echo "method6: '"$method6"'"
echo ""
