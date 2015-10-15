class Usession {
  def sessionFactory
  def searchService  
  static constraints = {
  }
  static mapping = {
    cache false
  }  
  String guid
  Integer userId //TODO rename user_id

  def createSession(iUserId){
    def session = sessionFactory.getCurrentSession()
    def sGuid=''
    def bExists=true
    try{
      while(bExists){
        //Моя параноидальная проверка :-))). D.M
        sGuid=java.util.UUID.randomUUID().toString()
        def lsTmp=searchService.fetchData([select:'count(*)',from:'usession',
            where:'guid=:guid'],null,null,[guid:sGuid],null)
        bExists=lsTmp[0]>0
        session.clear()
      }
    }catch(Exception e){
      log.debug("EXCEPTION Usession:createSession: generate guid (java-sucks) \n"+
        e.toString())
      return ''
    }
    try{
      def sSql="INSERT INTO usession(guid,users_id) VALUES(:guid,:uid)"
      def qSql=session.createSQLQuery(sSql)
      qSql.setString("guid",sGuid);
      qSql.setLong("uid",iUserId.toLong());
      qSql.executeUpdate();
    }catch(Exception e){
      log.debug("Usesion:createSession Cannot add new user. \n"+e.toString())
      return ''
    }
    session.clear()
    return sGuid
  }
  //////////////////////////////////////////////////////////////////////////////
  def deleteSession(sGuid){
    def session = sessionFactory.getCurrentSession()
    def qSql=session.createSQLQuery("DELETE FROM usession WHERE guid=:guid")
    qSql.setString("guid",sGuid);
    try{
      qSql.executeUpdate();
    }catch(Exception e){
      log.debug("Usesion:createSession Cannot delete session. \n"+e.toString())
    }
    session.clear()
  }
  //////////////////////////////////////////////////////////////////////////////
}
