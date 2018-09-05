<#  
.SYNOPSIS  
    Distribute the tests in VSTS pipeline across multiple agents 
.DESCRIPTION  
    This script slices tests files across multiple agents for faster execution.
    We search for specific type of file structure (in this example *spec.js), and slice them according to agent number
    If we encounter multiple files [file1..file10] and if we have 2 agents, agent1 executes tests odd number of files while agent2 executes even number of files
    We use JUnit test results to publish the test reports.
#>

$tests = Get-ChildItem .\0* -Filter "*spec.js" -Recurse # search for test files with specific pattern.
$totalAgents = [int]$Env:SYSTEM_TOTALJOBSINPHASE # standard VSTS variables available using parallel execution; total number of parallel jobs running
$agentNumber = [int]$Env:SYSTEM_JOBPOSITIONINPHASE # current job position
$testCount = $tests.Count

Write-Host "Total agents: $totalAgents"
Write-Host "Agent number: $agentNumber"
Write-Host "Total tests: $testCount"
mkdir .\junitReports # create temporary directory to copy all test reports for publishing them

# below conditions are used if parallel pipeline is not used. i.e. pipeline is running with single agent (no parallel configuration)
if ($totalAgents -eq 0) {
    $totalAgents = 1
}
if (!$agentNumber -or $agentNumber -eq 0) {
    $agentNumber = 1
}

# slice test files to make sure each agent gets unique test file to execute
For ($i = $agentNumber; $i -le $testCount; ) {
    $file = $tests[$i - 1]
    Write-Host "Executing $file"
    & ".\node_modules\.bin\mocha" $($file.FullName) --reporter mocha-multi-reporters --reporter-options configFile=config.json
    cp ".\testresults\*.xml" ".\junitReports\test-results$i.xml" # copy test reports to publish them after the test execution is completed
    $i = $i + $totalAgents
}
