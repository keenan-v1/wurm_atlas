// Import BenchmarkBase class.
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:wurm_atlas/wurm_atlas.dart';

class ReadTileBenchmark extends BenchmarkBase {

  ReadTileBenchmark() : super('ReadTile');

  Layer layer = Layer(LayerType.top, 'assets/happy_map');

  static void main() {
    ReadTileBenchmark().report();
  }

  @override
  void run() {
    layer.imageSync(0, 0, 256, 256);
  }

  @override
  void setup() {
    layer.openSync();
  }

  @override
  void teardown() {
    layer.closeSync();
  }
}

void main() {
  // Run TemplateBenchmark
  ReadTileBenchmark.main();
}