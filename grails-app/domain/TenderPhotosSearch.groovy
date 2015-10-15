import org.codehaus.groovy.grails.commons.ConfigurationHolder
class TenderPhotosSearch {
  def searchService
  static constraints = {
  }
  static mapping = {
    table 'DUMMY_NAME'
    version false
    cache false
  }

////////Userphoto part//////////
  Integer id
  Long user_id
  String picture
  String smallpicture
  String ultrasmallpicture
  Integer modstatus
  Integer is_main
  Integer is_tender
  Integer is_local
  Integer norder
  Date moddate
  String ptext
////////Tendmember part/////////
  Long t_id
  Integer t_rating
  Integer t_modstatus
  Double t_overall_rating

/////////////////constructor//////////////////////////////////////////////////////////////////////////

/////////////////Business logic///////////////////////////////////////////////////////////////////////

  def csiSelectTenderphotos(iTenderId,iSort,iOffset){
    if (!iTenderId) return null

    def hsSql=[select:'',from:'',where:'',order:'']
    def hsInt=[:]

    hsSql.select="*"
    hsSql.from='v_tenderphotos'
    hsSql.where="is_tender=:iTenderId and t_modstatus=1"
    switch(iSort) {
      case 1: hsSql.order="t_id desc";break;
      case 2: hsSql.order="t_overall_rating desc";break;
      case 0:
      default: hsSql.order="rand()";break;
    }
    hsInt['iTenderId']=iTenderId

    def hsRes=searchService.fetchDataByPages(hsSql,null,null,hsInt,null,
      null,null,Tools.getIntVal(ConfigurationHolder.config.tenders.tenderphotos.max,20),iOffset,'t_id',true,TenderPhotosSearch.class)
  }

}