# goodkey-downloads

Official hub for GoodKey installation files

## Windows Installation

To install GoodKey on Windows, download the installation file from the official
hub and follow the on-screen instructions.

## Important Note for Windows Users

In some cases, you may encounter a critical error warning after system startup,
leading to a system restart. This issue may be related to the `gkcertsvc.dll`
component. To resolve this, you can disable the certificate provider by running
the following command in an administrator terminal:

```
regsvr32.exe /u gkcertsvc.dll
```

Please note that this should only be done if you are experiencing the
aforementioned issue, as it may affect other functionalities of the GoodKey
software.
