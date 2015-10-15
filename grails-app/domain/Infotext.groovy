class Infotext {  
  def searchService
  def sessionFactory
  
  static mapping = {
  }	  
  
  static constraints = {
	icon(nullable:true)
  name(nullable:true)
  }
  
  Integer id
  Integer itemplate_id 
  String controller
  String action
  Integer npage
  String icon
  String shortname
  String name
  String header
  String title
  String keywords
  String description
  String itext
  String itext2
  String itext3
  String promotext1
  String promotext2
  Date moddate
  
  def csiSelectInfotext(sAction,sController,iItemplate_id,iOrder,iMax,iOffset){
    def session = sessionFactory.getCurrentSession()
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsInt=[:]
    def hsString=[:]
	
    hsSql.select="*"
    hsSql.from='infotext'
    hsSql.where="1=1"+
				((iItemplate_id>-1)?' AND itemplate_id =:itemplate_id':'')+
				((sAction!='')?' AND (action like CONCAT("%",:action) OR action like CONCAT(:action,"%") OR action like CONCAT("%",:action,"%"))':'')+
				((sController!='')?' AND (controller like CONCAT("%",:controller) OR controller like CONCAT(:controller,"%") OR controller like CONCAT("%",:controller,"%"))':'')
    hsSql.order="id DESC"
    if(iItemplate_id>-1)
      hsInt['itemplate_id']=iItemplate_id
    if(sAction!='')
      hsString['action']=sAction
    if(sController!='')
      hsString['controller']=sController

    def hsRes=searchService.fetchDataByPages(hsSql,null,null,hsInt,hsString,
      null,null,iMax,iOffset,'id',true,Infotext.class)          
  }
  
  def csiGetLastInsert(){
    return searchService.getLastInsert()
  }

  def csiSelectMailtemplate(sAction,iMax,iOffset){
    def session = sessionFactory.getCurrentSession()
    def hsSql=[select:'',from:'',where:'',order:''] 
    def hsInt=[:]
    def hsString=[:]
	
    hsSql.select="*"
    hsSql.from='email_template'
    hsSql.where="1=1"+
        ((sAction!='')?' AND (action like CONCAT("%",:action) OR action like CONCAT(:action,"%") OR action like CONCAT("%",:action,"%"))':'')
    hsSql.order="id DESC"
    if(sAction!='')
      hsString['action']=sAction
       
    def hsRes=searchService.fetchDataByPages(hsSql,null,null,null,hsString,
      null,null,iMax,iOffset,'id',true,Email_template.class)          
  }
}
