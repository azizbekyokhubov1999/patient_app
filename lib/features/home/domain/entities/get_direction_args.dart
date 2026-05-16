/// Arguments for future in-app directions / navigation flow.
class GetDirectionArgs {
  const GetDirectionArgs({
    required this.hospitalId,
    required this.hospitalName,
    required this.geoPoint,
  });

  final String hospitalId;
  final String hospitalName;
  final dynamic geoPoint;
}
