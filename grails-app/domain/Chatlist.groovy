class Chatlist {
  def searchService

  static constraints = {
  }

  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false
  }

/////chatstatus part////////
  Integer id
  Long fromuser
  Long touser
  String lastmessage
  Date lastdate
  Integer modstatus
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
  Integer x
  Integer y
/////User2User part//////////
  Integer r
/////exstra part/////////////
  Integer online
///////////////////////////////////////////////////////////////////////////////////////////////

	def csiSelectMessagesForUser(lId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*, user.id as user_id, IF (''!=IFNULL(user.nickname,''),user.nickname,user.firstname) as username, user2user.rating as r, (timediff((now() + interval -(15) minute),user.lastdate) < 0) as online"
    hsSql.from="""chatstatus
    							INNER JOIN user ON ((chatstatus.touser=:id AND chatstatus.fromuser = user.id) OR (chatstatus.fromuser=:id AND chatstatus.touser = user.id))
    							LEFT JOIN user2user ON ((chatstatus.touser=:id AND ((chatstatus.fromuser = user2user.fromuser and user2user.touser=:id) OR (chatstatus.fromuser = user2user.touser and user2user.fromuser=:id))) OR (chatstatus.fromuser=:id AND ((chatstatus.touser = user2user.fromuser and user2user.touser=:id) OR (chatstatus.touser = user2user.touser and user2user.fromuser=:id))))
    						"""
    hsSql.where="ifnull(user2user.rating,0)>-1"
    hsSql.order="chatstatus.lastdate DESC"

		hsLong['id']=lId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'chatstatus.id',true,Chatlist.class)

    return hsRes
	}
}
