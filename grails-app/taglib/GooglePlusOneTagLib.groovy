import org.codehaus.groovy.grails.commons.ConfigurationHolder
class GooglePlusOneTagLib {

  def plusone = { attrs, body ->
    out << "<g:plusone "+(attrs.size?"size=${attrs.size}":"")+(attrs.count?" count=${attrs.count}":"")+"></g:plusone>"
  }

  def plusoneScript = { attrs, body ->
    out << '''<script type="text/javascript">
      window.___gcfg = {lang: 'ru', parsetags: 'onload'};
      (function() {
        var po = document.createElement('script'); 
        po.type = 'text/javascript'; 
        po.async = true;
        po.src = 'https://apis.google.com/js/plusone.js';
        var s = document.getElementsByTagName('script')[0];
        s.parentNode.insertBefore(po, s);
      })();
    </script>'''
  }
}
