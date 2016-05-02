function Initialize-SrmApi($SrmServer, $SrmCredential = Get-Credential) {
    $SrmConnection = Connect-SrmServer -SrmServerAddress $SrmServer -Credential $SrmCredential
    $SrmApi = $SrmConnection.ExtensionData

    return $SrmApi
}

function Get-AllProtectionGroups($SrmApi) {
    $ProtectionGroupsData = $SrmApi.Protection.ListProtectionGroups()
    $ProtectionGroups = @()
    $ProtectionGroupsData | %{
        $ProtectionGroups += New-Object -TypeName PsObject -Property @{
            SrmId = $_.MoRef.ToString()
            Name = $_.GetInfo().Name
            Description = $_.GetInfo().Description
            Type = $_.GetInfo().Type
            SrmServer = $SrmServer
        }
    }

    return $ProtectionGroups
}

function Get-AllRecoveryPlans($SrmApi) {
    $RecoveryPlansData = $SrmApi.Recovery.ListPlans()
    $RecoveryPlans = @()
    foreach ($RecoveryPlanObject in $RecoveryPlansData) {
        $RecoveryPlans += New-Object -TypeName PsObject -Property @{
            SrmId = $RecoveryPlanObject.MoRef.ToString()
            Name = $RecoveryPlanObject.GetInfo().Name
            Description = $RecoveryPlanObject.GetInfo().Description
            State = $RecoveryPlanObject.GetInfo().State
            ProtectionGroups = $ProtectionGroups | ? SrmId -match $RecoveryPlanObject.GetInfo().ProtectionGroups.MoRef.ToString()
            SrmServer = $SrmServer
        }
    }

    return $RecoveryPlans
}

function Get-AllProtectedVMs($ProtectionGroupsData) {
    $ProtectedVMsData = $ProtectionGroupsData | %{ $_.ListProtectedVMs() }
    $ProtectedVMs = @()
    $ProtectedVMsData | %{
        $ProtectedVMs += New-Object -TypeName PsObject -Property @{
            # SRM has a unique ID for each protected VM, but this ID has no relation to the VM's ID as referenced by vCenter
            SrmId = $_.ProtectedVm
            Id = $_.VM.MoRef.ToString()
            # To obtain the VM object, the vCenter to which it belongs is needed as well, as VM IDs are not globally unique
            # The only reference I've found to the vCenter is in the URL used to query the SDK about the VM, so the following extracts that using a simple RegEx query
            # For some reason, other shells besides PowerCLI fail to populate the Vm.Client data, even if Initialize-PowerCLIEnvironement was run
            # Thus, it's best to run this from a true PowerCLI shell, at least for now
            Server = [regex]::Match($_.VM.Client.ServiceUrl,'(?<=\/\/)\w+')
            Name = Get-VM -Id $_.VM.MoRef.ToString()
            PeerVm = $_.PeerProtectedVm
            SrmServer = $SrmServer
        }
    }

    return $ProtectedVMs
}

function Get-AllInventoryMappings($ProtectionGroups) {
    $InventoryMappingsData = $SrmApi.Protection.ListInventoryMappings()
    $InventoryMappings = @()
    $InventoryMappings += New-Object -TypeName PsObject -Property @{
        Pools = $InventoryMappingsData.Pools | %{
            New-Object -TypeName PsObject -Property @{
                Id = $_.MoRef.ToString()
                Server = [regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')
                Name = Get-ResourcePool -Id $_.MoRef.ToString() -Server (([regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')).Value).Name
                SrmServer = $SrmServer
            }
        }
        Folders = $InventoryMappingsData.Folders | %{
            New-Object -TypeName PsObject -Property @{
                Id = $_.MoRef.ToString()
                Server = [regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')
                Name = Get-Folder -Id $_.MoRef.ToString() -Server (([regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')).Value).Name
                SrmServer = $SrmServer
            }
        }
       Networks = $InventoryMappingsData.Networks | %{
            New-Object -TypeName PsObject -Property @{
                Id = $_.MoRef.ToString()
                Server = ([regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+'))
                Name = Get-VDPortGroup -Id $_.MoRef.ToString() -Server (([regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')).Value).Name
                SrmServer = $SrmServer
            }
        }
        SrmServer = $SrmServer
    }

    return $InventoryMappings
}

function Get-AllProtectedDatastores {
    $ProtectedDatastoresData = $ProtectionGroupsData | %{ $_.ListProtectedDatastores() }
    $ProtectedDatastores = @()
    $ProtectedDatastoresData | %{
        $ProtectedDatastores += New-Object -TypeName PsObject -Property @{
            Id = $_.MoRef.ToString()
            Server = [regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')
            Name = (Get-Datastore -Id $_.MoRef.ToString() -Server ([regex]::Match($_.Client.ServiceUrl,'(?<=\/\/)\w+')).Name)
            SrmServer = $SrmServer
        }
    }

    return $ProtectedDatastores
}
