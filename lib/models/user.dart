class User{
  
  final String uid;
  final String email;
  final String photoURL;
  final String displayName;
  final bool isAnonymous;
  int score;
  bool isManager;

  User({this.uid,this.email,this.photoURL, this.displayName, this.isAnonymous});
  

  // Can only return a number in the range [0,5]
  int getLevel(){
    if(score != null){
      if(score < 1) // level 0
        return 0;
      else if(score < 3) // level 1
        return 1;
      else if(score < 8) // level 2
        return 2;
      else if(score < 23) // level 3
        return 3;
      else if(score < 48) // level 4
        return 4;
      else return 5; // level 5
    }
    return 0;
  }

}
