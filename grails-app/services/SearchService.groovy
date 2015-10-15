import org.codehaus.groovy.grails.commons.ConfigurationHolder

class SearchService {
  boolean transactional = false
  def sessionFactory
  // def m_oConnect=null <-- TODO? set one connection object?

  def fetchDataByPages(hsSql, hsFilter,
                hsLong,hsInt,hsString,hsList,lsNotUseInCount,
                iMax,iOffset,
                sCount,bComputeCount,
                clClassName,lsDictionaryIds=null){
				
    def session=sessionFactory.getCurrentSession()
    def hsRes=[records:[],count:0]

    if(lsNotUseInCount==null) lsNotUseInCount=[]
    if(hsLong==null)   hsLong=[:]
    if(hsInt==null)    hsInt=[:]
    if(hsString==null) hsString=[:]
    if(hsList==null)   hsList=[:]
    if(hsFilter==null)  hsFilter=[:]
    if(hsFilter.string_par==null)  hsFilter.string_par=[:]
    if(hsFilter.long_par==null)    hsFilter.long_par=[:]
    if(hsFilter.list_par==null)    hsFilter.list_par=[:]

    def sFrom=  ' FROM '+hsSql.from+(hsFilter.from?:'')
    def sWhere= ' WHERE '+hsSql.where+(hsFilter.where?:'')
    def sSelect=' SELECT '+hsSql.select+(hsFilter.select?:'')
    def sOrder= ' ORDER BY '+(hsFilter.order?:'')+hsSql.order
	//def sGroup= ((hsSql.group!=null)?' GROUP BY '+hsSql.group :'')
    def sGroup= ((hsSql.group!=null)?' GROUP BY '+(hsFilter.group?:'')+hsSql.group :'')
    
    if(hsFilter.string_par.size()!=0)  hsString+=hsFilter.string_par
    if(hsFilter.long_par.size()!=0)    hsLong+=hsFilter.long_par
    if(hsFilter.list_par.size()!=0)    hsList+=hsFilter.list_par
    // int todo...

    try{
      def qSql
      if(bComputeCount){
        qSql=session.createSQLQuery("SELECT count("+sCount+")"+sFrom+sWhere+sGroup)
	
        for(hsElem in hsLong){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setLong(hsElem.key,hsElem.value);
        }
        for(hsElem in hsInt){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setInteger(hsElem.key,hsElem.value);
        }
        for(hsElem in hsString){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setString(hsElem.key,hsElem.value);
        }
        for(hsElem in hsList){
          if(!(hsElem.key in lsNotUseInCount))
            qSql.setParameterList(hsElem.key,hsElem.value);
        }
        hsRes.records=qSql.list()		
        if(hsRes.records==null)
          hsRes.records=[]	  		  
        else if(hsRes.records.size()!=0){
          hsRes.count=hsRes.records[0]
          hsRes.records=[]
        }		
      }
      //--------------------------------
      if((lsDictionaryIds!=null)&&(hsRes.count!=0)){
        for(sField in lsDictionaryIds){
          qSql=session.createSQLQuery("SELECT DISTINCT "+sField+" "+sFrom+sWhere+sGroup)

          for(hsElem in hsLong){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setLong(hsElem.key,hsElem.value);
          }
          for(hsElem in hsInt){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setInteger(hsElem.key,hsElem.value);
          }
          for(hsElem in hsString){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setString(hsElem.key,hsElem.value);
          }
          for(hsElem in hsList){
            if(!(hsElem.key in lsNotUseInCount))
              qSql.setParameterList(hsElem.key,hsElem.value);
          }
          hsRes[sField]=qSql.list()		 
        }
      }

      if((hsRes.count==0) && bComputeCount)
        hsRes.records=[]
      else{
        qSql=session.createSQLQuery(sSelect+sFrom+sWhere+sGroup+sOrder)      
        if(iMax>0)
          qSql.setMaxResults(iMax )
        qSql.setFirstResult(iOffset)
        for(hsElem in hsLong)
          qSql.setLong(hsElem.key,hsElem.value);
        for(hsElem in hsInt)
          qSql.setInteger(hsElem.key,hsElem.value);
        for(hsElem in hsString)
          qSql.setString(hsElem.key,hsElem.value);
        for(hsElem in hsList)
          qSql.setParameterList(hsElem.key,hsElem.value);
        qSql.addEntity(clClassName)		
        hsRes.records=qSql.list()		
        if(!bComputeCount)
          hsRes.count=hsRes.records?.size()
      }
    }catch (Exception e) {
      log.debug("Error fetchDataByPages\n"+e.toString()+"\n"+
                sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder);
      hsRes.count=0
      hsRes.records=[]
    }
	//println('ConfigurationHolder.config.grails.profiler.disable='+ConfigurationHolder.config.grails.profiler.disable)
    /*if((ConfigurationHolder.config.grails.profiler.disable==null)?false:(!ConfigurationHolder.config.grails.profiler.disable)){
      log.debug(sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder)
      log.debug('Params:')
      log.debug(hsInt)
      log.debug(hsLong)
      log.debug(hsString)
      log.debug(hsList)
    }*/
	/*
	println(hsInt)
    println(hsLong)
    println(hsString)
    println(hsList)	 
    println(sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder)	
    println(hsRes.records)
	*/
    session.clear()
    return hsRes
  }
  //////////////////////////////////////////////////////////////////////////
  def fetchData(hsSql,hsLong,hsInt,hsString,hsList,clClassName=null,iMax=-1){
    def session=sessionFactory.getCurrentSession()
    def hsRes=[]

    if(hsLong==null)   hsLong=[:]
    if(hsInt==null)    hsInt=[:]
    if(hsString==null) hsString=[:]
    if(hsList==null)   hsList=[:]

    def sSelect=' SELECT '+hsSql.select
    def sFrom=  ' FROM '+hsSql.from
    def sWhere= ((hsSql.where!=null)?' WHERE '+hsSql.where:'')
    def sOrder= ((hsSql.order!=null)?' ORDER BY '+hsSql.order:'')
    //hsSql.order= ' ORDER BY '+(hsFilter.order?:'')+(hsSql.order?:'')
    def sGroup= ((hsSql.group!=null)?' GROUP BY '+hsSql.group :'')
    //println(hsLong)
    //println(hsString)
    //println(hsList)
    //println('SELECT '+hsSql.select+"\n FROM "+hsSql.from+"\n WHERE "+hsSql.where+"\n GROUP BY "+hsSql.group+"\n ORDER BY "+hsSql.order)
    /*
    if((ConfigurationHolder.config.grails.profiler.disable==null)?false:(!ConfigurationHolder.config.grails.profiler.disable)){
      log.debug('SELECT '+hsSql.select+"\n FROM "+hsSql.from+"\n WHERE "+hsSql.where+"\n GROUP BY "+hsSql.group+"\n ORDER BY "+hsSql.order)
      log.debug('Params:')
      log.debug(hsInt)
      log.debug(hsLong)
      log.debug(hsString)
      log.debug(hsList)
    }
   */
    try{
      def qSql
      qSql=session.createSQLQuery(sSelect+sFrom+sWhere+sGroup+sOrder)
      for(hsElem in hsLong)
        qSql.setLong(hsElem.key,hsElem.value);
      for(hsElem in hsInt)
        qSql.setInteger(hsElem.key,hsElem.value);
      for(hsElem in hsString)
        qSql.setString(hsElem.key,hsElem.value);
      for(hsElem in hsList)
        qSql.setParameterList(hsElem.key,hsElem.value);
      if(clClassName!=null)
        qSql.addEntity(clClassName)
      if(iMax>0)
        qSql.setMaxResults(iMax)     
      session.clear()  
      return qSql.list()
    }catch (Exception e) {
      log.debug("Error fetchData\n"+e.toString()+"\n"+
                sSelect+"\n"+sFrom+"\n"+sWhere+"\n"+sGroup+"\n"+sOrder);
      return []
    }
    return []
  }
  ///////////////////////////////////////////////////////////////////////////////////////////////////
  def getLastInsert(){
    def sSql="select last_insert_id()"
    def session = sessionFactory.getCurrentSession()    
    try{
      def qSql=session.createSQLQuery(sSql)
      def lsRecords=qSql.list()
      if(lsRecords.size()>0){
        session.clear()
        return lsRecords[0].toLong()
      }
    }catch (Exception e) {
      log.debug("Error SearchService::getLastInsert\n"+e.toString());
    }
    session.clear()
    return 0
  }

  def getDistance(x1,y1,x2,y2){
    def sSql="select distance("+x1+","+y1+","+x2+","+y2+")"
    def session = sessionFactory.getCurrentSession()    
    try{
      def qSql=session.createSQLQuery(sSql)
      def lsRecords=qSql.list()
      if(lsRecords.size()>0){
        session.clear()
        return lsRecords[0].toDouble()
      }
    }catch (Exception e) {
      log.debug("Error SearchService::getDistance\n"+e.toString());
    }
    session.clear()
    return 0
  }
}
