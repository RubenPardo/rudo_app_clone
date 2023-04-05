class HourBalance{
  final String worked, theoric, balance;

  HourBalance({required this.worked, required this.theoric,required this.balance});

  factory HourBalance.fromJson(Map<String, dynamic> json){
    return HourBalance(worked: json['worked'], theoric: json['theoric'], balance: json['extra']);
  }
}