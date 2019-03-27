try {
    Write-ChocolateySuccess 'Installing wsl'
    choco install -y Microsoft-Windows-Subsystem-Linux --source="'windowsfeatures'"
} catch {
  Write-ChocolateyFailure 'MyPackage' $($_.Exception.Message)
  throw
}
