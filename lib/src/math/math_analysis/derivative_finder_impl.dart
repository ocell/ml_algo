part of 'package:dart_ml/src/implementation.dart';

class _DerivativeFinderImpl implements DerivativeFinder {
  List<Float32x4Vector> _argumentsDeltaMatrix;
  double _argumentIncrement;
  TargetFunction _targetFunction;

  void configure(int numberOfArguments, double argumentDelta, TargetFunction function) {
    _argumentsDeltaMatrix = _generateArgumentsDeltaMatrix(argumentDelta, numberOfArguments);
    _argumentIncrement = argumentDelta;
    _targetFunction = function;
  }

  Float32x4Vector gradient(Float32x4Vector k, Float32x4Vector x, double y) {
    return new Float32x4Vector.from(
        new List<double>.generate(k.length, (int i) => partialDerivative(k, _argumentsDeltaMatrix[i], x, y)));
  }

  double partialDerivative(Float32x4Vector k, Float32x4Vector deltaK, Float32x4Vector x, double y) {
    return (_targetFunction(k + deltaK, x, y) - _targetFunction(k - deltaK, x, y)) / 2 / _argumentIncrement;
  }

  List<Float32x4Vector> _generateArgumentsDeltaMatrix(double increment, int length) {
    List<Float32x4Vector> matrix = new List<Float32x4Vector>(length);

    for (int i = 0; i < length; i++) {
      matrix[i] = new Float32x4Vector.from(new List<double>.generate(length, (int idx) => idx == i ? increment : 0.0));
    }

    return matrix;
  }
}
