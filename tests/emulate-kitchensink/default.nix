{androidenv, kitchensink}:

androidenv.emulateApp {
  name = "emulate-${kitchensink.name}";
  app = kitchensink;
  platformVersion = "23";
  package = "com.appcelerator.kitchensink";
  activity = ".KitchensinkActivity";
  systemImageType = "google_apis";
  abiVersion = "armeabi-v7a";
}
