class PcommentSearch {
  def searchService

  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false 
  }

/////pcomment part//////////////
  Long id
  Long user_id
  Integer photo_id
  Integer typeid
  String comtext
  Integer comstatus
  Date comdate
  Long refcomment_id

/////user part//////////////
  String username
  Integer age
  Integer gender_id
  Integer city_id
  Integer is_local
  String picture
  String smallpicture
/////User2User part//////////
  Integer r
/////exstra part/////////////
  Integer online

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  def csiSelectPcommentsForPhoto(lPhotoId,lUId,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]

    hsSql.select="""*, if(('' <> ifnull(user.nickname,'')),user.nickname,user.firstname) AS username,
                  (timediff((now() + interval -(15) minute),user.lastdate) < 0) AS online,
                  ifnull((select user2user.rating from user2user where (((user2user.fromuser =:id) and (user2user.touser = user.id)) or ((user2user.touser =:id) and (user2user.fromuser = user.id)))),0) AS r"""
    hsSql.from='pcomment join user'
    hsSql.where="pcomment.user_id = user.id and pcomment.comstatus>-1"+
				((lPhotoId>0)?' AND pcomment.photo_id =:photo_id':'')
    hsSql.order="pcomment.id DESC"

    if(lPhotoId>0)
      hsLong['photo_id']=lPhotoId
    hsLong['id']=lUId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,null,
      null,['id'],iMax,iOffset,'pcomment.id',true,PcommentSearch.class)
  }

}