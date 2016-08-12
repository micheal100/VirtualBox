# this is a Pester test file

Import-Module -Name $env:VirtualBoxModule 
# describes the function Get-VirtualBox
Describe -Name 'Get-VirtualBox' -Fixture {

  # scenario 1: call the function without arguments
  Context 'Running without arguments'   {
    # test 1: it does not throw an exception:
    It 'runs without errors' {
      # Gotcha: to use the "Should Not Throw" assertion,
      # make sure you place the command in a 
      # scriptblock (braces):
      { Get-VirtualBox } | Should Not Throw
    }
    It 'returns a com object' {
       $(Get-VirtualBox).gettype().Name | Should be '__ComObject'
    }
    it 'returns a number of machines'{
      $VirtualBox = Get-VirtualBox
      $VirtualBox.machines.Count -ge 0  | should be  $true
    }
  }
}

# describes the function Get-VirtualBoxMachine
Describe 'Get-VirtualBoxMachine' {

  # scenario 1: call the function without arguments
  Context 'Running without arguments'   {
     # test 1: it does not throw an exception:
     It 'should run without error' {
      #  
      { Get-VirtualBoxMachine } | Should not throw
    }
    #test system should always have VMs running, so objects should be returned
    It 'defaults to use -all, so should return objects' {
      $(Get-VirtualBoxMachine).gettype().name | Should be 'object[]'      
    }
    
  }
  #scenario 2: use -all parameter set
  Context 'Running with -all'   {
     # test 1: it does not throw an exception:
     It 'should run without error' {
      #  
      { Get-VirtualBoxMachine -all} | Should not throw
    }
    #test system should always have VMs, so objects should be returned
    It 'returns all VMs' {
      (Get-VirtualBoxMachine -all).count -eq ((Get-Virtualbox).machines.count) | Should be  $True     
    }
    
    #the 'vmUbuntu' should be only running VM in test
    It 'only return a single running vm' {
      (Get-VirtualBoxMachine -all -state Running).name  | Should be 'vmUbuntu'
    }
  }

  #scenario 3: use -name parameter set
  Context 'Running with -name'   {
     # test 1: it does not throw an exception:
     It 'should run throw an error when no name is specified' {
      #  
      { Get-VirtualBoxMachine -name } | Should  throw
    }
    #test system should always have VMs, so objects should be returned
    It 'returns a single VM when a name is passed' {
      (Get-VirtualBoxMachine -name 'vmUbuntu').name -like 'vmUbuntu'  | Should be  $True     
    }
    
    #throw an exception if no machine matching criteria is found
    It 'should throw an error with an invalid name is passed' {
      {Get-VirtualBoxMachine -name 'doesnotexist'} | Should  throw 
    }

    #test system should always have VMs, so objects should be returned
    It 'return return multiple VMs' {
      (Get-VirtualBoxMachine -name  'vmUbuntu', 'vm2012-01'  ).count -eq 2 | Should be  $True     
    }
  }
}

Remove-Module VirtualBox 