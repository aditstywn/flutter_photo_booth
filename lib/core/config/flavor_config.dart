enum FlavorType { prod, dev }

class FlavorConfig {
  final String appName;
  final FlavorType flavor;

  FlavorConfig({this.flavor = FlavorType.dev, this.appName = 'Dosen DEV'}) {
    _instance = this;
  }

  static FlavorConfig? _instance;

  static FlavorConfig get instance => _instance ?? FlavorConfig();
}
