import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.*
class UserController {
  def usersService
  def requestService
  def jcaptchaService
  def imageService
  def mailerService
  
  def reg = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if(hsRes.spy_protection){
      redirect(controller:'index',action:'captcha')
      return
    }
    hsRes+=requestService.getParams(['gender_id','save'],['id'],['firstname','email','passw','ind','kod','telef','control','act'])
    
    if (!(flash?.error?:[]).contains(6))
      hsRes.date=requestService.getParams(['birthday_day','birthday_month','birthday_year'],null,null).inrequest
    if (!flash.error)
      flash.error = []
    if (!hsRes.inrequest.firstname)
      flash.error<<1
    if((hsRes.inrequest?.passw?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:5))
      flash.error<<4
    if (!hsRes.inrequest.email)
      flash.error<<2
    else if (!Tools.checkEmailString(hsRes.inrequest.email))
      flash.error<<3
    else {
      def oUser = User.findByName(hsRes.inrequest.email)
      if (oUser && !flash.error)
        if(!usersService.loginInternalUser(hsRes.inrequest.email,hsRes.inrequest.passw,requestService,1)){    
          flash.error<<5 // Wrong password or user does not exists		
        }else {	
          if(oUser!=null){
            oUser.lastdate=new Date()
            if(!oUser.save(flush:true)) {
              log.debug(" Error on save User:")
              oUser.errors.each{log.debug(it)}	 
            }
          }
          if (hsRes.inrequest.control&&hsRes.inrequest.act) {
            redirect(controller:hsRes.inrequest.control, action:hsRes.inrequest.act, params:hsRes.inrequest)
            return
          } else {
            redirect(controller:'index', action:'index')
            return
          }
        }
    }
    imageService.init(this,'userphotopic','userphotokeeppic',ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0
    if (!hsRes.inrequest.save)
      imageService.finalizeFileSession(['file1'])
    imageService.startFileSession() // 1
    def hsPics=imageService.getSessionPics('file1') // 3
    if(hsPics!=null){
      hsRes.inrequest.picture=hsPics.photo
    }
    hsRes.imageurl = ConfigurationHolder.config.urlphoto + 'user/'
    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)

    return hsRes
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  def saveuserphoto={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)  

    imageService.init(this,'userphotopic','userphotokeeppic',ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0
    def iNo=1    	

    //ÇÀÃÐÓÆÀÅÌ ÃÐÀÔÈÊÓ
    def hsData= imageService.loadPicture(
      "file1",
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

    hsData['num']=1 //<- ÍÅÎÁÕÎÄÈÌÎ ÄËß ÊÎÐÐÅÊÒÍÎÉ ÐÀÁÎÒÛ js â savepictureresult

    // savepictureresult ÎÁÙÈÉ ØÀÁËÎÍ, ÅÑËÈ ÈÑÏÎËÜÇÎÂÀÒÜ ÑÊÐÈÏÒÛ ÀÍÀËÎÃÈ×ÍÎ ÑÄÅËÀÍÍÎÌÓ
    if(requestService.getIntDef('no_webcam',0)){
      render(view:'savepictureresult',model:hsData)
      return
    }else{
      render hsData.filename+','+hsData.thumbname+','+hsData.error+','+hsData.maxweight
      return
    }
    return
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deleteuserphoto={
    //TODO: check user logged in
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)  

    //ÎÁßÇÀÒÅËÜÍÀß ÈÍÈÖÈÀËÈÇÀÖÈß TODO: path into cfg
    imageService.init(this,'userphotopic','userphotokeeppic',ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar)
    
    def sName=requestService.getStr("name")
    render(contentType:"application/json"){imageService.deletePicture(sName)} // 4    
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////////////

  def userAdd = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if(hsRes.spy_protection){
      redirect(controller:'index',action:'captcha')
      return
    }
    hsRes+=requestService.getParams(['birthday_day','birthday_month','birthday_year','gender_id'],null,['firstname','email','passw','ind','kod','telef','control','act'])
    hsRes.inrequest.save = 1
    def lsDirectory=requestService.getParams(['birthday_day','birthday_month','birthday_year']).inrequest
    def lsTel = requestService.getParams(null,null,['ind','kod','telef']).inrequest
    flash.error = []
    def iRefId = 0
    if (!hsRes.inrequest.firstname)
      flash.error<<1
    if((hsRes.inrequest?.passw?:'').size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength?:5))
      flash.error<<4
    if (!hsRes.inrequest.email)
      flash.error<<2
    else if (!Tools.checkEmailString(hsRes.inrequest.email))
      flash.error<<3
    else {
      def oUser = User.findByName(hsRes.inrequest.email)
      if (oUser && !flash.error)
        if(!usersService.loginInternalUser(hsRes.inrequest.email,hsRes.inrequest.passw,requestService,1)){    
          flash.error<<5 // Wrong password or user does not exists		
        }else {	
          if(oUser!=null){
            oUser.lastdate=new Date()
            if(!oUser.save(flush:true)) {
              log.debug(" Error on save User:")
              oUser.errors.each{log.debug(it)}	 
            }
          }
          redirect(controller:'index', action:'index')
          return
        }
    }
    if((lsDirectory?:[]).size()!=3)
      flash.error<<6
    else {
      def bDay = new Date(hsRes.inrequest?.birthday_year-1900,hsRes.inrequest?.birthday_month-1,hsRes.inrequest?.birthday_day)
      if (bDay.getDate()!=hsRes.inrequest?.birthday_day)
        flash.error<<6
      else if(Tools.computeAge(bDay)<Tools.getIntVal(ConfigurationHolder.config.min_user_age,18))
        flash.error<<10
    }
    if (!hsRes.inrequest.gender_id)
      flash.error<<7
    if(lsTel && (lsTel?:[]).size()!=3)
      flash.error<<9
    else if (lsTel){
      for (t in lsTel)
        if (!t.value.replace(' ','').replace('-','').matches("[0-9]+"))
          if(!flash.error.find{it==9})
            flash.error<<9
    }
    if(!flash.error.size()){
      def sCode=java.util.UUID.randomUUID().toString()
      def oNewUser = new User()
      iRefId=oNewUser.csiInsertInternal([email:hsRes.inrequest?.email,password:Tools.hidePsw((hsRes.inrequest?.passw?:'')),firstname:hsRes.inrequest?.firstname,code:sCode])
      if (!iRefId)
        flash.error<<8
    }
    if(flash.error.size()){
      redirect(action:'reg',params:hsRes.inrequest)
      return
    }

    hsRes.user = User.get(iRefId)
    imageService.init(this,'userphotopic','userphotokeeppic',ConfigurationHolder.config.pathtophoto+'user'+File.separatorChar) // 0
    def hsPics=imageService.getSessionPics('file1')
    imageService.finalizeFileSession(['file1'])
    try {
      Userphoto.userphotoadd(hsRes,hsPics)
    }catch(Exception e){
      log.debug('Personal:userphotoadd. ERROR ON ADD userphoto OR UPDATE User '+hsRes.user.id+'\n'+e.toString())
    }

    hsRes.user.birthday = new Date(hsRes.inrequest?.birthday_year-1900,hsRes.inrequest?.birthday_month-1,hsRes.inrequest?.birthday_day)
    hsRes.user.gender_id = hsRes.inrequest?.gender_id
    hsRes.user.age = Tools.computeAge(hsRes.user.birthday)
    if (lsTel)
      hsRes.user.tel = '+'+hsRes.inrequest.ind.replace(' ','').replace('-','')+'('+hsRes.inrequest.kod.replace(' ','').replace('-','')+')'+hsRes.inrequest.telef.replace(' ','').replace('-','')

    try{
      if( !hsRes.user.save(flush:true)) {
        log.debug(" Error on save userphoto:")
        hsRes.user.errors.each{log.debug(it)}
      }
      mailerService.sendActivationMail(hsRes.user, hsRes.context)
    }catch(Exception e){
      log.debug('User:userAdd. ERROR ON ADD photo or sendActivationMail\n'+e.toString())
    }

    redirect(action:'login', params:[user:hsRes.inrequest.email,password:hsRes.inrequest.passw,provider:'ktoblizko',control:'personal',act:'anklocation'])
    return
  }

  def login = {
    requestService.init(this)
    requestService.setCookie('user','parararam',10000)
    def hsInrequest = requestService.getParams(['is_ajax','service'],['user_index','id'],['control','act','what','where']).inrequest
    hsInrequest+=requestService.getParams([],[],['code']).inrequest
    def sUser=requestService.getStr('user')
    def sProvider=requestService.getStr('provider')
    def sPassword=requestService.getStr('password')
    def sMoveTo=request.getHeader('referer')
    def iRemember=requestService.getIntDef('remember',0)
    if(!flash.user_id){//>>not from confirm
      if((hsInrequest?.user_index?:0) && session.user_enter_fail>Tools.getIntVal(ConfigurationHolder.config.user_max_enter_fail,10)){
        try{
          if (! jcaptchaService.validateResponse("image", session.id, params.captcha)){
            flash.error=99 //error in captha
            redirect(controller:(hsInrequest.control?:'index'),action:(hsInrequest.act?:'index'),params:hsInrequest)
            return
          } else {
            session.user_enter_fail=null
          }
        }catch(Exception e){
          flash.error=99 //error in captha
          redirect(controller:(hsInrequest.control?:'index'),action:(hsInrequest.act?:'index'),params:hsInrequest)
          return
        }
      }
      if((sUser=='')||(sProvider=='')){	  
        flash.error = 1 // set user and provider  
        if(requestService.getLongDef('openid',0))	  
          redirect(action:'openid',params:hsInrequest)
        else{          	
          redirect(controller:(hsInrequest.control?:'index'),action:(hsInrequest.act?:'index'),params:hsInrequest)
        }
        return
      }
      if (!sPassword){
        hsInrequest.user = sUser
        flash.error = 2 // empty password is not allowed
        redirect(controller:(hsInrequest.control?:'index'), action:(hsInrequest.act?:'index'),params:hsInrequest)
        return
      }
    }//<<not from confirm  
    if(sProvider.toLowerCase()==usersService.INTERNALPROVIDER){	
      if(!usersService.loginInternalUser(sUser,sPassword,requestService,iRemember,flash?.user_id?:0)){    
        flash.error=51 // Wrong password or user does not exists		
      }else {	
        def oUser=User.findWhere(name:sUser)
        if(oUser!=null){
          oUser.lastdate = new Date()
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
        }	          
      }
    }
    if (hsInrequest.control&&hsInrequest.act) {
      redirect(controller:hsInrequest.control, action:hsInrequest.act, params:hsInrequest)
      return
    }
    redirect(controller:'index', action:'index')
    return
  }
  
  def facebook={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    requestService.setCookie('user','parararam',10000)
    def hsInrequest = requestService.getParams(null,['m_fb_id'],['fb_first_name','fb_last_name','fb_gender','fb_email','fb_birthday','fb_pic','fb_photo','control','act','what','where']).inrequest
    hsInrequest.ankcomplete = true

    if(hsInrequest.m_fb_id?:0) {
      try {
        def bNewUser = true
        if (User.findWhere(openid:'f_'+hsInrequest.m_fb_id.toString()))
          bNewUser = false
        if (!bNewUser){
          if(!usersService.loginUser('f_'+hsInrequest.m_fb_id,hsInrequest.fb_first_name,hsInrequest.fb_last_name,hsInrequest.fb_gender,hsInrequest.fb_email,'facebook',requestService,hsInrequest.fb_photo))
            flash.error=5 // if user banned
          else {
            def oUser = User.get(usersService.m_hsUser.id)//Bad Style :(
            oUser.lastdate = new Date()
            if (oUser.ankstepcomplete!=4)
              hsInrequest.ankcomplete = false
            if(!oUser.save(flush:true)) {
              log.debug(" Error on save User:")
              oUser.errors.each{log.debug(it)}
            }
          }
        }else{
          def oUser = User.find("from User where email=:email and modstatus=1 and ref_id=0",[email:hsInrequest.fb_email])
          if (oUser!=null){
            if(!usersService.loginUser('f_'+hsInrequest.m_fb_id,hsInrequest.fb_first_name,hsInrequest.fb_last_name,hsInrequest.fb_gender,hsInrequest.fb_email,'facebook',requestService,hsInrequest.fb_photo,oUser.id)){
              hsInrequest.error=5 // if user banned
            } else {
              oUser.lastdate = new Date()
              oUser.is_facebook = 1
            }
          } else {
            if(!usersService.loginUser('f_'+hsInrequest.m_fb_id,hsInrequest.fb_first_name,hsInrequest.fb_last_name,hsInrequest.fb_gender,hsInrequest.fb_email,'facebook',requestService,hsInrequest.fb_photo)){
              hsInrequest.error=5 // if user banned
            } else {
              oUser=User.findWhere(openid:'f_'+hsInrequest.m_fb_id.toString())
              oUser.lastdate=new Date()
              try {
				        Userphoto.userphotoadd([user:[id:oUser.id]],[smallthumb:hsInrequest.fb_pic,thumb:hsInrequest.fb_pic,photo:hsInrequest.fb_photo],0,0)
              }catch(Exception e){
				        log.debug('User:facebook. ERROR ON ADD userphoto OR UPDATE User '+oUser.id+'\n'+e.toString())
              }
              oUser.is_facebook = 1
              oUser.birthday = new Date((hsInrequest?.fb_birthday.split('/')[2] as int)-1900,(hsInrequest?.fb_birthday.split('/')[0] as int)-1,hsInrequest?.fb_birthday.split('/')[1] as int)
              oUser.age = Tools.computeAge(oUser.birthday)
              mailerService.sendGreetingMail(oUser)
            }
          }
          if (oUser.ankstepcomplete!=4)
            hsInrequest.ankcomplete = false
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
        }
      } catch (Exception e) {        
        log.debug('Facebook parse error :'+e.toString())        
        hsInrequest.error=3
      }
    }else{
      hsInrequest.error=6
    }
    render hsInrequest as JSON
    return
  }
  
  def vk={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    requestService.setCookie('user','parararam',10000)
    def hsInrequest = requestService.getParams(['vk_gender'],['vk_id'],['vk_first_name','vk_last_name','vk_email','vk_birthday','vk_pic','vk_photo','vk_small','control','act','what','where']).inrequest
    hsInrequest.ankcomplete = true

    def bNewUser = true
    if (User.findWhere(openid:'vk_'+hsInrequest.vk_id.toString()))
      bNewUser = false
    if (bNewUser && !hsInrequest.vk_email){
      render(contentType:"application/json"){error(true)}
      return
    }
    if (bNewUser && !Tools.checkEmailString(hsInrequest.vk_email)) {
      def res = [:]
      res.error = true
      res.message = message(code:'login.vk.badEmail.error',args:[], default:'').toString()
      render res as JSON
      return
    }
    if (bNewUser && hsInrequest.vk_birthday!='undefined') {
      def bDay = new Date((hsInrequest?.vk_birthday.split('\\.')[2] as int)-1900,(hsInrequest?.vk_birthday.split('\\.')[1] as int)-1,hsInrequest?.vk_birthday.split('\\.')[0] as int)
      if (bDay.getDate()!=(hsInrequest?.vk_birthday.split('\\.')[0] as int)){
		    def res = [:]
		    res.error = true
		    res.message = message(code:'login.vk.badDate.error',args:[], default:'').toString()
		    render res as JSON
		    return
      } else if (Tools.computeAge(bDay)<Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)) {
  		  def res = [:]
		    res.error = true
		    res.message = message(code:'login.vk.tooYoung.error',args:[], default:'').toString()
		    render res as JSON
		    return
      }
    }

    if(hsInrequest.vk_id?:0) {
      try {
        if (!bNewUser){
          if(!usersService.loginUser('vk_'+hsInrequest.vk_id,hsInrequest.vk_first_name,hsInrequest.vk_last_name,((hsInrequest.vk_gender==2)?'male':'female'),hsInrequest.vk_email,'vkontakte',requestService,hsInrequest.vk_photo))
            flash.error=5 // if user banned
          else {
            def oUser = User.get(usersService.m_hsUser.id)//Bad Style :(
            oUser.lastdate = new Date()
            if (oUser.ankstepcomplete!=4)
              hsInrequest.ankcomplete = false
            if(!oUser.save(flush:true)) {
              log.debug(" Error on save User:")
              oUser.errors.each{log.debug(it)}
            }
          }
        }else{
          def oUser
          if(!usersService.loginUser('vk_'+hsInrequest.vk_id,hsInrequest.vk_first_name,hsInrequest.vk_last_name,((hsInrequest.vk_gender==2)?'male':'female'),hsInrequest.vk_email,'vkontakte',requestService,hsInrequest.vk_photo)){
            flash.error=5 // if user banned
          } else {
            oUser=User.findWhere(openid:'vk_'+hsInrequest.vk_id.toString())
            oUser.lastdate=new Date()
      		  try {
              Userphoto.userphotoadd([user:[id:oUser.id]],[smallthumb:hsInrequest.vk_small,thumb:hsInrequest.vk_pic,photo:hsInrequest.vk_photo],0,0)
            }catch(Exception e){
              log.debug('User:vk. ERROR ON ADD userphoto OR UPDATE User '+oUser.id+'\n'+e.toString())
            }
            oUser.is_vkontakte = 1
            oUser.birthday = new Date((hsInrequest?.vk_birthday.split('\\.')[2] as int)-1900,(hsInrequest?.vk_birthday.split('\\.')[1] as int)-1,hsInrequest?.vk_birthday.split('\\.')[0] as int)
            oUser.age = Tools.computeAge(oUser.birthday)
            def sCode = java.util.UUID.randomUUID().toString()
            oUser.code = sCode
          }
          if (oUser.ankstepcomplete!=4)
            hsInrequest.ankcomplete = false
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
          mailerService.sendActivationMail(oUser, hsRes.context)
        }
      } catch (Exception e) {        
        log.debug('VK parse error :'+e.toString())        
        flash.error=3
      }
    }else{
      flash.error=6
    }
    if (hsInrequest.control&&hsInrequest.act) {
      redirect(controller:hsInrequest.control, action:hsInrequest.act)
      return
    }
    render hsInrequest as JSON
    return
  }

  def twitter={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    requestService.setCookie('user','parararam',10000)
    def hsInrequest = requestService.getParams(['tw_gender'],['tw_id'],['tw_first_name','tw_last_name','tw_email','tw_birthday','tw_pic','tw_photo','control','act','what','where']).inrequest
    hsInrequest.ankcomplete = true

    def bNewUser = true
    if (User.findWhere(openid:'tw_'+hsInrequest.tw_id.toString()))
      bNewUser = false
    if (bNewUser && !hsInrequest.tw_email){
      render(contentType:"application/json"){error(true)}
      return
    }
    if (bNewUser && !Tools.checkEmailString(hsInrequest.tw_email)) {
      def res = [:]
      res.error = true
      res.message = message(code:'login.tw.badEmail.error',args:[], default:'').toString()
      render res as JSON
      return
    }
    if (bNewUser && !hsInrequest.tw_gender) {
      def res = [:]
      res.error = true
      res.message = message(code:'login.tw.noGender.error',args:[], default:'').toString()
      render res as JSON
      return
    }
    if (bNewUser && hsInrequest.tw_birthday) {
      def bDay = new Date((hsInrequest?.tw_birthday.split('\\.')[2] as int)-1900,(hsInrequest?.tw_birthday.split('\\.')[1] as int)-1,hsInrequest?.tw_birthday.split('\\.')[0] as int)
      if (bDay.getDate()!=(hsInrequest?.tw_birthday.split('\\.')[0] as int)){
        def res = [:]
        res.error = true
        res.message = message(code:'login.tw.badDate.error',args:[], default:'').toString()
        render res as JSON
        return
      } else if(Tools.computeAge(bDay)<Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)){
        def res = [:]
        res.error = true
        res.message = message(code:'login.tw.tooYoung.error',args:[], default:'').toString()
        render res as JSON
        return
      }
    }

    if(hsInrequest.tw_id?:0) {
      try {
        if (!bNewUser){
          if(!usersService.loginUser('tw_'+hsInrequest.tw_id,hsInrequest.tw_first_name,hsInrequest.tw_last_name?:'',((hsInrequest.tw_gender==1)?'male':'female'),hsInrequest.tw_email,'twitter',requestService,hsInrequest.tw_photo))
            flash.error=5 // if user banned
          else {
            def oUser = User.get(usersService.m_hsUser.id)//Bad Style :(
            oUser.lastdate = new Date()
            if (oUser.ankstepcomplete!=4)
              hsInrequest.ankcomplete = false
            if(!oUser.save(flush:true)) {
              log.debug(" Error on save User:")
              oUser.errors.each{log.debug(it)}
            }
          }
        }else{
          def oUser
          if(!usersService.loginUser('tw_'+hsInrequest.tw_id,hsInrequest.tw_first_name,hsInrequest.tw_last_name?:'',((hsInrequest.tw_gender==1)?'male':'female'),hsInrequest.tw_email,'twitter',requestService,hsInrequest.tw_photo)){
            flash.error=5 // if user banned
          } else {
            oUser=User.findWhere(openid:'tw_'+hsInrequest.tw_id.toString())
            oUser.lastdate=new Date()
            try {
              Userphoto.userphotoadd([user:[id:oUser.id]],[smallthumb:hsInrequest.tw_pic,thumb:hsInrequest.tw_pic.replace('_normal','_reasonably_small'),photo:hsInrequest.tw_pic.replace('_normal','')],0,0)
            }catch(Exception e){
              log.debug('User:twitter. ERROR ON ADD userphoto OR UPDATE User '+oUser.id+'\n'+e.toString())
            }
            oUser.is_twitter = 1
            oUser.birthday = new Date((hsInrequest?.tw_birthday.split('\\.')[2] as int)-1900,(hsInrequest?.tw_birthday.split('\\.')[1] as int)-1,hsInrequest?.tw_birthday.split('\\.')[0] as int)
            oUser.age = Tools.computeAge(oUser.birthday)
            def sCode = java.util.UUID.randomUUID().toString()
            oUser.code = sCode
          }
          if (oUser.ankstepcomplete!=4)
            hsInrequest.ankcomplete = false
          if(!oUser.save(flush:true)) {
            log.debug(" Error on save User:")
            oUser.errors.each{log.debug(it)}	 
          }
          mailerService.sendActivationMail(oUser, hsRes.context)
        }
      } catch (Exception e) {        
        log.debug('VK parse error :'+e.toString())        
        flash.error=3
      }
    }else{
      flash.error=6
    }
    if (hsInrequest.control&&hsInrequest.act) {
      redirect(controller:hsInrequest.control, action:hsInrequest.act)
      return
    }
    render hsInrequest as JSON
    return
  }
  ///////////////////////////////////////////////////////////////////////////////////////
  
  def logout = { 
    requestService.init(this)
    usersService.logoutUser(requestService)
    session.user_small_pic=null
    def sTmp=request.getHeader('referer')
    if(sTmp==null){
      redirect(controller:'index',action: 'index')
      return
    }
    else
      redirect(url:sTmp)  
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def confirm={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if(hsRes.spy_protection){
      redirect(controller:'index',action:'captcha')
      return
    }
    def sCode=requestService.getStr('id')
    if(sCode==''){
      flash.error = 1
    }else{
      def oUser=User.findWhere(code:sCode)
      def lRUid = 0
      if(oUser){
		    def oMainUser = User.find("from User where email=:email and is_emailchek=1 and ref_id=0 and id!=:id",[email:oUser.email,id:oUser.id])
		    if (oMainUser) {
		      switch (oUser.provider){
            case 'vkontakte': oMainUser.is_vkontakte = 1; break;
            case 'twitter': oMainUser.is_twitter = 1; break;
            case 'ktoblizko': break;
            default: log.debug(" User:confirm - Error: invalid provider")
          }
		      if(!oMainUser.save(flush:true)) {
            log.debug(" Error on save User")
            oUser.errors.each { log.debug(it)}
          }
		      oUser.ref_id = oMainUser.id
		      oUser.ankstepcomplete = oMainUser.ankstepcomplete
		    } else {
		      mailerService.sendGreetingMail(oUser)
		    }
        oUser.is_emailchek = 1
        oUser.code = ''
        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User")
          oUser.errors.each { log.debug(it)}
        }
		    oUser.checkStatus()
		    if (oUser.provider=='vkontakte'){
		      def aVk_id = oUser.openid.split('_')
		      if (oUser.ankstepcomplete == 4)
            redirect(action:'vk',params:[vk_id:aVk_id[1],act:'index',control:'index'])
		      else
            redirect(action:'vk',params:[vk_id:aVk_id[1],act:'anklocation',control:'personal'])
		      return
		    } else if (oUser.provider=='twitter'){
		      def aVk_id = oUser.openid.split('_')
		      if (oUser.ankstepcomplete == 4)
            redirect(action:'twitter',params:[tw_id:aVk_id[1],act:'index',control:'index'])
		      else
            redirect(action:'twitter',params:[tw_id:aVk_id[1],act:'anklocation',control:'personal'])
		      return
		    } else {
		      flash.user_id=oUser.id
		      if (oUser.ankstepcomplete == 4)
            redirect(action:'login',params:[provider:'ktoblizko',act:'index',control:'index'])
		      else
            redirect(action:'login',params:[provider:'ktoblizko',act:'anklocation',control:'personal'])
		      return
		    }
      }else{
        flash.error = 2
      }
    }
    return hsRes
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def restore={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if(hsRes.spy_protection){
      redirect(controller:'index',action:'captcha')
      return
    }
    hsRes.inrequest=[error:requestService.getIntDef('error',0)]
    hsRes.inrequest.name=requestService.getStr('name')
    if(hsRes.user!=null){
      redirect(controller:'index',action:'index')
      return
    }

    return hsRes 
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////  
  def rest={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes.inrequest=[:]
    if(hsRes.user!=null){
      redirect(controller:'index',action:'index')
      return
    }
    
    hsRes.inrequest.name=requestService.getStr('name')
    hsRes.inrequest.error=0
    
    withForm{
      if(!Tools.checkEmailString(hsRes.inrequest.name)){
        hsRes.inrequest.error=2 //ERROR IN EMAIL
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }
      def oUser=User.findWhere(name:hsRes.inrequest.name)
      if(!oUser){
        hsRes.inrequest.error=1 //USER NOT EXISTS
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }
      try{
        if (!jcaptchaService.validateResponse("image", session.id, params.captcha)){
          hsRes.inrequest.error=3 //error in captha
          redirect(action:"restore",params:hsRes.inrequest)
          return
        }
      }catch(Exception e){
        hsRes.inrequest.error=3 //error in captha
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }
      /*if(oUser.is_external){
        hsRes.inrequest.error=4 //External USER
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }*/
      if (!oUser.code) {
        oUser.code=java.util.UUID.randomUUID().toString()
        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User:")
          oUser.errors.each{log.debug(it)}
        }
      }
      hsRes.inrequest.error = mailerService.sendRestorePassMail(oUser, hsRes.context)
      if (hsRes.inrequest.error){
        redirect(action:"restore",params:hsRes.inrequest)
        return
      }
    }.invalidToken {
      hsRes.inrequest.error=5
      redirect(action:"restore",params:hsRes.inrequest)
      return
    }
    return hsRes 
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  def passwconfirm={
    requestService.init(this)
	def hsResult=requestService.getContextAndDictionary(false,true)
    hsResult.inrequest = [:]
    def sCode=requestService.getStr('id')
    if(sCode=='')
      hsResult.inrequest.error=2
    else{
      def oUser=User.findWhere(code:sCode)
      if(!oUser)
        hsResult.inrequest.error=2
      else{
        session.regusercode=sCode
        session.startchange=true
        redirect(action:'passwsetup')
        return
      }
    }
    render(view:'confirm',model:hsResult)
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////
   def passwsetup={
    requestService.init(this)
    def hsResult=requestService.getContextAndDictionary(false,true)
    if(hsResult.spy_protection){
      redirect(controller:'index',action:'captcha')
      return
    }
    hsResult.inrequest=[error:0]
    def oUser
    if(hsResult.user!=null){
      redirect(action:'index')
      return
    }
    def sCode = session.regusercode?:''
    if(!sCode){
      redirect(action:'restore')
      return
    }
    if(session.startchange?:false){
      session.startchange=false
      hsResult.inrequest.error = 0
    }else{
      oUser = User.findWhere(code:sCode)
      def sPassword1 = requestService.getStr('password1')
      def sPassword2 = requestService.getStr('password2')

      if(sPassword2 != sPassword1)
        hsResult.inrequest.error = 1
      else if(sPassword2.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5))
        hsResult.inrequest.error = 2
      else{
        oUser.password = Tools.hidePsw(sPassword2)
        oUser.code = ''
        try{
          if( !oUser.save(flush:true)) {
            log.debug(" Error on save user")
            oUser.errors.each { log.debug(it) }
          }else
            hsResult.inrequest.error = -1 //ïàðîëü èçìåíåí
        }catch(Exception e) {
          log.debug("Cannot save user \n"+e.toString())
          hsResult.inrequest.error = 3 // general error
        }
        session.regusercode = null
      }
    }

    if(hsResult.inrequest.error == -1){
      redirect(action:'login', params:[user:oUser.name,password:requestService.getStr('password1'),provider:'ktoblizko'])
    }

    return hsResult
  }
  //////////////////////////////////////////////////////////////////////////////////////////////////

  def view = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    if(hsRes.spy_protection){	  
      redirect(controller:'index',action:'captcha')
      return
    }
    def lId=requestService.getLongDef('id',0)	
    hsRes.detail = User.get(lId)
    if(hsRes.detail) {
      hsRes.detailPhotos = Userphoto.findAllByUser_id(hsRes.detail.id,[sort: "norder", order: "asc"])
      def dbday = hsRes.detail.birthday?:''      
      def months=['Января','Февраля','Марта','Апреля','Мая','Июня','Июля','Августа','Сентября','Октября','Ноября','Декабря']
      hsRes.dbday_day = dbday.getDate()
      hsRes.dbday_month = months[dbday.getMonth()]
      hsRes.imageurl = ConfigurationHolder.config.urluserphoto
      hsRes+=requestService.getParams(['geo_enabled','city_id','gender_id'],[],['name','email','wishes','description','hobby']) 
      hsRes.city=City.list()
      hsRes.tofriend_relnote = Relnote.findAllByType(0)
      hsRes.tofoe_relnote = Relnote.findAllByType(1)
      hsRes.detailonline = hsRes.detail.onlinestatus?((new Date().getTime() - hsRes.detail.lastdate.getTime()) < 900000):false
      if (hsRes.user)
        hsRes.relationshipStatus = User2user.find('from User2user where (fromuser=:sFromuser and touser=:sTouser) or (fromuser=:sTouser and touser=:sFromuser)',[sFromuser:hsRes.user.id,sTouser:hsRes.detail.id])
      return hsRes
    } else {
      response.sendError(404)
      return
    }
  }

}
