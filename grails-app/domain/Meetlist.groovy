class Meetlist {
  def searchService

  static constraints = {
  }

  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false
  }

/////meet part//////////////
  Long id
  Date inputdate
  Date mdate
  Long fromid
  Long toid
  String name
  String place
  Integer x
  Integer y
  Integer modstatus
  Integer fromrating
  Integer torating
/////user part//////////////
  Long user_id
  String username
  Integer age
  Integer gender_id
  Integer city_id
  Integer is_local
  String statusmessage
  String picture
  String smallpicture
/////User2User part//////////
  Integer r
/////exstra part/////////////
  Integer online
///////////////////////////////////////////////////////////////////////////////////////////////

	def csiSelectMeetingsForUser(lId,bType,iId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, user.id as user_id, IF (''!=IFNULL(user.nickname,''),user.nickname,user.firstname) as username, user2user.rating as r, (timediff((now() + interval -(15) minute),user.lastdate) < 0) as online"
    hsSql.from="""meet
    							INNER JOIN user ON ((meet.toid=:id AND meet.fromid = user.id) OR (meet.fromid=:id AND meet.toid = user.id))
    							LEFT JOIN user2user ON ((meet.toid=:id AND ((meet.fromid = user2user.fromuser and user2user.touser=:id) OR (meet.fromid = user2user.touser and user2user.fromuser=:id))) OR (meet.fromid=:id AND ((meet.toid = user2user.fromuser and user2user.touser=:id) OR (meet.toid = user2user.touser and user2user.fromuser=:id))))
    						"""
    hsSql.where="ifnull(user2user.rating,0)>-1"+
              ((iId!=3)?((bType)?' AND meet.fromid=:id':' AND meet.toid=:id'):'')+
              ((iId==1)?' AND now() > meet.mdate AND meet.modstatus>-1':(iId==2)?' AND meet.modstatus=-1':(iId==3)?' AND meet.modstatus=-2 AND (meet.fromid=:id OR meet.toid=:id)':' AND now() < meet.mdate AND meet.modstatus>-1')

    hsSql.order="meet.inputdate DESC"

    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'meet.id',true,Meetlist.class)

    return hsRes
	}

  def csiSelectMyMeetings(lId,iId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_myinvite"
    hsSql.where="r>-1"+
              ((iId==1)?' AND fromid=:id AND now() > mdate AND modstatus>-1':(iId==2)?' AND fromid=:id AND modstatus=-1':(iId==3)?' AND modstatus=-2 AND (fromid=:id OR toid=:id)':' AND fromid=:id AND now() < mdate AND modstatus>-1')

    hsSql.order="inputdate DESC"

    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'id',true,Meetlist.class)

    return hsRes
  }

  def csiSelectMeetingsMe(lId,iId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="v_inviteme"
    hsSql.where="r>-1"+
              ((iId==1)?' AND toid=:id AND now() > mdate AND modstatus>-1':(iId==2)?' AND toid=:id AND modstatus=-1':(iId==3)?' AND modstatus=-2 AND (fromid=:id OR toid=:id)':' AND toid=:id AND now() < mdate AND modstatus>-1')

    hsSql.order="inputdate DESC"

    hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'id',true,Meetlist.class)

    return hsRes
  }

}
