class User2user {

  static mapping = {
    version false
  }
  
  static constraints = {  
  }
  
  Integer id
  Long fromuser
  Long touser
  Integer markfromto
  Integer marktofrom
  Integer relnotefromto
  Integer relnotetofrom
  String notefromto
  String notetofrom
  Integer rating
  Date inputdate = new Date()

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  User2user(){}
  User2user(lUserId, ltoUserId, iMark, iRelnoteId, sNote){
    fromuser = lUserId
    touser = ltoUserId
    markfromto = iMark?:0
    marktofrom = 0
    relnotefromto = iRelnoteId?:0
    relnotetofrom = 0
    notefromto = sNote?:''
    notetofrom = ''
    rating = (iMark==1)?1:(iMark==-1)?-1:0
  }
////////////////////////Business logic///////////////////////////////////////////////////////////////////
  static void setRelationship(hsRes){
  	def oUser2User = User2user.find('from User2user where (fromuser=:sFromuser and touser=:sTouser) or (fromuser=:sTouser and touser=:sFromuser)',[sFromuser:hsRes.user.id,sTouser:hsRes.inrequest.user_id])
  	if (!oUser2User) {
  	  oUser2User = new User2user(hsRes.user.id,hsRes.inrequest.user_id,hsRes.inrequest.mark,hsRes.inrequest.relnote_id?:0,hsRes.inrequest.note?:'')
    	try {
      	oUser2User.save(flush:true)
    	} catch (Exception e) {
      	throw e
    	}
  	} else {
    	try {
      	oUser2User.updateRelationship(hsRes.user.id,hsRes.inrequest.mark?:0,hsRes.inrequest.relnote_id?:0,hsRes.inrequest.note?:'')
    	} catch (Exception e) {
      	throw e
    	}
  	}
    if ((hsRes.inrequest.mark?:0)==-1) {
      hsRes.user.openchatsUpdate(hsRes.inrequest.user_id?:0,true)
    }
  }

  void updateRelationship(lUserId, iMark, iRelnoteId, sNote) {
  	if(fromuser==lUserId) {
    	markfromto = iMark?:0
    	relnotefromto = iRelnoteId?:0
    	notefromto = sNote?:''
  	} else {
    	marktofrom = iMark?:0
    	relnotetofrom = iRelnoteId?:0
    	notetofrom = sNote?:''
  	}
  	if(marktofrom==-1 || markfromto==-1) {
  		rating = -1
  	} else {
  		rating = markfromto + marktofrom
  		if (relnotetofrom == relnotefromto && relnotefromto!=0 ) {
  			rating++
  		}
  	}
    try {
      save(flush:true)
    } catch (Exception e) {
      throw e
    }
  }

  static Integer getMutualRating(lUId,_lUId){
    return User2user.find('from User2user where (fromuser=:sFromuser and touser=:sTouser) or (fromuser=:sTouser and touser=:sFromuser)',[sFromuser:lUId as Long,sTouser:_lUId as Long])?.rating?:0
  }

}