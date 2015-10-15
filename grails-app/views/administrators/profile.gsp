<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение KtoBlizko.ru</title>
    <meta name="layout" content="admin" />
    <style type="text/css">
      .info label.lab { min-width: 105px; }      
    </style>
    <!-- <g:javascript>
    function initialize(){
	  <g:if test="${temp_notification!=null}">
      alert('${temp_notification?.text}');	  
	  </g:if>    
    }
    </g:javascript>-->
  </head>  
  <body onload="">

  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${flash?.error==1}"><li>Вы не заполнили обязательное поле &laquo;Пароль&raquo;</li></g:if>
        <g:if test="${flash?.error==2}"><li>Пароли не совпадают</li></g:if>
        <g:if test="${flash?.error==3}"><li>Слишком короткий пароль</li></g:if>
      </ul>
    </div>
  </g:if>

    <h1 class="blue">Профиль пользователя</h1><br/>
    <div class="info">
      <g:form url="[controller:'administrators',action:'profilesave']" method="POST">
        <fieldset>
          <legend>Изменение профиля</legend>
          <div style="width:50%;float:left">
            <span class="select">
              <label class="lab">Логин:</label>
              <input type="text" readonly value="${admin?.login}"/>
            </span><br/>
            <span class="select">
              <label for="name" class="lab">Имя:</label>
              <input type="text" name="name" value="${administrator?.name}"/>
            </span>
          </div>
          <div style="width:50%;float:right">
            <span class="select">
              <label class="lab">Группа:</label>
              <input type="text" readonly value="${groupname}"/>
            </span><br/>
            <span class="select">
              <label for="email" class="lab">Email:</label>
              <input type="text" name="email" value="${administrator?.email }"/>
            </span>
            <div style="margin:25px 10px 0 0;float:right">
              <input type="submit" value="Изменить"/>
            </div>                      
          </div>
        </fieldset>
      </g:form>
      <g:form url="[controller:'administrators',action:'changepass']" method="POST">
        <fieldset>
          <legend>Изменение пароля</legend>
          <span class="select">
            <label for="pass" class="lab">Новый пароль:</label>
            <input type="password" name="pass"/>
          </span>
          <span class="select">
            <label for="confirm_pass" class="lab" style="margin-left:10px;">Повторить:</label>
            <input type="password" name="confirm_pass"/>
          </span>
          <div style="margin:25px 10px 0 0;float:right">
            <input type="submit" value="Изменить"/>
          </div>                      
        </fieldset>
        
        <fieldset>
          <legend>Последний вход пользователя</legend>
          <span class="select">
            <label class="lab">Дата, время:</label>
            <input type="text" disabled value="${(lastlog?.logtime!=null)?String.format('%td.%<tm.%<tY %<tH:%<tM',lastlog?.logtime):''}"/>
          </span>
          <span class="select">
            <label class="lab" style="margin-left:10px;">IP адрес:</label>
            <input type="text" disabled value="${lastlog?.ip}"/>
          </span><br/>          
        <g:if test="${(unsuccess_log_amount)&&(unsuccess_log_amount > unsucess_limit)}">
          <div style="margin:25px 10px 0 0;float:right">
            <small><font color="red">Неуспешных попыток доступа за последние 7 дней: <b>${unsuccess_log_amount}</b></font></small>
          </div>
        </g:if>          
        </fieldset>          
      </g:form>
    </div>
    
  </body>
</html>
