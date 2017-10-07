part of 'package:dart_ml/src/implementation.dart';

class _SquaredLoss implements LossFunction {
  const _SquaredLoss();

  @override
  double loss(double predictedLabel, double originalLabel) => pow(predictedLabel - originalLabel, 2);
}