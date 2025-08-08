# Set the background color
$Host.UI.RawUI.BackgroundColor = "Black"

# Set the text color
$Host.UI.RawUI.ForegroundColor = "Green"


# Add current directory to PATH
$env:PATH += ";$PWD"


# Define commands and their descriptions
$adbCommands = @(

   
 
@{ Description = "List all connected devices"; Command = "adb devices" }

    
    
@{ "Description" = "Get device IP address"; "Command" = "adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }" }


    
@{ "Description" = "Connect headset wirelessly"; "Command" = "adb tcpip 5555; Start-Sleep -s 3; `$ips = @(adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }); Write-Output `$ips; if (`$ips.Count -gt 0) { adb connect ('{0}:5555' -f `$ips[0].Trim()) } else { Write-Output 'Could not determine device IP address.' }" }



@{ "Description" = "Disconnect headset wirelessly"; "Command" = "adb tcpip 5555; Start-Sleep -s 3; `$ips = @(adb shell ip route | Select-String -Pattern 'src ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' | ForEach-Object { `$_.Matches.Groups[1].Value }); Write-Output `$ips; if (`$ips.Count -gt 0) { adb disconnect ('{0}:5555' -f `$ips[0].Trim()) } else { Write-Output 'Could not determine device IP address.' }" }


 
@{ "Description" = "Install base.apk"; "Command" = "adb install base.apk" }


    
@{ "Description" = "List all third party packages"; "Command" = "adb shell cmd package list packages -3" }
    

    
@{ "Description" = "Get app version number"; "Command" = "`$packageName = Read-Host 'Enter package name'; (adb shell dumpsys package `$packageName | findstr versionCode) -replace '.*versionCode=([0-9]+).*', '`$1'" }


    
@{ "Description" = "Find package path"; "Command" = "`$packageName = Read-Host 'Enter package name'; adb shell pm path `$packageName" }
   
    

@{ "Description" = "base.apk file size check"; "Command" = "`$packageName = Read-Host 'Enter package name'; `$packagePath = (adb shell pm path `$packageName).Trim().Replace('package:', ''); `$output = adb shell du -m `$packagePath; `$output | ForEach-Object { `$_ -replace '`t', ' ' } | ForEach-Object { `$(`$_ -split ' ')[0] + ' MB ' + `$(`$_ -split ' ')[1] }" }


    
@{ "Description" = "Pull base.apk"; "Command" = "`$packageName = Read-Host 'Enter package name'; `$packagePath = (adb shell pm path `$packageName).Trim().Replace('package:', ''); adb pull `$packagePath" }


    
@{ "Description" = "Uninstall Program"; "Command" = "`$packageName = Read-Host 'Enter package name'; adb uninstall `$packageName" }

    

@{ "Description" = "List OBB folders"; "Command" = "adb shell ls /storage/emulated/0/Android/obb/" }
    
    

@{ "Description" = "List OBB file sizes"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb shell du -m /storage/emulated/0/Android/obb/`$obbFolder/* | ForEach-Object { `$_ -replace '`t', ' ' } | ForEach-Object { `$(`$_ -split ' ')[0] + ' MB ' + `$(`$_ -split ' ')[1] }" }
    
    

@{ "Description" = "Pull OBB folder"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb pull /storage/emulated/0/Android/obb/`$obbFolder" }
    
    

@{ "Description" = "Push OBB folder"; "Command" = "`$obbFolder = Read-Host 'Enter OBB folder name'; adb push `$obbFolder /storage/emulated/0/Android/obb/" }

    
    
@{ "Description" = "Take screenshot"; "Command" = "adb shell screencap -p /sdcard/screenshot.png; adb pull /sdcard/screenshot.png" }

    
    
@{ "Description" = "Start screen recording"; "Command" = "Start-Job -ScriptBlock { adb shell screenrecord /sdcard/video.mp4 }" }

    
    
@{ "Description" = "Stop screen recording & pull video"; "Command" = "adb shell pkill -2 screenrecord; sleep 3; adb pull /sdcard/video.mp4" }

    
    
@{ "Description" = "Clear log"; "Command" = "adb logcat -c" }

    
    
@{ "Description" = "Pull log"; "Command" = "adb shell setprop log.tag.Unity DEBUG; adb logcat -d > log.txt" }

    
    
@{ "Description" = "Pull Android Manifest"; "Command" = "aapt2 dump xmltree base.apk --file AndroidManifest.xml > AndroidManifest.txt" }

    
    
@{ "Description" = "Get package name"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'package: name=').Line.Split('''')[1]; if (`$output) { `$output } else { 'not applicable' }" }



@{ "Description" = "Get install location"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'install-location'); if (`$output) { `$output.Line } else { 'not applicable' }" }



@{ "Description" = "Check android.hardware.vr.headtracking"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'android.hardware.vr.headtracking'); if (`$output) { `$output.Line } else { 'not applicable' }" }



@{ "Description" = "Check Min and Target SDK versions"; "Command" = "`$output = aapt2 dump badging base.apk | Where-Object { `$_ -match 'sdkVersion:' -or `$_ -match 'targetSdkVersion:' }; if (`$output) { `$output -join ""`n"" } else { 'not applicable' }" }



@{ "Description" = "List all features used"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'uses-feature'); if (`$output) { `$output.Line } else { 'not applicable' }" }



@{ "Description" = "List all permissions used"; "Command" = "`$output = aapt2 dump permissions base.apk; if (`$output) { `$output } else { 'not applicable' }" }



@{ "Description" = "64-bit binary check"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'native-code'); if (`$output) { `$output.Line } else { 'not applicable' }" }



@{ "Description" = "Debuggable status"; "Command" = "`$output = (aapt2 dump badging base.apk | Select-String 'android:debuggable', 'application-debuggable'); if (`$output) { `$output.Line } else { 'not applicable' }" }



@{ "Description" = "Verify APK signature"; "Command" = "`$env:JAVA_HOME = 'C:\Program Files\Java\jdk-24'; `$env:Path += ';C:\Program Files\Java\jdk-24\bin'; `$env:JDK_JAVA_OPTIONS = '--enable-native-access=ALL-UNNAMED'; apksigner verify --verbose base.apk" }



@{ "Description" = "Install the OVR Metrics Tool"; "Command" = "adb install OVRMetricsTool_v1.6.5.apk" }

    

@{ "Description" = "Pull OVR performance logs"; "Command" = "adb pull sdcard/Android/data/com.oculus.ovrmonitormetricsservice/files/CapturedMetrics" }

    

@{ "Description" = "To open OVR"; "Command" = "adb shell am start omms://app" }

    

@{ "Description" = "Enable OVR overlay"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_OVERLAY" }

    

@{ "Description" = "Enable OVR Render Scale graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_GRAPH --es stat render_scale" }

    

@{ "Description" = "Disable OVR overlay"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.DISABLE_OVERLAY" }
    


@{ "Description" = "Enable OVR Asynchronous Spacewarp graph"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_GRAPH --es stat spacewarped_frames_per_second" }
    


@{ "Description" = "Record OVR metrics to CSV file"; "Command" = "adb shell am broadcast -n com.oculus.ovrmonitormetricsservice/.SettingsBroadcastReceiver -a com.oculus.ovrmonitormetricsservice.ENABLE_CSV" }


    
@{ "Description" = "Find the Oculus VR Shell versionCode"; "Command" = "`$output = (adb shell dumpsys package com.oculus.vrshell | Select-String 'versionCode'); if (`$output) { `$output.Line } else { 'not applicable' }" }


    
@{ "Description" = "Get device serial number"; "Command" = "adb shell getprop ro.serialno" }


    
@{ "Description" = "Reboot device"; "Command" = "adb reboot" }



@{ "Description" = "Enable WiFi on device"; "Command" = "adb shell svc wifi enable" }



@{ "Description" = "Disable WiFi on device"; "Command" = "adb shell svc wifi disable" }



@{ "Description" = "Get headset temperature"; "Command" = "`$t = (adb shell dumpsys battery | findstr temperature | Select-Object -First 1) -replace '[^\d]', ''; if ([string]::IsNullOrWhiteSpace(`$t)) { Write-Output 'Temperature not found' } else { ([math]::Floor([int]`$t / 10)).ToString() + '.' + ([int]`$t % 10) + ' C' }" }



@{ "Description" = "Pull .csv Performance log";
  "Command" = "`$packageName = Read-Host 'Enter package name'; `$profileDataStarted = `$false; `$headers = `$null; `$data = @(); adb shell dumpsys gfxinfo `$packageName framestats | ForEach-Object { if (`$_ -match '^---PROFILEDATA---$') { `$profileDataStarted = !`$profileDataStarted } elseif (`$profileDataStarted) { if (`$null -eq `$headers) { `$headers = `$_ -split ','; `$headers = `$headers | ForEach-Object { `$_.Trim().Replace(' ', '_').Replace('-', '_') } } else { `$values = `$_ -split ','; `$obj = [PSCustomObject]@{}; for (`$i = 0; `$i -lt `$headers.Count; `$i++) { if (`$headers[`$i] -ne '') { `$obj | Add-Member -MemberType NoteProperty -Name `$headers[`$i] -Value `$values[`$i].Trim() } }; `$data += `$obj } } }; `$data | Export-Csv -Path 'performance_log.csv' -NoTypeInformation" }


    
@{ Description = "Pull Performance metrics";
    Command = "`$packageName = Read-Host 'Enter package name'; `$output = adb shell `"dumpsys cpuinfo | grep `$packageName; dumpsys meminfo `$packageName; dumpsys gfxinfo `$packageName framestats; dumpsys netstats | grep `$packageName; dumpsys batterystats | grep `$packageName; dumpsys SurfaceFlinger | grep `$packageName; dumpsys activity `$packageName`" | Set-Content performance_metrics.txt" }



@{ "Description" = "Low battery state simulation"; "Command" = "adb shell dumpsys battery set ac 0; adb shell dumpsys battery set usb 0; adb shell dumpsys battery set wireless 0; adb shell dumpsys battery set level 1; adb shell dumpsys battery unplug" }



@{ "Description" = "Turn off low battery state simulation"; "Command" = "adb shell dumpsys battery reset; adb shell settings put global low_power 0" }



@{ "Description" = "Custom command mode"; "Command" = "while (`$true) { `$command = Read-Host 'Enter custom command (or press Enter to exit)'; if (`$command -eq '') { Write-Host 'Exiting custom command mode.'; break }; `$output = cmd /c `$command 2>&1; `$output }" }



)


# Show menu
function Show-Menu {
    Clear-Host
    Write-Host "walrus VR"
    Write-Host "-------------------"
    $half = [math]::Floor($adbCommands.Count / 2)
    for ($i = 0; $i -lt $half; $i++) {
        Write-Host "$($i + 1). $($adbCommands[$i].Description)" -NoNewline
        Write-Host (" " * (40 - $adbCommands[$i].Description.Length)) -NoNewline
        if ($i + $half -lt $adbCommands.Count) {
            Write-Host "$($i + $half + 1). $($adbCommands[$i + $half].Description)"
        } else {
            Write-Host ""
        }
    }
    if ($adbCommands.Count % 2 -eq 1) {
        Write-Host "$($adbCommands.Count). $($adbCommands[-1].Description)"
    }
    $choice = Read-Host "Enter your choice"
    return $choice
}


# Function to run commands
function Run-ADBCommand {
    param ($index)
    $command = $adbCommands[$index].Command
    if ($adbCommands[$index].Params) {
        $params = @()
        foreach ($paramName in $adbCommands[$index].Params) {
            $paramValue = Read-Host "Enter $paramName"
            $params += $paramValue
        }
        Invoke-Expression "$command $($params -join ' ')"
    } else {
        Invoke-Expression $command
    }
    Write-Host "Command executed."
    Read-Host "Press Enter to continue..."
}

# Main loop
while ($true) {
    $choice = Show-Menu
    if ($choice -eq ($adbCommands.Count + 1).ToString()) {
        exit
    } elseif ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $adbCommands.Count) {
        Run-ADBCommand -index ([int]$choice - 1)
    } else {
        Write-Host "Invalid choice. Please try again."
        Start-Sleep -s 2
    }
}