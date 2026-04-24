class Medicine {
  String id;
  String name;
  String startDate;
  String duration;
  List<String> times;
  String melody;
  bool? isNew; // 👈 ДОБАВИТЬ ЭТУ СТРОКУ

  Medicine({
    required this.id,
    this.name = '',
    required this.startDate,
    this.duration = '30',
    required this.times,
    required this.melody,
    this.isNew = false, // 👈 И ЭТУ (по умолчанию false)
  });

  // В методах toJson и fromJson поле isNew можно НЕ добавлять, 
  // так как оно нужно нам только временно для работы интерфейса.
  
  Map<String, dynamic> toJson() => {
        'name': name,
        'startDate': startDate,
        'duration': duration,
        'times': times,
        'melody': melody,
      };

  factory Medicine.fromJson(String id, Map<String, dynamic> json) {
    return Medicine(
      id: id,
      name: json['name'] ?? '',
      startDate: json['startDate'] ?? '',
      duration: json['duration'] ?? '30',
      times: List<String>.from(json['times'] ?? []),
      melody: json['melody'] ?? 'vivaldi_spring.mp3',
      isNew: false, // При загрузке из файла лекарство уже не новое
    );
  }
}






