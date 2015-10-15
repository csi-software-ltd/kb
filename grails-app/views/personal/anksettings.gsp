<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" />
    <g:javascript>
    function backToAnkdescription(){
      $('backToAncdescriptionForm').submit();
    }
    </g:javascript>
  </head>
  <body onload="viewSmallMap()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <div class="path">
    <g:each in="${regmenu}" var="item" status="i">
      <div class="${(item?.npage < infotext?.npage)?'passed':((item?.npage==infotext?.npage)?'current':'future')} triangle" style="z-index:${regmenu.size()-i};${(i==1)?'width:150px':''}"><p style="${(i==0)?'margin-left:10px':''}">${item?.shortname}</p></div>
    </g:each>
    </div>
    <div style="padding-top:5px;clear:left"/>

  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${flash?.error == 1}"><li>Ошибка справочников. Попробуйте позже.</li></g:if>
        <g:if test="${flash?.error == 2}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
        <g:if test="${flash?.error == 3}"><li>Возраст от больше чем возраст до.</li></g:if>
      </ul>
    </div>
  </g:if>
    <div class="info">
      <g:form name="profileSettings" controller="personal" action="saveAnksettings">
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
          <span class="select">
            <label for="visageto">Возраст до</label>
            <select name="visageto">
            <g:each in="${(min_user_age..max_user_age-1)}" var="i">
              <option value="${i}" <g:if test="${inrequest?.visageto==i}">selected="selected"</g:if>>${i}</option>
            </g:each>
              <option value="100" <g:if test="${inrequest?.visageto==100||!inrequest?.visageto}">selected="selected"</g:if>>${max_user_age}+</option>
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
          <input type="button" onclick="backToAnkdescription()" value="<g:message code='button.back' />"/>
          <input type="submit" value="<g:message code='button.save' />"/>
        </div>
      </g:form>
    </div>
    <g:form name="backToAncdescriptionForm" controller="personal" action="ankdescription">
    </g:form>
  </body>
</html>
