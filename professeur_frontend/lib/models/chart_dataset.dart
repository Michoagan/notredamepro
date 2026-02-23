class ChartDataset {
  final String label;
  final List<double> data;
  final String borderColor;

  ChartDataset({
    required this.label,
    required this.data,
    required this.borderColor,
  });

  factory ChartDataset.fromJson(Map<String, dynamic> json) {
    return ChartDataset(
      label: json['label'],
      data: List<double>.from(json['data'].map((x) {
        if (x == null) return 0.0;
        if (x is num) return x.toDouble();
        return double.tryParse(x.toString()) ?? 0.0;
      })),
      borderColor: json['borderColor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'data': data, 'borderColor': borderColor};
  }
}
