{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" "x86_64-darwin" ]
, xcodeVersion ? "9.3"
, xcodeBaseDir ? "/Applications/Xcode.app"
, tiVersion ? "7.1.0.GA"
, rename ? false
, newBundleId ? "com.example.kitchensink", iosMobileProvisioningProfile ? null, iosCertificate ? null, iosCertificateName ? "Example", iosCertificatePassword ? "", iosVersion ? "11.3"
, enableWirelessDistribution ? false, installURL ? null
}:

let
  pkgs = import nixpkgs {};
  pkgs_i686 = import nixpkgs { system = "i686-linux"; };
in
rec {
  kitchensink_android_debug = pkgs.lib.genAttrs systems (system:
  let
    pkgs = import nixpkgs { inherit system; };

    titaniumenv = import ./.. {
      inherit pkgs pkgs_i686 tiVersion;
    };
  in
  import ./kitchensink {
    inherit (pkgs) fetchgit;
    inherit titaniumenv;
    target = "android";
  });
  
  kitchensink_android_release = pkgs.lib.genAttrs systems (system:
  let
    pkgs = import nixpkgs { inherit system; };

    titaniumenv = import ./.. {
      inherit pkgs pkgs_i686 tiVersion;
    };
  in
  import ./kitchensink {
    inherit (pkgs) fetchgit;
    inherit titaniumenv;
    target = "android";
    release = true;
  });
  
  emulate_kitchensink_debug = pkgs.lib.genAttrs systems (system:
  let
    pkgs = import nixpkgs { inherit system; };

    androidenv = import ../../nix-androidenvtests/androidenv {};
  in
  import ./emulate-kitchensink {
    inherit androidenv;
    kitchensink = builtins.getAttr system kitchensink_android_debug;
  });
  
  emulate_kitchensink_release = pkgs.lib.genAttrs systems (system:
  let
    pkgs = import nixpkgs { inherit system; };
  in
  import ./emulate-kitchensink {
    inherit (pkgs) androidenv;
    kitchensink = builtins.getAttr system kitchensink_android_release;
  });
  
} // (if builtins.elem "x86_64-darwin" systems then 
  let
    pkgs = import nixpkgs { system = "x86_64-darwin"; };
    titaniumenv = import ./.. {
      inherit pkgs pkgs_i686 tiVersion;
    };
  in
  rec {
  kitchensink_ios_development = import ./kitchensink {
    inherit (pkgs) fetchgit;
    inherit iosVersion titaniumenv;
    target = "iphone";
  };

  simulate_kitchensink =
  let
    xcodeenv = import ../../nix-xcodeenvtests/xcodeenv {
      inherit (pkgs) stdenv;
    };
  in
  import ./simulate-kitchensink {
    inherit xcodeenv;
    kitchensink = kitchensink_ios_development;
    bundleId = if rename then newBundleId else "com.appcelerator.kitchensink";
  };
} else {}) // (if rename then
  let
    pkgs = import nixpkgs { system = "x86_64-darwin"; };
    titaniumenv = import ./.. {
      inherit pkgs pkgs_i686 tiVersion;
    };
  in
  {
    kitchensink_ipa = import ./kitchensink {
      inherit (pkgs) stdenv fetchgit;
      inherit titaniumenv;
      target = "iphone";
      release = true;
      rename = true;
      inherit newBundleId iosMobileProvisioningProfile iosCertificate iosCertificateName iosCertificatePassword iosVersion;
      inherit enableWirelessDistribution installURL;
    };
  }

else {})
