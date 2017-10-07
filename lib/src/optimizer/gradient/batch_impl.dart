part of 'package:dart_ml/src/implementation.dart';

class _BGDOptimizerImpl extends _GradientOptimizerImpl implements BGDOptimizer {

  _BGDOptimizerImpl({
    double learningRate,
    double minWeightsDistance,
    int iterationLimit,
    Regularization regularization,
    double alpha,
    double argumentIncrement
  }) : super(
    learningRate: learningRate,
    minWeightsDistance: minWeightsDistance,
    iterationLimit: iterationLimit,
    regularization: regularization,
    alpha: alpha,
    argumentIncrement: argumentIncrement
  );

  @override
  Iterable<int> _getSamplesRange(int totalSamplesCount) => [0, totalSamplesCount];
}
