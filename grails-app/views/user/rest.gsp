<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>  
    <meta name="layout" content="main" />  
  </head>
  <body>
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    
  <g:if test="${inrequest?.error==0}">    
    <p>На ваш email направлено письмо с адресом на форму изменения пароля</p>
  </g:if><g:else>
    <div class="notice">
      <ul>
        <g:if test="${inrequest?.error==1}"><li>Пользователя с таким именем не существует</li></g:if>
        <g:elseif test="${inrequest?.error==2}"><li>Ошибка в адресе email</li></g:elseif>
        <g:elseif test="${inrequest?.error==3}"><li>Ошибочный проверочный код</li></g:elseif>
        <g:elseif test="${inrequest?.error==4}"><li>Ошибка</li></g:elseif>
      </ul>
    </div> 
  </g:else>
  </body>
</html>
