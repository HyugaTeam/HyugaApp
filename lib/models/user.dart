class User{
  
  final String uid;
  final String email;
  final String photoURL;
  final String displayName;
  final bool isAnonymous;
  int score;
  bool isManager;

  User({this.uid,this.email,this.photoURL, this.displayName, this.isAnonymous});
  
  int getLevel(){
    if(score != null){
      if(score < 500) // level 1
        return 1;
      else if(score < 1000)
        return 2;
      else if(score < 1500)
        return 3;
      else if(score < 2000)
        return 4;
      else return 5;
    }
  }

}
