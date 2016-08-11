# this is a Pester test file

Import-Module -Name $env:VirtualBoxModule -Verbose
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
    It 'runs throws an error' {
      # Gotcha: to use the "Should Not Throw" assertion,
      # make sure you place the command in a 
      # scriptblock (braces):
      { Get-VirtualBoxMachine } | Should Throw
    }
    It 'does something' {
      # call function Get-VirtualBoxMachine and pipe the result to an assertion
      # Example:
      # Get-VirtualBoxMachine | Should Be 'Expected Output'
      # Hint: 
      # Once you typed "Should", press CTRL+J to see
      # available code snippets. You can also click anywhere
      # inside a "Should" and press CTRL+J to change assertion.
      # However, make sure the module "Pester" is
      # loaded to see the snippets. If the module is not loaded yet,
      # no snippets will show.
    }
    # test 2: it returns nothing ($null):
    It 'does not return anything'     {
      Get-VirtualBoxMachine | Should BeNullOrEmpty 
    }
  }
}

Remove-Module VirtualBox