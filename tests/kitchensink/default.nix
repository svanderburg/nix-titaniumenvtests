{ titaniumenv, fetchgit, target, release ? false
, rename ? false, stdenv ? null, newBundleId ? null, iosMobileProvisioningProfile ? null, iosCertificate ? null, iosCertificateName ? null, iosCertificatePassword ? null, iosVersion ? null
, enableWirelessDistribution ? false, installURL ? null
}:

assert rename -> (stdenv != null && newBundleId != null && iosMobileProvisioningProfile != null && iosCertificate != null && iosCertificateName != null && iosCertificatePassword != null);

let
  src = fetchgit {
    url = https://github.com/appcelerator/kitchensink-v2.git;
    rev = "b931e4e993a67367fe6ec51ec9a73e7dd807bd54";
    sha256 = "1x2hlc4vgkc2xj7pai61avp4x3m1lsq8zyww9lswmns1v51qyixs";
  };

  # Rename the bundle id to something else
  renamedSrc = stdenv.mkDerivation {
    name = "KitchenSink-renamedsrc";
    inherit src;
    buildPhase = ''
      sed -i -e "s|com.appcelerator.kitchensink|${newBundleId}|" tiapp.xml
    '';
    installPhase = ''
      mkdir -p $out
      mv * $out
    '';
  };
in
titaniumenv.buildApp {
  name = "KitchenSink-${target}-${if release then "release" else "debug"}";
  src = if rename then renamedSrc else src;

  preBuild = ''
    sed -i -e "s|8.2.0.GA|8.3.2.GA|" tiapp.xml
  '';

  inherit target release;

  androidKeyStore = ./keystore;
  androidKeyAlias = "myfirstapp";
  androidKeyStorePassword = "mykeystore";

  inherit iosMobileProvisioningProfile iosCertificate iosCertificateName iosCertificatePassword iosVersion;
  inherit enableWirelessDistribution installURL;

  androidsdkArgs = {
    platformVersions = [ "29" ];
  };
}
