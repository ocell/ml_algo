import 'package:ml_algo/src/linear_optimizer/gradient_optimizer/learning_rate_generator/learning_rate_type.dart';
import 'package:ml_algo/src/linear_optimizer/initial_coefficients_generator/initial_coefficients_type.dart';
import 'package:ml_algo/src/linear_optimizer/linear_optimizer_type.dart';
import 'package:ml_algo/src/linear_optimizer/regularization_type.dart';
import 'package:ml_algo/src/model_selection/assessable.dart';
import 'package:ml_algo/src/predictor/predictor.dart';
import 'package:ml_algo/src/regressor/_helpers/squared_cost_optimizer_factory.dart';
import 'package:ml_algo/src/regressor/linear_regressor_impl.dart';
import 'package:ml_dataframe/ml_dataframe.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/vector.dart';

/// A class that performs linear regression
///
/// A typical linear regressor uses the equation of a line for multidimensional
/// space to make a prediction. Each `x` in the equation has its own coefficient
/// (weight) and the combination of these `x`-es and its coefficients gives the
/// `y` term. The latter is a value, that the regressor should predict, and
/// as all the `x` values are known (since it is the input for the algorithm),
/// the regressor should find the best coefficients (weights) (they are unknown)
/// to make a best prediction of `y` term.
abstract class LinearRegressor implements Assessable, Predictor {
  /// Parameters:
  ///
  /// [fittingData] A [DataFrame] with observations, that will be used by the
  /// regressor to learn coefficients of the predicting hyperplane. Must contain
  /// [targetName] column.
  ///
  /// [targetName] A string, that serves as a name of the target column, that
  /// contains labels or outcomes.
  ///
  /// [optimizerType] Defines an algorithm of optimization, that will be used
  /// to find the best coefficients of a cost function. Also defines, which
  /// regularization type (L1 or L2) one may use to learn a linear regressor.
  ///
  /// [iterationsLimit] A number of fitting iterations. Uses as a condition of
  /// convergence in the optimization algorithm. Default value is `100`.
  ///
  /// [initialLearningRate] A value, defining velocity of the convergence of the
  /// gradient descent optimizer. Default value is `1e-3`.
  ///
  /// [minCoefficientsUpdate] A minimum distance between coefficient vectors in
  /// two contiguous iterations. Uses as a condition of convergence in the
  /// optimization algorithm. If difference between the two vectors is small
  /// enough, there is no reason to continue fitting. Default value is `1e-12`
  ///
  /// [lambda] A coefficient of regularization. Uses to prevent the regressor's
  /// overfitting. The more the value of [lambda], the more regular the
  /// coefficients of the predicting hyperplane are. Extremely large [lambda]
  /// may decrease the coefficients to nothing, otherwise too small [lambda] may
  /// be a cause of too large absolute values of the coefficients.
  ///
  /// [regularizationType] A way the coefficients of the regressor will be
  /// regularized to prevent a model overfitting.
  ///
  /// [randomSeed] A seed, that will be passed to a random value generator,
  /// used by stochastic optimizers. Will be ignored, if the solver cannot be
  /// stochastic. Remember, each time you run the stochastic regressor with the
  /// same parameters but with unspecified [randomSeed], you will receive
  /// different results. To avoid it, define [randomSeed]
  ///
  /// [batchSize] A size of data (in rows), that will be used for fitting per
  /// one iteration. Applicable not for all optimizers. If gradient-based
  /// optimizer is used and If [batchSize] == `1`, stochastic mode will be
  /// activated; if `1` < [batchSize] < `total number of rows`, mini-batch mode
  /// will be activated; if [batchSize] == `total number of rows`, full-batch
  /// mode will be activated.
  ///
  /// [fitIntercept] Whether or not to fit intercept term. Default value is
  /// `false`. Intercept in 2-dimensional space is a bias of the line (relative
  /// to X-axis) to be learned by the regressor
  ///
  /// [interceptScale] A value, defining a size of the intercept.
  ///
  /// [isFittingDataNormalized] Defines, whether the [fittingData] normalized
  /// or not. Normalization should be performed column-wise. Normalized data
  /// may be needed for some optimizers (e.g., for
  /// [LinearOptimizerType.vanillaCD])
  ///
  /// [learningRateType] A value, defining a strategy for the learning rate
  /// behaviour throughout the whole fitting process.
  ///
  /// [initialCoefficientsType] Defines the coefficients, that will be
  /// autogenerated before the first iteration of optimization. By default,
  /// all the autogenerated coefficients are equal to zeroes at the start.
  /// If [initialCoefficients] are provided, the parameter will be ignored
  ///
  /// [initialCoefficients] Coefficients to be used in the first iteration of
  /// optimization algorithm. [initialCoefficients] is a vector, length of which
  /// must be equal to the number of features in [fittingData]: the number of
  /// features is equal to the number of columns in [fittingData] minus 1
  /// (target column).
  ///
  /// [dtype] A data type for all the numeric values, used by the algorithm. Can
  /// affect performance or accuracy of the computations. Default value is
  /// [DType.float32]
  factory LinearRegressor(DataFrame fittingData, String targetName, {
    LinearOptimizerType optimizerType,
    int iterationsLimit = 100,
    LearningRateType learningRateType = LearningRateType.constant,
    InitialCoefficientsType initialCoefficientsType =
        InitialCoefficientsType.zeroes,
    double initialLearningRate = 1e-3,
    double minCoefficientsUpdate = 1e-12,
    double lambda,
    RegularizationType regularizationType,
    bool fitIntercept = false,
    double interceptScale = 1.0,
    int randomSeed,
    int batchSize = 1,
    Matrix initialCoefficients,
    bool isFittingDataNormalized = false,
    DType dtype = DType.float32,
  }) {
    final optimizer = createSquaredCostOptimizer(
      fittingData,
      targetName,
      optimizerType: optimizerType,
      iterationsLimit: iterationsLimit,
      initialLearningRate: initialLearningRate,
      minCoefficientsUpdate: minCoefficientsUpdate,
      lambda: lambda,
      regularizationType: regularizationType,
      randomSeed: randomSeed,
      batchSize: batchSize,
      learningRateType: learningRateType,
      initialCoefficientsType: initialCoefficientsType,
      fitIntercept: fitIntercept,
      interceptScale: interceptScale,
      isFittingDataNormalized: isFittingDataNormalized,
      dtype: dtype,
    );

    final coefficients = optimizer.findExtrema(
      initialCoefficients: initialCoefficients,
      isMinimizingObjective: true,
    ).getColumn(0);

    return LinearRegressorImpl(
      coefficients,
      targetName,
      fitIntercept: fitIntercept,
      interceptScale: interceptScale,
      dtype: dtype,
    );
  }

  /// Learned coefficients (or weights) for given features
  Vector get coefficients;

  bool get fitIntercept;

  double get interceptScale;
}
