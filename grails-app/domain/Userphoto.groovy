class Userphoto {

  static mapping = {
    version false
  }
  
  static constraints = {  
  }
  
  Integer id
  Long user_id
  String picture
  String smallpicture
  String ultrasmallpicture
  Integer modstatus
  Integer is_main
  Integer is_tender = 0
  Integer is_local
  Integer norder
  Date moddate
  String ptext = ''

////////////////////////Business logic///////////////////////////////////////////////////////////////////
  static Boolean userphotoadd(hsRes,hsPics,lId=0,bIsLoc=1) {
    def oUserhoto
		def bUserSave=false
		if(lId>0){
	  	oUserhoto = Userphoto.get(lId)
	  	if(oUserhoto){
			if(hsRes.user.id!=oUserhoto.user_id)
		  	oUserhoto = null
	  	}
		}else{
	  	if(hsPics?.photo){
			oUserhoto = new Userphoto()
			oUserhoto.user_id=hsRes.user.id
			oUserhoto.norder=(Userphoto.findAllWhere(user_id:oUserhoto.user_id)?:[]).size()+1
			if(Userphoto.findAllWhere(user_id:hsRes.user.id))
		  	oUserhoto.is_main=0
			else
		  	oUserhoto.is_main=1
	  	}
		}
		if(oUserhoto){
	  	hsRes.user = User.get(hsRes.user.id)
	  	oUserhoto.picture = (hsPics?.photo)?:oUserhoto.picture
	  	oUserhoto.smallpicture = (hsPics?.thumb)?:oUserhoto.smallpicture
	  	oUserhoto.ultrasmallpicture = (hsPics?.smallthumb)?:oUserhoto.ultrasmallpicture
	  	oUserhoto.modstatus = 1
	  	oUserhoto.is_local = bIsLoc
	  	oUserhoto.moddate=new Date()
	  	try{
				oUserhoto.save(flush:true)
	  	}catch(Exception e){
				throw e
	  	}
	  	if(oUserhoto.is_main){
				hsRes.user.picture = oUserhoto.picture
				hsRes.user.smallpicture = oUserhoto.smallpicture
				hsRes.user.ultrasmallpicture = oUserhoto.ultrasmallpicture
				hsRes.user.is_local = oUserhoto.is_local
				bUserSave = true
	  	}
	  	if(bUserSave){
				try{
		  		hsRes.user.save(flush:true)
				}catch(Exception e){
		  		throw e
				}
	  	}
		} else {
	  	return false
		}
		return true
  }

  static Boolean userphotodelete(lUserId,lId,imageService) {
		def oUserphoto = Userphoto.get(lId)
		if(oUserphoto&&lUserId==oUserphoto.user_id){
			def tmpNorder = oUserphoto.norder
			def tmpHomephoto
			def lsPictures = []
			if(oUserphoto.is_local)
				lsPictures<<oUserphoto.picture
			oUserphoto.delete(flush:true)
			imageService.deletePictureFilesFromHd(lsPictures)
			while (tmpNorder <= Userphoto.findAllByUser_id(lUserId).size()){
				tmpHomephoto = Userphoto.findByUser_idAndNorder(lUserId, ++tmpNorder)
				tmpHomephoto.norder = tmpNorder-1
				tmpHomephoto.save(flush:true)
			}
		}
		return true
	}

  static def set_main_photo(hsRes,lId) {
    def oUserphoto = Userphoto.get(lId)
    if(oUserphoto){
      if(hsRes.user.id == oUserphoto.user_id){
        def oPrevMainHomephoto = Userphoto.findWhere(is_main:1,user_id:hsRes.user.id)
        if(oPrevMainHomephoto){
          oPrevMainHomephoto.is_main = 0
					oUserphoto.is_main=1
					try {
						oPrevMainHomephoto.save(flush:true)
						oUserphoto.save(flush:true)
					}catch(Exception e){
						throw e
					}
          hsRes.prev_main_photo_id = oPrevMainHomephoto.id
          hsRes.cur_main_photo_id = oUserphoto.id
        } else {
          oUserphoto.is_main=1
					try {
						oUserphoto.save(flush:true)
					}catch(Exception e){
						throw e
					}
          hsRes.cur_main_photo_id=oUserphoto.id
        }
				hsRes.user.picture = oUserphoto.picture
				hsRes.user.smallpicture = oUserphoto.smallpicture
				hsRes.user.ultrasmallpicture = oUserphoto.ultrasmallpicture
				hsRes.user.is_local = oUserphoto.is_local
				try {
					hsRes.user.save(flush:true)
				}catch(Exception e){
					throw e
				}
      }
    }
		return hsRes
  }

  static Boolean sort_photo(lUId, getIds) {
    def lsId=[]
    def oUserphoto
		int i = 0
		getIds.each {
			it.split(',').each{
				oUserphoto = Userphoto.get(it.replace('photo_','').toLong())
				if(oUserphoto && lUId == oUserphoto.user_id){
					oUserphoto.norder = ++i
					try{
						oUserphoto.save(flush:true)
					}catch(Exception e){
						throw e
					}
				}
			}
		}
		return true
  }

  static def set_tender_photo(hsRes,lId) {
    def oUserphoto = Userphoto.get(lId)
    if(oUserphoto){
      if(hsRes.user.id == oUserphoto.user_id){
      	def oCurTender = Tender.getCurrentTender()
        def oPrevTenderHomephoto = Userphoto.findWhere(is_tender:(oCurTender?.id?:-1),user_id:hsRes.user.id)
        if(oPrevTenderHomephoto){
          oPrevTenderHomephoto.is_tender = 0
					oUserphoto.is_tender = oCurTender?.id?:0
					try {
						Tendmembers.findOrCreate(hsRes.user.id)
						oPrevTenderHomephoto.save(flush:true)
						oUserphoto.save(flush:true)
					}catch(Exception e){
						throw e
					}
        } else {
          oUserphoto.is_tender = oCurTender?.id?:0
					try {
						Tendmembers.findOrCreate(hsRes.user.id)
						oUserphoto.save(flush:true)
					}catch(Exception e){
						throw e
					}
        }
      }
    }
		return hsRes
  }

}