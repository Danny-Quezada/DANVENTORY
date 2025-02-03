class LinearRegression<T> {
  final double Function(T) getX;
  final double Function(T) getY;

  LinearRegression({required this.getX, required this.getY});

  double calculateSlope(List<T> data) {
    final n = data.length;
    final sumX = data.map(getX).reduce((a, b) => a + b);
    final sumY = data.map(getY).reduce((a, b) => a + b);
    final sumXY = data
        .map((e) => getX(e) * getY(e))
        .reduce((a, b) => a + b);
    final sumX2 = data.map((e) => getX(e) * getX(e)).reduce((a, b) => a + b);

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    return slope;
  }

  double calculateIntercept(List<T> data, double slope) {
    final n = data.length;
    final sumX = data.map(getX).reduce((a, b) => a + b);
    final sumY = data.map(getY).reduce((a, b) => a + b);

    final intercept = (sumY - slope * sumX) / n;
    return intercept;
  }

  LinearRegressionResult calculate(List<T> data) {
    final slope = calculateSlope(data);
    final intercept = calculateIntercept(data, slope);
    return LinearRegressionResult(slope: slope, intercept: intercept);
  }
}

class LinearRegressionResult {
  final double slope;
  final double intercept;

  LinearRegressionResult({required this.slope, required this.intercept});

  double predict(double xValue) {
    return slope * xValue + intercept;
  }
}
