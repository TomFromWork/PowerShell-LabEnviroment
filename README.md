# PowerShell-LabEnviroment
A PowerShell module for creating Hyper-V VM's in my enviroment.

### How to use
- Copy module folder to `C:\Program Files\WindowsPowerShell\Modules`

### Modules
- `New-LabSwitch -Verbose`
  - Creates a new external switch.
- `New-LabVm -Name 'TestLab' -verbose`
  - Creates a new VM with the name "TestLab".
- `New-LabVhd -Name TestVhd -AttachToVm TestLab`.
  - Creates a new 50GB VHD and attaches it to the VM "TestLab".
