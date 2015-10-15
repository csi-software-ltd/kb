<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение KtoBlizko.ru</title>
    <meta name="layout" content="admin" />
  </head>  
  <body>    
  <g:if test="${redir}">
    <g:form url="[controller:'administrators',action:'index']" method="POST" name="indexForm" id="indexForm">
      <input type="submit" style="display:none;">
    </g:form>
    <g:javascript>
      eval("$('indexForm').submit();");
    </g:javascript>
  </g:if><g:else>
    <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${flash.error==1}"><li>Не введен логин</li></g:if>
        <g:elseif test="${flash.error==2}"><li>Пароль введен неверно, или администратора с таким логином не существует</li></g:elseif>
        <g:elseif test="${flash.error==3}"><li>Доступ временно заблокирован</li></g:elseif>      
      </ul>
    </div>
    </g:if>
    <div style="width:340px;margin:150px auto">
      <h1 class="blue">Войти в панель управления</h1>
      <g:form url="[controller:'administrators',action:'login']" method="POST">
        <input type="text" name="login" id="login" placeholder="логин"/><br/>
        <input type="password" name="password" placeholder="пароль"/><br/>        
        <div style="clear:left;margin-top:25px">
          <input type="submit" value="Войти"/>
        </div>
      </g:form>    
    </div>
    
  </g:else>
  </body>
</html>
