import org.codehaus.groovy.grails.commons.ConfigurationHolder

grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [ html: ['text/html','application/xhtml+xml'],
  xml: ['text/xml', 'application/xml'],
  text: 'text/plain',
  js: 'text/javascript',
  rss: 'application/rss+xml',
  atom: 'application/atom+xml',
  css: 'text/css',
  csv: 'text/csv',
  all: '*/*',
  json: ['application/json','text/json'],
  form: 'application/x-www-form-urlencoded',
  multipartForm: 'multipart/form-data'
]
grails.views.default.codec="html" // none, html, base64
grails.views.gsp.encoding="UTF-8"
grails.converters.encoding="UTF-8"
grails.enable.native2ascii = true
grails.profiler.disable = true

grails.config.locations = [ "classpath:${appName}-config.properties"]

grails {
   mail {
     props = ["mail.smtp.auth":"true",
              "mail.smtp.socketFactory.port":"465",
              "mail.smtp.socketFactory.class":"javax.net.ssl.SSLSocketFactory",
              "mail.smtp.socketFactory.fallback":"false"]
   }
}

import org.apache.log4j.DailyRollingFileAppender

log4j = {
  appenders {
    appender new DailyRollingFileAppender(
        name:"file", 
        datePattern:"'.'yyyy-MM-dd", 
        layout:pattern(conversionPattern:'%d [%p] {%c{2}} %m%n'),    
        file:"${logger.file}"); 
    appender new DailyRollingFileAppender(
        name:"stacktraceLog", 
        datePattern:"'.'yyyy-MM-dd", 
        layout:pattern(conversionPattern:'%d [%p] {%c{2}} %m%n'),
        file:"${logger.stack}"); 
    console name:"logger", layout:pattern(conversionPattern: "%d [%t] %-5p %c(%l)  - %m%n")     
  }
 
  root {
    error 'stdout', 'file'
    additivity = true
  }
  error   'org.codehaus.groovy.grails.web.servlet',  //  controllers
      'org.codehaus.groovy.grails.web.pages', //  GSP
      'org.hibernate'
  error stacktraceLog:"StackTrace"       
  warn 'org.mortbay.log'
  debug 'grails.app'
  //  trace "${logger.hibernatelevel}"  
  debug logger:"com.linkedin.grails" 
}

/* upgrade comment FROM >>>>>>>>>>>>>>>> */
import java.awt.Font
import java.awt.Color

import com.octo.captcha.service.multitype.GenericManageableCaptchaService
import com.octo.captcha.engine.GenericCaptchaEngine
import com.octo.captcha.image.gimpy.GimpyFactory
import com.octo.captcha.component.word.wordgenerator.RandomWordGenerator
import com.octo.captcha.component.image.wordtoimage.ComposedWordToImage
import com.octo.captcha.component.image.fontgenerator.RandomFontGenerator
import com.octo.captcha.component.image.backgroundgenerator.GradientBackgroundGenerator
import com.octo.captcha.component.image.color.SingleColorGenerator
import com.octo.captcha.component.image.textpaster.NonLinearTextPaster

import org.apache.log4j.DailyRollingFileAppender

jcaptchas {
  image = new GenericManageableCaptchaService(
      new GenericCaptchaEngine(
          new GimpyFactory(
              new RandomWordGenerator(
                  "abcdefghjkmnpqrstuvwxyz0123456789"
                  //"0123456789"
              ),
              new ComposedWordToImage(
                  new RandomFontGenerator(
                      20, // min font size
                      30, // max font size
                      [new Font("Arial", 0, 10)] as Font[]
                  ),
                  new GradientBackgroundGenerator(
                      150, // width
                      50, // height
                      new SingleColorGenerator(new Color(255, 255, 255)),
                      new SingleColorGenerator(new Color(255, 255, 255))
                  ),
                  new NonLinearTextPaster(
                      6, // minimal length of text
                      6, // maximal length of text
                      new Color(0,0,0)
                  )))),
     180, // minGuarantedStorageDelayInSeconds
     180000 // maxCaptchaStoreSize
   )
  }
/* upgrade comment TO <<<<<<<<<<<<<<< */
compress {
    // just in case for some reason you want to disable the filter
    enabled = true
    debug = false
    statsEnabled = true
    compressionThreshold = 1024
    // filter's url-patterns
    urlPatterns = ["/*"]
    // include and exclude are mutually exclusive
    includePathPatterns = []
    excludePathPatterns = [".*\\.gif", ".*\\.ico", ".*\\.jpg", ".*\\.swf"]
    // include and exclude are mutually exclusive
    includeContentTypes = []
    excludeContentTypes = ["image/png"]
    // include and exclude are mutually exclusive
    includeUserAgentPatterns = []
    excludeUserAgentPatterns = [".*MSIE 4.*"]
    // probably don't want these, but their available if needed
    javaUtilLogger = ""
    jakartaCommonsLogger = ""

    development {
        debug = true
        compressionThreshold = 2048
    }
    production {
        statsEnabled = false
    }
}
