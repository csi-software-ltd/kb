<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" />
    <g:javascript>
      function updateMetro(lCityId){
        ${remoteFunction(controller:'personal', action:'metroupd',
                         update:'metro_UPD',
                         params:'\'cityId=\'+lCityId'
        )};     
      }
    </g:javascript>
  </head>
  <body onload="viewSmallMap()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${(flash?.error?:[]).contains(1)}"><li>Ошибка справочников. Попробуйте позже.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(2)}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(3)}"><li>Возраст от больше чем возраст до.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(4)}"><li>Вы не заполнили обязательное поле &laquo;Имя&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(5)}"><li>Некорректно заполнено поле &laquo;Дата рождения&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(6)}"><li>Ваш возраст слишком мал!</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(7)}"><li>Вы не заполнили обязательное поле &laquo;Пол&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(8)}"><li>Некорректно заполнено поле &laquo;Телефон&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(9)}"><li>Вы не заполнили обязательное поле &laquo;Город&raquo;</li></g:if>
      </ul>
    </div>
  </g:if>
    <div class="info">
      <g:form name="mainSettings" controller="personal" action="saveMainSettings">
        <fieldset>                    
          <legend>Учетная запись</legend>
          <span class="select">
            <label for="firstname">Имя</label>
            <input type="text" name="firstname" value="${inrequest?.firstname?:''}"/>
          </span><br/>
          <span class="select">
            <label for="nickname">Никнейм</label>
            <input type="text" name="nickname" value="${inrequest?.nickname?:''}"/>          
          </span>
        </fieldset>
        <fieldset>
          <span class="select">
            <label for="gender_id">Пол</label>
            <select name="gender_id">
              <option value="0" <g:if test="${inrequest?.gender_id==0}">selected="selected"</g:if>>Выберите пол</option>
              <option value="1" <g:if test="${inrequest?.gender_id==1}">selected="selected"</g:if>>Парень</option>
              <option value="2" <g:if test="${inrequest?.gender_id==2}">selected="selected"</g:if>>Девушка</option>
            </select>
          </span><br/>
          <div class="select">
            <label for="birthday">Дата рождения</label>
            <g:datePicker name="birthday" precision="day" value="${inrequest?.birthday?:(date?.birthday_day&&date?.birthday_month&&date?.birthday_year)?new Date(date?.birthday_year-1900,date?.birthday_month-1,date?.birthday_day):new Date()}" years="${((new Date()).getYear()+1900-min_user_age)..1940}"/>
          </div><br/>
          <div style="clear:left">
            <label for="birthday">Мобильный телефон</label>
            <span nowrap>
              + <input type="text" id="ind" name="ind" value="${ind?:''}" size="3" style="width:55px" />
              ( <input type="text" id="kod" name="kod" value="${kod?:''}" size="3" style="width:60px"/> )
              <input type="text" id="telef" name="telef" value="${telef?:''}" size="9" style="width:100px"/>
            </span>          
          </div>
        </fieldset>        
        <fieldset>
          <legend>Местоположение</legend>
          <span class="select">
            <label for="city_id">Город</label>
            <select name="city_id" style="width:140px" onchange="updateMetro(this.value)">
              <option value="0" <g:if test="${inrequest?.city_id==0}">selected="selected"</g:if>>Выберите город</option>
              <g:each in="${city}" var="item">
              <option value="${item?.id}" <g:if test="${inrequest?.city_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
              </g:each>
            </select>
          </span><br/>
          <span id="metro_UPD" class="select">
          <g:if test="${metro}">
            <label for="metro_id">Метро</label>
            <select name="metro_id" id="metro_id" style="width:260px">
              <option value="0" <g:if test="${inrequest?.metro_id==0}">selected="selected"</g:if>>Выберите метро</option>
            <g:each in="${metro}" var="item">
              <option value="${item?.id}" <g:if test="${inrequest?.metro_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select> 
          </g:if>
          </span>
        </fieldset>
        <fieldset>
          <legend>Интересы и предпочтения</legend>
          <label for="description">О себе</label>
          <g:textArea name="description">${inrequest?.description?:''}</g:textArea>
          <label for="hobby">Мои хобби</label>
          <g:textArea name="hobby">${inrequest?.hobby?:''}</g:textArea>
          <label for="wishes">Мои пожелания</label>
          <g:textArea name="wishes">${inrequest?.wishes?:''}</g:textArea>          
        </fieldset>
        <fieldset>
          <legend>Кому меня показывать</legend>        
          <span class="select">
            <label for="vissexstatus">Пол</label>
            <select name="vissexstatus">
              <option value="0" <g:if test="${inrequest?.vissexstatus==0}">selected="selected"</g:if>>любой</option>
              <option value="1" <g:if test="${inrequest?.vissexstatus==1}">selected="selected"</g:if>>парни</option>
              <option value="2" <g:if test="${inrequest?.vissexstatus==2}">selected="selected"</g:if>>девушки</option>
            </select>
          </span><br/>
          <span class="select">
            <label for="visagefrom">Возраст от</label>
            <select name="visagefrom">
            <g:each in="${(min_user_age..max_user_age-1)}" var="i">
              <option value="${i}" <g:if test="${inrequest?.visagefrom==i}">selected="selected"</g:if>>${i}</option>
            </g:each>
              <option value="${max_user_age}" <g:if test="${inrequest?.visagefrom==max_user_age}">selected="selected"</g:if>>${max_user_age}+</option>
            </select>
          </span><br/>
          <span class="select" style="clear:left">
            <label for="visageto">Возраст до</label>
            <select name="visageto">
            <g:each in="${(min_user_age..max_user_age-1)}" var="i">
              <option value="${i}" <g:if test="${inrequest?.visageto==i}">selected="selected"</g:if>>${i}</option>
            </g:each>
              <option value="100" <g:if test="${inrequest?.visageto==100}">selected="selected"</g:if>>${max_user_age}+</option>
            </select>
          </span>
        </fieldset>
        <fieldset>        
          <legend>Видимость анкеты в режиме оффлайн</legend>
          <span class="select">
            <label for="visoffline">Показывать</label>
            <select name="visoffline">
              <option value="1" <g:if test="${inrequest?.visoffline==1}">selected="selected"</g:if>>да</option>
              <option value="0" <g:if test="${inrequest?.visoffline==0}">selected="selected"</g:if>>нет</option>
            </select>
          </span>
        </fieldset>
        <div style="margin:25px 15px">
          <input type="submit" value="<g:message code='button.save' />"/>
        </div>
      </g:form>    
    </div>
  </body>
</html>
