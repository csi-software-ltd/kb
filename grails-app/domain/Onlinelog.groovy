import org.codehaus.groovy.grails.commons.ConfigurationHolder

class Onlinelog {
  def searchService
  static mapping = {
    version false
  }  

  static constraints = {
    reference (nullable:true)	   
  }
  
  String page
  Integer type
  Long reccount
  Long home_id
  String keyword
  String userip
  String reference
  String reclist
  Integer ref_id
  String lang
  Long users_id
  String site
  String useragent
  String prop
  
  String toString() {"${this.page}"  }  

  def findSpy(){
    def hsLong=[:]
    def hsSql=[select:'',from:'',where:'',group:'']			
	hsSql.select="userip"
    hsSql.from="onlinelog"
    hsSql.where="timestampdiff(MINUTE,requesttime,current_timestamp)<:period_in_minuts "+
	" and useragent not like '%YandexBot%' and useragent not like '%GoogleBot%' "+
    " and useragent not like '%msnBot%' and useragent not like '%Yahoo! Slurp%' "+ 
    " and useragent not like '%bingbot%' "+
    " and useragent not like '%dotBot%' and useragent not like '%StackRambler%' "+
    " and useragent not like '%aportworm%' and useragent not like '%Mail.Ru/1.0%' "+
    " and useragent not like '%searchbot%'"
    hsSql.group="userip having count(*)>:spy_max"
	hsLong['spy_max']=Tools.getIntVal(ConfigurationHolder.config.spy_max,500)
	hsLong['period_in_minuts']=(Tools.getIntVal(ConfigurationHolder.config.spy_timeout,300000)/60000).toInteger()
    return searchService.fetchData(hsSql,hsLong,null,null,null)    
  }  
}
