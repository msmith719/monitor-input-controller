function Switch-MonitorInputs {
    param (
        [Parameter(Mandatory=$false)] [ValidateSet("Desktop","Laptop","3rdMonDesktop","3rdMonLaptop")]
        $Device
    )
    
    #Monitor names found in the ControlMyMonotor app in the top drop down menu for the monitor 
    #selector between the model number and \\.\DISPLAY...
    #The \\.\DISPLAY1\Monitor0 name will work too, but can change from time to time if a monitor 
    #is disconnected and reconnected
    $MonNameSamsungLeft = "H1AK500000"
    $MonNameSamsungRight = "HNAW201368"
    $MonNameHP24in = "CNK7500YPK"

    function Set-MonitorInputs {
        param (
            [String]$Monitor,
            $InputCode
        )
        
        $MonToolPath = "c:\tools\controlmymonitor"
        $MonTool = "$MonToolPath\ControlMyMonitor.exe"
        
        #60 is the VCP code for Input/Source
        Start-Process $MonTool -ArgumentList "/SetValue $Monitor 60 $InputCode"
    }

    #Determining VCP codes for the inputs takes looking in the ControlMyMonitor 
    #app and some trial and error
    # For Samsung 32UR59C monitor VCP input codes - DisplayPort: 15, HDMI: 6
    $Samsung_HDMI = 6
    $Samsung_DisplayPort = 15
    # HP 24uh monitor VCP input codes - VGA: 1, DVI:3, HDMI: 17
    $HP_HDMI = 17
    $HP_DVI = 3

    if ($Device -eq "3rdMonDesktop") {
        #Set 3rd monitor to Desktop
        Set-MonitorInputs -Monitor $MonNameHP24in -InputCode $HP_DVI
    }
    elseif ($Device -eq "3rdMonLaptop") {
        #Set 3rd monitor to Laptop
        Set-MonitorInputs -Monitor $MonNameHP24in -InputCode $HP_HDMI
    }
    elseif ($Device -eq 'Laptop') {
        #Set inputs for Laptop
        Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_DisplayPort
        Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_HDMI
        Set-MonitorInputs -Monitor $MonNameHP24in -InputCode $HP_HDMI
    }
    else {
        #Set Inputs for Desktop
        Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_HDMI
        Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_DisplayPort
        Set-MonitorInputs -Monitor $MonNameHP24in -InputCode $HP_DVI
    }
}