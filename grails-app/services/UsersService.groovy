import org.codehaus.groovy.grails.commons.ConfigurationHolder

class UsersService implements Serializable{
  static boolean transactional = false
  static scope = "session"
  static proxy = true
  def transient m_hsUser=null
  static final INTERNALPROVIDER='ktoblizko' //NOTE: lowercase
  static final COOKIENAME='user'
  private static final long serialVersionUID = 1L;
  
  static getOpenIdUrl(sUser,sProvider){
    sUser=sUser.toLowerCase()
    sProvider=sProvider.toLowerCase()

    if(sProvider=='yandex')
      return "http://openid.yandex.ru/"+sUser+"/"
    if(sProvider=='rambler')
      return "http://id.rambler.ru/User/"+sUser+"/"
    if(sProvider=='google')
      return "http://www.google.com/profiles/"+sUser
    if(sProvider=='livejournal')
      return "http://"+sUser+".livejournal.com"
    if(sProvider=='liveinternet')
      return "http://www.liveinternet.ru/User/"+sUser
    if(sProvider=='mail')
      return "http://openid.mail.ru/mail/"+sUser
    if(sProvider=='bk')	  
      return "http://"+sUser+".id.bk.ru"
    if(sProvider=='list')	  
      return "http://"+sUser+".id.list.ru"
    if(sProvider=='inbox')	  
      return "http://"+sUser+".id.inbox.ru"	  	  
    if(sProvider=='aol')
      return "http://openid.aol.com/"+sUser
    if(sProvider=='facebook')
      return "http://www.facebook.com/"+sUser
            
    return sUser //if(sProvider=='openid')
  }

  ///////////////////////////////////////////////////////////////////
  def saveSession(requestService,iRemember=0){
    if((m_hsUser.id?:0)==0)
      return
    def oSession=new Usession()
    def sGuid=oSession.createSession(m_hsUser.id)
    requestService.setCookie(COOKIENAME,sGuid,iRemember?Tools.getIntVal(ConfigurationHolder.config.user.remembertime,2592000):-1)
  }
  ///////////////////////////////////////////////////////////////////
  def deleteSession(requestService){ 
    def oSession=new Usession()
    def sGuid=requestService.getCookie(COOKIENAME)	
    oSession.deleteSession(sGuid)
    requestService.setCookie(COOKIENAME,'',Tools.getIntVal(ConfigurationHolder.config.user.timeout,259200))
    m_hsUser=null    
  }
 ///////////////////////////////////////////////////////////////////
  def restoreSession(requestService){
    def sGuid=requestService.getCookie(COOKIENAME)		
    if(sGuid=='')  return
	
    def oUser=new User()	
    def hsUser=oUser.restorySession(sGuid)
    if((hsUser!=null)&&(hsUser.size()>0))
      m_hsUser=[url:hsUser[0].openid,name:hsUser[0].name,
                provider:hsUser[0].provider,id:hsUser[0].id,
				picture:hsUser[0].picture,
				ref_id:hsUser[0].ref_id,modstatus:hsUser[0].modstatus,
				nickname:hsUser[0].nickname,is_local:hsUser[0].is_local,city_id:hsUser[0].city_id]
    else
      deleteSession(requestService)
	  
  }
  ///////////////////////////////////////////////////////////////////
  def loginUser(sUrlId,sUserFirstName,sUserLastName,sUserGender,sUserEmail,sProvider,requestService,sUserPic='',iRef_id=0){
    def sOpenId=sUrlId.toString().toLowerCase()
    m_hsUser=[url:sOpenId,firstname:sUserFirstName,lastname:sUserLastName,provider:sProvider,gender_id:sUserGender,email:sUserEmail,id:-1,picture:sUserPic,ref_id:iRef_id]
    def hsDbUser=User.find('from User where openid=:id',[id:sOpenId])
    if(hsDbUser!=null){
      if(hsDbUser.banned==0){
		if(hsDbUser.ref_id!=0 || iRef_id!=0){
			def hsDbMainUser=User.find('from User where id=:id',[id:hsDbUser.ref_id?:iRef_id])
			if(hsDbMainUser?.banned==0){
			  m_hsUser.id=hsDbMainUser.id
			  //m_hsUser.ref_id=hsDbUser.ref_id
			  saveSession(requestService)
			  return true
			}
		} else {
		  m_hsUser.id=hsDbUser.id
		  //m_hsUser.ref_id=hsDbUser.ref_id
		  saveSession(requestService)
		  return true
		}
      }
      m_hsUser=null
      return false
    }
    //create new
    ////YOU MUST NOT USE THIS IN USER_SERVICE. D.M.!requestService.setStatistic('registration')
    def oUser=new User()
    def iId=oUser.csiInsertExternal(m_hsUser)
    if(iId<=0){ //cannot create user
      log.debug('User: loginUser: ERROR: cannot create user or get last insert id')
      m_hsUser=null
      return false
    }
	if(iRef_id)
		m_hsUser.id=iRef_id
	else
		m_hsUser.id=iId
    saveSession(requestService)
    return true
  }
  ///////////////////////////////////////////////////////////////////      
  def loginInternalUser(sUserName,sPassword,requestService,iRemember,lUserId=0){
    m_hsUser=null
    def hsDbUser=null
    if(lUserId){
      hsDbUser=User.get(lUserId)
    }else{
      sPassword=Tools.hidePsw(sPassword)
      hsDbUser=User.find('from User where name=:email and password=:password',
                        [email:sUserName.toLowerCase(),password:sPassword])
    }
    if(hsDbUser==null)
      return false
    if(hsDbUser.banned==0){
      if(hsDbUser.ref_id!=0){
        def hsDbMainUser=User.find('from User where id=:id',[id:hsDbUser.ref_id?:0 as long])
        if(hsDbMainUser?.banned==0){
          m_hsUser=[url:'',name:sUserName,provider:INTERNALPROVIDER,id:hsDbMainUser.id,modstatus:hsDbMainUser.modstatus,nickname:hsDbMainUser.nickname]	  
          saveSession(requestService,iRemember)
          return true
        }
      } else {
        m_hsUser=[url:'',name:sUserName,provider:INTERNALPROVIDER,id:hsDbUser.id,modstatus:hsDbUser.modstatus,nickname:hsDbUser.nickname]	  
        saveSession(requestService,iRemember)
        return true
      }
    }
    return false
  }
  ////////////////////////////////////////////////////////////////////
  def getCurrentUser(requestService){
    //if(m_hsUser==null)
    // restoreSession(requestService)
    //else
      if (!checkSession(requestService)){ 
	    m_hsUser = null
	  }else{
	    restoreSession(requestService)
	  }
    return m_hsUser
  }
  ///////////////////////////////////////////////////////////////////
  def logoutUser(requestService){
    m_hsUser=null
    deleteSession(requestService)
    return true
  }
  ///////////////////////////////////////////////////////////////////
  def checkSession(requestService){
    if (!requestService) return
    def bGuid=requestService.getCookie(COOKIENAME)?true:false
    return bGuid
  }
  ///////////////////////////////////////////////////////////////////
  //def clearUserRegistraions(){ <---- moved into job since service has session scope
  //  def oTempusers=new Tempusers()
  //  oTempusers.clearOldRegistrations(Tools.getIntVal(ConfigurationHolder.config.user.registrationtimelive))
  // }
}
