import 'package:ml_algo/src/data_preprocessing/data_frame/header_extractor/header_extractor.dart';

abstract class DataFrameHeaderExtractorFactory {
  DataFrameHeaderExtractor create(List<bool> readMask);
}
