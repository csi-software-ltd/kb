import org.codehaus.groovy.grails.commons.ConfigurationHolder

class User {
  def sessionFactory 
  def searchService
  static constraints = {
    tel (nullable:true,maxSize:50)    
    email(nullable:true,email:true,maxSize:50)
    password(nullable:true,maxSize:50)
    lastdate(nullable:true)
    metro_id(nullable:true)
    ref_id(nullable:true)
    picture(nullable:true)
    smallpicture(nullable:true)
    ultrasmallpicture(nullable:true)
    firstname(nullable:true)
    lastname(nullable:true)
    description(nullable:true)
    statusmessage(nullable:true)
    gender_id(nullable:true)
    city_id(nullable:true)
    age(nullable:true)
    birthday(nullable:true)
    code(nullable:true)
    hobby(nullable:true)
    wishes(nullable:true)
    openchats(nullable:true)
    x(nullable:true)
    y(nullable:true)
    geocodestatus(nullable:true)
    onlinestatus(nullable:true)
    vissexstatus(nullable:true)
    visagefrom(nullable:true)
    visageto(nullable:true)
    visoffline(nullable:true)
    rating(nullable:true)
  }
  static mapping = {
    version false
    cache false
  }
  Long id
  String name
  String firstname
  String lastname
  String nickname
  Date birthday
  Integer age
  Integer gender_id
  Integer city_id
  Long metro_id
  String statusmessage
  String description
  String hobby
  String wishes
  String openchats
  String tender_votelist

  String openid
  String provider
  Integer banned  
  Integer is_vkontakte
  Integer is_facebook
  Integer is_twitter
  Integer is_local
    
  String tel  
  Integer is_telcheck
  String email
  Integer is_emailchek
  Integer ankstepcomplete
  String password
  Date inputdate
  Date lastdate  
  String picture
  String smallpicture
  String ultrasmallpicture
  Long ref_id
  Integer modstatus
  String code
  Integer x
  Integer y
  Integer geocodestatus
  Integer onlinestatus
  Integer vissexstatus
  Integer visagefrom
  Integer visageto
  Integer visoffline
  Integer rating

  String toString() {"${firstname} '${nickname}' ${lastname}" }
  //////////////////////////////////////////////////////////////////////////////
  def csiInsertInternal(hsUser){
    def session = sessionFactory.getCurrentSession()
    def iId=0
    hsUser.email=hsUser.email.toLowerCase()
    def sSql="""
          INSERT INTO user(openid,name,provider,banned,is_local,email,password,firstname,lastname,nickname,modstatus,code,ref_id,ankstepcomplete,is_emailchek,rating,geocodestatus,openchats,tender_votelist)
          VALUES (:openid,:name,'ktoblizko',0,1,:name,:password,:firstname,:lastname,:nickname,:modstatus,:code,0,1,0,0,0,'','')
          ON DUPLICATE KEY  UPDATE name=:name,provider='ktoblizko',password=:password,modstatus=:modstatus
          """
    def qSql=session.createSQLQuery(sSql)
    qSql.setString("name",hsUser.email);
    qSql.setString("openid",ConfigurationHolder.config.user.internal.url+hsUser.email.replace('@','$'));
    qSql.setString("password",hsUser.password?:'');
    qSql.setString("firstname",hsUser.firstname);
    qSql.setString("lastname",hsUser.lastname?:'');
    qSql.setString("nickname",hsUser.nickname?:'');
    qSql.setLong("modstatus",0);
    qSql.setString("code",hsUser.code?:'');
    
    try{
      qSql.executeUpdate();
      return searchService.getLastInsert();
    }catch(Exception e){
      log.debug("User:csiInsert Cannot add new user. \n"+e.toString())
    }
    session.clear()
    return iId
  }
  //////////////////////////////////////////////////////////////////////////////
  def csiInsertExternal(hsUser){
    def session = sessionFactory.getCurrentSession()
    def iId=0
    def sSql="""
          INSERT INTO user(openid,name,firstname,lastname,provider,banned,is_local,picture,ref_id,modstatus,nickname,gender_id,email,ankstepcomplete,is_emailchek,rating,geocodestatus,openchats,tender_votelist)
          VALUES (:openid,:name,:firstname,:lastname,:provider,0,0,:picture,:ref_id,0,:firstname,:gender_id,:email,1,:is_emailchek,0,0,'','')
          ON DUPLICATE KEY  UPDATE name=:name,provider=:provider,picture=:picture
          """
    def qSql=session.createSQLQuery(sSql)
    qSql.setString("openid",hsUser.url?:'');
    qSql.setString("name",(hsUser.firstname+' '+hsUser.lastname)?:'');
    qSql.setString("firstname",hsUser.firstname?:'');
    qSql.setString("lastname",hsUser.lastname?:'');
    qSql.setString("provider",hsUser.provider?:'');
    qSql.setString("picture",hsUser.picture?:'');
    qSql.setLong("ref_id",hsUser.ref_id?:0);
    qSql.setLong("is_emailchek",(hsUser.provider=='vkontakte')?0:1);
    qSql.setLong("gender_id",(hsUser.gender_id=='male')?1:2);
    qSql.setString("email",hsUser.email?:'');
    try{
      qSql.executeUpdate();
      return searchService.getLastInsert();
    }catch(Exception e){
      log.debug("Users:csiInsertExternal Cannot add new user. \n"+e.toString())
    }
    session.clear()
    return iId
  }
  ////////////////////////////////////////////////////////////////////////////////
  def csiSelectUsers(sUserName,sProvider,iModstatus,iUserId,iTelchek,sRegistrDateFrom,sRegistrDateTo,sEnterDateFrom,sEnterDateTo,iOrder,iMax,iOffset){
    def session = sessionFactory.getCurrentSession()
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='user'
    hsSql.where="ref_id=0"+
              ((sUserName!='')?' AND name like CONCAT("%",:name, "%")':'')+
	            ((sProvider!='')?' AND provider=:provider':'')+
              ((iModstatus>-1)?' AND modstatus =:modstatus':'')+
              ((iTelchek>-1)?' AND is_telcheck =:telchek':'')+
              ((iUserId>0)?' AND id =:id':'')+
              ((sRegistrDateFrom!='')?' AND inputdate >:inputdatefrom':'')+
              ((sRegistrDateTo!='')?' AND inputdate <:inputdateto':'')+
              ((sEnterDateFrom!='')?' AND lastdate >:lastdatefrom':'')+
              ((sEnterDateTo!='')?' AND lastdate <:lastdateto':'')

    hsSql.order=(iOrder==1)?"lastdate DESC":((iOrder==2)?"id":"inputdate DESC")
    if(sRegistrDateFrom!='')
      hsString['inputdatefrom']=sRegistrDateFrom
    if(sRegistrDateTo!='')
      hsString['inputdateto']=sRegistrDateTo
    if(sEnterDateFrom!='')
      hsString['lastdatefrom']=sEnterDateFrom
    if(sEnterDateTo!='')
      hsString['lastdateto']=sEnterDateTo
    if(iModstatus>-1)
       hsLong['modstatus']=iModstatus
    if(iTelchek>-1)
       hsLong['telchek']=iTelchek
    if(sUserName!='')
       hsString['name']=sUserName
    if(sProvider!='')
       hsString['provider']=sProvider
    if(iUserId>0)
      hsLong['id']=iUserId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,User.class)
  }  
  //////////////////////////////////////////////////////////////////////////////

  def csiSearchUsers(iAgeMin,iAgeMax,iCityId,iGenderId,lX,lY,lRemote,iOrder,iHotlink,iMax,iOffset,xl=-1,yl=-1,xr=-1,yr=-1){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='user'
    hsSql.where="ref_id=0 and x!=0 and modstatus=1 and onlinestatus=1  and distance(x,y,:x2,:y2)>-1"+
              ((iAgeMin>0)?' AND age>=:age_min':'')+
              ((iAgeMax>0)?' AND age<=:age_max':'')+
              ((iCityId>0)?' AND city_id=:city_id':'')+
              ((iGenderId>0)?' AND gender_id=:gender_id':'')+
              ((lRemote>0)?' AND distance(x,y,:x2,:y2)<:remote':'')+
              ((xl>-1)?' AND x>:xl and x<:xr and y>:yl and y<:yr':'')

    switch(iOrder) {
      case 1:hsSql.order='lastdate DESC, id DESC';break;
      case 2:hsSql.order='distance(x,y,:x2,:y2) ASC, id ASC';break;
      case 4:hsSql.order='concat(if(nickname<>"",nickname,""),if(firstname<>"",firstname,"")), id';break;
      default:hsSql.order='id DESC';break;
    }

    switch(iHotlink) {
      case 2:hsSql.where+=' and inputdate>=:inputdate';if(!iOrder)hsSql.order='inputdate DESC';break;
      case 3:hsSql.where+=' and rating>=:rating';if(!iOrder)hsSql.order='rating DESC';break;
      default:break;
    }

    hsLong['x2']=lX
    hsLong['y2']=lY
    if(xl>-1) {
      hsLong['xl']=xl
      hsLong['xr']=xr
      hsLong['yl']=yl
      hsLong['yr']=yr
    }
    if(lRemote>0)
      hsLong['remote']=lRemote
    if(iAgeMin>0)
      hsLong['age_min']=iAgeMin
    if(iAgeMax>0)
      hsLong['age_max']=iAgeMax
    if(iCityId>0)
      hsLong['city_id']=iCityId
    if(iGenderId>0)
      hsLong['gender_id']=iGenderId
    if(iHotlink==3)
      hsLong['rating']=Tools.getIntVal(ConfigurationHolder.config.popular.minrating,1)
    else if (iHotlink==2)
      hsString['inputdate']=String.format("%tF %<tT",new Date()-Tools.getIntVal(ConfigurationHolder.config.newest.daysdiff,140))

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,User.class)

    return hsRes
  }

  //////////////////////////////////////////////////////////////////////////////
  def restorySession(sGuid){  
    def hsSql=[
      select:"*, user.id as id",
      from:"user,usession",
      where:"(user.id=usession.users_id) AND (user.banned=0) AND (usession.guid=:guid)"]
    
    return searchService.fetchData(hsSql,null,null,[guid:sGuid],null,User.class)
  }
  /////////////////////////////////////////////////////////////////////////////
  def csiGetInactiveUsers(iTimelive) {
    def hsInt=[t:iTimelive]
    def hsSql=[select:'*',
               from:'user',
               where:'(UNIX_TIMESTAMP(now())-UNIX_TIMESTAMP(lastdate))>:t'
              ]
    return searchService.fetchData(hsSql,null,hsInt,null,null,User.class)
  }

  Boolean validateTelNumber(){
    this.smscode = Tools.generateSMScode()
    if(!this.save(flush:true))
      return false
    return true
  }

  def csiGetRandPhoto(){	
    def hsSql = [select :"*",
                 from   :'user ',
                 where  :'picture!=""',
                 order  :'rand()']
    return searchService.fetchData(hsSql,null,null,null,null,User.class,1)
  }

  static Boolean updateAnkLoc(hsRes) {
    if (!hsRes.inrequest?.city_id){
      hsRes.user.city_id = getCityId(hsRes.inrequest?.x,hsRes.inrequest?.y)
    } else
      hsRes.user.city_id = hsRes.inrequest?.city_id
    hsRes.user.metro_id = hsRes.inrequest?.metro_id?:0
    if (!hsRes.inrequest?.x){
      Random rand = new Random(System.currentTimeMillis())
      if (!hsRes.user.metro_id){
        def offset = Tools.getIntVal(ConfigurationHolder.config.coordOffset.city,2000)
        hsRes.user.x = City.get(hsRes.user.city_id).x + (rand.nextInt().abs() % (2 * offset) - offset)
        hsRes.user.y = City.get(hsRes.user.city_id).y + (rand.nextInt().abs() % (2 * offset) - offset)
      } else {
        def offset = Tools.getIntVal(ConfigurationHolder.config.coordOffset.metro,1000)
        hsRes.user.x = Metro.get(hsRes.user.metro_id).x + (rand.nextInt().abs() % (2 * offset) - offset)
        hsRes.user.y = Metro.get(hsRes.user.metro_id).y + (rand.nextInt().abs() % (2 * offset) - offset)
      }
    } else if (hsRes.inrequest?.x == 3031579 && hsRes.inrequest?.y == 5993904) {
      Random rand = new Random(System.currentTimeMillis())
      if (!hsRes.user.metro_id){
        def offset = Tools.getIntVal(ConfigurationHolder.config.coordOffset.city,2000)
        hsRes.user.x = hsRes.inrequest?.x + (rand.nextInt().abs() % (2 * offset) - offset)
        hsRes.user.y = hsRes.inrequest?.y + (rand.nextInt().abs() % (2 * offset) - offset)
      } else {
        def offset = Tools.getIntVal(ConfigurationHolder.config.coordOffset.metro,1000)
        hsRes.user.x = Metro.get(hsRes.user.metro_id)?.x + (rand.nextInt().abs() % (2 * offset) - offset)
        hsRes.user.y = Metro.get(hsRes.user.metro_id)?.y + (rand.nextInt().abs() % (2 * offset) - offset)
      }
    } else {
      hsRes.user.x = hsRes.inrequest?.x
      hsRes.user.y = hsRes.inrequest?.y
    }
    hsRes.user.geocodestatus = hsRes.inrequest?.geocodestatus?:0
    if (hsRes.inrequest?.geocodestatus==2) {
      try {
        def oUserplace
        if(hsRes.inrequest?.place_id)
          oUserplace = Userplace.userplaceUpdate(hsRes)
        else
          oUserplace = Userplace.userplaceadd(hsRes)
        if (oUserplace)
          Userplace.setMain(oUserplace.id,hsRes.user.id)
      } catch(Exception e) {
        return false
      }
    } else {
      Userplace.resetMain(hsRes.user.id)
    }
    if (hsRes.user.ankstepcomplete==1)
      hsRes.user.ankstepcomplete = 2

    if(!hsRes.user.save(flush:true)) {
      return false
    }
    return true
  }

  static getCityId (x,y) {
    def lsCity = City.list()
    def minDistInd = lsCity[0].id
    def minDist = Math.pow((lsCity[0].x - x),2) + Math.pow((lsCity[0].y - y),2)
    for (int i = 1; i < lsCity.size(); i++ ) {
      if (minDist>Math.pow((lsCity[i].x - x),2) + Math.pow((lsCity[i].y - y),2)) {
        minDist = Math.pow((lsCity[i].x - x),2) + Math.pow((lsCity[i].y - y),2)
        minDistInd = lsCity[i].id
      }
    }
    return minDistInd
  }

  static Boolean updateAnkDescr(hsRes) {
    hsRes.user.description = hsRes.inrequest?.description?:''
    hsRes.user.hobby = hsRes.inrequest?.hobby?:''
    hsRes.user.wishes = hsRes.inrequest?.wishes?:''

    if (hsRes.user.ankstepcomplete==2)
      hsRes.user.ankstepcomplete = 3

    if(!hsRes.user.save(flush:true)) {
      return false
    }
    return true
  }

  static Boolean updateAnkSett(hsRes) {
    hsRes.user.vissexstatus = hsRes.inrequest?.vissexstatus?:0
    hsRes.user.visagefrom = hsRes.inrequest?.visagefrom?:Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.user.visageto = hsRes.inrequest?.visageto?:100
    hsRes.user.visoffline = hsRes.inrequest?.visoffline?:0

    if (hsRes.user.ankstepcomplete==3)
      hsRes.user.ankstepcomplete = 4

    if(!hsRes.user.save(flush:true)) {
      return false
    }
    return true
  }

  void checkStatus() {
    if(ankstepcomplete==4 && is_emailchek == 1){
      modstatus = 1
      save()
    }
  }

  Boolean updateMainSett(hsRes) {
    vissexstatus = hsRes.inrequest?.vissexstatus?:0
    visagefrom = hsRes.inrequest?.visagefrom?:Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    visageto = hsRes.inrequest?.visageto?:100
    visoffline = hsRes.inrequest?.visoffline?:0
    description = hsRes.inrequest?.description?:''
    hobby = hsRes.inrequest?.hobby?:''
    wishes = hsRes.inrequest?.wishes?:''
    birthday = new Date(hsRes.inrequest?.birthday_year-1900,hsRes.inrequest?.birthday_month-1,hsRes.inrequest?.birthday_day)
    gender_id = hsRes.inrequest?.gender_id
    age = Tools.computeAge(birthday)
    firstname = hsRes.inrequest?.firstname?:''
    lastname = hsRes.inrequest?.lastname?:''
    nickname = hsRes.inrequest?.nickname?:''
    city_id = hsRes.inrequest?.city_id?:0
    metro_id = hsRes.inrequest?.metro_id?:0

    def oldTel = tel?:''
    tel = ''
    if (hsRes.inrequest.ind)
      tel = '+'+hsRes.inrequest.ind.replace(' ','').replace('-','')+'('+hsRes.inrequest.kod.replace(' ','').replace('-','')+')'+hsRes.inrequest.telef.replace(' ','').replace('-','')
    if(oldTel != tel && tel != '')
      is_telcheck  = 0

    if(!save(flush:true)) {
      return false
    }
    return true
  }

  static def updateCoords(hsRes,lX,lY){
    def oUser = User.get(hsRes.user.id)
    if(lX == 3031579 && lY == 5993904) {
      Random rand = new Random(System.currentTimeMillis())
      def offset = Tools.getIntVal(ConfigurationHolder.config.coordOffset.city?:2000)
      oUser.x = lX + (rand.nextInt().abs() % (2 * offset) - offset)
      oUser.y = lY + (rand.nextInt().abs() % (2 * offset) - offset)
    } else {
      oUser.x = lX
      oUser.y = lY
    }

    try {
      oUser.save(flush:true);
    } catch(Exception e) {
      throw e
    }
    return [x:oUser.x,y:oUser.y]
  }

  static def updateGeoSt(hsRes,iStatus){
    def oUser = User.get(hsRes.user.id)
    if(iStatus==-2) {
      oUser.geocodestatus = 0
      Userplace.resetMain(hsRes.user.id)
    } else if(iStatus==-1) {
      oUser.geocodestatus = 1
      Userplace.resetMain(hsRes.user.id)
    } else {
      oUser.geocodestatus = 2
      def oPlace = Userplace.getAndSetMain(iStatus,hsRes.user.id)
      oUser.x = oPlace?.x?:3031579
      oUser.y = oPlace?.y?:5993904
    }

    try {
      oUser.save(flush:true);
    } catch(Exception e) {
      throw e
    }
    return [geoSt:oUser.geocodestatus,x:oUser.x,y:oUser.y]
  }

  void updateStatusMessage(sMessage=''){
    statusmessage = sMessage
    try {
      merge(flush:true)
    } catch(Exception e) {
      log.debug('User:updateStatusMessage. Error on update statusmessage for user '+id+'\n'+e.toString())
    }
  }

  void updateOnlineStatus(iStatus=0){
    onlinestatus = iStatus
    try {
      merge(flush:true)
    } catch(Exception e) {
      log.debug('User:updateOnlineStatus. Error on update online status for user '+id+'\n'+e.toString())
    }
  }

  void updateLastdate(){
    refresh()
    if ((new Date().getTime() - lastdate.getTime())>300000) {
      lastdate = new Date()
      try {
        merge(flush:true)
      } catch(Exception e) {
        log.debug('User:updateLastdate. Error on update lastdate for user '+id+'\n'+e.toString())
      }
    }
  }

  void openchatsUpdate(lId,bDelete=false){
    refresh()
    if(!bDelete)
      openchats = (openchats?openchats+','+lId:openchats+lId).split(',').toList().unique().join(',')
    else
      openchats = (openchats.split(',')-lId.toString()).join(',')

    try {
      merge(flush:true)
    } catch(Exception e) {
      log.debug('User:openchatsUpdate. Error on update openchats for user '+id+'\n'+e.toString())
    }
  }

  void estimate(lId){
    refresh()
    tender_votelist = tender_votelist + lId + ','

    try {
      merge(flush:true)
    } catch(Exception e) {
      log.debug('User:openchatsUpdate. Error on update openchats for user '+id+'\n'+e.toString())
    }
  }

}