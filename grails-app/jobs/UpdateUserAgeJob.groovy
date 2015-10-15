import org.codehaus.groovy.grails.commons.ConfigurationHolder

class UpdateUserAgeJob {
    //def timeout = 50000l // execute job once in 50 seconds
	def cronExpression = (ConfigurationHolder.config.updateUserAge.cron!=[:])?ConfigurationHolder.config.updateUserAge.cron:"0 0 0 * * ?"

    def execute() {
      log.debug("LOG>> Update user Age")
	  def userToUpdate = User.findAllByRef_id(0)
	  for (oU in userToUpdate){
		try{
			oU.age = Tools.computeAge(oU.birthday)
		} catch (Exception e){
		  log.debug("Error on save User id:"+oU.id+"\n"+e.toString())
		}
	  }
	  log.debug("LOG>> Users age was updated succesfully")
    }
}