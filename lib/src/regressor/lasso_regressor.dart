import 'package:ml_algo/ml_algo.dart';
import 'package:ml_algo/src/cost_function/cost_function_type.dart';
import 'package:ml_algo/src/data_preprocessing/intercept_preprocessor/intercept_preprocessor.dart';
import 'package:ml_algo/src/data_preprocessing/intercept_preprocessor/intercept_preprocessor_factory.dart';
import 'package:ml_algo/src/data_preprocessing/intercept_preprocessor/intercept_preprocessor_factory_impl.dart';
import 'package:ml_algo/src/default_parameter_values.dart';
import 'package:ml_algo/src/metric/factory.dart';
import 'package:ml_algo/src/metric/metric_type.dart';
import 'package:ml_algo/src/optimizer/coordinate/coordinate.dart';
import 'package:ml_algo/src/optimizer/initial_weights_generator/initial_weights_type.dart';
import 'package:ml_algo/src/regressor/regressor.dart';
import 'package:ml_linalg/linalg.dart';

class LassoRegressor implements Regressor {
  LassoRegressor({
    // public arguments
    int iterationsLimit = DefaultParameterValues.iterationsLimit,
    double minWeightsUpdate = DefaultParameterValues.minCoefficientsUpdate,
    double lambda,
    bool fitIntercept = false,
    double interceptScale = 1.0,
    Type dtype = DefaultParameterValues.dtype,
    InitialWeightsType initialWeightsType = InitialWeightsType.zeroes,

    // hidden arguments
    InterceptPreprocessorFactory interceptPreprocessorFactory =
        const InterceptPreprocessorFactoryImpl(),
  })  : _interceptPreprocessor = interceptPreprocessorFactory.create(dtype,
            scale: fitIntercept ? interceptScale : 0.0),
        _optimizer = CoordinateOptimizer(
          initialWeightsType: initialWeightsType,
          costFunctionType: CostFunctionType.squared,
          iterationsLimit: iterationsLimit,
          minCoefficientsDiff: minWeightsUpdate,
          lambda: lambda,
          dtype: dtype,
        );

  final CoordinateOptimizer _optimizer;
  final InterceptPreprocessor _interceptPreprocessor;

  @override
  MLVector get weights => _weights;
  MLVector _weights;

  @override
  void fit(MLMatrix features, MLMatrix labels,
      {MLMatrix initialWeights, bool isDataNormalized = false}) {
    _weights = _optimizer
        .findExtrema(
          _interceptPreprocessor.addIntercept(features),
          labels,
          initialWeights: initialWeights.transpose(),
          isMinimizingObjective: true,
          arePointsNormalized: isDataNormalized
        ).getRow(0);
  }

  @override
  double test(MLMatrix features, MLMatrix origLabels, MetricType metricType) {
    final metric = MetricFactory.createByType(metricType);
    final prediction = predict(features);
    return metric.getScore(prediction, origLabels);
  }

  @override
  MLMatrix predict(MLMatrix features) => features * _weights;
}
