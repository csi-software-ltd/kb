class Lastsearch {

  static mapping = {
    version false
  }

  static constraints = {
  }

  Long id
  Long user_id
  Integer gender_id
  Integer age_min
  Integer age_max
  Integer sort
  Integer visibility_id
  Integer remote

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Lastsearch(){}
  Lastsearch(lUserId, iGenderId, iAgeMin, iAgeMax, iSort, iVisibilityId, iRemote){
    user_id = lUserId
    gender_id = iGenderId
    age_min = iAgeMin
    age_max = iAgeMax
    sort = iSort
    visibility_id = iVisibilityId
    remote = iRemote
  }
////////////////////////Business logic///////////////////////////////////////////////////////////////////

  static void setLastsearch(lUserId, iGenderId, iAgeMin, iAgeMax, iSort, iVisibilityId, iRemote){
  	def oLastsearch = Lastsearch.findByUser_id(lUserId)
  	if (!oLastsearch) {
  	  oLastsearch = new Lastsearch(lUserId, iGenderId, iAgeMin, iAgeMax, iSort, iVisibilityId, iRemote)
    	try {
      	oLastsearch.save(flush:true)
    	} catch (Exception e) {
      	throw e
    	}
  	} else {
    	try {
      	oLastsearch.updateLastsearch(iGenderId, iAgeMin, iAgeMax, iSort, iVisibilityId, iRemote)
    	} catch (Exception e) {
      	throw e
    	}
  	}
  }

  static void setLastsearchWOSort(lUserId, iGenderId, iAgeMin, iAgeMax, iVisibilityId, iRemote){
  	def oLastsearch = Lastsearch.findByUser_id(lUserId)
  	if (!oLastsearch) {
  	  oLastsearch = new Lastsearch(lUserId, iGenderId, iAgeMin, iAgeMax, 0, iVisibilityId, iRemote)
    	try {
      	oLastsearch.save(flush:true)
    	} catch (Exception e) {
      	throw e
    	}
  	} else {
    	try {
      	oLastsearch.updateLastsearch(iGenderId, iAgeMin, iAgeMax, oLastsearch.sort, iVisibilityId, iRemote)
    	} catch (Exception e) {
      	throw e
    	}
  	}
  }

  void updateLastsearch(iGenderId, iAgeMin, iAgeMax, iSort, iVisibilityId, iRemote) {
    gender_id = iGenderId
    age_min = iAgeMin
    age_max = iAgeMax
    sort = iSort
    visibility_id = iVisibilityId
    remote = iRemote
    try {
      save(flush:true)
    } catch (Exception e) {
      throw e
    }
  }

}