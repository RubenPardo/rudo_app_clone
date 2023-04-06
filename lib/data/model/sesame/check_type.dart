enum CheckType{

  checkIn(1),
  checkout(1), // Se usa el mismo para el check in y el check out
  pause(7), 
  noFound(-1);



  const CheckType(this.value);
  final int value;

  static CheckType fromType(type) {
    switch(type){
      case 1:
        return CheckType.checkIn;
      case 1:
        return CheckType.checkout;
      case 7:
        return CheckType.pause;
      default:
        return CheckType.noFound;
    }
  }

  static CheckType fromStatus(status) {
    switch(status){
      case 'in':
        return CheckType.checkIn;
      case 'out':
        return CheckType.checkout;
      case 'pause':
        return CheckType.pause;
      default:
        return CheckType.noFound;
    }
  }

}
