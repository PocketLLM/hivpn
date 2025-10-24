enum ConnectionQuality {
  excellent,
  good,
  fair,
  poor,
  offline,
}

extension ConnectionQualityX on ConnectionQuality {
  int get severity {
    switch (this) {
      case ConnectionQuality.excellent:
        return 0;
      case ConnectionQuality.good:
        return 1;
      case ConnectionQuality.fair:
        return 2;
      case ConnectionQuality.poor:
        return 3;
      case ConnectionQuality.offline:
        return 4;
    }
  }
}
