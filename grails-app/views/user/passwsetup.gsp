<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>  
    <meta name="layout" content="main" />  
  </head>
  <body>
    <h1 class="blue">${infotext.title?infotext.header:''}</h1>    
  <g:if test="${inrequest.error}">
    <div class="notice">
      <ul>
        <g:if test="${inrequest?.error==1}"><li>Введенные пароли не совпадают</li></g:if>
        <g:elseif test="${inrequest?.error==2}"><li>Слишком короткий пароль</li></g:elseif>
        <g:elseif test="${inrequest?.error==3}"><li>Возникла непредвиденная ошибка</li></g:elseif>
      </ul>
    </div>
  </g:if>
  
    <g:form url="[controller:'user',action:'passwsetup']" method="POST" useToken="true">
      <div class="info">
        <fieldset class="noborder">
          <span class="select">
            <label for="">Введите пароль</label>
            <input type="password" name="password1" value="" <g:if test="${inrequest?.error == 2}">class="red"</g:if>/>
          </span><br/>
          <div class="select">
            <label for="">Повторите пароль</label>       
            <input type="password" name="password2" value="" <g:if test="${inrequest?.error == 1}">class="red"</g:if> />
          </div>
          <div style="clear:left;margin-top:25px">
            <input type="submit" value="Отправить" />
          </div>        
        </fieldset>
      </div>
    </g:form>  
    
  </body>
</html>
