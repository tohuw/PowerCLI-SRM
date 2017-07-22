# PowerCLI-SRM

## DEPRECATED
Use the built-in PowerCLI SRM support. This was from a simpler time when no such support existed. If you're stranded in that sort of version, Ben Meadowcroft wrote better support than I ever managed out of this project. It remains merely as a historical curiosity.

## What is this?
This project is **a PowerShell script module for the VMware Site Recovery Manager API**. VMware Site Recovery Manager (SRM) has an API for interfacing and retrieving data, and sending certain commands. The end objective of this project is to provide appropriate PowerShell cmdlets for each significant capability of the SRM API (versions 5.8 and above).

## Current Status
Currently working on fleshing out the retrievable objects through a set of Get-All{Object} cmdlets, *a la* Get-AllGPOs from Microsoft's Group Policy module. From there, individual Get cmdlets can be factored out of this base. Then, the file ought to be converted to a script module (psm), with the attendant metadata. Once all this is done, the next step will be Set cmdlets. I need to create a visual mapping of target cmdlets to API functions, which would help flesh out a real roadmap. In the meantime, this summary will do.

## How Can I Help?
Have a read through the [official SRM API documentation](https://www.vmware.com/support/developer/srm-api/srm_61_api.pdf) and take a look at the current open Issues on this project. Any insight is greatly appreciated.
