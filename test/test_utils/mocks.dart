import 'package:ml_algo/src/cost_function/cost_function.dart';
import 'package:ml_algo/src/link_function/link_function.dart';
import 'package:ml_algo/src/math/randomizer/randomizer.dart';
import 'package:ml_algo/src/math/randomizer/randomizer_factory.dart';
import 'package:ml_algo/src/model_selection/assessable.dart';
import 'package:ml_algo/src/model_selection/data_splitter/splitter.dart';
import 'package:ml_algo/src/optimizer/linear/convergence_detector/convergence_detector.dart';
import 'package:ml_algo/src/optimizer/linear/convergence_detector/convergence_detector_factory.dart';
import 'package:ml_algo/src/optimizer/linear/gradient/learning_rate_generator/learning_rate_generator.dart';
import 'package:ml_algo/src/optimizer/linear/gradient/learning_rate_generator/learning_rate_generator_factory.dart';
import 'package:ml_algo/src/optimizer/linear/gradient/learning_rate_generator/learning_rate_type.dart';
import 'package:ml_algo/src/optimizer/linear/initial_weights_generator/initial_weights_generator.dart';
import 'package:ml_algo/src/optimizer/linear/initial_weights_generator/initial_weights_generator_factory.dart';
import 'package:ml_algo/src/optimizer/linear/initial_weights_generator/initial_weights_type.dart';
import 'package:ml_algo/src/optimizer/linear/linear_optimizer.dart';
import 'package:ml_algo/src/optimizer/linear/linear_optimizer_factory.dart';
import 'package:ml_algo/src/optimizer/non_linear/decision_tree/split_assessor/split_assessor.dart';
import 'package:ml_algo/src/optimizer/non_linear/decision_tree/stump_selector/observations_splitter/observations_splitter.dart';
import 'package:ml_algo/src/optimizer/non_linear/decision_tree/stump_selector/stump_selector.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:mockito/mockito.dart';

class RandomizerFactoryMock extends Mock implements RandomizerFactory {}

class RandomizerMock extends Mock implements Randomizer {}

class CostFunctionMock extends Mock implements CostFunction {}

class LearningRateGeneratorFactoryMock extends Mock
    implements LearningRateGeneratorFactory {}

class LearningRateGeneratorMock extends Mock implements
    LearningRateGenerator {}

class InitialWeightsGeneratorFactoryMock extends Mock
    implements InitialWeightsGeneratorFactory {}

class InitialWeightsGeneratorMock extends Mock
    implements InitialWeightsGenerator {}

class LinkFunctionMock extends Mock implements LinkFunction {}

class OptimizerFactoryMock extends Mock implements LinearOptimizerFactory {}

class OptimizerMock extends Mock implements LinearOptimizer {}

class ConvergenceDetectorFactoryMock extends Mock
    implements ConvergenceDetectorFactory {}

class ConvergenceDetectorMock extends Mock implements ConvergenceDetector {}

class SplitterMock extends Mock implements Splitter {}

class PredictorMock extends Mock implements Assessable {}

class StumpAssessorMock extends Mock implements SplitAssessor {}

class StumpSelectorMock extends Mock implements StumpSelector {}

class NodeSplitterMock extends Mock implements ObservationsSplitter {}

LearningRateGeneratorFactoryMock createLearningRateGeneratorFactoryMock({
  Map<LearningRateType, LearningRateGenerator> generators,
}) {
  final factory = LearningRateGeneratorFactoryMock();
  generators.forEach((LearningRateType type, LearningRateGenerator generator) {
    when(factory.fromType(type)).thenReturn(generator);
  });
  return factory;
}

RandomizerFactoryMock createRandomizerFactoryMock({
  Map<int, RandomizerMock> randomizers,
}) {
  final factory = RandomizerFactoryMock();
  randomizers.forEach((int seed, Randomizer randomizer) {
    when(factory.create(seed)).thenReturn(randomizer);
  });
  return factory;
}

InitialWeightsGeneratorFactoryMock createInitialWeightsGeneratorFactoryMock({
  Map<InitialWeightsType, InitialWeightsGenerator> generators,
}) {
  final factory = InitialWeightsGeneratorFactoryMock();
  generators
      .forEach((InitialWeightsType type, InitialWeightsGenerator generator) {
    when(factory.fromType(type, any)).thenReturn(generator);
  });
  return factory;
}

OptimizerFactoryMock createGradientOptimizerFactoryMock(
    Matrix points,
    Matrix labels,
    LinearOptimizer optimizer,
) {
  final factory = OptimizerFactoryMock();
  when(factory.gradient(
    points,
    labels,
    dtype: anyNamed('dtype'),
    randomizerFactory: anyNamed('randomizerFactory'),
    costFunction: anyNamed('costFunction'),
    learningRateGeneratorFactory: anyNamed('learningRateGeneratorFactory'),
    initialWeightsGeneratorFactory:
      anyNamed('initialWeightsGeneratorFactory'),
    learningRateType: anyNamed('learningRateType'),
    initialWeightsType: anyNamed('initialWeightsType'),
    initialLearningRate: anyNamed('initialLearningRate'),
    minCoefficientsUpdate: anyNamed('minCoefficientsUpdate'),
    iterationLimit: anyNamed('iterationLimit'),
    lambda: anyNamed('lambda'),
    batchSize: anyNamed('batchSize'),
    randomSeed: anyNamed('randomSeed'),
  )).thenReturn(optimizer);
  return factory;
}
