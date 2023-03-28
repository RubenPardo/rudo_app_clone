class UserAuth{

  String email,firstName,lastName,idToken,clientId, googleToken;
  

  UserAuth(this.email,this.firstName,this.lastName,this.idToken,this.clientId,this.googleToken);

  Map<String,String> toJson(){
    return {
      'email': email , 
      'first_name': firstName, 
      'last_name':  lastName, 
      'client_id':  clientId,
      'token': googleToken,
      'id_token':  idToken, 
    };
  }

}