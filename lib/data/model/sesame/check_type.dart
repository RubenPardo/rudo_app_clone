enum CheckType{

  checkIn(1),
  checkout(3), // TODO averiguar si es el 3 de verdad
  pause(7), 
  noFound(-1);



  const CheckType(this.value);
  final int value;

  static CheckType fromType(type) {
    switch(type){
      case 1:
        return CheckType.checkIn;
      case 3:
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
