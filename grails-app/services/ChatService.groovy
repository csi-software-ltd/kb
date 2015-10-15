import org.codehaus.groovy.grails.commons.ConfigurationHolder
class ChatService {

	static transactional = true

	void addNewChatMessage(lUserId, lInterlocutorId, sCtext){
		def oChatstatus = Chatstatus.find('from Chatstatus where (fromuser=:sFromuser and touser=:sTouser) or (fromuser=:sTouser and touser=:sFromuser)',[sFromuser:lUserId,sTouser:lInterlocutorId])
    if (!oChatstatus) {
      oChatstatus = new Chatstatus(lUserId, lInterlocutorId, sCtext)
      try {
        oChatstatus.save(flush:true)
      } catch (Exception e) {
        throw e
      }
    } else {
      try {
        updateChatstatus(oChatstatus,lUserId, sCtext)
      } catch (Exception e) {
        throw e
      }
    }
		def oChat = new Chat(lUserId, lInterlocutorId, sCtext)
		try {
			oChat.save(flush:true)
		} catch (Exception e) {
			throw e
		}
	}

  void updateChatstatus(_oChatstatus,_lUserId, _sCtext) {
    if(_oChatstatus.fromuser==_lUserId) {
    	_oChatstatus.lastmessage = _sCtext
    	_oChatstatus.lastdate = new Date()
    	_oChatstatus.modstatus = 1
    } else {
    	_oChatstatus.lastmessage = _sCtext
    	_oChatstatus.lastdate = new Date()
    	_oChatstatus.modstatus = -1
    }
    try {
      _oChatstatus.save(flush:true)
    } catch (Exception e) {
      throw e
    }
  }

  Chatstatus updateStatus(lUserId, lInterlocutorId){
    def oChatstatus = Chatstatus.find('from Chatstatus where (fromuser=:sFromuser and touser=:sTouser and modstatus=-1) or (fromuser=:sTouser and touser=:sFromuser and modstatus=1)',[sFromuser:lUserId,sTouser:lInterlocutorId])
    if(oChatstatus?.fromuser==lUserId && oChatstatus?.modstatus==-1) {
      oChatstatus.modstatus = 0
    } else if (oChatstatus?.touser==lUserId && oChatstatus?.modstatus==1) {
      oChatstatus.modstatus = 0
    }
    try {
      oChatstatus?.save(flush:true)
    } catch (Exception e) {
      throw e
    }
    return oChatstatus
  }

  def watchNew(_lId) {
    def test = Chatstatus.findAll('from Chatstatus where (fromuser=:id and modstatus=-1) or (touser=:id and modstatus=1)',[id:_lId])
    [count:test.size(),list:test.collect{ if(it.touser==_lId) it.fromuser; else it.touser; }.join(','),ld:test.collect{ it.lastdate.getTime()/1000 }.join(','),countM:Meet.findAll('from Meet where toid=:id and modstatus=0 and now() < mdate',[id:_lId]).size()]
  }

}
