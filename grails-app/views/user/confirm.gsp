<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?:'Восстановление пароля'}</title>
    <meta name="layout" content="main" />
  </head>
  <body>
    <div class="notice">
      <ul>
        <g:if test="${inrequest?.error==2}"><li>Пользователь не найден</li></g:if>
        <g:elseif test="${flash?.error==1}"><li>Неверная, либо неактивная ссылка</li></g:elseif> 
      </ul>
    </div>
  </body>
</html>
