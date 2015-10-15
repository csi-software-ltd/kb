class Tender {
  def searchService
  static constraints = {
  }

  Integer id
  String name
  String slogan
  String info
  Date date_start
  Date date_end
  Integer modstatus = 0

/////////////////constructor//////////////////////////////////////////////////////////////////////////

/////////////////Business logic///////////////////////////////////////////////////////////////////////

  def csiSelectTenders(sTenderName,iModstatus,iTenderId,sTenderDate,iOrder,iMax,iOffset){
    def hsSql=[select:'',from:'',where:'',order:'']
    def hsLong=[:]
    def hsString=[:]

    hsSql.select="*"
    hsSql.from='tender'
    hsSql.where="1=1"+
              ((sTenderName!='')?' AND name like CONCAT("%",:name, "%")':'')+
              ((iModstatus>-1)?' AND modstatus =:modstatus':'')+
              ((iTenderId>0)?' AND id =:id':'')+
              ((sTenderDate!='')?' AND date_start <=:tenderdate and date_end >=:tenderdate':'')

    hsSql.order="date_end DESC"

    if(sTenderDate!='')
      hsString['tenderdate']=sTenderDate
    if(iModstatus>-1)
      hsLong['modstatus']=iModstatus
    if(sTenderName!='')
      hsString['name']=sTenderName
    if(iTenderId>0)
      hsLong['id']=iTenderId

    def hsRes=searchService.fetchDataByPages(hsSql,null,hsLong,null,hsString,
      null,null,iMax,iOffset,'id',true,Tender.class)
  }

  static Tender getCurrentTender() {
    return Tender.find('from Tender where modstatus=1 and date_start <=CURDATE() and date_end >=CURDATE()')
  }
}