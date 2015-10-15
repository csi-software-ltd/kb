import org.codehaus.groovy.grails.commons.ConfigurationHolder
class RawHtmlTagLib {

  def rawHtml = { attrs, body ->
    out << body().decodeHTML()
  }
  
  def userName = { attrs, body ->
    out << body().replace('.','·').replace('@','<img class="favicon" src="'+
        ConfigurationHolder.config.grails.serverURL+'/images/favicon.gif" border="0">')
  }
  
  def shortString = { attributes ->
    String text = attributes.text
    int length  = attributes.length ? Integer.parseInt(attributes.length) : 100
    
    if ( text ) {
      if ( text.length() < length )
        out << text.encodeAsHTML()
      else {
        text = text[0..length-1]
        if ( text.lastIndexOf('. ') != -1 )
          out << text[0 .. text.lastIndexOf('. ') ]
        else if ( text.lastIndexOf(' ') != -1 )
          out << text[0 .. text.lastIndexOf(' ')] << '&hellip;'
        else
          out << text << '&hellip;'
      }
    }
  }  
}
