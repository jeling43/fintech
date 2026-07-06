/// Metadata about a PDF import operation.
class ImportMetadata {
  final String id;
  final String filename;
  final String sha256Hash;
  final DateTime importedAt;
  final int pageCount;
  final bool usedOcr;
  final String? errorMessage;

  const ImportMetadata({
    required this.id,
    required this.filename,
    required this.sha256Hash,
    required this.importedAt,
    required this.pageCount,
    this.usedOcr = false,
    this.errorMessage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'sha256Hash': sha256Hash,
      'importedAt': importedAt.toIso8601String(),
      'pageCount': pageCount,
      'usedOcr': usedOcr,
      'errorMessage': errorMessage,
    };
  }

  factory ImportMetadata.fromMap(Map<String, dynamic> map) {
    return ImportMetadata(
      id: map['id'] as String,
      filename: map['filename'] as String,
      sha256Hash: map['sha256Hash'] as String,
      importedAt: DateTime.parse(map['importedAt'] as String),
      pageCount: map['pageCount'] as int,
      usedOcr: map['usedOcr'] as bool? ?? false,
      errorMessage: map['errorMessage'] as String?,
    );
  }
}
