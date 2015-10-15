import org.codehaus.groovy.grails.commons.ConfigurationHolder
import javax.servlet.http.Cookie

class RequestService {
  boolean transactional = false
  static scope = "request" //!!!!
  static proxy = true
  def transient m_oController=null
  def transient usersService
  def static final DATE_FORMAT='yyyy-MM-dd'
  
  def init(oController){
    m_oController=oController
  }
  ////////////////////////////////////////////////////////////////////////////////////
  private checkInit(){
    if(m_oController==null)
      log.debug("Does not set controller object in Request Service. Call requestService.init(this)")
    return (m_oController==null)
  }  
  ////////////////////////////////////////////////////////////////////////////////////
  def getContextAndDictionary(bContextOnly=false,bGetInfotext=false,bWallet=false,bGetBanners=false) {
    //def sServer=m_oRequest.getServerName().toLowerCase()
    if(checkInit()) return [:]

    def sServer=m_oController.request.getServerName().toLowerCase()
    def iPort=m_oController.request.getServerPort()
    def sLang='' //en
    def hsRes=[
          context:[
            lang:sLang,
            is_dev:(Tools.getIntVal(ConfigurationHolder.config.isdev,0)==1),
            addport:(iPort!=80)?(':'+iPort):'',
            serverURL:(ConfigurationHolder.config.grails.mailServerURL?:ConfigurationHolder.config.grails.serverURL),
            appname:ConfigurationHolder.config.grails.serverApp,
            mapkey:ConfigurationHolder.config.yandex.mapkey
          ]
        ]
    //spy protection
    /*hsRes.spy_protection=false
    if(Temp_ipblock.findWhere(userip:m_oController.request.remoteAddr,status:2)){		
      hsRes.spy_protection=true	  
    }*/
    //capcha fail
    hsRes.capcha_fail=false
    if(Temp_ipblock.findWhere(userip:m_oController.request.remoteAddr,status:1)){
      hsRes.capcha_fail=true
    }

    hsRes.vk_api_key=ConfigurationHolder.config.vk.APIKey
    hsRes.fb_api_key=ConfigurationHolder.config.facebook.APIKey
    hsRes.tw_api_key=ConfigurationHolder.config.twitter.APIKey

    hsRes.user_max_enter_fail=Tools.getIntVal(ConfigurationHolder.config.user_max_enter_fail,10)

    ///////chat refresh delay>>
    hsRes.chat_refresh_delay = Tools.getIntVal(ConfigurationHolder.config.chat_refresh.delay,5000)
    hsRes.get_new_message_delay = Tools.getIntVal(ConfigurationHolder.config.get_new_message.delay,5000)
    ///////<<chat refresh delay
					  
    if(bContextOnly)
      return hsRes

           
	  //htmlPageTextCorrection
    //hsRes.context.gberrortype=Gberrortype.findAll()

    hsRes.user = User.get(usersService.getCurrentUser(this)?.id)

    if(bGetInfotext){
        //infotext ---------------------------------		      	  	      	            
        hsRes?.infotext=Infotext.findWhere(controller:m_oController.controllerName,action:m_oController.actionName)
        if(hsRes.user)  
          hsRes?.usermenu=Infotext.findAll('FROM Infotext WHERE itemplate_id=1 ORDER BY npage ASC')			 //owner Dmitry    */
    }
    
    /*def oUser = new User()
    hsRes.tmp = oUser.csiGetRandPhoto()*/
    def tender_id = Tender.getCurrentTender()?.id?:0
    if (tender_id){
      def oTender = new TenderSearch()
      hsRes.tenderData = oTender.csiGetDataForMain(tender_id?:-1)
    }

    hsRes.imageurl = ConfigurationHolder.config.urlphoto + 'user/'
    if(hsRes.user) {
      hsRes.placelist = Userplace.findAllByUser_id(hsRes.user?.id?:0)
      hsRes.cntNew = Chatstatus.findAll('from Chatstatus where (fromuser=:id and modstatus=-1) or (touser=:id and modstatus=1)',[id:hsRes.user?.id]).size()
      hsRes.cntMNew = Meet.findAll('from Meet where toid=:id and modstatus=0 and now() < mdate',[id:hsRes.user.id]).size()
    }
    /*	
      def oMboxSearch=new MboxSearch()
      hsRes.msg_unread_count=oMboxSearch.getMbox(hsRes.user?.id,0,-1,0,0,1).count
    */
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////
  def setStatistic(page,type=0,home_id=0,reccount=0,keyword='',prop='',reclist=[]) {
    def sServer=m_oController.request.getServerName().toLowerCase()

    def uri=m_oController.request.forwardURI
   // println(uri)
    def sLang='ru' //TODO
    def sWeb='web' //TODO
    
    def user=usersService.getCurrentUser(this)   
    
    def referer=m_oController.request.getHeader("Referer")
    def aReferer
    def sReferer=''
    if(referer!=null){
      aReferer=referer.split('//')
	  if((aReferer?:[]).size()>1){
        def index=aReferer[1].indexOf('/')
        if(index>0)	  
          aReferer[1]=aReferer[1].substring(0,index)
        sReferer=aReferer[1]       
	  }
    }
    def iRefId
    def lsStatref = Statref.findAll('FROM Statref')
    lsStatref.each{
      if ((it.domain)
	    &&(sReferer.contains(it.domain)))
		iRefId = it.id
    }
    if (!iRefId) iRefId = 6
    try{
    def oOnlinelog = new Onlinelog() 
    oOnlinelog.userip = m_oController.request.remoteAddr
    oOnlinelog.reference = sReferer
    oOnlinelog.ref_id = iRefId
    oOnlinelog.page=page
    oOnlinelog.type=type
    oOnlinelog.reccount=reccount
	oOnlinelog.reclist=Tools.arrayToString(reclist,', ')    
    oOnlinelog.home_id=home_id
    oOnlinelog.keyword=keyword
    oOnlinelog.lang=sLang
    oOnlinelog.users_id=(user!=null)?user.id:0
    oOnlinelog.site=sWeb
	oOnlinelog.prop=prop
	
	def sHeader=m_oController.request.getHeader("User-Agent")	
	
	if((sHeader?:'').size()>255){	  
	  sHeader=sHeader.substring(0,255)
	}
	oOnlinelog.useragent=sHeader?sHeader:''
    
      if(!oOnlinelog.save(flush:true)) {
        log.debug(" Error on save Onlinelog:")    
        oOnlinelog.errors.each{log.debug(it)}
      }   	
    }catch(Exception e){
	  log.debug(" Error on save Onlinelog:"+e.toString())    
    }	
  }  
  ///////////////////////////////////////////////////////////////////////////////////
  def getRaw(sName){
    if(checkInit()) return null
    
    return m_oController.params[sName]
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getIds(sName){
    if(checkInit()) return null
    if(m_oController.params[sName]==null)
      return null
    
    def lsRes=[]
    try{
      if(m_oController.params[sName] instanceof String){	  
        lsRes << m_oController.params[sName].toLong()
	  }
      else
        lsRes=m_oController.params[sName].collect{it.toLong()}
    }catch(Exception e){
      log.debug("getIds wrong Long \n"+e.toString())
      lsRes=null
    }
    return lsRes
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getStringList(sName){
    if(checkInit()) return []
    if(m_oController.params[sName]==null)
    return []
    
    def lsRes=[]
    try{
      if(m_oController.params[sName] instanceof String)
      lsRes << m_oController.params[sName].trim()
      else
      lsRes=m_oController.params[sName].collect{it.trim()}
    }catch(Exception e){
      log.debug("Error in list param ${sName}\n"+e.toString())
      lsRes=null
    }
    return lsRes
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getLongDef(sName,iDef){
    try{
	  iDef=iDef.toLong()
	}catch(Exception e){
      //exception here usual on convertion. Pass it.
    }
    if(checkInit()) return iDef
    
    if (m_oController.params==null) return iDef
    if (m_oController.params[sName]==null) return iDef
    if (m_oController.params[sName]=='') return iDef
    try{	
      return m_oController.params[sName].toLong()
    }catch(Exception e){
      //exception here usual on convertion. Pass it.
    }
    return iDef
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getFloatDef(sName,iDef){
    try{
	  iDef=iDef.toFloat()
	}catch(Exception e){
      //exception here usual on convertion. Pass it.
    }
    if(checkInit()) return iDef
    
    if (m_oController.params==null) return iDef
    if (m_oController.params[sName]==null) return iDef
    if (m_oController.params[sName]=='') return iDef
    try{	
      return m_oController.params[sName].toFloat()
    }catch(Exception e){
      //exception here usual on convertion. Pass it.
    }
    return iDef
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getStr(sName){
    if(checkInit()) return ''
    
    try{
      if (m_oController.params==null)
        return ""
      if (m_oController.params[sName]==null)
        return ""
      return m_oController.params[sName].trim()
    }catch(Exception e){
      log.debug("Error in string param ${sName}\n"+e.toString())
    }
    return ""
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getPhoneCode(sName){
    def sPhone = getPreparedStr(sName)
    try{
      sPhone=sPhone.replace('(','').replace(')','').replace('+','').replace('-','').replace(' ','').replace('.','')
      def iTest=sPhone.toLong()
      return sPhone
    }catch(Exception e){
      return ''
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getPhone(sName){
    def sPhone=getPhoneCode(sName)
    if(sPhone.size()>3)
      return sPhone[0..2]+'-'+sPhone[3..-1]
    else
      return sPhone
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getPreparedStrNull(sName){
    sName=getPreparedStr(sName)
    return (sName=='')?null:sName
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getPreparedStr(sName){
    return Tools.prepareSearchString(getStr(sName))
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getMax(){
    def iCfg=Tools.getIntVal(ConfigurationHolder.config.request.max)
    def iMax=getLongDef('max',iCfg).toInteger()
    return Math.min( iMax,iCfg)
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getOffset(){
    def iOffset=getLongDef('offset',0).toInteger()
    return Math.max(iOffset,0)
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getIntFromFloatDef(sName,iDef){
    if(checkInit()) return iDef
    
    if (m_oController.params==null) return iDef
    def sIn=m_oController.params[sName]
    if (sIn==null) return iDef
    if (sIn=='') return iDef
    sIn=sIn.replace(',','.')
    if (sIn=='.') return iDef
    def iPos=sIn.indexOf('.')
    if(iPos>=0)
      sIn=sIn.substring(0,iPos)
    if (sIn=='') return (iPos>=0)?0:iDef
    try{
      return sIn.toInteger()
    }catch(Exception e){
      //pass exception
    }
    return iDef
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getIntDef(sName,iDef){
    if(checkInit()) return iDef
    
    if (m_oController.params[sName]==null) return iDef
    if (m_oController.params[sName]=='') return iDef
    try{
      return m_oController.params[sName].toInteger()
    }catch(Exception e){;
    }
    return iDef
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def setSessionIds(sSessionName,sParamName){
    if(checkInit()) return 
    def sId=getLongDef(sParamName,0).toString()
    if(sId!='0'){
      if(m_oController.session[sSessionName]==null)
        m_oController.session[sSessionName]=[]
      if(sId in m_oController.session[sSessionName]){
        while (sId in m_oController.session[sSessionName])
          m_oController.session[sSessionName].remove(sId)
      }else{
        m_oController.session[sSessionName] << sId
      }
    }
  }
  
  ///////////////////////////////////////////////////////////////////////////////////
  def setSessionParamIds(sSessionName,sId){
    if(checkInit()) return
        if(sId!='0'){
          if(m_oController.session[sSessionName]==null)
            m_oController.session[sSessionName]=[]
          if(sId in m_oController.session[sSessionName]){           
          }else{
            m_oController.session[sSessionName] << sId
          }
        }     
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def setCookie(sName,sValue,iTimeout,bDomain = true){   
    if(checkInit()) return

    if((m_oController.response==null)||(m_oController.request==null)){
      log.debug("ERROR: Call Request method setCookie without nessesary params")
      return
    }
    def oCookie = new Cookie(sName, sValue)

    def sServerURL = ConfigurationHolder.config.grails.serverURL

    if(sServerURL.find(/localhost/)==null&&!sServerURL.matches('.*ktoblizko\\u002Eru.*'))
      if (bDomain){
        def lsServerURL = sServerURL.tokenize(':')
        if(sServerURL.tokenize('.').size()>2){
          oCookie.domain = sServerURL - sServerURL.tokenize('.')[0]-(lsServerURL.size()>2?':'+lsServerURL[2]:'')
        }else{
          oCookie.domain = sServerURL-'http://'-(lsServerURL.size()>2?':'+lsServerURL[2]:'')
        }
      }

    oCookie.path = !sServerURL.matches('.*ktoblizko\\u002Eru.*')?'/KB':'/'
    oCookie.maxAge = iTimeout //108000// 30 days

    m_oController.response.addCookie(oCookie)
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getCookie(sName){
    if(checkInit()) return ''
    
    if((m_oController.response==null)||(m_oController.request==null)){
      log.debug("ERROR: Call Request method getCookie without nessesary params")
      return null
    }	
    def hsCookie=m_oController.request.cookies.find{it.name == sName}

    if(hsCookie)
      return hsCookie.value
    return null
  }    
  ////////////////////////////////////////////////////////////////////////////////////
  def getDate(sName){
    def iYear=getIntDef(sName+'_year',-1)
    def iMonth=getIntDef(sName+'_month',-1)
    def iDay=getIntDef(sName+'_day',-1)
    if((iYear<=0)||(iMonth<=0)||(iDay<=0))
      return null
    try{
      return  (new GregorianCalendar(iYear,iMonth-1, iDay)).time
    }catch(Exception e){
      return null
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////
  def getParams(intParams,liParams=[],lsParams=[],ldParams=[]){
    def hRet=[long:[:],int:[:],string:[:],inrequest:[:]]
    for (elem in lsParams){
      hRet.string[elem]=getStr(elem)
      if(hRet.string[elem]!='')
      hRet.inrequest[elem]=hRet.string[elem]
    }
	for (elem in liParams){
      hRet.long[elem]=getLongDef(elem,0)
      if(hRet.long[elem]!=0)
      hRet.inrequest[elem]=hRet.long[elem]
    }
    for (elem in intParams){
      hRet.int[elem]=getIntDef(elem,0)
      if(hRet.int[elem]!=0)
      hRet.inrequest[elem]=hRet.int[elem]
    }
    def datCurrent
    for (elem in ldParams){ //dates	
      datCurrent=getDate(elem)	  
      hRet.string[elem]=((datCurrent!=null)? datCurrent.format(DATE_FORMAT)
      : getStr(elem))
      if(hRet.string[elem]!='')
      hRet.inrequest[elem]=hRet.string[elem]
    }
    return hRet
  }
  //////////////////////////////////////////////////////////////////////////////////////
  def sendError(iStatusCode,sMessage = null){
    if(checkInit()) return
    
    if((m_oController.response==null)||(m_oController.request==null)){
      log.debug("ERROR: Call Request method sendError without nessesary params")
      return
    }
    try{
      if (sMessage) 
        m_oController.response.sendError(iStatusCode,sMessage)
      else
        m_oController.response.sendError(iStatusCode)
    }catch(Exception e){
      log.debug('Error in Request method sendError\n'+e.toString())
    }
  }
  ///////////////////////////////////////////////////////////////////////////////////
  def getList(sName,bZero=false){
    if(checkInit()) return null
    if(m_oController.params[sName]==null)
    return null
    
    def lsRes=[]
    
    lsRes=m_oController.params[sName].split(',')

    if(bZero){     
      if(lsRes[0]==0 || lsRes[0]=='0' || lsRes[0]=='')
        lsRes=[]
    }
    return lsRes
  }  
}