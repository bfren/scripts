# THE MIT LICENSE (MIT)
#
# Copyright © 2020 bcg|design
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the “Software”), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


$Version = "0.1.2012091256"


# ======================================================================================================================
# Configuration
# ======================================================================================================================

$LogRoot = "C:\Users\Administrator\Documents\Backup Logs"


# ======================================================================================================================
# Set variables
# ======================================================================================================================

$Today = Get-Date -UFormat "%y%m%d"
$LogFile="$LogRoot\$Today.log"


# ======================================================================================================================
# Define Functions
# ======================================================================================================================

function OutputAndLog {
    Param([String]$Text)

    $Time = Get-Date -UFormat "%Y-%m-%d %H:%M"

    "$Time | $Text" | Write-Output
    "$Time | $Text" | Out-File -FilePath $LogFile -Append
}


# ======================================================================================================================
# Start
# ======================================================================================================================

OutputAndLog "Starting all VMs (start script version $Version)"
Write-Host "Logging to $LogFile"


# ======================================================================================================================
# Get all VMs...
#   Where AutomaticStartAction is set to 'Start'
#   Start VM
# ======================================================================================================================

$VMs = Get-VM | Where-Object {$_.AutomaticStartAction -eq "Start"}
foreach ($VM in $VMs)
{
    OutputAndLog "Starting $VM..."
    Start-VM -VM $VM
    
    OutputAndLog "complete."
}

OutputAndLog "done."
