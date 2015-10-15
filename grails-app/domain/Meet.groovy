import java.text.SimpleDateFormat
class Meet {
  static constraints = {
    x(nullable:true)
    y(nullable:true)
  }

  Long id
  Date inputdate = new Date()
  Date mdate
  Long fromid
  Long toid
  String name
  String place
  Integer x
  Integer y
  Integer modstatus = 0
  Integer fromrating = 0
  Integer torating = 0

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Meet(){}
  Meet(lUFid, lUTid, sName, sPlace, dDate, lX, lY){
    mdate = dDate
    fromid = lUFid
    toid = lUTid
    name = sName
    place = sPlace
    x = lX?:0
    y = lY?:0
  }
/////////////////Business logic///////////////////////////////////////////////////////////////////////
  static Meet addNewMeeting(hsRes) {
    def oMeet = new Meet(hsRes.user.id,hsRes.inrequest.interlocutor_id,hsRes.inrequest.meetname,
      hsRes.inrequest.meetwhere,new SimpleDateFormat("dd.MM.yyyy HH:mm").parse(hsRes.inrequest.datetime),hsRes.inrequest.meetX?:0,hsRes.inrequest.meetY?:0)
    try {
      oMeet.save(flush:true)
    } catch (Exception e) {
      throw e
    }
    return oMeet
  }

  void setstatus(iStatus) {
    modstatus = iStatus
    try {
      save(flush:true)
    } catch (Exception e) {
      throw e
    }
  }

  void setrating(lUId,iRating) {
    if (fromid==lUId) {
      fromrating = iRating
    } else if (toid==lUId) {
      torating = iRating
    }
    try {
      save(flush:true)
    } catch (Exception e) {
      throw e
    }
  }

  static Meet abolishOldMeeting(lId,lMId) {
    def oMeet = Meet.get(lMId)
    if(oMeet?.fromid==lId)
      oMeet.modstatus = -2
    else if (oMeet?.toid==lId)
      oMeet.modstatus = -1
    else
      return null

    try {
      oMeet.save(flush:true)
    } catch (Exception e) {
      throw e
    }
    return oMeet
  }

}