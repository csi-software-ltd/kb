import org.codehaus.groovy.grails.commons.ConfigurationHolder
class TenderSearch {
  def searchService
  static constraints = {
  }
  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false
  }

////////Tendmember part/////////
  Long id
  Long user_id
  Integer tender_id
  Double rating
  Integer modstatus
////////User part///////////////
  String firstname
  String nickname
  Integer age
  Integer city_id
////////Userphoto part//////////
  Integer img_id
  String picture
  Integer is_local

/////////////////constructor//////////////////////////////////////////////////////////////////////////

/////////////////Business logic///////////////////////////////////////////////////////////////////////

  def csiGetDataForMain(iTenderId){
    if (!iTenderId) return null

    def hsSql=[select:'',from:'',where:'',order:'']
    def hsInt=[:]

    hsSql.select="*"
    hsSql.from='v_tender_main'
    hsSql.where="tender_id=:iTenderId and modstatus=1"
    hsSql.order="rand()"

    hsInt['iTenderId']=iTenderId

    def hsRes=searchService.fetchDataByPages(hsSql,null,null,hsInt,null,
      null,null,Tools.getIntVal(ConfigurationHolder.config.mainpage.tenderphotos.max,10),0,'',false,TenderSearch.class)
  }

}