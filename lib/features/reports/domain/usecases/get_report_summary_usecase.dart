import '../entities/report_models.dart';
import '../repositories/report_repository.dart';

class GetReportSummaryUseCase {
  final ReportRepository repository;

  GetReportSummaryUseCase(this.repository);

  Future<ReportSummary> execute({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return repository.getSummary(startDate: startDate, endDate: endDate);
  }
}
