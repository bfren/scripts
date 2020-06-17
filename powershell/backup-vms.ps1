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


$Version = 0.1.2006171130


# ======================================================================================================================
# Configuration
# ======================================================================================================================

$BackupRoot = "P:\Snapshots"
$Days = 14


# ======================================================================================================================
# Set variables
# ======================================================================================================================

$Today = Get-Date -UFormat "%y%m%d"
$BackupPath="$BackupRoot\$Today"


# ======================================================================================================================
# Get all VMs...
#   Create a checkpoint
#   Export the snapshot to backup path
#   Remove the snapshot (to save space)
# ======================================================================================================================

Write-Host "Starting VM backup to $BackupPath..."
Get-VM `
| Checkpoint-VM -Passthru `
| Export-VMSnapshot -Path $BackupPath -Passthru `
| Remove-VMSnapshot


# ======================================================================================================================
# Delete all old backups...
#   Get all files in backup root
#   Where last write time was more than $days ago
#   Remove item
# ======================================================================================================================

Write-Host "Cleaning VM backups older than $Days days in $BackupRoot..."
Get-ChildItem -Path "$BackupRoot\*.*" -Recurse `
| Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Days)} `
| Remove-Item