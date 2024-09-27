# Define paths
$piactlPath = "C:\Program Files\Private Internet Access\piactl"
$vboxManagePath = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$vmName = "kali-linux-2024.2-virtualbox-amd64"  # Replace with your actual VirtualBox VM name

# Get the port number from PIA
$portNumber = & "$piactlPath" get portforward

# Check if the port number is valid
if ($portNumber -match '^\d+$') {
    Write-Output "Retrieved port number: $portNumber"
    
    # Check if the VM is running
    $vmStatus = & "$vboxManagePath" showvminfo "$vmName" --machinereadable | Select-String -Pattern 'VMState="running"'
    
    if ($vmStatus) {
        Write-Output "VM is running. Updating port forwarding rule..."
        
        # Update the port forwarding rule in VirtualBox while VM is running
        & "$vboxManagePath" controlvm $vmName natpf1 delete "guestssh" 2>$null # Remove the existing rule if it exists
        & "$vboxManagePath" controlvm $vmName natpf1 "guestssh,tcp,,$portNumber,,8000"
        Write-Output "Port forwarding updated successfully!"
    } else {
        Write-Output "VM is not running. Updating port forwarding rule in the configuration..."
        
        # Update the port forwarding rule in VirtualBox while VM is off
        & "$vboxManagePath" modifyvm $vmName --natpf1 delete "guestssh" 2>$null # Remove the existing rule if it exists
        & "$vboxManagePath" modifyvm $vmName --natpf1 "guestssh,tcp,,$portNumber,,8000"
        Write-Output "Port forwarding updated successfully in VM configuration!"
    }
} else {
    Write-Output "Failed to retrieve a valid port number."
}