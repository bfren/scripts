# Copyright (c) bfren - licensed under https://mit.bfren.dev/2020


$Version = "0.2.2006211130"


# ======================================================================================================================
# Configuration
# ======================================================================================================================

$BackupRoot = ""
$LogRoot = ""
$Days = 14


# ======================================================================================================================
# Set variables
# ======================================================================================================================

$Today = Get-Date -UFormat "%y%m%d"
$BackupPath="$BackupRoot\$Today"
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

OutputAndLog "Starting new backup (backup script version $Version)"
Write-Host "Logging to $LogFile"


# ======================================================================================================================
# Get all VMs with Checkpoints enabled...
#   Create a checkpoint
#   Export the snapshot to backup path
#   Remove the snapshot (to save space)
# ======================================================================================================================

$VMs = Get-VM | Where-Object {$_.CheckpointType -ne "Disabled"}
foreach ($VM in $VMs)
{
    OutputAndLog "$VM"

    OutputAndLog " .. creating checkpoint"
    $Snapshot = $VM | Checkpoint-VM -Passthru

    OutputAndLog " .. exporting to '$BackupPath'"
    $Snapshot | Export-VMSnapshot -Path $BackupPath

    OutputAndLog " .. removing snapshot"
    $Snapshot | Remove-VMSnapshot
    
    OutputAndLog "complete."
}


# ======================================================================================================================
# Delete all old backups...
#   Get all files in backup root
#   Where last write time was more than $days ago
#   Remove item
# ======================================================================================================================

OutputAndLog "Cleaning VM backups older than $Days days in $BackupRoot..."

$Files = Get-ChildItem -Path $BackupRoot -Recurse | Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Days)}
foreach ($File in $Files)
{
    OutputAndLog " .. removing $File"
    $File | Remove-Item
}

OutputAndLog "done"