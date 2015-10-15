class Userplace {
  static constraints = {
    x(nullable:true)
    y(nullable:true)
  }

  Long id
  Long user_id
  String name
  String address
  Integer city_id
  Long metro_id
  Integer is_main = 0
  Integer x
  Integer y
/////////////////constructor//////////////////////////////////////////////////////////////////////////
  Userplace(){}
  Userplace(lUi, sName, sAddr, iCId, iMId, lX, lY){
    user_id = lUi
    name = sName
    address = sAddr?:''
    city_id = iCId?:78
    metro_id = iMId?:0
    is_main = 0
    x = lX?:0
    y = lY?:0
  }
/////////////////Business logic///////////////////////////////////////////////////////////////////////
  static Userplace userplaceadd(hsRes) {
    def oUserplace = new Userplace(hsRes.user.id,hsRes.inrequest.name,hsRes.inrequest.address,
      hsRes.inrequest.city_id,hsRes.inrequest.metro_id,hsRes.inrequest.x,hsRes.inrequest.y)
    try {
      oUserplace.save(flush:true)
    } catch (Exception e) {
      throw e
    }
    return oUserplace
  }
  static Userplace userplaceUpdate(hsRes) {
    def oUserplace = Userplace.get(hsRes.inrequest?.place_id)
    if (oUserplace){
      oUserplace.name = hsRes.inrequest?.name?:oUserplace.name
      oUserplace.address = hsRes.inrequest?.address?:oUserplace.address
      oUserplace.city_id = hsRes.inrequest?.city_id?:oUserplace.city_id
      oUserplace.metro_id = hsRes.inrequest?.metro_id?:0
      oUserplace.x = hsRes.inrequest?.x?:oUserplace.x
      oUserplace.y = hsRes.inrequest?.y?:oUserplace.y
      try {
        oUserplace.save(flush:true)
      } catch (Exception e) {
        throw e
      }
    } else {
      return null
    }
    return oUserplace
  }

  static Userplace getAndSetMain(iId,lUserId) {
    def oUserplace = findByIdAndUser_id(iId,lUserId)
    if (!oUserplace)
      return null
    resetMain(oUserplace.user_id)
    oUserplace.is_main = 1
    oUserplace.save(flush:true)
    return oUserplace
  }

  static void resetMain(lUserId) {
    def oUserplace = findByUser_idAndIs_main(lUserId,1)
    if (oUserplace){
      oUserplace.is_main = 0
      oUserplace.save(flush:true)
    }
  }

  static void setMain(iId,lUserId) {
    def oUserplace = findByIdAndUser_id(iId,lUserId)
    if (!oUserplace)
      return
    resetMain(oUserplace.user_id)
    oUserplace.is_main = 1
    oUserplace.save(flush:true)
    return
  }

}
