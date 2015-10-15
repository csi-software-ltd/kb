import org.codehaus.groovy.grails.commons.ConfigurationHolder
class Temp_ipblock {  
  def sessionFactory
  def searchService
  
  static constraints = {    
  }
  
  static mapping = {
    version false
  }
  
  Long id 
  Integer status  
  String userip
  Date requesttime  

  def csiDelete(iStatus){
    def session = sessionFactory.getCurrentSession()
	def sSql = "DELETE FROM temp_ipblock WHERE status=:status AND timestampdiff(MINUTE,requesttime,current_timestamp)>:period_in_minuts"         
    def qSql = session.createSQLQuery(sSql)        
	def minuts=0
	if(iStatus)
	  minuts=Tools.getIntVal(ConfigurationHolder.config.ip_capcha_fail_block,30).toInteger()
	else  
	  minuts=(Tools.getIntVal(ConfigurationHolder.config.spy_timeout,300000)/60000).toInteger()
	qSql.setLong('period_in_minuts',minuts)
	qSql.setLong('status',iStatus)
    qSql.executeUpdate()			
    session.clear()
  }
  def findSpy(iStatus){
    def hsLong=[:]
    def hsSql=[select:'',from:'',where:'',group:'']			
	hsSql.select="userip"
    hsSql.from="temp_ipblock"
    hsSql.where="status=:status AND timestampdiff(MINUTE,requesttime,current_timestamp)<:period_in_minuts "	
    hsSql.group="userip having count(*)>:spy_max"	
	hsLong['status']=iStatus
	hsLong['spy_max']=Tools.getIntVal(ConfigurationHolder.config.ip_capcha_fail_max,10)
	hsLong['period_in_minuts']=(Tools.getIntVal(ConfigurationHolder.config.spy_timeout,300000)/60000).toInteger()
    return searchService.fetchData(hsSql,hsLong,null,null,null)    
  }
}

