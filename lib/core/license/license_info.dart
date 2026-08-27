class LicenseInfo {
  const LicenseInfo({
    required this.deviceId,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String deviceId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  Map<String, dynamic> toPayloadJson() => {
    'd': deviceId,
    'i': issuedAt.toUtc().millisecondsSinceEpoch ~/ 1000,
    'e': expiresAt.toUtc().millisecondsSinceEpoch ~/ 1000,
  };

  factory LicenseInfo.fromPayloadJson(Map<String, dynamic> json) {
    final deviceId = (json['d'] as String?)?.trim().toUpperCase();
    final issuedSec = json['i'];
    final expiresSec = json['e'];
    if (deviceId == null ||
        deviceId.isEmpty ||
        issuedSec is! num ||
        expiresSec is! num) {
      throw FormatException('Invalid license payload.');
    }
    return LicenseInfo(
      deviceId: deviceId,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(
        issuedSec.toInt() * 1000,
        isUtc: true,
      ),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        expiresSec.toInt() * 1000,
        isUtc: true,
      ),
    );
  }
}
