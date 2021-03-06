Nix Titanium environment tests
==============================
This package provides facilities to test the
[Kitchensink v2](https://github.com/appcelerator/kitchensink-v2) test
application so that all supported Nix build functionality can be
tested.

Prerequisites
=============
In order to run the examples, you must have the
[Nix package manager](http://nixos.org/nix) installed and a copy of
[Nixpkgs](http://nixos.org/nixpkgs). Consult the Nix manual for more details on
this.

Usage
=====
There are a variety of build artefacts that can be produced with the Nix
package manager.

Building an Android app
-----------------------
With the following command, a debug version of an Android APK can be produced:

```bash
$ nix-build -A kitchensink_android_debug.x86_64-linux
```

A production version (with minified JavaScript code) can be produced as
follows:

```bash
$ nix-build -A kitchensink_android_release.x86_64-linux
```

Running the Android app in the emulator
---------------------------------------
It is also possible to generate a shell script that launches an Android emulator
running an app.

A script for the debug version of the Android app can be generated as follows:

```bash
$ nix-build -A emulate_kitchensink_debug.x86_64-linux
```

A release version can be generated by running:

```bash
$ nix-build -A emulate_kitchensink_release.x86_64-linux
```

The result is a shell script that can be launched as follows:

```bash
$ ./result/bin/run-test-emulator
```

Building for the iOS simulator
------------------------------
A build for the iOS simulator can be built as follows:

```bash
$ nix-build -A kitchensink_ios_development
```

Running the iOS app in the simulator
------------------------------------
A shell script that lauches the iOS simulator for the app can be generated as
follows:

```bash
$ nix-build -A simulate_kitchensink
$ ./result/bin/run-test-simulator
```

Building an IPA for test or release purposes
--------------------------------------------
It is also possible to produce an IPA archive for testing purposes on real
devices or submission to the app store.

The app can be renamed to match the bundle id in the corresponding mobile
provisioning profile that is required for signing:

```bash
$ nix-build --arg rename true \
  --argstr newBundleId "com.mycompany.kitchensink" \
  --arg iosMobileProvisioningProfile /Users/sander/adhoc.mobileprovision \
  --arg iosCertificate /Users/sander/MyCertificate.p12 \
  --argstr iosCertificateName "My Company" \
  --argstr iosCertificatePassword "" \
  -A kitchensink_ipa
```
