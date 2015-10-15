<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>  
    <meta name="layout" content="main" />  
  </head>
  <body>
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
  <g:if test="${inrequest?.error}">
    <div class="notice">
      <ul>
        <g:if test="${inrequest?.error==1}"><li>Пользователя с таким именем не существует</li></g:if>
        <g:if test="${inrequest?.error==2}"><li>Ошибка в адресе email</li></g:if>
        <g:if test="${inrequest?.error==3}"><li>Ошибочный проверочный код</li></g:if>
        <g:if test="${inrequest?.error==4}"><li>Пожалуйста, <g:link controller="user" action="index">авторизуйтесь</g:link> через соц. сеть</li></g:if>
        <g:if test="${inrequest?.error==5}"><li>Ваш запрос уже обработан</li></g:if>
        <g:if test="${inrequest?.error==-100}"><li>Ошибка отправки письма. Попробуйте позже.</li></g:if>
      </ul>
    </div>
  </g:if>
    
    <g:form url="[controller:'user',action:'rest']" method="POST" useToken="true">
      <div class="info">
        <fieldset class="noborder">
          <span class="select">
            <label for="name">Укажите ваш email</label>
            <input type="text" name="name" value="${inrequest.name}" <g:if test="${inrequest?.error in [1,2]}">class="red"</g:if>/>
          </span><br/>
          <div class="select">
            <label for="image">Введите проверочный код</label>
            <jcaptcha:jpeg name="image" align="absmiddle" style="margin-right:27px"/>
            <input type="text" name="captcha" value="" <g:if test="${inrequest?.error==3}">class="red"</g:if> style="width: 150px;" />
          </div>
          <div style="margin-top:25px">
            <input type="submit" value="Отправить" />
          </div>
        </fieldset>
      </div>
    </g:form>
  </body>
</html>
