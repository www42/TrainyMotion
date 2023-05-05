# Origin

The template is copied from [here](https://github.com/az140mp/azure-quickstart-templates/tree/master/demos/nested-vms-in-virtual-network). The bicep part only has been copied, ARM json files have been omitted.

# My Changes

```bicep
param _artifactsLocation string = deployment().properties.templateLink.uri
param _artifactsLocation string = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization'
param _artifactsLocation string = 'https://github.com/www42/TrainyMotion/tree/master/NestedVirtualization/dsc/dscinstallwindowsfeatures.zip'
```