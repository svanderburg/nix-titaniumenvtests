{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" "x86_64-darwin" ]
, xcodeVersion ? "9.3"
, xcodeBaseDir ? "/Applications/Xcode.app"
, tiVersion ? "7.5.1.GA"
, rename ? false
, newBundleId ? "com.example.kitchensink", iosMobileProvisioningProfile ? null, iosCertificate ? null, iosCertificateName ? "Example", iosCertificatePassword ? "", iosVersion ? "12.1"
, enableWirelessDistribution ? false, installURL ? null
, useUpstream ? false
}:

let
  pkgs = import nixpkgs {};
  pkgs_i686 = import nixpkgs { system = "i686-linux"; };

  getTitaniumEnv = pkgs:
    if useUpstream then pkgs.titaniumenv else import ../titaniumenv {
      inherit pkgs pkgs_i686 tiVersion;
    };

  getAndroidEnv = pkgs:
    if useUpstream then pkgs.androidenv else import ../../nix-androidenvtests/androidenv {
      inherit pkgs pkgs_i686;
    };

  getXcodeEnv = pkgs:
    if useUpstream then pkgs.xcodeenv else import ../../nix-xcodeenvtests/xcodeenv {
      inherit (pkgs) stdenv;
    };
in
rec {
  kitchensink_android_debug = pkgs.lib.genAttrs systems (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    import ./kitchensink {
      inherit (pkgs) fetchgit;
      titaniumenv = getTitaniumEnv pkgs;
      target = "android";
    });

  kitchensink_android_release = pkgs.lib.genAttrs systems (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    import ./kitchensink {
      inherit (pkgs) fetchgit;
      titaniumenv = getTitaniumEnv pkgs;
      target = "android";
      release = true;
    });

  emulate_kitchensink_debug = pkgs.lib.genAttrs systems (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    import ./emulate-kitchensink {
      androidenv = getAndroidEnv pkgs;
      kitchensink = builtins.getAttr system kitchensink_android_debug;
    });

  emulate_kitchensink_release = pkgs.lib.genAttrs systems (system:
    let
      pkgs = import nixpkgs { inherit system; };
    in
    import ./emulate-kitchensink {
      androidenv = getAndroidEnv pkgs;
      kitchensink = builtins.getAttr system kitchensink_android_release;
    });
  } // (if builtins.elem "x86_64-darwin" systems then 
    let
      pkgs = import nixpkgs { system = "x86_64-darwin"; };
    in
    rec {
    kitchensink_ios_development = import ./kitchensink {
      inherit (pkgs) fetchgit;
      inherit iosVersion;
      titaniumenv = getTitaniumEnv pkgs;
      target = "iphone";
    };

    simulate_kitchensink = import ./simulate-kitchensink {
      xcodeenv = getXcodeEnv pkgs;
      kitchensink = kitchensink_ios_development;
      bundleId = if rename then newBundleId else "com.appcelerator.kitchensink";
    };
} else {}) // (if rename then
  let
    pkgs = import nixpkgs { system = "x86_64-darwin"; };
  in
  {
    kitchensink_ipa = import ./kitchensink {
      inherit (pkgs) stdenv fetchgit;
      target = "iphone";
      titaniumenv = getTitaniumEnv pkgs;
      release = true;
      rename = true;
      inherit newBundleId iosMobileProvisioningProfile iosCertificate iosCertificateName iosCertificatePassword iosVersion;
      inherit enableWirelessDistribution installURL;
    };
  }
else {})
