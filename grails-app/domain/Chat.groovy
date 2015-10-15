class Chat {
  def searchService
  static constraints = {
  }
  static mapping = {
    version false
  }

  Integer id
  Long fromuser
  Long touser
  String ctext
  Date inputdate

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Chat(){}
  Chat(lUserId, ltoUserId, sNote){
    fromuser = lUserId
    touser = ltoUserId
    ctext = sNote
    inputdate = new Date()
  }
///////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectChatForUser(lId,lUid,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="*"
    hsSql.from="chat"
    hsSql.where="(fromuser=:lId and touser=:lUid) or (fromuser=:lUid and touser=:lId)"
    hsSql.order="inputdate DESC"

    hsLong['lId']=lId
    hsLong['lUid']=lUid

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,null,iMax,iOffset,'id',true,Chat.class)

    return hsRes
  }

  def csiSelectNewChatForUser(lId,lUid,dLastDate,iMax){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from="chat"
    hsSql.where="((fromuser=:lId and touser=:lUid) or (fromuser=:lUid and touser=:lId)) and inputdate>:lastdate"
    hsSql.order="inputdate ASC"

    hsLong['lId']=lId
    hsLong['lUid']=lUid
    hsString['lastdate']=String.format("%tF %<tT",dLastDate)

    def hsRes=searchService.fetchData(hsSql,hsLong,null,hsString,
      null,Chat.class,iMax)

    return hsRes
  }

}