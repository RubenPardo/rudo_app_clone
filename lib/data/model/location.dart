enum Location{

  atWork,atHome,noWork,error; // las dos ultimas son inventadas, TODO averiguar como son,

  static Location getLocation(String value){
    switch(value){
      case 'at_work':
        return Location.atWork;
      case 'at_home':
        return Location.atHome;
      case 'no_work':
        return Location.noWork;
      
    }
    return Location.error;
  }
}
