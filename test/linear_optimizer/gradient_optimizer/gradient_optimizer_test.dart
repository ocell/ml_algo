import 'package:ml_algo/src/cost_function/cost_function.dart';
import 'package:ml_algo/src/linear_optimizer/gradient_optimizer/gradient_optimizer.dart';
import 'package:ml_algo/src/linear_optimizer/initial_coefficients_generator/initial_coefficients_type.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/linalg.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../mocks.mocks.dart';

void main() {
  group('Gradient optimizer', () {
    final costFunctionMock = MockCostFunction();
    late MockRandomizer randomizerMock;
    late MockLearningRateGenerator learningRateGeneratorMock;
    late MockInitialCoefficientsGenerator initialCoefficientsGeneratorMock;
    late MockConvergenceDetector convergenceDetectorMock;

    final points = Matrix.fromList([
      [5, 10, 15],
      [1, 2, 3],
      [10, 20, 30],
      [100, 200, 300],
    ]);
    final labels = Matrix.column([10.0, 20.0, 30.0, 40.0]);
    final defaultIterationsCount = 3;
    final providedCoefficients = Matrix.column([1.5, 2.5, 3.5]);
    final autoGeneratedInitialCoefficients = Matrix.column([10.5, -2.5, 13.75]);
    final interval = [0, points.rowsNum];
    final learningRate = 10.0;
    final gradient = Matrix.column([100, 200, 300]);
    final batchSize1 = 1;
    final batchSize2 = 2;
    final bigBatchSize = 1000;
    final negativeBatchSize = -1;
    final zeroBatchSize = 0;
    final defaultLambda = 105.1;
    final cost = 12009.23;
    final defaultInitialLearningRate = 1.0;

    final providedCoeffsIteration2 =
        providedCoefficients - gradient * learningRate;
    final providedCoeffsIteration3 =
        providedCoeffsIteration2 - gradient * learningRate;

    final autoGenCoeffsIteration2 =
        autoGeneratedInitialCoefficients - gradient * learningRate;
    final autoGenCoeffsIteration3 =
        autoGenCoeffsIteration2 - gradient * learningRate;

    final createGradientOptimizer = ({
      required int batchSize,
      CostFunction? costFunction,
      InitialCoefficientsType? initialCoefficientsType,
      double? initialLearningRate,
      double? lambda,
      int? randomSeed,
      DType? dtype,
    }) =>
        GradientOptimizer(
          points,
          labels,
          costFunction: costFunction ?? costFunctionMock,
          initialLearningRate:
              initialLearningRate ?? defaultInitialLearningRate,
          batchSize: batchSize,
          dtype: dtype ?? DType.float32,
          lambda: lambda ?? defaultLambda,
          randomizer: randomizerMock,
          learningRateGenerator: learningRateGeneratorMock,
          initialCoefficientsGenerator: initialCoefficientsGeneratorMock,
          convergenceDetector: convergenceDetectorMock,
        );

    setUp(() {
      randomizerMock = MockRandomizer();
      learningRateGeneratorMock = MockLearningRateGenerator();
      initialCoefficientsGeneratorMock = MockInitialCoefficientsGenerator();
      convergenceDetectorMock = MockConvergenceDetector();

      when(
        initialCoefficientsGeneratorMock.generate(
          argThat(anything),
        ),
      ).thenReturn(
        autoGeneratedInitialCoefficients.toVector(),
      );

      when(
        convergenceDetectorMock.isConverged(
          any,
          argThat(inInclusiveRange(0, defaultIterationsCount - 1)),
        ),
      ).thenReturn(false);

      when(
        convergenceDetectorMock.isConverged(
          any,
          defaultIterationsCount,
        ),
      ).thenReturn(true);

      when(
        learningRateGeneratorMock.getNextValue(),
      ).thenReturn(learningRate);

      when(
        learningRateGeneratorMock.stop(),
      ).thenReturn(null);

      when(
        randomizerMock.getIntegerInterval(
          argThat(anything),
          argThat(anything),
          intervalLength: anyNamed('intervalLength'),
        ),
      ).thenReturn(interval);

      when(
        costFunctionMock.getCost(
          argThat(anything),
          argThat(anything),
          argThat(anything),
        ),
      ).thenReturn(cost);

      when(
        costFunctionMock.getGradient(
          argThat(anything),
          argThat(anything),
          argThat(anything),
        ),
      ).thenReturn(gradient);
    });

    tearDown(() {
      reset(initialCoefficientsGeneratorMock);
      reset(learningRateGeneratorMock);
      reset(convergenceDetectorMock);
      reset(randomizerMock);
      reset(costFunctionMock);
    });

    test('should process `batchSize` parameter, batchSize=$batchSize1', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema();

      verify(
        randomizerMock.getIntegerInterval(
          argThat(anything),
          argThat(anything),
          intervalLength: batchSize1,
        ),
      ).called(defaultIterationsCount);
    });

    test('should process `batchSize` parameter, batchSize=$batchSize2', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize2,
      );

      optimizer.findExtrema();

      verify(
        randomizerMock.getIntegerInterval(
          argThat(anything),
          argThat(anything),
          intervalLength: batchSize2,
        ),
      ).called(defaultIterationsCount);
    });

    test('should throw an exception if too big batch size is provided', () {
      final actual = () => createGradientOptimizer(
            batchSize: bigBatchSize,
          );

      expect(actual, throwsRangeError);
    });

    test('should throw an exception if negative batch size is provided', () {
      final actual = () => createGradientOptimizer(
            batchSize: negativeBatchSize,
          );

      expect(actual, throwsRangeError);
    });

    test('should throw an exception if zero batch size is provided', () {
      final actual = () => createGradientOptimizer(
            batchSize: zeroBatchSize,
          );

      expect(actual, throwsRangeError);
    });

    test(
        'should consider coefficients diff while the convergence is being '
        'detected', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );
      final expectedDiff =
          ((autoGeneratedInitialCoefficients - gradient * learningRate) -
                  autoGeneratedInitialCoefficients)
              .norm();

      optimizer.findExtrema();

      verify(
        convergenceDetectorMock.isConverged(
          double.maxFinite,
          any,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(
          expectedDiff,
          any,
        ),
      ).called(3);
    });

    test(
        'should consider initial coefficients while the convergence is being '
        'detected', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );
      final expectedDiff = ((providedCoefficients - gradient * learningRate) -
              providedCoefficients)
          .norm();

      optimizer.findExtrema(initialCoefficients: providedCoefficients);

      verify(
        convergenceDetectorMock.isConverged(
          double.maxFinite,
          any,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(
          expectedDiff,
          any,
        ),
      ).called(3);
    });

    test(
        'should consider optimization objective while the convergence is being '
        'detected', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );
      final expectedDiff = ((providedCoefficients + gradient * learningRate) -
              providedCoefficients)
          .norm();

      optimizer.findExtrema(
          initialCoefficients: providedCoefficients,
          isMinimizingObjective: false);

      verify(
        convergenceDetectorMock.isConverged(
          double.maxFinite,
          any,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(
          expectedDiff,
          any,
        ),
      ).called(3);
    });

    test(
        'should consider iteration number while the convergence is being '
        'detected', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema();

      verify(
        convergenceDetectorMock.isConverged(
          any,
          0,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(
          any,
          1,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(
          any,
          2,
        ),
      ).called(1);

      verify(
        convergenceDetectorMock.isConverged(any, 3),
      ).called(1);
    });

    test(
        'should init learning rate generator right after the optimizer '
        'creation', () {
      final initialLearningRate = 133.3;

      createGradientOptimizer(
        initialLearningRate: initialLearningRate,
        batchSize: batchSize1,
      );

      verify(
        learningRateGeneratorMock.init(
          initialLearningRate,
        ),
      ).called(1);
    });

    test(
        'should call learning rate generator exactly $defaultIterationsCount '
        'times', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema();

      verify(
        learningRateGeneratorMock.getNextValue(),
      ).called(defaultIterationsCount);
    });

    test('should stop learning rate generator', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema();

      verify(
        learningRateGeneratorMock.stop(),
      ).called(1);
    });

    test('should calculate gradient using coefficients, points and labels', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );

      optimizer.findExtrema();

      verify(
        costFunctionMock.getGradient(
          points,
          autoGeneratedInitialCoefficients,
          labels,
        ),
      ).called(1);

      verify(
        costFunctionMock.getGradient(points, autoGenCoeffsIteration2, labels),
      ).called(1);

      verify(
        costFunctionMock.getGradient(
          points,
          autoGenCoeffsIteration3,
          labels,
        ),
      ).called(1);
    });

    test(
        'should calculate gradient using coefficients, points and labels, '
        'initial coefficients are provided', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );

      optimizer.findExtrema(initialCoefficients: providedCoefficients);

      verify(costFunctionMock.getGradient(
        points,
        providedCoefficients,
        labels,
      )).called(1);

      verify(costFunctionMock.getGradient(
        points,
        providedCoeffsIteration2,
        labels,
      )).called(1);

      verify(
        costFunctionMock.getGradient(
          points,
          providedCoeffsIteration3,
          labels,
        ),
      ).called(1);
    });

    test('should regularize coefficients', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );
      final iteration2Coefficients =
          providedCoefficients * (1 - 2 * learningRate * defaultLambda) -
              gradient * learningRate;
      final iteration3Coefficients =
          iteration2Coefficients * (1 - 2 * learningRate * defaultLambda) -
              gradient * learningRate;

      optimizer.findExtrema(initialCoefficients: providedCoefficients);

      verify(
        costFunctionMock.getGradient(
          points,
          providedCoefficients,
          labels,
        ),
      ).called(1);

      verify(
        costFunctionMock.getGradient(
          points,
          iteration2Coefficients,
          labels,
        ),
      ).called(1);

      verify(
        costFunctionMock.getGradient(
          points,
          iteration3Coefficients,
          labels,
        ),
      ).called(1);
    });

    test('should calculate cost values if collectLearningData is true', () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
        lambda: 0,
      );

      optimizer.findExtrema(collectLearningData: true);

      verify(
        costFunctionMock.getCost(
          points,
          autoGeneratedInitialCoefficients,
          labels,
        ),
      ).called(1);

      verify(
        costFunctionMock.getCost(
          points,
          autoGenCoeffsIteration2,
          labels,
        ),
      ).called(1);

      verify(
        costFunctionMock.getCost(
          points,
          autoGenCoeffsIteration3,
          labels,
        ),
      ).called(1);
    });

    test('should collect cost per iteration if collectLearningData is true',
        () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema(collectLearningData: true);

      expect(optimizer.costPerIteration, [cost, cost, cost]);
    });

    test('should clear cost per iteration list if optimization starts over',
        () {
      final optimizer = createGradientOptimizer(
        batchSize: batchSize1,
      );

      optimizer.findExtrema(collectLearningData: true);
      expect(optimizer.costPerIteration, [cost, cost, cost]);

      optimizer.findExtrema();
      expect(optimizer.costPerIteration, <num>[]);
    });
  });
}
