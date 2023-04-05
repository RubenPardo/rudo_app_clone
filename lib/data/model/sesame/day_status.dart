enum DayStatus{
  festivity('assets/images/festivity.png','Festivos y findes'), 
  holiday('assets/images/holiday.png','Vacaciones'), 
  working('assets/images/warning.png','No se tienen registros'), 
  medicalLeave('assets/images/medical.png','Baja médica'),
  noFound('','');

  const DayStatus(this.asset,this.value);
  final String value,asset;

  static DayStatus fromString( String type) {
    switch(type){
      case 'festivity':
        return DayStatus.festivity;
      case 'holiday':
        return DayStatus.holiday;
      case 'working':
        return DayStatus.working;
      case 'medical': // todo cambiar
        return DayStatus.medicalLeave;
      default:
        return DayStatus.noFound;
    }
  }

}