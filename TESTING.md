# GoodKey Desktop Client: A Comprehensive Guide for Testers

## Introduction

This guide provides detailed instructions on using the GoodKey desktop client for cryptographic operations. It covers setting up the client, integrating its PKCS#11 module with various applications, and performing signing and verification tasks. This comprehensive guide is designed to help testers replicate procedures efficiently and effectively.

## Table of Contents

- [GoodKey Desktop Client: A Comprehensive Guide for Testers](#goodkey-desktop-client-a-comprehensive-guide-for-testers)
  - [Introduction](#introduction)
  - [Table of Contents](#table-of-contents)
  - [Downloading and Installing the GoodKey Client](#downloading-and-installing-the-goodkey-client)
    - [Allowing Installation of an Untrusted Application](#allowing-installation-of-an-untrusted-application)
  - [Setting Up the GoodKey Client](#setting-up-the-goodkey-client)
    - [Checking Authentication Status](#checking-authentication-status)
    - [Registering the Client via Browser](#registering-the-client-via-browser)
    - [Registering with an Extended Access Token](#registering-with-an-extended-access-token)
    - [Verifying Authentication](#verifying-authentication)
  - [Managing Keys and Certificates](#managing-keys-and-certificates)
    - [Listing Available Keys](#listing-available-keys)
    - [Listing Available Certificates](#listing-available-certificates)
  - [Integrating GoodKey PKCS#11 Module with Applications](#integrating-goodkey-pkcs11-module-with-applications)
    - [Adobe Acrobat Reader](#adobe-acrobat-reader)
      - [Adding the PKCS#11 Provider](#adding-the-pkcs11-provider)
      - [Signing a Document](#signing-a-document)
    - [Using `pkcs11-tool`](#using-pkcs11-tool)
      - [Listing Objects on the Device](#listing-objects-on-the-device)
      - [Listing Supported Mechanisms](#listing-supported-mechanisms)
      - [Signing and Verifying Data](#signing-and-verifying-data)
        - [RSA Algorithm](#rsa-algorithm)
        - [ECDSA Algorithm](#ecdsa-algorithm)
    - [Fortify](#fortify)
  - [Windows Integration](#windows-integration)
    - [`signtool`](#signtool)
      - [Listing Certificates in the My Store](#listing-certificates-in-the-my-store)
      - [Obtaining a valid Code Signing Certificate](#obtaining-a-valid-code-signing-certificate)
      - [Signing Files with `signtool`](#signing-files-with-signtool)
        - [Adding `signtool` to the PATH Environment Variable](#adding-signtool-to-the-path-environment-variable)
        - [Signing an Executable File](#signing-an-executable-file)
        - [Verifying a Signature](#verifying-a-signature)
  - [Conclusion](#conclusion)

## Downloading and Installing the GoodKey Client

To begin using the GoodKey desktop client, download the latest version from the official GitHub releases page:

- [GoodKey Downloads](https://github.com/PeculiarVentures/goodkey-downloads/releases)

### Allowing Installation of an Untrusted Application

**Note:** The GoodKey application is currently unsigned. You will need to allow the installation of an untrusted application on your system. Please follow your operating system's guidelines for installing unsigned applications.

- **Windows:** You may receive a warning from SmartScreen. Click **More info** and then **Run anyway**.
- **macOS:** You might see a message stating the app can't be opened because it is from an unidentified developer. Go to **System Preferences** > **Security & Privacy** > **General**, and click **Open Anyway**.

## Setting Up the GoodKey Client

The GoodKey client allows users to manage cryptographic keys and certificates associated with their GoodKey account. Before integrating it with applications, ensure that the client is properly installed and authenticated.

### Checking Authentication Status

To verify if the GoodKey client is authenticated, open your terminal or command prompt and run:

```bash
gkutils auth status
```

**Expected Output if Not Authenticated:**

```bash
rpc error: code = Unknown desc = Client for GoodKey Server is not initialized. Run 'gkutils auth register' to authenticate.
```

### Registering the Client via Browser

1. **Initiate the Registration Process:**

   ```bash
   gkutils auth register
   ```

2. **Authenticate via Browser:**

   - A browser window will open automatically.
   - Log in to your GoodKey account.
   - Authorize the client when prompted.
   - Approve any prompts to open the application from the browser.

3. **Complete Registration:**

   - Return to the terminal.
   - The client should now be registered and authenticated.

### Registering with an Extended Access Token

Alternatively, you can register the client using an Extended Access Token obtained from your GoodKey account.

1. **Obtain an Extended Access Token** from your GoodKey account settings.

2. **Register the Client with the Token:**

   ```bash
   gkutils auth register -t <YourAccessToken>
   ```

   Replace `<YourAccessToken>` with your actual token.

### Verifying Authentication

After registration, check the authentication status again:

```bash
gkutils auth status
```

**Expected Output:**

```bash
Authenticated as:
  ID:         fc02a79e-280e-4e8e-aacc-81b1cf37ccdb
  First Name: Stepan
  Last Name:  Miroshin
  Email:      microshine@peculiarventures.com
```

## Managing Keys and Certificates

Once authenticated, you can manage your cryptographic assets using the GoodKey client.

### Listing Available Keys

To view all keys associated with your account:

```bash
gkutils key list
```

**Sample Output:**

```bash
Keys:
  ID:      021c9cf9-c9f3-4da6-b948-ae2c501b9fbd
  Name:    RSA 2048
  Type:    rsa2048
  Status:  active

  ID:      22db28de-ef40-4d10-8f0d-013750883ce9
  Name:    EC P-256
  Type:    ecP256
  Status:  active
```

### Listing Available Certificates

To view all certificates associated with your account:

```bash
gkutils cert list
```

**Sample Output:**

```bash
Certificates:
  ID:      0ab05e8a-abba-46e7-8145-056b28985863
  Type:    x509
  Name:    Self-Signed for EC P-256
  Has Key: true

  ID:      88b78152-1065-49f2-a1be-9aee11e9e46a
  Type:    x509
  Name:    Self-Signed for RSA 2048
  Has Key: true
```

## Integrating GoodKey PKCS#11 Module with Applications

The GoodKey client includes a PKCS#11 module (`gkp11.dll` for Windows and `gkp11.so` for macOS/Linux) that enables integration with various applications for cryptographic operations.

### Adobe Acrobat Reader

Adobe Acrobat Reader can utilize the GoodKey PKCS#11 module to digitally sign PDF documents.

#### Adding the PKCS#11 Provider

1. **Launch Adobe Acrobat Reader.**

2. **Access Preferences:**

   - **Windows:** Click **Edit** > **Preferences**.
   - **macOS:** Click **Acrobat Reader** > **Preferences**.

3. **Navigate to Signature Settings:**

   - Select **Signatures** from the left sidebar.
   - Under **Identities & Trusted Certificates**, click **More...**.

4. **Attach the PKCS#11 Module:**

   - In the **Digital ID and Trusted Certificate Settings** window, select **Digital IDs** on the left.
   - Click **PKCS#11 Modules and Tokens**.
   - Click **Attach Module...**.
   - Browse and select the PKCS#11 library:
     - **Windows:** `C:\Windows\System32\gkp11.dll`
     - **macOS/Linux:** `/usr/local/lib/gkp11.so`
   - Click **Open**, then **OK** to confirm.

#### Signing a Document

1. **Open the PDF Document** you wish to sign.

2. **Prepare the Form:**

   - Go to **Tools** > **Prepare Form**.
   - Use the **Add a Digital Signature Field** tool to place a signature field in the document.

3. **Exit Prepare Form Mode:**

   - Click **Close** in the **Prepare Form** toolbar.

4. **Sign the Document:**

   - Click on the signature field you added.
   - In the **Sign with a Digital ID** dialog, select your certificate from the GoodKey PKCS#11 module.
   - If prompted for a password, enter any value (GoodKey does not require a password).
   - Follow the on-screen instructions to complete the signing process.
   - Save the signed document.

> **Note:** Adobe Acrobat Reader does not support ECDSA signatures. Use an RSA certificate for signing.

### Using `pkcs11-tool`

The `pkcs11-tool` utility allows command-line interaction with PKCS#11 modules for various cryptographic operations.

#### Listing Objects on the Device

To display all objects (keys, certificates) on the GoodKey PKCS#11 module:

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so -O
```

#### Listing Supported Mechanisms

To list all cryptographic mechanisms supported by the GoodKey PKCS#11 module:

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so -M
```

#### Signing and Verifying Data

##### RSA Algorithm

**Signing Data with RSA:**

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so --sign \
  -m SHA256-RSA-PKCS \
  --id <RSA_KEY_ID> \
  --input-file data.txt \
  --output-file signature.bin
```

**Verifying RSA Signature:**

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so --verify \
  -m SHA256-RSA-PKCS \
  --id <RSA_KEY_ID> \
  --input-file data.txt \
  --signature-file signature.bin
```

Replace `<RSA_KEY_ID>` with your RSA key's identifier.

##### ECDSA Algorithm

**Signing Data with ECDSA:**

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so --sign \
  -m ECDSA-SHA256 \
  --id <EC_KEY_ID> \
  --input-file data.txt \
  --output-file signature.bin
```

**Verifying ECDSA Signature:**

```bash
pkcs11-tool --module /usr/local/lib/gkp11.so --verify \
  -m ECDSA-SHA256 \
  --id <EC_KEY_ID> \
  --input-file data.txt \
  --signature-file signature.bin
```

Replace `<EC_KEY_ID>` with your ECDSA key's identifier.

### Fortify

Fortify is a cryptographic library that supports PKCS#11 modules. To configure Fortify to use the GoodKey PKCS#11 module:

1. **Locate the Fortify Configuration File:**

   ```bash
   ~/.fortify/config.json
   ```

2. **Edit the Configuration File:**

   ```bash
   nano ~/.fortify/config.json
   ```

3. **Add GoodKey as a Provider:**

   Insert the following JSON snippet into the `providers` array:

   ```json
   {
     "providers": [
       {
         "name": "GoodKey",
         "lib": "/usr/local/lib/gkp11.so",
         "slots": [0]
       }
     ]
   }
   ```

4. **Save and Close the File.**

5. **Test the Configuration:**

   - Visit the [Fortify Examples Page](https://peculiarventures.github.io/fortify-examples/example5.html).
   - Select **GoodKey** as the provider.
   - Choose a certificate for signing.
   - Enter a message and click **Sign**.

**Note:** On Windows, GoodKey certificates will also be available in Fortify through the system provider.

## Windows Integration

### `signtool`

The `signtool` utility in Windows is used for signing code and verifying digital signatures. With GoodKey integrated into the My store and CNG (Cryptography Next Generation) provider, you can utilize it for signing operations seamlessly.

#### Listing Certificates in the My Store

To display all certificates available in the My store, including GoodKey certificates, use the following PowerShell command:

```powershell
Get-ChildItem -Path Cert:\CurrentUser\My
```

**Example Output:**

```powershell
PS C:\Users\micro\github\pv\goodkey-service-app> Get-ChildItem -Path Cert:\CurrentUser\My

   PSParentPath: Microsoft.PowerShell.Security\Certificate::CurrentUser\My

Thumbprint                                Subject
----------                                -------
F8AF4D207C1D3745B5DB8BF390E3C6438614DC3E  C=US, O=GoodKey, CN=Code Signing EC P-256
C628BEF7CAA5220C8F5D7D632B62ACA303EDFFF1  C=US, O=GoodKey, CN=Code Signing RSA 2048
970951B167FD919C5548B9D128FC8352184D8556  CN=localhost
086A6D22D7D41776AE3DF8553D0B9E1D2EB71307  CN=3cf91281-5803-43af-92a0-7b90c3f43a87
```

**Note:** The `certutil -store -user My` command does not display certificates from the GoodKey provider.

#### Obtaining a valid Code Signing Certificate

To use `signtool`, you need valid certificates that have code signing capabilities. If you do not have such a certificate, follow these steps:

1. **Request a Certificate on the GoodKey Website:**

   - Visit the GoodKey website and submit a certificate request.

2. **Issue the Certificate:**

   - Navigate to the [GoodKey Demo CA](https://peculiarventures.github.io/goodkey-demo-ca/) website.
   - Issue a certificate with the **Code Signing** profile.

3. **Install the Issued Certificate:**

   - Install the issued certificate on the GoodKey website by adding it to the key's certificates.

**Important:** To ensure the certificate is trusted, it must be in the list of trusted certificates. If it is not, install it in the trusted certificates store.

#### Signing Files with `signtool`

GoodKey certificates in the My store can be used with `signtool` to sign files.

##### Adding `signtool` to the PATH Environment Variable

If the `signtool` utility is not recognized in the terminal, you need to add its path to the `PATH` environment variable. The path depends on the installed version of the Windows Kit. For example:

```powershell
$env:PATH += ";C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64"
```

**Note:** Adjust the version number (`10.0.22621.0`) to match the installed version of the Windows Kit on your system.

**Important:** If you run the signing command from the Visual Studio Developer Command Prompt, the utility may not detect certificates from the GoodKey provider.

##### Signing an Executable File

Use the following command to sign an executable file:

```cmd
signtool sign /sha1 <Thumbprint> /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 /v .\data.ps1
```

Replace `<Thumbprint>` with the thumbprint of your GoodKey certificate (e.g., `f8af4d207c1d3745b5db8bf390e3c6438614dc3e`). This command signs the file `data.ps1` with SHA-256 and adds a timestamp from the specified URL.

##### Verifying a Signature

To verify the signature on a file, use the following command:

```cmd
signtool verify /pa /v data.ps1
```

This command verifies the signature on `data.ps1` using the certificate chain in the My store.

## Conclusion

This guide provides a structured approach for testers to set up and utilize the GoodKey desktop client effectively. By following the instructions, testers can:

- Download and install the GoodKey client.
- Authenticate and register the client.
- Manage cryptographic keys and certificates.
- Integrate the GoodKey PKCS#11 module with applications like Adobe Acrobat Reader, `pkcs11-tool`, and Fortify.
- Perform signing and verification operations using both RSA and ECDSA algorithms.
- Utilize GoodKey certificates with Windows utilities like `signtool`, leveraging its integration as a CNG key and certificate provider.

**Note:** The GoodKey application is currently unsigned. When installing, you may receive warnings about installing an untrusted application. Please follow your operating system's instructions to allow the installation of unsigned software.
