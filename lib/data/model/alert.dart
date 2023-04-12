class Alert{
  final String title, description;
  final DateTime date;
  final bool isReaded;

  Alert({required this.title, required this.description,required this.isReaded,required this.date});

  factory Alert.dummy(bool isReaded){
    return Alert(title: 'Reseteo de los equipos', description: 'Recuerda que mañana es el último día para guardar los archivos de tu ordenador antes del reseteo de los equipos.', isReaded: isReaded, date: DateTime.now());
  }

   factory Alert.fromJson(Map<String, String> json){
    return Alert.dummy(false);
  }
}