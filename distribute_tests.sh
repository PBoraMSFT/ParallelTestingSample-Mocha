#!/bin/bash

shopt -s globstar nullglob
tests=( "0"*/**/*"spec.js" ) ## search folders starting with 0 and contains test pattern

IFS=$'\n' tests=($(sort <<<"${tests[*]}"))
unset IFS

totalAgents=$SYSTEM_TOTALJOBSINPHASE
agentNumber=$SYSTEM_JOBPOSITIONINPHASE
testCount=${#tests[@]}

if [ $totalAgents -eq 0 ]; then totalAgents=1; fi ##this is to handle multi agent disabled.
if [ -z "$agentNumber" ]; then agentNumber=1; fi

echo "Total agents: $totalAgents"
echo "Agent number: $agentNumber"
echo "Total test files: $testCount"
mkdir ./junitReports

for (( i=$agentNumber; i<=$testCount; ))
do
    file=${tests[$i-1]}
    echo "Executing" "$(printf "./$file")"
    ./node_modules/.bin/mocha "$(printf "./$file")" --reporter mocha-multi-reporters --reporter-options configFile=config.json
    mv ./testresults/test-results.xml "$(printf "./junitReports/test-results$i.xml")"
    i=$(($i+$totalAgents))
done