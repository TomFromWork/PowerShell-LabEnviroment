function New-LabSwitch {
    param(
        [Parameter()]
        [string]$SwitchName = 'LabSwitch',

        [Parameter()]
        [string]$AdapterName = 'Ethernet'
    )

    if (-not (Get-VMSwitch -Name $SwitchName -SwitchType 'External' -ErrorAction SilentlyContinue)) {
        $null = New-VMSwitch -Name $SwitchName -NetAdapterName $AdapterName
    } else {
        Write-Verbose -Message "The switch [$($SwitchName)] has already been created."
    }
}

function New-LabVm {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$Path = "D:\VM's\Hyper-V\",

        [parameter()]
        [string]$Memory = 4GB,

        [Parameter()]
        [string]$Switch = 'LabSwitch',

        [Parameter()]
        [ValidateRange(1, 2)]
        [int]$Generation = 2

    )

    if (-not (Get-Vm -Name $Name -ErrorAction SilentlyContinue)) {
        $null = New-VM -Name $Name -Path $Path -MemoryStartupBytes $Memory -SwitchName $Switch -Generation $Generation
    } else {
        Write-Verbose -Message 'The VM [$($Name)] has already has been created.'
    }
}

function New-LabVhd {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter()]
        [string]$AttachToVm,

        [Parameter()]
        [ValidateRange(512MB, 1TB)]
        [int64]$Size = 50GB,

        [Parameter()]
        [ValidateSet('Dynamic', 'Fixed')]
        [string]$Sizing = 'Dynamic',

        [Parameter()]
        [string]$Path = 'D:\VM''s\Hyper-V\VHDS\'
    )

    $vhdxFileName = "$Name.vhdx"
    $vhdxFilePath = Join-Path -Path $Path -ChildPath "$Name.vhdx"

    #### Tests to see if the VHD already exists
    if (-not (Test-Path -Path $vhdxFilePath -PathType Leaf)) {
        $params = @{
            SizeBytes = $Size
            Path = $vhdxFilePath
        }
        if ($Sizing -eq 'Dynamic') {
            $params.Dynamic = $true
        } elseif ($Sizing -eq 'Fixed') {
            $params.Fixed = $true
        }

        New-VHD @params
        Write-Verbose -Message "Created new VHD at path [$($vhdxFilePath)]"
    }

    if ($PSBoundParameters.ContainsKey('AttachToVm')) {
        if (-not ($vm = Get-VM -Name $AttachToVm -ErrorAction SilentlyContinue)) {  ### Checks to see if the VM exists
            Write-Warning -Message "The VM [$($AttachToVm)] does not exist. Unable to attach VHD."
        } elseif (-not ($vm | Get-VMHardDiskDrive | Where-Object {$_.Path -eq $vhdxFilePath})) {  ### VM exists but VHD hasn't been connected.
            $vm | Add-VMHardDiskDrive -Path $vhdxFilePath
            Write-Verbose -Message "Attached VHDX [$($vhdxFilePath)] to VM [$($AttachToVM)]."
        } else {  ### The VHD is already attached
            Write-Verbose -Message "VHDX [$($vhdxFilePath)] already attached to VM [$($AttachToVM)]." 
        }
    }
}