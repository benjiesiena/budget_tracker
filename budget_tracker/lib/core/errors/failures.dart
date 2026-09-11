/// Base type for expected, handled failures. Repositories and use cases
/// return `Either<Failure, T>`-style results (or throw these) rather than
/// letting raw exceptions leak into the presentation layer.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}

class InsufficientDataFailure extends Failure {
  const InsufficientDataFailure(super.message);
}

class SecurityFailure extends Failure {
  const SecurityFailure(super.message);
}

class BackupFailure extends Failure {
  const BackupFailure(super.message);
}

/// Thrown by AI tools when a requested calculation can't be produced from
/// available data. The AI orchestrator must surface this as "I don't know"
/// rather than letting the model guess — see ResponseValidator.
class AIToolFailure extends Failure {
  final String toolName;
  const AIToolFailure(this.toolName, String message) : super(message);
}
