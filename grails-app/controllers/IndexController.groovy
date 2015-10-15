import org.codehaus.groovy.grails.commons.ConfigurationHolder
import grails.converters.JSON
class IndexController {
  def usersService
  def requestService
  def jcaptchaService
  def static final DATE_FORMAT='yyyy-MM-dd'
  
  def captcha={    
  }
  
  def spy_protection={
    if (jcaptchaService.validateResponse("image", session.id, params.captcha)){	  
      def oTemp_ipblock=new Temp_ipblock()
      def lsTemp_ipblock=Temp_ipblock.findAllWhere(userip:request.remoteAddr)	  
      for(temp in lsTemp_ipblock){	
        def oTemp_ipblockTmp=Temp_ipblock.get(temp.id)
        oTemp_ipblockTmp.delete()	    
      }	    
    }
    redirect(action:'index')	
  }
  
  def index = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    if(hsRes.spy_protection){	  
      redirect(controller:'index',action:'captcha')
      return
    }

    if(flash.error==51 || flash.error==1)
      if(session.user_enter_fail)
        session.user_enter_fail++
      else
        session.user_enter_fail=1
		
    hsRes+=requestService.getParams(['city_id','gender_id','age_min','age_max'])		
    hsRes.age_max=Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)
    hsRes.age_min=Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.agestep=Tools.getIntVal(ConfigurationHolder.config.slider.age_step,2)
    hsRes.arr=[];
    def i=0
    for(i=hsRes.age_min;i<=hsRes.age_max;i=i+hsRes.agestep)
      hsRes.arr<<i; 
    hsRes.city = City.list()
    hsRes.metro = Metro.list()
    hsRes.remote = Remote.list()
    if (hsRes.user) {
      hsRes.lastsearch = Lastsearch.findByUser_id(hsRes.user.id)
    }

    hsRes.records_new = User.findAllByModstatusAndRef_id(1,0,[max:12,sort:'inputdate',order:'desc'])
    hsRes.records_top = User.findAllByModstatusAndRef_id(1,0,[max:12,sort:'rating',order:'desc'])

    hsRes.imageurl = ConfigurationHolder.config.urlphoto + 'user/'

    return hsRes
  }
  
  def search_table = {
    requestService.init(this) 	
    def hsRes=requestService.getContextAndDictionary(false,false)
    hsRes+=requestService.getParams(['city_id','gender_id','age_min','age_max','sort','hotlink'],['remote'],['view'])
    def iOnline = requestService.getIntDef('visibility_id',0)
    def mapBounds = [:]

    hsRes.imageurl = ConfigurationHolder.config.urlphoto + 'user/'
    hsRes.inrequest.max = (hsRes.inrequest.view=='list')?Tools.getIntVal(ConfigurationHolder.config.search.listing.max,7):Tools.getIntVal(ConfigurationHolder.config.search.map.max,100)
    if (hsRes.inrequest.view=='map')
      mapBounds = requestService.getParams(null,['xl','yl','xr','yr']).inrequest

    if(hsRes.user) {
      try {
        Lastsearch.setLastsearch(hsRes.user.id,hsRes.inrequest.gender_id?:0,hsRes.inrequest.age_min,hsRes.inrequest.age_max,hsRes.inrequest.sort?:0,iOnline,hsRes.inrequest.remote?:0)
      } catch(Exception e) {
        log.debug('Index:search_table. Error on set lastsearch for user '+hsRes.user.id+'\n'+e.toString())
      }
      def oUsers = new UserSearch()
      hsRes.data = oUsers.csiSearchUsers(
        hsRes.user?.id?:0,
        hsRes.inrequest?.age_min?:18,
        hsRes.inrequest?.age_max?:100,
        hsRes.inrequest?.city_id?:0,
        hsRes.inrequest?.gender_id?:0,
        iOnline,
        hsRes.user?.x?:City.get(hsRes.inrequest?.city_id?:78)?.x?:0,
        hsRes.user?.y?:City.get(hsRes.inrequest?.city_id?:78)?.y?:0,
        hsRes.inrequest?.remote?:0,
        hsRes.inrequest?.sort?:0,
        hsRes.inrequest?.hotlink?:0,
        hsRes.inrequest.max,
        requestService.getOffset(),
        (mapBounds?.xl?:-1),
        (mapBounds?.yl?:-1),
        (mapBounds?.xr?:-1),
        (mapBounds?.yr?:-1))
    } else {
      def oUsers = new User()
      hsRes.data = oUsers.csiSearchUsers(
        hsRes.inrequest?.age_min?:18,
        hsRes.inrequest?.age_max?:100,
        hsRes.inrequest?.city_id?:0,
        hsRes.inrequest?.gender_id?:0,
        City.get(hsRes.inrequest?.city_id?:78)?.x?:0,
        City.get(hsRes.inrequest?.city_id?:78)?.y?:0,
        hsRes.inrequest?.remote?:0,
        hsRes.inrequest?.sort?:0,
        hsRes.inrequest?.hotlink?:0,
        hsRes.inrequest.max,
        requestService.getOffset(),
        (mapBounds?.xl?:-1),
        (mapBounds?.yl?:-1),
        (mapBounds?.xr?:-1),
        (mapBounds?.yr?:-1))
    }

    hsRes.min_user_age = Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.max_user_age = Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)
    hsRes.city=City.list()

    return hsRes
  }

  def about = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    return hsRes
  }
  
  def rules = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    return hsRes
  }

  def contacts = { 
  }
  
  def search = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    hsRes+=requestService.getParams(['city_id','gender_id','age_min','age_max','sort','visibility_id','index'],['remote'],['view'])
    if (hsRes.user && hsRes.inrequest.index) {
      try {
        Lastsearch.setLastsearchWOSort(hsRes.user.id,hsRes.inrequest.gender_id?:0,hsRes.inrequest.age_min,hsRes.inrequest.age_max,hsRes.inrequest.visibility_id?:0,hsRes.inrequest.remote?:0)
      } catch(Exception e) {
        log.debug('Index:search_table. Error on set lastsearch for user '+hsRes.user.id+'\n'+e.toString())
      }
    }
    hsRes.age_max=Tools.getIntVal(ConfigurationHolder.config.max_user_age,60)
    hsRes.age_min=Tools.getIntVal(ConfigurationHolder.config.min_user_age,18)
    hsRes.agestep=Tools.getIntVal(ConfigurationHolder.config.slider.age_step,2)
    hsRes.arr=[];
    def i=0
    for(i=hsRes.age_min;i<=hsRes.age_max;i=i+hsRes.agestep)
      hsRes.arr<<i; 
    hsRes.city = City.list()
    hsRes.metro = Metro.list()
    hsRes.tofriend_relnote = Relnote.findAllByType(0)
    hsRes.remote = Remote.list()
    if (hsRes.user) {
      hsRes.lastsearch = Lastsearch.findByUser_id(hsRes.user.id)
    }

    hsRes.imageurl = ConfigurationHolder.config.urlphoto + 'user/'

    return hsRes
  }
  
  def map = {
  }

  def coordUpd = {
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary()
    def lX = requestService.getLongDef('x',0)
    def lY = requestService.getLongDef('amp;y',0)
    if(!(hsRes.user && lX && lY)) {
      render(contentType:"application/json"){error(true)}
      return
    }
    def result
    try {
      result = User.updateCoords(hsRes,lX,lY)
    } catch(Exception e) {
      log.debug('Index:coordUpd. Error on update coords for user '+hsRes.user.id+'\n'+e.toString())
      render(contentType:"application/json"){error(true)}
      return
    }

    render result as JSON
    return
  }

  def geoStatusUpdate = {
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary()
    def iStatus = requestService.getIntDef('status',0)
    if(!(hsRes.user && iStatus)) {
      render(contentType:"application/json"){error(true)}
      return
    }
    def result
    try {
      result = User.updateGeoSt(hsRes,iStatus)
    } catch(Exception e) {
      log.debug('Index:geoStatusUpdate. Error on update geostatus for user '+hsRes.user.id+'\n'+e.toString())
      render(contentType:"application/json"){error(true)}
      return
    }

    render result as JSON
    return
  }

  def statusmessageUpdate={
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary()
    def sMessage = requestService.getStr('message')
    if (hsRes.user) {
      hsRes.user.updateStatusMessage(sMessage)
    }

    render(contentType:"application/json"){error(false)}
  }

  def onlineStatusUpdate={
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary()
    def iStatus = requestService.getIntDef('status',0)
    if (hsRes.user) {
      hsRes.user.updateOnlineStatus(iStatus)
    }

    render(contentType:"application/json"){error(false)}
  }

  def relationship = {
    requestService.init(this)
    def hsRes = requestService.getContextAndDictionary()
    hsRes+=requestService.getParams(['relnote_id','mark','type'],['user_id'],['note'])

    def result = [:]
    result.error = false
    result.type = hsRes.inrequest?.type?:1
    if (!(hsRes.inrequest?.relnote_id || hsRes.inrequest?.note) && hsRes.inrequest.mark) {
      result.error = true
      result.message = message(code:'relationship.noNote.errormessage')
    }
    if (!result.error && hsRes.user && hsRes.inrequest.user_id) {
      try {
        User2user.setRelationship(hsRes)
        result.bchats = hsRes.user.openchats?true:false
      } catch(Exception e) {
        log.debug('Index:relationship. Error on set relationship for users '+hsRes.user.id+' and '+hsRes.inrequest.user_id+'\n'+e.toString())
        result.error = true
        result.message = message(code:'relationship.database.errormessage')
      }
    }

    render result as JSON
    return
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////tenders>>>//////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////

  def tenders={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)

    hsRes.tenderDetails = Tender.getCurrentTender()
    return hsRes
  }

  def tenderPhotos={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(false,true)
    def iSort = requestService.getIntDef('sort',0)
    hsRes.tenderDetails = Tender.getCurrentTender()
    def oSearch = new TenderPhotosSearch()
    def result = oSearch.csiSelectTenderphotos(hsRes.tenderDetails?.id?:-1,iSort?:0,requestService.getOffset())
    hsRes.imges = result.records
    hsRes.count = result.count

    return hsRes
  }

  def tenderRatingPhoto={
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary()
    hsRes.lId=requestService.getLongDef('user_id',0)
    hsRes.rating=requestService.getIntDef('rating',0)

    if (hsRes.user&&hsRes.lId&&hsRes.rating) {
      if (!hsRes.user.tender_votelist?.split(',')?.toList()?.contains(hsRes.lId)) {
        try {
          hsRes.rating = Tendmembers.setrating(hsRes.lId,hsRes.rating)?.overall_rating
          hsRes.user.estimate(hsRes.lId)
        } catch(Exception e) {
          log.debug('Personal:tenderRatingPhoto. ERROR ON set rating for User: '+hsRes.lId+'\n'+e.toString())
        }
        render ([error:false,rating:hsRes.rating] as JSON)
        return
      }
    }
    render(contentType:"application/json"){error(false)}
    return
  }

  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////tenders<<<//////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////
  def robots = {
    requestService.init(this)
    def hsRes=requestService.getContextAndDictionary(true)
    if(Tools.getIntVal(ConfigurationHolder.config.is_robots_txt,0)){
      if(hsRes.context.is_dev){
        render(contentType: 'text/plain', encoding: 'UTF-8'){
          mkp.yield Temp_robots.findWhere(is_dev:1)?.robots?:''
        }
      } else {
        render(contentType: 'text/plain', encoding: 'UTF-8'){
          mkp.yield Temp_robots.findWhere(is_dev:0)?.robots?:''
        }
      }
    }else{
      render(contentType: 'text/plain', encoding: 'UTF-8'){
        mkp.yield Temp_robots.findWhere(is_dev:1)?.robots?:''
      }
    }
  }
}