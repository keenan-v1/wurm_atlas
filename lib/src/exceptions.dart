import 'package:wurm_atlas/src/layer.dart';
import 'package:wurm_atlas/src/layer_type.dart';

/// Exception thrown when a validation fails.
///
/// Used by [Layer.validate] and [Layer.validateSync] to indicate that the
/// layer file is not valid.
///
/// See Also:
/// - [Layer] for the layer class
/// - [LayerType] for the layer type enum, which includes validation data
///
class ValidationException implements Exception {
  /// The message indicating why the validation failed.
  final String message;

  ValidationException(this.message);
}


class OutOfBoundsException implements Exception {
  final String message;
  final int? x;
  final int? y;
  final int? position;

  OutOfBoundsException(this.message, {this.x, this.y, this.position});
}
