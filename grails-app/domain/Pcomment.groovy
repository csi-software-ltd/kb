class Pcomment {
  static constraints = {
  }

  Long id
  Long user_id
  Integer photo_id
  Integer typeid = 1
  String comtext
  Integer comstatus = 0
  Date comdate = new Date()
  Long refcomment_id = 0

/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Pcomment(){}
  Pcomment(_lUid, _lPhotoId, _sText){
    user_id = _lUid
    photo_id = _lPhotoId
    typeid = 1
    comtext = _sText
    comstatus = 0
    comdate = new Date()
    refcomment_id = 0
  }
/////////////////Business logic///////////////////////////////////////////////////////////////////////

  static Pcomment addNewComment(lPhotoId,sText,lUId){
    return (new Pcomment(lUId,lPhotoId,sText)).save(flush:true)
  }

  static void deleteComment(lId,lUId){
    def oPcomment = Pcomment.get(lId)
    if (lUId==Userphoto.get(oPcomment?.photo_id?:0)?.user_id) {
      oPcomment.comstatus = -2
      oPcomment.save(flush:true)
    }
  }

}