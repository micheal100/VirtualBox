
function Get-VirtualBox{
    <#
            .SYNOPSIS
            Get the VirtualBox service

            .DESCRIPTION
            Create a PowerShell object for the VirtualBox COM object.

   
            .OUTPUTS
            COM Object

            .EXAMPLE
            PS C:\> $vbox=Get-VirtualBox
            Create a variable $vbox to referece the VirtualBox service

            .LINK
            Get-VBoxMachine
            Stop-VBoxMachine
            Start-VBoxMachine
            Suspend-VBoxMachine

            .NOTES
            NAME        :  Get-VirtualBox
            VERSION     :  0.1
            LAST UPDATED:  
            AUTHOR      :  Original code by Jeffrey Hicks, updated by Michael Halpin

    #>

    [OutputType([__ComObject])]
    Param
    ()

    Begin
    {
        Write-Verbose -Message "Starting $($myinvocation.mycommand)"
    }
    Process
    {
        #create vbox app
        Write-Verbose -Message 'Creating the VirtualBox COM object'
        $vbox = New-Object -ComObject 'VirtualBox.VirtualBox'

        $vbox 
    }
    End
    {
        Write-Verbose -Message "Ending $($myinvocation.mycommand)"
    }
}


function Get-VirtualBoxMachine{
    <#
            .SYNOPSIS
            Get a VirtualBox virtual machine
            .DESCRIPTION
            Retrieve any or all vritual box machines by name, by state or all. The default usage, without any parameters is to display all running virtual machines. Use -IncludeRaw to add the native COM object for the virtual machine.
            .PARAMETER Name
            The name of a virtual machine. IMPORTANT: Names are case sensitive.
            .PARAMETER All
            Return all virtual machines regardless of state. Valid values are:
            "Stopped","Running","Saved","Teleported","Aborted","Paused","Stuck","Snapshotting",
            "Starting","Stopping","Restoring","TeleportingPausedVM","TeleportingIn","FaultTolerantSync",
            "DeletingSnapshotOnline","DeletingSnapshot", and "SettingUp"
            .PARAMETER State
            Return virtual machines based on their state.
            .PARAMETER IncludeRaw
            Include the raw or native COM object for the virtual machine.

            .INPUTS
            Strings for virtual machine names
            .OUTPUTS
            Custom Object

            .EXAMPLE
            Example of how to run the script

            .LINK
            Links to further documentation

            .NOTES
            NAME        :  Get-VBoxMachine
            VERSION     :  0.1
            LAST UPDATED:  
            AUTHOR      :  Michael Halpin

    #>

    [CmdletBinding(DefaultParameterSetName = 'All')]
    [OutputType([PSObject])]
    Param
    (
        #Name of the VMs
        [Parameter(ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true, 
        Position = 0,
        ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Name,
        
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,
        
        #Don't set default, only filter if needed, otherwise show all
        [ValidateSet('Stopped','Running','Saved','Teleported','Aborted',
                'Paused','Stuck','Snapshotting','Starting','Stopping',
                'Restoring','TeleportingPausedVM','TeleportingIn','FaultTolerantSync',
        'DeletingSnapshotOnline','DeletingSnapshot','SettingUp')]
        [string]$State,
        
        [switch]$IncludeRaw


    )

    Begin
    {
        Write-Verbose -Message "Starting $($myinvocation.mycommand)"
        
        #always vbox variable, in case changes to VMs since last set             
        $vbox = Get-VirtualBox
    }
    Process
    {
        if ($Name) 
        {
            #get virtual machines by name
            Write-Verbose -Message 'Getting virtual machines by name'
            #initialize an array to hold virtual machines
            $vmachines = @()
            foreach ($item in $Name) 
            {
                Write-Verbose -Message "Finding $item"
                try
                {
                  # Content
                  $vmachines += $vbox.FindMachine($item)
                }
                catch
                {
                  "Error was $_"
                  $line = $_.InvocationInfo.ScriptLineNumber
                  "Error was in Line $line"
                }
                
                
                
            }
        } #if -all or if no parameter passed, default to all VMs
        elseif ($psCmdlet.ParameterSetName  -like 'All' )
        {
            #get all machines
            Write-Verbose -Message 'Getting all virtual machines'
            $vmachines = $vbox.Machines
        }

        #filter VMs by state, regardless of if -name or -all
        if ($State) 
        {
            Write-Verbose -Message "Getting virtual machines with a state of $State"

            #convert State to numeric value
            Switch ($state) {
                'Stopped'                {$istate =  1}
                'Saved'                  {$istate =  2}
                'Teleported'             {$istate =  3}
                'Aborted'                {$istate =  4}
                'Running'                {$istate =  5}
                'Paused'                 {$istate =  6}
                'Stuck'                  {$istate =  7}
                'Snapshotting'           {$istate =  8}
                'Starting'               {$istate =  9}
                'Stopping'               {$istate = 10}
                'Restoring'              {$istate = 11}
                'TeleportingPausedVM'    {$istate = 12}
                'TeleportingIn'          {$istate = 13}
                'FaultTolerantSync'      {$istate = 14}
                'DeletingSnapshotOnline' {$istate = 15}
                'DeletingSnapshot'       {$istate = 16}
                'SettingUp'              {$istate = 17}

            }

            $vmachines = $vbox.Machines | Where-Object {
                $_.State -eq $istate
            }
        }

        Write-Verbose -Message "Found $(($vmachines | Measure-Object).count) virtual machines"
        if ($vmachines) 
        {
            #write a virtual machine object to the pipeline
            foreach ($vmachine in $vmachines) 
            {
                #Decode state
                Switch ($vmachine.State) {
                    1 {$vstate = 'Stopped'}
                    2 {$vstate = 'Saved'}
                    3 {$vstate = 'Teleported'}
                    4 {$vstate = 'Aborted'}
                    5 {$vstate = 'Running'}
                    6 {$vstate = 'Paused'}
                    7 {$vstate = 'Stuck'}
                    8 {$vstate = 'Snapshotting'}
                    9 {$vstate = 'Starting'}
                    10 {$vstate = 'Stopping'}
                    11 {$vstate = 'Restoring'}
                    12 {$vstate = 'TeleportingPausedVM'}
                    13 {$vstate = 'TeleportingIn'}
                    14 {$vstate = 'FaultTolerantSync'}
                    15 {$vstate = 'DeletingSnapshotOnline'}
                    16 {$vstate = 'DeletingSnapshot'}
                    17 {$vstate = 'SettingUp'}

                    Default {$vstate = $vmachine.State}
                }

                $obj = New-Object -TypeName PSObject -Property @{
                    Name        = $vmachine.name
                    State       = $vstate
                    Description = $vmachine.description
                    ID          = $vmachine.ID
                    OS          = $vmachine.OSTypeID
                    CPUCount    = $vmachine.CPUCount
                    MemoryMB    = $vmachine.MemorySize
                }
                if ($IncludeRaw) 
                {
                    #add raw COM object as a property
                    $obj | Add-Member -MemberType Noteproperty -Name Raw -Value $vmachine -passthru
                }
                else {$obj}
            } #foreach
        } #if vmachines
        else 
        {
            throw 'No matching virtual machines found. Machine names are CaSe SenSitIve.'
        }
    }
    End
    {
        Write-Verbose -Message "Ending $($myinvocation.mycommand)"
    }
}

