import javax.imageio.ImageIO
import java.awt.image.BufferedImage
import grails.converters.*
import org.codehaus.groovy.grails.commons.ConfigurationHolder
import java.text.SimpleDateFormat

class AdministratorsController {
  
  def requestService
  def ImageService
  def usersService

  def static final COOKIENAME = 'admin'
  def static final BASEINFO_PICSESSION = 'admin_baseinfo_pics'
  def static final BASEINFO_KEEPPICSESSION = 'admin_baseinfo_keeppics'
  def beforeInterceptor = [action:this.&checkAdmin,except:['login','index']]
  def static final DATE_FORMAT='yyyy-MM-dd'
  
  def checkAdmin() {
    if(session?.admin?.id!=null){     
    }else{
      redirect(controller:'administrators', action:'index',params:[redir:1])
      return false;
    }
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def checkAccess(iActionId){
    def bDenied = true
    session.admin.menu.each{
      if (iActionId==it.id) bDenied = false
    }
    if (bDenied) {
      redirect(action:'profile');
      return
    }
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def index = {
    if (session?.admin?.id){
      redirect(action:'profile')
      return
    } else return params
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def login = {
    requestService.init(this)
    def sAdmin=requestService.getStr('login')
    def sPassword=requestService.getStr('password')	
    
    if (sAdmin==''){
      flash.error = 1 // set login
      redirect(controller:'administrators',action:'index')//TODO change action
      return
    }
    def oAdminlog = new Adminlog()
    def blocktime = Tools.getIntVal(ConfigurationHolder.config.admin.blocktime,1800)
    def unsuccess_log_limit = Tools.getIntVal(ConfigurationHolder.config.admin.unsuccess_log_limit,5)
    sPassword=Tools.hidePsw(sPassword)
    def oAdmin=Admin.find('from Admin where login=:login',
                             [login:sAdmin.toLowerCase()])
    if(!oAdmin){
      flash.error=2 // Wrong password or admin does not exists
      redirect(controller:'administrators',action:'index')
      return
    }else if (oAdminlog.csiCountUnsuccessLogs(oAdmin.id, new Date(System.currentTimeMillis()-blocktime*1000))[0]>=unsuccess_log_limit){
      flash.error=3 // Admin blocked
      oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:2)
      if (!oAdminlog.save(flush:true)){
        log.debug('error on save Adminlog in Admin:login')
        oAdminlog.errors.each{log.debug(it)}
      }
      redirect(controller:'administrators',action:'index')
      return	
    }else if (oAdmin.password != sPassword) {
      flash.error=2 // Wrong password or admin does not exists
      oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:0)
      if (!oAdminlog.save(flush:true)){
        log.debug('error on save Adminlog in Admin:login')
        oAdminlog.errors.each{log.debug(it)}
      }
      redirect(controller:'administrators',action:'index')
      return
    }	
    
    def oAdminmenu = new Adminmenu()
    session.admin = [id            : oAdmin.id,
                     login         : oAdmin.login,                     
                     group         : oAdmin.admingroup_id,
                     menu          : oAdminmenu.csiGetMenu(oAdmin.admingroup_id),
                     accesslevel   : oAdmin.accesslevel
                     ]					       
  	
    //println(session.admin)
    oAdminlog = new Adminlog(admin_id:oAdmin.id,logtime:new Date(),ip:request.remoteAddr,success:1)
    if (!oAdminlog.save(flush:true)){
      log.debug('error on save Adminlog in Admin:login')
      oAdminlog.errors.each{log.debug(it)}
    }
    redirect(action:'profile',params:[ext:1])
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def logout = {
    requestService.init(this)
    session.admin = null

    redirect(controller:'administrators',action: 'index')
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def menu = {
    requestService.init(this)
    def iPage = requestService.getIntDef('menu',1)
    switch (iPage){
      case  1: redirect(action:'profile'); return
      case  2: redirect(action:'administration'); return
      case  3: redirect(action:'users'); return
      case  4: redirect(action:'tenders'); return
      case  5: redirect(action:'infotext'); return
    }
    return [admin:session.admin,action_id:iPage]
  }
////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////Administrator`s profile >>>//////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def profile = {
    requestService.init(this)
    def hsRes = [administrator:Admin.get(session.admin.id),action_id:1]	
    hsRes.admin = session.admin
    def oAdminlog = new Adminlog()
    def lsLogs = oAdminlog.csiGetLogs(hsRes.admin.id)
    if (lsLogs.size()>1){
      hsRes.lastlog = lsLogs[1]
      hsRes.unsuccess_log_amount = oAdminlog.csiCountUnsuccessLogs(hsRes.admin.id, new Date()-7)[0]
      hsRes.unsuccess_limit = Tools.getIntVal(ConfigurationHolder.config.admin.unsuccess_log_showlimit,5)
    }
    hsRes.groupname = Admingroup.get(hsRes.administrator.admingroup_id).name
	
    return hsRes
  }
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def profilesave = {
    checkAccess(1)
    requestService.init(this)
    def hsRes = requestService.getParams([],[],['name','email'])	
    hsRes.inrequest.id=session.admin.id	
    if (hsRes.inrequest.id){
      def oAdmin = Admin.get(hsRes.inrequest.id)             
      oAdmin.name = hsRes.inrequest.name?:''
      oAdmin.email = hsRes.inrequest.email?:''        
      if (!oAdmin.save(flush:true)){
        log.debug('error on save Admin: Administrators.usersave')
        oAdmin.errors.each{log.debug(it)}
      } 
    }
    redirect(action:'profile')
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def changepass = {
    requestService.init(this)
    def hsRes = [done:true,message:'Ошибка']
    def sPass = requestService.getStr('pass')
    def lAjax = requestService.getLongDef('ajax',0)
    if (lAjax) checkAccess(2)
    def lId = lAjax?requestService.getLongDef('id',0):session.admin.id
    //def lId = session.admin.id
    /*if(!sPass)
      flash.error=1
    else*/
	if(sPass.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)){
      flash.error=3	
      hsRes = [done: false,message:message(code:'admin.passw.min.length.error', default:'')+' '+Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)]	  
    }else if (lId>1){
      if (sPass==requestService.getStr('confirm_pass')){
        def oAdmin = new Admin()
        oAdmin.changePass(lId,Tools.hidePsw(sPass))
        hsRes.message = message(code:'passw.done', default:'')
        flash.error=0
      } else {
        hsRes = [done: false,message:message(code:'admin.passwordequal.error', default:'')]        
        flash.error=2
      }
    }
    if (lAjax){
      render hsRes as JSON
      return
    }
    redirect(action:'profile')
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Administrator`s profile <<<///////////////////////////////////////////////////////// 
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Users >>>///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def users = {    
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=3
    hsRes.admin = session.admin	
    hsRes.provider = Provider.findAll('FROM Provider')	
    hsRes.imageurl = ConfigurationHolder.config.urluserphoto

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////
  def userlist = {    
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=3
    hsRes.admin = session.admin
    def oUser=new User()	
    hsRes.imageurl = ConfigurationHolder.config.urluserphoto        
    hsRes+=requestService.getParams(['telchek'],['user_id'],['name','provider'],['registr_date_from','registr_date_to','enter_date_from','enter_date_to'])
    hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)    
    hsRes+=oUser.csiSelectUsers(hsRes.inrequest?.name?:'',hsRes.inrequest?.provider?:'',hsRes.inrequest?.modstatus?:0,hsRes.inrequest?.user_id?:0,hsRes.inrequest?.telchek?:0,hsRes.string.registr_date_from,hsRes.string.registr_date_to,hsRes.string.enter_date_from,hsRes.string.enter_date_to,requestService.getLongDef('order',0),20,requestService.getOffset())

    return hsRes
  }    
 
  def banned={
    requestService.init(this)
    def iId=requestService.getLongDef('id',0)
    def iBanned=requestService.getLongDef('amp;banned',0)
    if(iId>0){
      def oUser=User.get(iId)
      oUser.banned=iBanned

      if(!oUser.save(flush:true)) {
        log.debug(" Error on save User:")
        oUser.errors.each{log.debug(it)}	 
      }
    }
    render(contentType:"application/json"){error(false)}
  }

  def telchek={
    requestService.init(this)
    def iId=requestService.getLongDef('id',0)
    def iTelchek=requestService.getLongDef('amp;telchek',0)
    if(iId>0){
      def oUser=User.get(iId)
      if(oUser?.tel){
        oUser.is_telcheck=iTelchek

        if(!oUser.save(flush:true)) {
          log.debug(" Error on save User(administrator/telchek/"+iId+"):")
          oUser.errors.each{log.debug(it)}
        }
      }
    }
    render(contentType:"application/json"){error(false)}
  }

  def getUserPass={
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=3
    hsRes.admin = session.admin
    
    def lId=requestService.getLongDef('id',0)
    def oUser = User.get(lId)
    if (oUser)
      render oUser as JSON
    render(contentType:"application/json"){error(true)}
  }

  def changeUserPass={
    checkAccess(3)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)  	
    hsRes.action_id=3
    hsRes.admin = session.admin

    def lId=requestService.getLongDef('id',0)
    def oUser = User.get(lId)
    if (oUser) {
      def sPass=requestService.getStr('pass')
      def sPass2=requestService.getStr('pass2')
      if(sPass2!=sPass){
        hsRes.error = true
        hsRes.message = message(code:'admin.changeUserPass.notEqual.error',args:[], default:'').toString()
      } else if(sPass2.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)){
        hsRes.error = true
        hsRes.message = message(code:'admin.changeUserPass.tooEasy.error',args:[], default:'').toString()
      } else  {
        oUser.password=Tools.hidePsw(sPass2)
        if( !oUser.save(flush:true)) {
          log.debug(" Error on save user")
          hsRes.error = true
          hsRes.message = message(code:'admin.changeUserPass.savePass.error',args:[], default:'').toString()
        }
      }
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Users <<<///////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////User administration >>>////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def administration = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[part:requestService.getLongDef('part',0)],action_id:2]
    if (hsRes.inrequest.part){
      hsRes += [groupusers:Admin.findAll('from Admin')]
    } else {
      hsRes += [groupusers:Admingroup.findAll('from Admingroup')]
    }
    hsRes.admin = session.admin
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupuserlist = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[part:requestService.getLongDef('id',0)]]
    if (hsRes.inrequest.part){
      hsRes += [groupusers:Admin.findAll('from Admin where id<>1')]
    }else{
      hsRes += [groupusers:Admingroup.findAll('from Admingroup')]
    }
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupuserdetails = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [inrequest:[id   :requestService.getLongDef('id',0),
                            part :requestService.getLongDef('amp;part',0)]]
    if (hsRes.inrequest.part){
      hsRes += [groups:Admingroup.findAll('from Admingroup')]
      if (hsRes.inrequest.id&&hsRes.inrequest.id != 1){
        hsRes += [user:Admin.get(hsRes.inrequest.id)]        
      }
    }else{
      hsRes += [group:Admingroup.get(hsRes.inrequest.id)]
    }
    return hsRes
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def groupsave = {
    checkAccess(2)
    requestService.init(this)
    def hParams = requestService.getParams(['id','is_users','is_tenders'])
    if (hParams.inrequest.id>0){
      def oAdmingroup = Admingroup.get(hParams.inrequest.id)
      try {
        def sMenu = '1,'
        oAdmingroup.is_profile = 1
        if (hParams.inrequest.is_users)      {oAdmingroup.is_users=1;    sMenu += '3,'}
        else oAdmingroup.is_users=0
        if (hParams.inrequest.is_tenders)      {oAdmingroup.is_tenders=1;    sMenu += '4,'}
        else oAdmingroup.is_tenders=0
		
        if (oAdmingroup.is_superuser)        sMenu+='2,'	  
	  
        oAdmingroup.menu = sMenu
    
        if (!oAdmingroup.save(flush:true)){
          log.debug('error on save Admingroup: Administrators.groupsave')
          oAdmingroup.errors.each{log.debug(it)}
        }
      } catch(Exception e){
        log.debug('error in Administrators.groupsave')
        log.debug(e.toString())
      }
      def hsRes = [id:hParams.inrequest.id]
      hsRes['amp;part'] = 0
      redirect(action:'groupuserdetails',params:hsRes)
      return
    }
    render(contentType:"application/json"){error(true)}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def usersave = {
    checkAccess(2)
    requestService.init(this)
    def hParams = requestService.getParams(['group','id'],[],['login','name','email','confirm_pass','pass'])    
    if (hParams.inrequest.id>1){
      def oAdmin = Admin.get(hParams.inrequest.id)
      try{
        oAdmin.admingroup_id = hParams.inrequest.group?:0        
        oAdmin.login = hParams.inrequest.login?:''
        oAdmin.name = hParams.inrequest.name?:''
        oAdmin.email = hParams.inrequest.email?:''
        oAdmin.password = oAdmin.password?:''
        if (!oAdmin.save(flush:true)){
          log.debug('error on save Admin: Administrators.usersave')
          oAdmin.errors.each{log.debug(it)}
        }        
      }catch(Exception e){
        log.debug('error in Administrators.usersave')
        log.debug(e.toString())
      }
      def hsRes = [id:hParams.inrequest.id]
      hsRes['amp;part'] = 1
      redirect(action:'groupuserdetails',params:hsRes)
      return
    }
    render(contentType:"application/json"){error(true)}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def creategroup = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:true, message:'Ошибка']
    def sName = requestService.getStr('name')
    if (sName) {
      def lsAdmingroups = Admingroup.findAllWhere(name:sName)
      if (!lsAdmingroups){
        def oAdmingroup = new Admingroup(name:sName,menu:'',is_profile:0,is_groupmanage:0,is_users:0)
        if (!oAdmingroup.save(flush:true)){
          log.debug('Error on create Admingroup: Administrators.creategroup')
          oAdmingroup.errors.each{log.debug(it)}
          hsRes = [done:true,message:message(code:'admin.group.add.error', default:'')]
        }else{
          hsRes = [done:true]
		      hsRes.id=oAdmingroup.id
        }
      }else{
        hsRes = [done:false,message:message(code:'admin.group.add.alreadyexists.error', default:'')]
      }
    }else{
      hsRes = [done:false,message:message(code:'admin.group.add.entername.error', default:'')]
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def createuser = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:true, message:message(code:'error', default:'')]
    def sLogin = requestService.getStr('login')
    def sPass = requestService.getStr('pass')
    if (sLogin) {
      def lsAdmin = Admin.findAllWhere(login:sLogin)
      if (!lsAdmin){
        if(sPass.size()<Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)){
          hsRes = [done: false,message:message(code:'admin.passw.min.length.error', default:'')+' '+Tools.getIntVal(ConfigurationHolder.config.user.passwordlength,5)]
        }else if (sPass==requestService.getStr('confirm_pass')){
          def oAdmin = new Admin(login:sLogin,password:Tools.hidePsw(sPass),
                                 email:'',name:'',admingroup_id:0,accesslevel:0)
          if (!oAdmin.save(flush:true)){
            log.debug('Error on create Admin: Administrators.createuser')
            oAdmin.errors.each{log.debug(it)}
            hsRes = [done:true,message:message(code:'admin.adduser.error', default:'')]			
          }else{
            hsRes = [done:true]
            hsRes.id=oAdmin.id
          }
        }else{
          hsRes = [done:false, message:message(code:'admin.passwordequal.error', default:'')]
        }
      }else{
        hsRes = [done:false,message:message(code:'admin.user.alreadyexists.error', default:'')]
      }
    }else{
      hsRes = [done:false, message:message(code:'admin.enter.user.login', default:'')]
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deleteuser = {
    checkAccess(2)
    requestService.init(this)
    def hsRes = [done:false, message:'Ошибка']
    def lId = requestService.getLongDef('id',0)
    if (lId>1){
      if (lId == session.admin.id)
        hsRes.message = message(code:'admin.user.not.delete.error', default:'')
      else{
        def oAdmin = Admin.get(lId)
		    if(oAdmin){
          oAdmin.delete()
          hsRes.done = true
		    }
      }
    }
    render hsRes as JSON
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def deletegroup = {
    checkAccess(2)
    requestService.init(this)
    def lId = requestService.getLongDef('id',0)
    if (lId>0){
      def oAdmingroup = Admingroup.get(lId)
      oAdmingroup.delete()
    }
    render(contentType:"application/json"){ok(true)}
  }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////User administration <<<////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Tenders >>>/////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  def tenders = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=4
    hsRes.admin = session.admin
    hsRes.provider = Provider.findAll('FROM Provider')
    hsRes.imageurl = ConfigurationHolder.config.urluserphoto

    return hsRes
  }
  /////////////////////////////////////////////////////////////////////////////////////////////

  def tenderlist = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=4
    hsRes.admin = session.admin

    def oTenders = new Tender()
    hsRes.imageurl = ConfigurationHolder.config.urluserphoto
    hsRes+=requestService.getParams(null,['tender_id'],['name'],['tender_date'])
    hsRes.inrequest.modstatus = requestService.getIntDef('modstatus',0)   
    hsRes+=oTenders.csiSelectTenders(hsRes.inrequest?.name?:'',hsRes.inrequest?.modstatus?:0,hsRes.inrequest?.tender_id?:0,hsRes.string.tender_date,requestService.getLongDef('order',0),20,requestService.getOffset())

    return hsRes
  }

  def tenderdetails = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=4
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(null,null,['name','slogan','info'],['date_start','date_end'])
    hsRes.tender_id = requestService.getIntDef('tender_id',0)
    SimpleDateFormat sdf = new SimpleDateFormat("EEE MMM dd HH:mm:ss z yyyy", Locale.US)
    if(hsRes.inrequest?.date_start?:'')
      hsRes.inrequest.date_start = sdf.parse(hsRes.inrequest.date_start)
    if(hsRes.inrequest?.date_end?:'')
      hsRes.inrequest.date_end = sdf.parse(hsRes.inrequest.date_end)

    if (!flash.error && hsRes.tender_id) {
      hsRes.inrequest = Tender.get(hsRes.tender_id)
    }

    return hsRes
  }

  def tendersave = {
    checkAccess(4)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.action_id=4
    hsRes.admin = session.admin

    hsRes+=requestService.getParams(null,null,['name','slogan','info'])
    hsRes.inrequest.tender_id = requestService.getIntDef('tender_id',0)
    hsRes.inrequest.date_start = requestService.getDate('tender_date_start')
    hsRes.inrequest.date_end = requestService.getDate('tender_date_end')

    flash.error = []
    if(!hsRes.inrequest.name)
      flash.error<<1
    def bDate=true
    if(!hsRes.inrequest.date_start){
      flash.error<<2
      bDate=false
    }
    if(!hsRes.inrequest.date_end){
      flash.error<<3
      bDate=false
    }
    if (bDate && hsRes.inrequest.date_start>hsRes.inrequest.date_end)
      flash.error<<4
    if (!flash.error) {
      if(Tender.find('from Tender where ((date_start<=:date_start AND date_end>=:date_start) OR (date_start<=:date_end AND date_end>=:date_end) OR (date_start>=:date_start AND date_end<=:date_end)) and id!=:id',
          [date_start:hsRes.inrequest.date_start,date_end:hsRes.inrequest.date_end,id:(hsRes.inrequest.tender_id?:0)]))
        flash.error<<5
    }

    if (!flash.error) {
      if (hsRes.inrequest.tender_id) {
        hsRes.tender = Tender.get(hsRes.tender_id)
      } else {
        hsRes.tender = new Tender()
      }
      if (hsRes.tender) {
        hsRes.tender.name = hsRes.inrequest.name
        hsRes.tender.slogan = hsRes.inrequest.slogan?:""
        hsRes.tender.info = hsRes.inrequest.info?:""
        hsRes.tender.date_start = hsRes.inrequest.date_start
        hsRes.tender.date_end = hsRes.inrequest.date_end
        hsRes.inrequest.modstatus = 0
        try {
          hsRes.tender.save(flush:true)
          hsRes.inrequest.tender_id = hsRes.tender.id
        } catch(Exception e) {
          flash.error<<10
          log.debug('Administrators:tendersave. ERROR ON save Tender: '+(hsRes.tender?.id?:0)+'\n'+e.toString())
        }
      }
    }
    redirect(action:'tenderdetails',params:hsRes.inrequest)
  }

  def changeTendstatus={
    requestService.init(this)
    def iId=requestService.getIntDef('id',0)
    def iStatus=requestService.getIntDef('amp;modstatus',0)
    if(iId>0){
      def oTender=Tender.get(iId)
      oTender.modstatus=iStatus
      if(!oTender.save(flush:true)) {
        log.debug(" Error on save Tender(administrator/changeTendstatus/"+iId+"):")
        oTender.errors.each{log.debug(it)}
      }
    }
    render(contentType:"application/json"){error(false)}
  }

  def deleteTender={
    requestService.init(this)
    def iId=requestService.getIntDef('id',0)
    if(iId>0){
      def oTender=Tender.get(iId)
      oTender?.delete(flush:true)
    }
    render(contentType:"application/json"){error(false)}
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Tenders >>>/////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Infotext >>>////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
//owner Dmitry>>
  def infotext = {    
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')   
    hsRes.action_id=5
    hsRes.admin = session.admin 

    def fromEdit = requestService.getIntDef('fromEdit',0)
    hsRes.type = requestService.getIntDef('type',0)
    if (fromEdit){
      session.lastRequest.fromEdit = fromEdit
      hsRes.inrequest = session.lastRequest
    }
    return hsRes
  }

  def infotextlist = {
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)    
    hsRes.action_id=5
    hsRes.admin = session.admin
    def oInfotext=new Infotext()

    if (session.lastRequest?.fromEdit?:0){
      hsRes.inrequest = session.lastRequest
      session.lastRequest.fromEdit = 0
    } else {
      hsRes+=requestService.getParams(['id'],[],['inf_action','inf_controller'])
      hsRes.inrequest.itemplate_id = requestService.getIntDef('itemplate_id',-1)
      session.lastRequest = [:]
      session.lastRequest = hsRes.inrequest
    }

    if (!hsRes.inrequest.id){
      hsRes+=oInfotext.csiSelectInfotext(hsRes.inrequest.inf_action?:'',hsRes.inrequest.inf_controller?:'',(hsRes.inrequest.itemplate_id!=null)?hsRes.inrequest.itemplate_id:-1,requestService.getLongDef('order',0),20,requestService.getOffset())
      hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')
    } else {
      hsRes+=oInfotext.csiSelectMailtemplate(hsRes.inrequest.inf_action?:'',20,requestService.getOffset())
    }
    return hsRes
  }

  def infotextedit = {
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)    
    hsRes.action_id=5
    hsRes.admin = session.admin
    def lId=requestService.getLongDef('id',0)
    def lType=requestService.getLongDef('type',0)

    if (!lType)
      hsRes.infotext = Infotext.get(lId)
    else
      hsRes.emailTemplate = Email_template.get(lId)
    if(hsRes.infotext){
      def bSave=requestService.getLongDef('save',0)
      if(!bSave)
        hsRes.inrequest=hsRes.infotext
      else {
        flash.save_error=[]
        hsRes+=requestService.getParams([],[],['title','keywords','description','promotext1','promotext2','itext','itext2','itext3','header'])
        hsRes.infotext.title = hsRes.inrequest.title?:''
        hsRes.infotext.keywords = hsRes.inrequest.keywords?:''
        hsRes.infotext.description = hsRes.inrequest.description?:''
        hsRes.infotext.header = hsRes.inrequest.header?:''
        hsRes.infotext.promotext1 = hsRes.inrequest.promotext1?:''
        hsRes.infotext.promotext2 = hsRes.inrequest.promotext2?:''
        hsRes.infotext.itext = hsRes.inrequest.itext?:''
        hsRes.infotext.itext2 = hsRes.inrequest.itext2?:''
        hsRes.infotext.itext3 = hsRes.inrequest.itext3?:''
        hsRes.infotext.moddate = new Date()
        if(!hsRes.infotext.save(flush:true)) {
          log.debug(" Error on save infotext:")
          hsRes.infotext.errors.each{log.debug(it)}
          flash.save_error<<101
        }
        hsRes.inrequest=hsRes.infotext
      }
    } else if (hsRes.emailTemplate){
      def bSave=requestService.getLongDef('save',0)
      if(!bSave)
        hsRes.inrequest=hsRes.emailTemplate.properties
      else {
        flash.save_error=[]
        hsRes+=requestService.getParams([],[],['title','itext','name'])
        hsRes.emailTemplate.title = hsRes.inrequest.title?:''
        hsRes.emailTemplate.itext = hsRes.inrequest.itext?:''
        hsRes.emailTemplate.name = hsRes.inrequest.name?:''
        if(!hsRes.emailTemplate.save(flush:true)) {
          log.debug(" Error on save emailTemplate:")
          hsRes.emailTemplate.errors.each{log.debug(it)}
          flash.save_error<<101
        }
        hsRes.inrequest=hsRes.emailTemplate.properties
      }
    } else {
      redirect(action:'index')
      return
    }
    hsRes.type=lType
    return hsRes
  }
  //owner Dmitry<<
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////// Infotext Add //////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //owner Marina<<
  def infotextadd = {    
    checkAccess(5)
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false) 
    hsRes.action_id=5
    hsRes.admin = session.admin  
    hsRes+=requestService.getParams(['itemplate_id','npage','type'],[],['tcontroller','taction','name'])
    hsRes.itemplate=Itemplate.findAll('FROM Itemplate ORDER BY name')   

    return hsRes
  }
  
  def saveinfotext={    
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false)
    hsRes+=requestService.getParams(['itemplate_id','npage','type'],[],['tcontroller','taction','name'])
    
    if((!hsRes.inrequest?.tcontroller && !hsRes.inrequest?.type)|| !hsRes.inrequest?.taction || !hsRes.inrequest?.name){
      redirect(action:'infotextadd')
      return
    }
    def iId
    if(!hsRes.inrequest?.type) {
      def oInfotext = new Infotext()
      oInfotext.itemplate_id = hsRes.inrequest?.itemplate_id?:0
      oInfotext.controller = hsRes.inrequest?.tcontroller
      oInfotext.action = hsRes.inrequest?.taction    
      oInfotext.npage = hsRes.inrequest?.npage?:0
      oInfotext.icon = ''
      oInfotext.shortname = ''
      oInfotext.name = hsRes.inrequest?.name
      oInfotext.header = ''
      oInfotext.title = hsRes.inrequest?.name
      oInfotext.keywords = ''
      oInfotext.description = ''
      oInfotext.itext = ''
      oInfotext.itext2 = ''
      oInfotext.itext3 = ''
      oInfotext.promotext1 = ''
      oInfotext.promotext2 = ''
      oInfotext.moddate = new Date()
    
      if(!oInfotext.save(flush:true)) {
        log.debug(" Error on save Infotext:")
        oInfotext.errors.each{log.debug(it)}
      }
      iId = oInfotext.id
    } else {
      def oEmailTemplate = new Email_template()
      oEmailTemplate.action = hsRes.inrequest?.taction
      oEmailTemplate.name = hsRes.inrequest?.name
      oEmailTemplate.title = hsRes.inrequest?.name
      oEmailTemplate.itext = ''
    
      if(!oEmailTemplate.save(flush:true)) {
        log.debug(" Error on save Email_template:")
        oEmailTemplate.errors.each{log.debug(it)}
      }
      iId = oEmailTemplate.id
    }
  
    redirect(action:'infotextedit',id:iId, params: [type:hsRes.inrequest?.type?:0])
    return
  }  
  //owner Marina<<
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////Infotext <<<////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////
}
