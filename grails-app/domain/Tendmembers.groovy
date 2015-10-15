class Tendmembers {
  static constraints = {
  }

  Long id
  Long user_id
  Integer tender_id
  Integer rating = 0
  Integer votecount = 0
  Double overall_rating = 5d
  Integer modstatus = 1

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Tendmembers(){}
  Tendmembers(lUId,iTId){
    user_id = lUId
    tender_id = iTId
    rating = 0
    modstatus = 1
  }
/////////////////Business logic///////////////////////////////////////////////////////////////////////

  static def findOrCreate(lId) {
    def tender_id = Tender.getCurrentTender()?.id?:0
    if (!tender_id)
      throw new Exception ('No tenders are available today')

    return Tendmembers.findByUser_idAndTender_id(lId,tender_id)?:(new Tendmembers(lId,tender_id)).save(flush:true)
  }

  static def setrating(lId,iRating) {
    def tender_id = Tender.getCurrentTender()?.id?:0
    if (!tender_id)
      throw new Exception ('No tenders are available today')

    return Tendmembers.findByUser_idAndTender_id(lId,tender_id)?.updateRating(iRating)
  }

  def updateRating(iRating) {
    rating += iRating
    votecount++
    overall_rating = Tools.computeRating(this,Tendmembers.executeQuery('select avg(overall_rating) from Tendmembers')[0])
    return save(flush:true)
  }
}