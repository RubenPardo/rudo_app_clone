enum ResponseStatus{
  needsAction, accepted, declined, noFound;


  static ResponseStatus fromString(string) {
    switch(string){
      case 'accepted':
        return ResponseStatus.accepted;
      case 'needsAction':
        return ResponseStatus.needsAction;
      case 'declined':
        return ResponseStatus.declined;
      default:
        return ResponseStatus.noFound;
    }
  }
}