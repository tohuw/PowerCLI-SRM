#PowerCLI-SRM
##A PowerShell Script Module for the VMware Site Recovery Manager API

VMware Site Recovery Manager (SRM) has an API for interfacing and retrieving data, and sending certain commands. The end objective of this project is to provide appropriate PowerShell cmdlets for each significant capability of the SRM API (versions 5.8 and above).

##Current Status
Currently working on fleshing out the retrievable objects through a set of Get-All{Object} cmdlets, *a la* Get-AllGPOs from Microsoft's Group Policy module. From there, individual Get cmdlets can be factored out of this base. Once all this is done, the next step will be Set cmdlets. I need to create a visual mapping of target cmdlets to API functions, which would help flesh out a real roadmap. In the meantime, this summary will do.

##How Can I Help?
Have a read through the [official SRM API documentation](https://www.vmware.com/support/developer/srm-api/srm_61_api.pdf) and take a look at the current open Issues on this project. Any insight is greatly appreciated.
