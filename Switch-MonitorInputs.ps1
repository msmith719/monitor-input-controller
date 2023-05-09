<#
.SYNOPSIS
Swiches monitor to specified inputs
.DESCRIPTION
Uses NirSoft's ControlMyMonitor to change the monitor input via a PowerShell function rather than manually changing the input source on the monitor. This is helpful when you have more than one monitor and need to switch between inputs frequently. The command can be run without explicitly specifying the device/device group; will set based on the defauls in "else".
Download ControlMyMonitor from https://www.nirsoft.net/utils/control_my_monitor.html
.PARAMETER  Device
This is the device name or device group name that is used in the if/ifelse/else to specify which device(s) should be set to which input.
.EXAMPLE
Switch-MonitorInputs 3rdMonDesktop
.EXAMPLE
Switch-MonitorInputs Desktop
.EXAMPLE
Switch-MonitorInputs Laptop
.EXAMPLE
Switch-MonitorInputs
.INPUTS
None
.OUTPUTS
None
#>
function Switch-MonitorInputs {
    param (
        [Parameter(Mandatory = $false)] [ValidateSet("Desktop", "Laptop", "3rdMonDesktop", "3rdMonLaptop")]
        $Device
    )
    
    #########################################
    # --------- BEGIN Custom Inputs ---------
    #########################################

    #Monitor names found in the ControlMyMonotor app in the top drop down menu for the monitor 
    #selector between the model number and \\.\DISPLAY...
    #The \\.\DISPLAY1\Monitor0 name will work too, but can change from time to time if a monitor 
    #is disconnected and reconnected
    $MonNameSamsungLeft = "HNAW201368" #Left Samsung 4k display
    $MonNameSamsungRight = "H1AK500000" #Right Samsung 4k display
    $MonNameHP24Left = "CNK7410QLS" #3rd Monitor
    $MonNameHP24Right = "CNK7500YPK"

    #Where the ControlMyMonitor files live
    $MonToolPath = "c:\tools\controlmymonitor" 
    
    #Determining VCP codes for the inputs requires looking in the ControlMyMonitor 
    #app and some trial and error
    # For Samsung 32" 4K UR59C monitor VCP input codes - DisplayPort: 15, HDMI: 6
    $Samsung_HDMI = 6
    $Samsung_DisplayPort = 15
    # HP 24uh monitor VCP input codes - VGA: 1, DVI:3, HDMI: 17
    $HP_HDMI = 17
    $HP_DVI = 3
    $HP_VGA = 1

    $hostnameLaptop = "umc"
    $hostnameDesktop = "neb"

    #########################################
    # ---------- END Custom Inputs ----------
    #########################################

    function Set-MonitorInputs {
        param (
            [String]$Monitor,
            [int]$InputCode
        )
        
        $MonTool = "$MonToolPath\ControlMyMonitor.exe"

        #60 is the VCP code for Input/Source
        Start-Process $MonTool -ArgumentList "/SetValue $Monitor 60 $InputCode"
    }

    if ($Device -eq "3rdMonDesktop") {
        #Set 3rd monitor to Desktop
        Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_DVI
    }
    elseif ($Device -eq "3rdMonLaptop") {
        #Set 3rd monitor to Laptop
        Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_HDMI
    }
    elseif ($Device -eq 'Laptop') {
        #Set inputs for Laptop
        Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_HDMI
        Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_DisplayPort        
        Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_HDMI
    }
    elseif ($Device -eq 'Desktop') {
        #Set Inputs for Desktop
        Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_DisplayPort
        Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_HDMI
        Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_DVI
    }
    else {
        if ((hostname) -like "$hostnameLaptop*") {
            #Set Inputs for Desktop
            Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_DisplayPort
            Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_HDMI
            Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_DVI
        }
        elseif ((hostname) -like "$hostnameDesktop*") {
            #Set inputs for Laptop
            Set-MonitorInputs -Monitor $MonNameSamsungLeft -InputCode $Samsung_HDMI
            Set-MonitorInputs -Monitor $MonNameSamsungRight -InputCode $Samsung_DisplayPort        
            Set-MonitorInputs -Monitor $MonNameHP24Left -InputCode $HP_HDMI
        }
        else {
            Write-Error "Condition not meet. Edit/Troubleshoot the script."
        }  
    }      
}