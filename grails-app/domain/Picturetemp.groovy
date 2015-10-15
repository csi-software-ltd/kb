class Picturetemp { //TODO: Rename into Temppicture
  def sessionFactory
  def searchService
  
  static constraints = {
  }

  String fullname
  String filename
  String toString() {"${this.filename}" }
  
  def csiGetOldFiles(iTimelive) { 
    def hsInt=[t:iTimelive]
    def hsSql=[select:'*',
               from:'picturetemp',
               where:'(UNIX_TIMESTAMP(now())-UNIX_TIMESTAMP(picdate))>:t'
              ]
    return searchService.fetchData(hsSql,null,hsInt,null,null,Picturetemp.class)
  }
  def csiGetFilesForDelete(iTimelive) {
    def hsInt=[t:iTimelive]
    def hsSql=[select:'*',
               from:"""picturetemp 
                left join userphoto ON (picturetemp.filename=userphoto.picture or picturetemp.filename=userphoto.smallpicture or picturetemp.filename=userphoto.ultrasmallpicture)
                left join user ON (picturetemp.filename=user.picture or picturetemp.filename=user.smallpicture or picturetemp.filename=user.ultrasmallpicture)""",
               where:'(UNIX_TIMESTAMP(now())-UNIX_TIMESTAMP(picdate))>:t and 0=ifnull(user_id,0) and 0=ifnull(user.id,0)'
              ]
    return searchService.fetchData(hsSql,null,hsInt,null,null,Picturetemp.class)
  }
  //////////////////////////////////////////////////////////////////////////////////
  def csiDeleteByIds(lsIds) { 
    if((lsIds?:[]).size()==0)    return
    def session = sessionFactory.getCurrentSession()
    def sSql="DELETE FROM picturetemp WHERE id in (:ids)"
    try{
      def qSql=session.createSQLQuery(sSql)
      qSql.setParameterList("ids",lsIds)
      qSql.executeUpdate()
    }catch (Exception e) {
      log.debug("Error Picturetemp:csiDeleteById\n"+e.toString());
    }
    session.clear()  
  }  
  ///////////////////////////////////////////////////////////////////////////////////
  def csiDeleteByFilenames(lsIds) { 
    if((lsIds?:[]).size()==0)    return
    def session = sessionFactory.getCurrentSession()
    def sSql="DELETE FROM picturetemp WHERE filename in (:ids)"
    try{
      def qSql=session.createSQLQuery(sSql)
      qSql.setParameterList("ids",lsIds)
      qSql.executeUpdate()
    }catch (Exception e) {
      log.debug("Error Picturetemp:csiDeleteByFilename\n"+e.toString());
    }
    session.clear()  
  }  
  
}
