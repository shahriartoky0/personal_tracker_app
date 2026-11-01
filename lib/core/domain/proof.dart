/// A proof image that is ready to be attached: stored app-private on device,
/// with the final storage path (`<userId>/<uuid>.<ext>`) already chosen.
class PreparedProof {
  const PreparedProof({required this.path, required this.localFile});
  final String path;
  final String localFile;
}
