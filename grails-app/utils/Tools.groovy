import org.codehaus.groovy.grails.commons.ConfigurationHolder
import java.util.regex.Matcher
import java.util.regex.Pattern
import java.security.MessageDigest

class Tools  {   
  static prepareSearchString(sRequest){
    //из пользовательской ключевой фразы надо выкидывать символы:
    //    * ' " , ; %  с заменой их на  заменяя их на пробел
    //   - с заменой на пустой символ
    if(sRequest==null)
      return ''
    sRequest=sRequest.replace("'", ' ').replace('"',' ').replace(',',' ').replace(';',' ')
    sRequest=sRequest.replace('.',' ').replace('%',' ').replace('_',' ').replace('?',' ').replace('!',' ').replace('/',' ')
    return sRequest.replaceAll(/\s+/, " ").trim()
  }
  ///////////////////////////////////////////////////////////////////////////////
  static prepareEmailString(sEmail){
    // remove -,.,@
    if(sEmail==null)
      return ''
    return sEmail.replace("@", '').replace('-','').replace('.','')
  }
  ///////////////////////////////////////////////////////////////////////////////
  static checkEmailString(sEmail){
    return sEmail ==~ /^[A-Za-z0-9](([_\.\-]?[a-zA-Z0-9]+)*)[_]*@([A-Za-z0-9]+)(([\.\-]?[a-zA-Z0-9]+)*)\.([A-Za-z]{2,})$/ 
  }
  /////////////////////////////////////////////////////////////////////////////
  static generateMD5(sText) {
    MessageDigest digest = java.security.MessageDigest.getInstance("MD5");
    digest.update(sText.getBytes());
    def mdRes=digest.digest()
    def sOut=''
    for (i in mdRes) 
      sOut+=Integer.toHexString(0xFF & i)
    return sOut;  
  }
  /////////////////////////////////////////////////////////////////////////////
  static hidePsw(sPsw) {
    return generateMD5('_yellcat'+sPsw+'yellcat-')
	/*def psw='_yellcat'+sPsw+'yellcat-'
	return psw.encodeAsMD5()*/
  }
  /////////////////////////////////////////////////////////////////////////////
  static getIntVal(sValue,iDefault=0){
    if(sValue==null)
      return iDefault
    try{
      iDefault=sValue.toInteger()
    }catch(Exception e){
      //do nothing
    }
    return iDefault
  }  
  ///////////////////////////////////////////////////////////////////////////
  static String arrayToString(sValue,separator) {
    if(((sValue!=null)?sValue:[]).size()==0)
      return ''
    StringBuffer result = new StringBuffer();
    if (sValue.size() > 0) {
      result.append(sValue[0]);
      for (int i=1; i<sValue.size(); i++) {
        result.append(separator);
        result.append(sValue[i]);
      }
    }
    return result.toString();
  }
  ///////////////////////////////////////////////////////////////////////////
  static String escape(sValue){
    return sValue.replace("'","\\'").replace('"','\\"')
  }
  static fixHtml(sText,sFrom){
    if(!(sText?:'').size())
	  return ''
    def start=false
	def lsTags=[]
	switch(sFrom){
	  case 'admin': start=true;
        lsTags=['u','i','em','b','ol','ul','li','s','sub','sup','address','pre','p',
        'h1','h2','h3','h4','h5','h6','strong']
		break		
	  case 'personal':	
        if(Tools.getIntVal(ConfigurationHolder.config.editor.fixHtml)) start=true
        lsTags=['u','i','em','b','ol','ul','li','s','sub','sup','address','pre','p',
        'h1','h2','h3','h4','h5','h6','strong']
		break
	}	
	sText=sText.replace("\r",' ').replace("\n",' ').replace("'",'"')
	if(start){      
      sText=sText.replace("[YELLclose]",'').replace("[YELLspan]",'')
      sText=sText.replace('<br />','[YELLbr]')
      sText=sText.replace('<br>','[YELLbr]')
      sText=sText.replace('</span>','[/YELLspan]')
    
      sText=sText.replaceAll( /(<span )(style="[^\">]*?;")(>)/,'[YELLspan] $2[YELLclose]')
    
      for(sTag in lsTags) //TODO? change pre into p?
        sText=sText.replace('<'+sTag+'>','[YELL'+sTag+']').replace('</'+sTag+'>','[/YELL'+sTag+']')  
    
      sText=sText.replace('<',' &lt; ').replace('>',' &gt; ')
    
      for(sTag in lsTags) //TODO? change pre into p?
        sText=sText.replace('[YELL'+sTag+']','<'+sTag+'>').replace('[/YELL'+sTag+']','</'+sTag+'>')  
    
      sText=sText.replace('[YELLspan]','<span').replace('[YELLclose]','>').replace('[/YELLspan]','</span>')
      sText=sText.replace('[YELLbr]','<br />')      
    }
    return sText
  }
  static loginf(sStr){
    //Logger.getLogger(Tools.class).debug('112')
  }

  static String transliterate (sPhrase) {
	def alpha = "абвгдеёжзиыйклмнопрстуфхцчшщьэюяъ"
	def _alpha = ["a","b","v","g","d","e","yo","g","z","i","y","i",
						"k","l","m","n","o","p","r","s","t","u",
						"f","h","tz","ch","sh","sh","'","e","yu","ya","'"]
	int k
	def result = ""
	def sPrepPhrase = sPhrase.toLowerCase().replace("'", '').replace(')','').replace('(','').replace('\\','').replace('+','_').replace('№','').replace('@','').replace('#','').replace('"','').replace(',','').replace(';','').replace('.','').replace('%','').replace('?','').replace('!','').replace('/','').trim().replace(' ','_')
	for(int i=0; i<sPrepPhrase.size();i++){
	  k = alpha.indexOf(sPrepPhrase[i])
	  if(k != -1)
		result += _alpha[k]
	  else 
		result += sPrepPhrase[i]
	}
	if(result=='') result = ((ConfigurationHolder.config.linkname.prefix)?ConfigurationHolder.config.linkname.prefix:"arenda_")
	return result
  }

  static String generateSMScode() {
	Random rand = new Random(System.currentTimeMillis())
	return (rand.nextInt().abs() % 89999 + 10000).toString() //10000..99999
  }

 static int computeAge(dDate) {
	def now = new GregorianCalendar()
	def fake = new GregorianCalendar(now.get(Calendar.YEAR), dDate.getMonth()-1, dDate.getDate())
	return now.get(Calendar.YEAR) - dDate.getYear() - 1900 - (fake > now ? 1 : 0)
  }

  static double computeRating(oTendmember,fAvg) {
    if (!oTendmember)
      throw new Exception ('Where are no tendmember')
    if (!fAvg)
      fAvg = 5d
    return (Math.round(((oTendmember.rating / oTendmember.votecount) + (getIntVal(ConfigurationHolder.config.tendmember.ratingcoeff,50) / 100 / Math.sqrt(oTendmember.votecount)) * (fAvg - (oTendmember.rating / oTendmember.votecount)))*100)/100)
  }

}