import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON

class PersonalController {
  def requestService
  def imageService
  def chatService
  def static final DATE_FORMAT='yyyy-MM-dd'

  def checkUser(hsRes) {
    if(!hsRes?.user){
      redirect(controller:'index', action:'index')
      return false;
    }
    return true
  }

  def settings = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    hsRes+=requestService.getParams(
	  ['birthday_day','birthday_month','birthday_year','gender_id','city_id', 'metro_id','vissexstatus','visagefrom','visageto','visoffline'],
	  null,
	  ['firstname','lastname','nickname','description','hobby','wishes'])
    if (!(flash?.error?:[]).contains(5))
      hsRes.date=requestService.getParams(['birthday_day','birthday_month','birthday_year'],null,null).inrequest
    if (!flash.error){
      hsRes.inrequest = hsRes.user
      if(hsRes.inrequest.tel?:'') {
        hsRes.ind = hsRes.inrequest.tel.split("\\(")[0].replace('+','')
        hsRes.telef = hsRes.inrequest.tel.split('\\)')[1]
        hsRes.kod = hsRes.inrequest.tel.split('\\(')[1].split('\\)')[0]
      }
	} else {
      hsRes.ind = requestService.getStr('ind')
      hsRes.telef = requestService.getStr('telef')
      hsRes.kod = requestService.getStr('kod')
	}
    hsRes.city = City.list()
    if (hsRes.inrequest?.city_id)
      hsRes.metro = Metro.findAllByCity_idAndModstatus(hsRes.user.city_id,1)
    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.max_user_age = Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)

    return hsRes
  }

  def saveMainSettings = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(
	  ['birthday_day','birthday_month','birthday_year','gender_id','city_id','metro_id','vissexstatus','visagefrom','visageto','visoffline'],
	  null,
	  ['firstname','lastname','nickname','description','hobby','wishes','ind','kod','telef'])

    def lsSett = requestService.getParams(['vissexstatus','visagefrom','visageto','visoffline']).int
    def lsDirectory=requestService.getParams(['birthday_day','birthday_month','birthday_year']).inrequest
    def lsTel = requestService.getParams(null,null,['ind','kod','telef']).inrequest
    flash.error = []
    if(lsSett.size()!=4)
      flash.error << 1
    if (hsRes.inrequest.visageto && hsRes.inrequest.visageto < hsRes.inrequest.visagefrom)
      flash.error << 3
    if (!hsRes.inrequest.firstname)
      flash.error << 4
    if((lsDirectory?:[]).size()!=3)
      flash.error << 5
    else {
      def bDay = new Date(hsRes.inrequest?.birthday_year-1900,hsRes.inrequest?.birthday_month-1,hsRes.inrequest?.birthday_day)
      if (bDay.getDate()!=hsRes.inrequest?.birthday_day)
        flash.error << 5
	  else if(Tools.computeAge(bDay)<Tools.getIntVal(ConfigurationHolder.config.min_user_age,18))
      flash.error << 6
    }
    if (!hsRes.inrequest.gender_id)
      flash.error << 7
    if(lsTel && (lsTel?:[]).size()!=3)
      flash.error << 8
    else if (lsTel){
      for (t in lsTel)
        if (!t.value.replace(' ','').replace('-','').matches("[0-9]+"))
          if(!flash.error.find{it==8})
            flash.error << 8
    }
    if (!hsRes.inrequest.city_id)
      flash.error << 9
    if(flash.error.size()){
      redirect(action:'settings', params:hsRes.inrequest)
      return
    }
    if (!hsRes.user.updateMainSett(hsRes)){
      flash.error << 2
    }

    redirect(action:'settings', params:hsRes.inrequest)
    return
  }

  def metroupd={
    requestService.init(this)
    def lCityId=requestService.getIntDef('cityId',0)
    def dValue=requestService.getLongDef('amp;dValue',0)
    return [metro: Metro.findAllByCity_idAndModstatus(lCityId,1), dValue: dValue]
  }

  def getPlaceData={
    requestService.init(this)
    def lId = requestService.getIntDef('id',0)
    def hsRes = [:]
    hsRes.data = Userplace.get(lId)
    if (!hsRes.data) {
      hsRes.error = true
    }

    render hsRes as JSON
  }

  def anklocation = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.regmenu = Infotext.findAll('FROM Infotext WHERE itemplate_id=2 ORDER BY npage ASC')
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(['city_id', 'metro_id'],['x','y'])
    hsRes.inrequest.geocodestatus = requestService.getIntDef('geocodestatus',0)
    hsRes.place_id = requestService.getIntDef('place_id',0)
    hsRes.places = Userplace.findAllByUser_id(hsRes.user.id)
    hsRes.city = City.list()

    if (!flash.error)
      hsRes.inrequest = hsRes.user
    if (hsRes.user.geocodestatus==2) {
      hsRes.name = Userplace.findByUser_idAndIs_main(hsRes.user.id,1).name
      hsRes.address = Userplace.findByUser_idAndIs_main(hsRes.user.id,1).address
    } else {
      hsRes.name = requestService.getStr('name')
      hsRes.address = requestService.getStr('address')
    }
    if (hsRes.user.city_id)
      hsRes.metro = Metro.findAllByCity_idAndModstatus(hsRes.inrequest.city_id,1)

    return hsRes
  }

  def saveAnklocation = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(['city_id','metro_id','place_id'],['x','y'],['name', 'address'])
    hsRes.inrequest.geocodestatus = requestService.getIntDef('geocodestatus',0)

    if (!hsRes.inrequest?.x && !hsRes.inrequest?.city_id) {
      flash.error = 1
      redirect(action:'anklocation', params:hsRes.inrequest)
      return
    }
    if (hsRes.inrequest.geocodestatus==2){
      if (!hsRes.inrequest.name) {
        flash.error = 3
        redirect(action:'anklocation', params:hsRes.inrequest)
        return
      } else if (!hsRes.inrequest.city_id){
        flash.error = 4
        redirect(action:'anklocation', params:hsRes.inrequest)
        return
      }
    }
    if (!User.updateAnkLoc(hsRes)){
      flash.error = 2
      redirect(action:'anklocation', params:hsRes.inrequest)
      return
    }

    redirect(action:'ankdescription')
    return
  }

  def ankdescription = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.regmenu = Infotext.findAll('FROM Infotext WHERE itemplate_id=2 ORDER BY npage ASC')
    if (!checkUser(hsRes)) return

    if(hsRes.user.ankstepcomplete<2) {
      redirect(controller:'index', action:'index')
      return
    }

    return hsRes
  }

  def saveAnkdescription = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(null,null,['description','hobby','wishes'])

    if (!User.updateAnkDescr(hsRes)){
      flash.error = 2
      redirect(action:'ankdescription', params:hsRes.inrequest)
      return
    }

    redirect(action:'anksettings')
    return
  }

  def anksettings = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.regmenu = Infotext.findAll('FROM Infotext WHERE itemplate_id=2 ORDER BY npage ASC')
    if (!checkUser(hsRes)) return

    if(hsRes.user.ankstepcomplete<3) {
      redirect(controller:'index', action:'index')
      return
    }

    hsRes+=requestService.getParams(['vissexstatus','visagefrom','visageto','visoffline'])
    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.max_user_age = Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)

    return hsRes
  }

  def saveAnksettings = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(['vissexstatus','visagefrom','visageto','visoffline'])

    def lsSett = requestService.getParams(['vissexstatus','visagefrom','visageto','visoffline']).int
    if(lsSett.size()!=4){
      flash.error = 1
      redirect(action:'anksettings', params:hsRes.inrequest)
      return
    }
    if (hsRes.inrequest.visageto && hsRes.inrequest.visageto < hsRes.inrequest.visagefrom){
      flash.error = 3
      redirect(action:'anksettings', params:hsRes.inrequest)
      return
    }
    if (!User.updateAnkSett(hsRes)){
      flash.error = 2
      redirect(action:'anksettings', params:hsRes.inrequest)
      return
    }
    hsRes.user.checkStatus()

    redirect(controller:'index', action:'index')
    return
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////photo>>>////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  def photo = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return
    if(hsRes.user){
      hsRes.photo=Userphoto.findAll('FROM Userphoto WHERE user_id=:user_id ORDER BY norder',[user_id:hsRes.user?.id])
      hsRes.curTenderId = Tender.getCurrentTender()?.id?:-1
    }else{
      response.sendError(404)
      return
    }
    
    return hsRes
  }

  def userphoto={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true,true)
    if (!checkUser(hsRes)) return
    hsRes.id = requestService.getLongDef('id',0)
    hsRes.i = 1
    hsRes.maxI = Tools.getIntVal(ConfigurationHolder.config.photomultiupload.max,4)
    imageService.init(this,'homephotopic'+hsRes.id,'homephotokeeppic'+hsRes.id,ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0
    imageService.startFileSession() // 1
    imageService.finalizeFileSession(null)
    if(hsRes.id>0){
      hsRes.userphoto = Userphoto.get(hsRes.id)
      if(hsRes.userphoto?.user_id==hsRes.user.id){
        hsRes.images=[:]
        if(hsRes.userphoto.is_local){
          if((hsRes.userphoto.picture?:'')!='')
            imageService.putIntoSessionFromDb(hsRes.userphoto.picture,'file1') // 2
          def hsPics=imageService.getSessionPics('file1') // 3
          if(hsPics!=null){
            hsRes.images['photo_1']=hsPics.photo
            hsRes.images['thumb_1']=hsPics.thumb
            hsRes.images['is_local'] = true
          }
        } else {
          hsRes.images['photo_1'] = hsRes.userphoto.picture
          hsRes.images['thumb_1'] = hsRes.userphoto.smallpicture
          hsRes.images['is_local'] = false
        }
      } else {
        response.sendError(404)
        return
      }
    }
    return hsRes
  }
   /////////////////////////////////////////////////////////////////////////////////////////////////////////
  def userphotoadd={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return
    def lId = requestService.getLongDef('id',0)

    imageService.init(this,'homephotopic'+lId,'homephotokeeppic'+lId,ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0

    def hsPics
    def lsFiles = []

    for (int i=1; i<=Tools.getIntVal(ConfigurationHolder.config.photomultiupload.max,4); i++){
      hsPics=imageService.getSessionPics(('file'+i))
      if (!hsPics)
        continue
      lsFiles << ('file'+i)
      try {
        Userphoto.userphotoadd(hsRes,hsPics,lId)
      }catch(Exception e){
        log.debug('Personal:userphotoadd. ERROR ON ADD userphoto OR UPDATE User '+hsRes.user.id+'\n'+e.toString())
      }
    }
    if(lId>0&&!lsFiles&&Userphoto.get(lId)){
      imageService.putIntoSessionFromDb(Userphoto.get(lId).picture,'file1')
      lsFiles << 'file1'
    }
    imageService.finalizeFileSession(lsFiles)
    redirect(action:'photo')
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def userphotodelete={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return
    def lId = requestService.getLongDef('id',0)
    if(lId>0){
      imageService.init(this,'','',ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar)
      Userphoto.userphotodelete(hsRes.user.id,lId,imageService)
    }
    redirect(action:'photo')
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def saveuserphoto={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return
    def lId = requestService.getLongDef('id',0)
    def iNo = requestService.getLongDef('no',0)
    def bFlag=false
    if(lId>0){
      def oUserphoto = Userphoto.get(lId)
      if(hsRes.user.id==oUserphoto?.user_id)
        bFlag=true
    }else{
      bFlag=true
    }	
    def hsData = [:]
    hsData.data=[]
    imageService.init(this,'homephotopic'+lId,'homephotokeeppic'+lId,ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0

    if(bFlag){
      if(iNo==1){
        request.multiFileMap?.file1?.each { file ->
          if (iNo<=Tools.getIntVal(ConfigurationHolder.config.photomultiupload.max,4)){
          //ЗАГРУЖАЕМ ГРАФИКУ
            hsData.data << imageService.loadMultiplePicture(
              file,
              Tools.getIntVal(ConfigurationHolder.config.photo.weight,2097152),     // weight
              Tools.getIntVal(ConfigurationHolder.config.userphoto.image.size,220), // size
              Tools.getIntVal(ConfigurationHolder.config.userphoto.thumb.size,140), // thumb size
              true,//SaveThumb
              true,//bToSquare
              Tools.getIntVal(ConfigurationHolder.config.userphoto.image.height,220),// height
              Tools.getIntVal(ConfigurationHolder.config.userphoto.thumb.height,140),// thumb height	
              true,//bSquareOnlyThumb
              false,//bSaveThumpWithSize
              iNo,
              Tools.getIntVal(ConfigurationHolder.config.userphoto.smallthumb.size,70),//small thumb size
              Tools.getIntVal(ConfigurationHolder.config.userphoto.smallthumb.height,70),//small thumb height
              true,//bSaveSmallThumb
              false//bSaveSmallThumpWithSize
            ) // 3
          }
          iNo++
        }
      } else {
        hsData.data << imageService.loadPicture(
          "file"+(iNo?:1),
          Tools.getIntVal(ConfigurationHolder.config.photo.weight,2097152),     // weight
          Tools.getIntVal(ConfigurationHolder.config.userphoto.image.size,220), // size
          Tools.getIntVal(ConfigurationHolder.config.userphoto.thumb.size,140), // thumb size
          true,//SaveThumb
          true,//bToSquare
          Tools.getIntVal(ConfigurationHolder.config.userphoto.image.height,220),// height
          Tools.getIntVal(ConfigurationHolder.config.userphoto.thumb.height,140),// thumb height	
          true,//bSquareOnlyThumb
          false,//bSaveThumpWithSize
          Tools.getIntVal(ConfigurationHolder.config.userphoto.smallthumb.size,70),//small thumb size
          Tools.getIntVal(ConfigurationHolder.config.userphoto.smallthumb.height,70),//small thumb height
          true,//bSaveSmallThumb
          false//bSaveSmallThumpWithSize
        ) // 3

        hsData.data[0]['num']=iNo?:1 //<- НЕОБХОДИМО ДЛЯ КОРРЕКТНОЙ РАБОТЫ js в savepictureresult  
      }
      // savepictureresult ОБЩИЙ ШАБЛОН, ЕСЛИ ИСПОЛЬЗОВАТЬ СКРИПТЫ АНАЛОГИЧНО СДЕЛАННОМУ
      render(view:'savepictureresult',model:hsData)
      return
    }

    render(contentType:"application/json"){error(true)}
    return
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deletepicuserphoto={
    //TODO: check user logged in
    requestService.init(this)	
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    def lId = requestService.getLongDef('amp;id',0)
    //ОБЯЗАТЕЛЬНАЯ ИНИЦИАЛИЗАЦИЯ TODO: path into cfg
    imageService.init(this,'homephotopic'+lId,'homephotokeeppic'+lId,ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar)
    
    def sName=requestService.getStr("name")
    render(contentType:"application/json"){imageService.deletePicture(sName)} // 4    
  }
  ///////////////////////////////////////////////////////////////////////////////////////////  
  def set_main_photo={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    def lId = requestService.getLongDef('id',0)
    try {
      hsRes = Userphoto.set_main_photo(hsRes,lId)
    }catch(Exception e){
      log.debug('Personal:set_main_photo. ERROR ON UPDATE userphoto OR user '+hsRes.user.id+'\n'+e.toString())
    }

    return hsRes
  }

  def sort_photo={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    def getIds = requestService.getStringList('ids')
    try {
      Userphoto.sort_photo(hsRes.user.id,getIds)
    }catch(Exception e){
      log.debug('Personal:sort_photo. Error on save userphoto \n'+e.toString())
    }

    render(contentType:"application/json"){error(false)}//AJAX
  }

  def set_tender_photo={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    def lId = requestService.getLongDef('id',0)
    try {
      hsRes = Userphoto.set_tender_photo(hsRes,lId)
    }catch(Exception e){
      log.debug('Personal:set_tender_photo. ERROR ON UPDATE userphoto OR create tendmembers for user: '+hsRes.user.id+'\n'+e.toString())
    }

    render(contentType:"application/json"){error(false)}//AJAX
  }

  def bigPhoto = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)

    def sIds = requestService.getStr('id')?.split('-')

    if(sIds.size()>1){
      hsRes.photo = Userphoto.findByIdAndUser_id(sIds[0],sIds[1])
      hsRes.alreadyVoting = (hsRes.user?.tender_votelist?.split(',')?.toList()?.contains(sIds[1]))?true:false
      hsRes.city = City.list()
      hsRes.curTenderId = Tender.getCurrentTender()?.id?:-1
      if (hsRes.photo?.is_tender==hsRes.curTenderId) {
        try {
          hsRes.tendmember = Tendmembers.findOrCreate(sIds[1])
        } catch(Exception e) {
          log.debug('Personal:bigPhoto. --> '+e.toString())
        }
      }
      if (hsRes.photo) {
        def oComments = new PcommentSearch()
        hsRes.comments = oComments.csiSelectPcommentsForPhoto(hsRes.photo.id,(hsRes.user?.id?:0 as Long),5,requestService.getOffset())
        //ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar
        //println imageService.getImageWidth('o_'+hsRes.photo.picture,'http://imgea.trace.ru/imgea/'+'user/')
      }
      if (hsRes.user) {
        hsRes.maycomment = (User2user.getMutualRating(hsRes.user.id,sIds[1])>=0)?true:false
      }
    }

    return hsRes
  }

  def oldercomments = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)

    hsRes.lId = requestService.getIntDef('id',0)
    hsRes.offset = requestService.getOffset()
    def oComments = new PcommentSearch()
    hsRes.comments = oComments.csiSelectPcommentsForPhoto(hsRes.lId,(hsRes.user?.id?:0 as Long),5,hsRes.offset)
    hsRes.city = City.list()

    return hsRes
  }

  def addnewPhotoComment={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    hsRes.sText=requestService.getStr('comtext')
    hsRes.photo_id=requestService.getIntDef('photo_id',0)

    if (hsRes.user&&hsRes.sText&&hsRes.photo_id) {
      try {
        hsRes.pcomment = Pcomment.addNewComment(hsRes.photo_id,hsRes.sText,hsRes.user.id)
        hsRes.city = City.list()
      } catch(Exception e) {
        log.debug('Personal:addnewPhotoComment. ERROR ON add new Comment for Photo: '+hsRes.photo_id+'\n'+e.toString())
      }
    }
    return hsRes
  }

  def deleteComment={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()

    if (hsRes.user) {
      try {
        Pcomment.deleteComment(requestService.getLongDef('id',0),hsRes.user.id)
      } catch(Exception e) {
        log.debug('Personal:deleteComment. ERROR ON delete Comment:\n'+e.toString())
      }
    }

    render(contentType:"application/json"){error(false)}
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////photo<<<////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////userplace>>>////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  def place={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    //hsRes+=requestService.getParams(['city_id', 'metro_id'],['x','y'])
    hsRes.city = City.list()
    if (hsRes.user.city_id)
      hsRes.metro = Metro.findAllByCity_idAndModstatus(hsRes.user.city_id,1)

    return hsRes
  }

  def placelist={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    hsRes.userplace = Userplace.findAllByUser_id(hsRes.user.id)

    return hsRes
  }

  def savePlace={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return

    hsRes+=requestService.getParams(['city_id', 'metro_id','place_id'],['x','y'],['name','address'])
    def result = [:]
    result.error = false
    if(!hsRes.inrequest?.name)
      result.error = true
    if (!result.error){
      try {
        if (!hsRes.inrequest.place_id) {
          Userplace.userplaceadd(hsRes)
        } else {
          Userplace.userplaceUpdate(hsRes)
        }
      }catch(Exception e){
        log.debug('Personal:savePlace. ERROR ON ADD OR UPDATE userplace for user: '+hsRes.user.id+'\n'+e.toString())
      }
    }
    render result as JSON
    return
  }

  def placedelete={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if (!checkUser(hsRes)) return
    hsRes+=requestService.getParams(null,['id'])

    def oUserplace = Userplace.get(hsRes.inrequest?.id?:0)
    if (!oUserplace || hsRes.user.id!=oUserplace.user_id){
      response.sendError(404)
      return
    }
    def result = [:]
    result.lIds = hsRes.inrequest?.id

    if (oUserplace.is_main){
      User.updateGeoSt(hsRes,-2)
      result.is_main = 1
    }
    oUserplace.delete(flush:true)

    render result as JSON
    return
  }

  def mmGeoupd={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    if(hsRes.user)
      hsRes.placelist = Userplace.findAllByUser_id(hsRes.user?.id?:0)
    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////userplace<<<////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////favorite>>>/////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  def favorite={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes.tofriend_relnote = Relnote.findAllByType(0)
    hsRes.tofoe_relnote = Relnote.findAllByType(1)

    return hsRes
  }

  def myfriends={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    hsRes+=requestService.getParams(['type'])
    hsRes.max = Tools.getIntVal(ConfigurationHolder.config.search.listing.max,7)
    def oUsers = new UserSearch()
    switch(hsRes.inrequest?.type?:1) {
      case 2:hsRes.data = oUsers.csiSearchWhereImFriend(hsRes.user.id,hsRes.max,requestService.getOffset());break;
      case 3:hsRes.data = oUsers.csiSearchIgnored(hsRes.user.id,hsRes.max,requestService.getOffset());break;
      case 1:
      default:hsRes.data = oUsers.csiSearchMyFriends(hsRes.user.id,hsRes.max,requestService.getOffset());break;
    }
    hsRes.city=City.list()
    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.max_user_age = Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)

    return hsRes
  }

  def mymapfriends={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    hsRes.max = Tools.getIntVal(ConfigurationHolder.config.search.map.max,100)
    def oUsers = new UserSearch()
    hsRes.data = oUsers.csiSearchMyFriends(hsRes.user.id,hsRes.max,requestService.getOffset())
    hsRes.city=City.list()
    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.max_user_age = Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)

    return hsRes
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////favorite<<</////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////messages>>>/////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  def messages={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes.openchats = hsRes.user.openchats?hsRes.user.openchats.split(',')?.collect{[name:User.get(it?.toLong()).nickname?:User.get(it?.toLong()).firstname,id:it]}:[:]
    def tmp = Chatstatus.findAll('from Chatstatus where (fromuser=:id and modstatus=-1) or (touser=:id and modstatus=1)',[id:hsRes.user.id])
    hsRes.nlist = tmp.collect{ if(it.touser==hsRes.user.id) it.fromuser; else it.touser; }.join(',')
    hsRes.nld = tmp.collect{ it.lastdate.getTime()/1000 }.join(',')
    hsRes.tofoe_relnote = Relnote.findAllByType(1)

    return hsRes
  }

  def messageList={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    def oChatlist = new Chatlist()
    hsRes.data = oChatlist.csiSelectMessagesForUser(hsRes.user.id,10,requestService.getOffset())
    hsRes.city=City.list()
    
    return hsRes
  }

  def messageDetails={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    def lId=requestService.getLongDef('id',0)
    hsRes.interlocutor = User.get(lId)
    chatService.updateStatus(hsRes.user.id,lId)
    def oChat = new Chat()
    hsRes.data = oChat.csiSelectChatForUser(hsRes.user.id,lId,10,requestService.getOffset())
    session.chatVersDate = new Date()
    hsRes.data.records.sort {
      c1, c2 -> c1.inputdate <=> c2.inputdate
    }
    hsRes.city=City.list()
    hsRes.online = ((new Date()).getTime() - hsRes.interlocutor.lastdate.getTime()) < 900000

    return hsRes
  }

  def oldMessageDetails={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    def lId=requestService.getLongDef('id',0)
    def offset=requestService.getLongDef('amp;offset',0).toInteger()
    hsRes.interlocutor = User.get(lId)

    def oChat = new Chat()
    hsRes.data = oChat.csiSelectChatForUser(hsRes.user.id,lId,10,offset)
    if(!hsRes.data.records) {
      render ''
      return
    } else {
      hsRes.data.records.sort {
        c1, c2 -> c1.inputdate <=> c2.inputdate
      }
    }

    return hsRes
  }

  def getopenchats={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes.lId=requestService.getLongDef('UId',0)
    def bClose=requestService.getIntDef('amp;bclose',0)
    if (hsRes.lId) {
      try {
        hsRes.user.openchatsUpdate(hsRes.lId,bClose?true:false)
      } catch(Exception e) {
        log.debug('Personal:getopenchats. ERROR ON update openchats on User '+hsRes.user.id+'\n'+e.toString())
      }
    }
    hsRes.openchats = hsRes.user.openchats?hsRes.user.openchats.split(',')?.collect{[name:User.get(it?.toLong())?.nickname?:User.get(it?.toLong())?.firstname,id:it]}:[:]
    if (bClose) {
      hsRes.lId = hsRes.user.openchats?hsRes.user.openchats.split(',')[0]:0
    }

    return hsRes
  }

  def newMessage={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }
    hsRes.lId=requestService.getLongDef('interlocutor_id',0)
    hsRes.ctext=requestService.getStr('ctext')
    if (!(hsRes.lId && hsRes.ctext)) {
      render(contentType:"application/json"){error(true)}
      return
    }

    try {
      chatService.addNewChatMessage(hsRes.user.id,hsRes.lId,hsRes.ctext)
    } catch(Exception e) {
      log.debug('Personal:newMessage. ERROR ON add chatmessage for User: '+hsRes.user.id+' and User: '+hsRes.lId+'\n'+e.toString())
      render(contentType:"application/json"){error(true)}
      return
    }

    render(contentType:"application/json"){error(false)}
    return
  }

  def chatUpd={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    def lId=requestService.getLongDef('id',0)

    def oChat = new Chat()
    hsRes.data = [:]
    hsRes.data.records = oChat.csiSelectNewChatForUser(hsRes.user.id,lId,(session.chatVersDate?:new Date()),-1)
    session.chatVersDate = new Date()
    hsRes.interlocutor = User.get(lId)
    hsRes.online = ((new Date()).getTime() - hsRes.interlocutor.lastdate.getTime()) < 900000
    if (hsRes.data.records)
      chatService.updateStatus(hsRes.user.id,lId)
    render(view:"oldMessageDetails",model:hsRes)
  }

  def watchNew={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    def lId=requestService.getLongDef('id',0)

    if (User.get(lId)) {
      render chatService.watchNew(lId) as JSON
    } else {
      render(contentType:"application/json"){error(true)}
    }
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////messages<<</////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////meeting>>>//////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  def meeting={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    return hsRes
  }

  def meetingmenu={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)) return

    hsRes.lId=requestService.getLongDef('id',0)
    return hsRes
  }

  def meetingList={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if (!checkUser(hsRes)) return

    hsRes.inrequest = [:]
    hsRes.inrequest.id=requestService.getIntDef('id',0)
    hsRes.inrequest.type=requestService.getIntDef('type',0)

    def oMeetlist = new Meetlist()
    if (hsRes.inrequest.type)
      hsRes.data = oMeetlist.csiSelectMyMeetings(hsRes.user.id,hsRes.inrequest.id,10,requestService.getOffset())
    else
      hsRes.data = oMeetlist.csiSelectMeetingsMe(hsRes.user.id,hsRes.inrequest.id,10,requestService.getOffset())
    hsRes.city=City.list()

    return hsRes
  }

  def meetingAdd={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    hsRes+=requestService.getParams(['meetX','meetY','mapwhere'],['interlocutor_id','meeting_id'],['datetime', 'meetname','meetwhere'])
    if (!hsRes.inrequest.interlocutor_id){
      render(contentType:"application/json"){error(true)}
      return
    }
    if (!hsRes.inrequest.meetname) {
      render ([error:true,errorprop:message(code:'meetingAdd.noName.error',args:[], default:'').toString()] as JSON)
      return
    }
    if (!hsRes.inrequest.meetwhere) {
      render ([error:true,errorprop:message(code:'meetingAdd.noWhere.error',args:[], default:'').toString()] as JSON)
      return
    }
    if (!hsRes.inrequest.datetime) {
      render ([error:true,errorprop:message(code:'meetingAdd.noDateTime.error',args:[], default:'').toString()] as JSON)
      return
    }

    try {
      Meet.addNewMeeting(hsRes)
      if (hsRes.inrequest.meeting_id) {
        Meet.abolishOldMeeting(hsRes.user.id,hsRes.inrequest.meeting_id)
      }
    } catch(Exception e) {
      log.debug('Personal:meetingAdd. ERROR ON add Meet for User: '+hsRes.user.id+' and User: '+hsRes.inrequest.interlocutor_id+'\n'+e.toString())
      render ([error:true,errorprop:message(code:'meetingAdd.database.error',args:[], default:'').toString()] as JSON)
      return
    }

    render(contentType:"application/json"){error(false)}
    return
  }

  def changeStatus={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    hsRes.lId=requestService.getLongDef('id',0)
    hsRes.status=requestService.getIntDef('amp;status',0)
    def oMeet
    if (hsRes.status==-2) {
      oMeet= Meet.findByIdAndFromid(hsRes.lId,hsRes.user.id)
    } else {
      oMeet= Meet.findByIdAndToid(hsRes.lId,hsRes.user.id)
    }
    if (!(oMeet && hsRes.status)) {
      render(contentType:"application/json"){error(true)}
      return
    }

    try {
      oMeet.setstatus(hsRes.status)
    } catch(Exception e) {
      log.debug('Personal:changeStatus. ERROR ON changing Meet status for User: '+hsRes.user.id+' and ID: '+hsRes.lId+'\n'+e.toString())
      render(contentType:"application/json"){error(true)}
      return
    }

    render(contentType:"application/json"){error(false)}
    return
  }

  def meetRating={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    if (!checkUser(hsRes)){
      render(contentType:"application/json"){error(true)}
      return
    }

    hsRes.lId=requestService.getLongDef('id',0)
    hsRes.rating=requestService.getIntDef('amp;rating',0)

    def oMeet = Meet.get(hsRes.lId)
    if (!oMeet) {
      render(contentType:"application/json"){error(true)}
      return
    }

    try {
      oMeet.setrating(hsRes.user.id,hsRes.rating)
    } catch(Exception e) {
      log.debug('Personal:meetRating. ERROR ON setting Meet rating for User: '+hsRes.user.id+' and ID: '+hsRes.lId+'\n'+e.toString())
      render(contentType:"application/json"){error(true)}
      return
    }

    render(contentType:"application/json"){error(false)}
    return
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////meeting<<<//////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
}