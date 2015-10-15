class Chatstatus {

  static constraints = {
  }
  static mapping = {
    version false
  }

  Integer id
  Long fromuser
  Long touser
  String lastmessage
  Date lastdate
  Integer modstatus

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Chatstatus(){}
  Chatstatus(lUserId, ltoUserId, sNote){
    fromuser = lUserId
    touser = ltoUserId
    lastmessage = sNote
    lastdate = new Date()
    modstatus = 1
  }

}