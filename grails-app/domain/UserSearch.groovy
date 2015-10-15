import org.codehaus.groovy.grails.commons.ConfigurationHolder
class UserSearch {
  def searchService

  static constraints = {
  }

  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false
  }

///////User part //////////
  Long mid
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

  String openid
  String provider
  Integer banned
  Integer is_vkontakte
  Integer is_facebook
  Integer is_twitter
  Integer is_local

  String tel
  String email
  Date inputdate
  Date lastdate
  String picture
  String smallpicture
  String ultrasmallpicture
  Integer modstatus
  String code
  Integer x
  Integer y
  Integer geocodestatus
  Integer onlinestatus
  Integer vissexstatus
  Integer visagefrom
  Integer visageto
  Integer rating
////////User2User part/////////
  Integer r
  String inp
////////Exstra part////////////
  Integer online
  Integer fav

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSearchUsers(lId,iAgeMin,iAgeMax,iCityId,iGenderId,iOnline,lX,lY,lRemote,iOrder,iHotlink,iMax,iOffset,xl=-1,yl=-1,xr=-1,yr=-1){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='v_user'
    hsSql.where="mid=:id and distance(x,y,:x2,:y2)>-1"+
              ((iAgeMin>0)?' AND age>=:age_min':'')+
              ((iAgeMax>0)?' AND age<=:age_max':'')+
              ((iCityId>0)?' AND city_id=:city_id':'')+
              ((iGenderId>0)?' AND gender_id=:gender_id':'')+
              ((iOnline>-1)?' AND online=:online':'')+
              ((lRemote>0)?' AND distance(x,y,:x2,:y2)<:remote':'')+
              ((xl>-1)?' AND x>:xl and x<:xr and y>:yl and y<:yr':'')

    switch(iOrder) {
      case 1:hsSql.order='lastdate DESC, id DESC';break;
      case 2:hsSql.order='distance(x,y,:x2,:y2) ASC, id ASC';break;
      case 3:hsSql.order='r DESC, id DESC';break;
      case 4:hsSql.order='concat(if(nickname<>"",nickname,""),if(firstname<>"",firstname,"")), id';break;
      case 5:hsSql.order='inp DESC, id DESC';break;
      default:hsSql.order='id DESC';break;
    }

    switch(iHotlink) {
      case 1:hsSql.where+=' and fav=1';break;
      case 2:hsSql.where+=' and inputdate>=:inputdate';if(!iOrder)hsSql.order='inputdate DESC';break;
      case 3:hsSql.where+=' and rating>=:rating';if(!iOrder)hsSql.order='rating DESC';break;
      default:break;
    }

    hsLong['id']=lId
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
    if(iOnline>-1)
      hsLong['online']=iOnline
    if(iHotlink==3)
      hsLong['rating']=Tools.getIntVal(ConfigurationHolder.config.popular.minrating,1)
    else if (iHotlink==2)
      hsString['inputdate']=String.format("%tF %<tT",new Date()-Tools.getIntVal(ConfigurationHolder.config.newest.daysdiff,140))

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,UserSearch.class)

    return hsRes
  }

  def csiSearchMyFriends(lId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, user.id as mid, user2user.inputdate as inp, user2user.rating as r, 1 as fav, (timediff((now() + interval -(15) minute), user.lastdate) < 0) AS online"
    hsSql.from='user2user, user'
    hsSql.where="""(user2user.fromuser=:id and user2user.touser=user.id and markfromto=1 and marktofrom!=-1) OR 
                (user2user.touser=:id and user2user.fromuser=user.id and marktofrom=1 and markfromto!=-1)"""
    hsSql.order='user.id DESC'
    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'user.id',true,UserSearch.class)

    return hsRes
  }

  def csiSearchWhereImFriend(lId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, user.id as mid, user2user.inputdate as inp, user2user.rating as r, 0 as fav, (timediff((now() + interval -(15) minute), user.lastdate) < 0) AS online"
    hsSql.from='user2user, user'
    hsSql.where="""(user2user.fromuser=:id and user2user.touser=user.id and markfromto=0 and marktofrom=1) OR 
                (user2user.touser=:id and user2user.fromuser=user.id and marktofrom=0 and markfromto=1)"""
    hsSql.order='user.id DESC'
    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'user.id',true,UserSearch.class)

    return hsRes
  }

  def csiSearchIgnored(lId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, user.id as mid, user2user.inputdate as inp, user2user.rating as r, -1 as fav, (timediff((now() + interval -(15) minute), user.lastdate) < 0) AS online"
    hsSql.from='user2user, user'
    hsSql.where="""(user2user.fromuser=:id and user2user.touser=user.id and markfromto=-1) OR 
                (user2user.touser=:id and user2user.fromuser=user.id and marktofrom=-1)"""
    hsSql.order='user.id DESC'
    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'user.id',true,UserSearch.class)

    return hsRes
  }

}