import org.codehaus.groovy.grails.commons.ConfigurationHolder
class MailerService {

    static transactional = false

  def sendActivationMail(oUser, oContext){
		def lsText=Email_template.findWhere(action:'#activation')
		def sText='[@EMAIL], for activation of your account use follow link [@URL]'
		def sHeader="Registration at KtoBlozko"
		if(lsText){
			sText=lsText.itext
			sHeader=lsText.title
		}
		sText=sText.replace(
			'[@NICKNAME]',oUser.nickname?:oUser.firstname?:'').replace(
			'[@EMAIL]',oUser.email).replace(
			'[@URL]',(ConfigurationHolder.config.grails.mailServerURL+((oContext.is_dev)?"/${oContext.appname}":"")+'/user/confirm/'+oUser.code))
		sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
		sHeader=sHeader.replace(
			'[@EMAIL]',oUser.email).replace(
			'[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/confirm/'+oUser.code))

		try{
			sendMail{
				to oUser.email
				subject sHeader
				html sText
			}
		} catch(Exception e) {
	  	log.debug("Cannot sent email \n"+e.toString())
		}
/*		body( view:"/_mail",
		model:[mail_body:sText])*/
  }

  def sendGreetingMail(oUser){
		def lsText=Email_template.findWhere(action:'#greeting_user')
		def sText='[@EMAIL] Registration at KtoBlozko'
		def sHeader="Registration at KtoBlozko"
		if(lsText){
	  	sText=lsText.itext
	  	sHeader=lsText.title
		}
		sText=sText.replace(
			'[@NICKNAME]',oUser.nickname?:oUser.firstname?:'').replace(
			'[@EMAIL]',oUser.email)
		sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
		sHeader=sHeader.replace('[@EMAIL]',oUser.email)

		try{
	  	sendMail{
				to oUser.email
				subject sHeader
				html sText
	  	}
		} catch(Exception e) {
	  	log.debug("Cannot sent email \n"+e.toString())
		}
  }

  def sendRestorePassMail(oUser, oContext){
		def lsText=Email_template.findWhere(action:'#restore')
		def sText='[@EMAIL], for restore of your password use follow link [@URL]'
		def sHeader="Restore password"
		if(lsText){
	  	sText=lsText.itext
	  	sHeader=lsText.title
		}
		sText=sText.replace(
			'[@NICKNAME]',oUser.nickname?:oUser.firstname?:'').replace(
			'[@EMAIL]',oUser.email).replace(
			'[@URL]',(ConfigurationHolder.config.grails.mailServerURL+((oContext.is_dev)?"/${oContext.appname}":"")+'/user/passwconfirm/'+oUser.code))
		sText=((sText?:'').size()>Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500))?sText.substring(0,Tools.getIntVal(ConfigurationHolder.config.mail.textsize,500)):sText
		sHeader=sHeader.replace(
			'[@EMAIL]',oUser.email).replace(
			'[@URL]',(ConfigurationHolder.config.grails.mailServerURL+'/user/passwconfirm/'+oUser.code))

		try{
	  	sendMail{
			to oUser.email
			subject sHeader
			html sText
	  	}
		} catch(Exception e) {
	  	log.debug("Cannot sent email \n"+e.toString())
	  	return -100
		}
		return 0
  }

}