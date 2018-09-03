$tests = Get-ChildItem .\0* -Filter "*spec.js" -Recurse
$totalAgents = [int]$Env:System_TotalJobsInPhase
$agentNumber = [int]$Env:System_JobPositionInPhase
$testCount = $tests.Count

Write-Host "Total agents: $totalAgents"
Write-Host "Agent number: $agentNumber"
Write-Host "Total tests: $testCount"
mkdir .\junitReports

if ($totalAgents -eq 0) {
    For ($i = 0; $i -le $testCount; $i++) {
        $file = $tests[$i]
        Write-Host "Executing $file"
        & ".\node_modules\.bin\mocha" $($file.FullName) --reporter mocha-multi-reporters --reporter-options configFile=config.json
        cp ".\testresults\*.xml" ".\junitReports\test-results$i.xml"
    }
}
else {
    For ($i = $agentNumber; $i -le $testCount; ) {
        $file = $tests[$i - 1]
        Write-Host "Executing $file"
        & ".\node_modules\.bin\mocha" $($file.FullName) --reporter mocha-multi-reporters --reporter-options configFile=config.json
        cp ".\testresults\*.xml" ".\junitReports\test-results$i.xml"
        $i = $i + $totalAgents
    }
}
