class LastdateFilters {

    def filters = {
        all(controller:'administrators',invert:true) {
            before = {
                /*if (session.user_id) {
                    def oUser = User.get(session.user_id)
                    if (oUser) {
                        println session.user_id
                        oUser.withNewSession { org.hibernate.Session sess ->
                            oUser.updateLastdate()
                            //session.clear()
                            sess.close();
                            sess.disconnect()
                        }
                    }
                }*/
            }
            after = { model ->
                if (model?.user) {
                    model.user.updateLastdate()
                }
            }
            afterView = {
                
            }
        }
    }
    
}
