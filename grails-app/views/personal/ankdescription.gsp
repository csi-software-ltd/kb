<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" />
    <g:javascript>
    function backToAnclocation(){
      $('backToAnclocationForm').submit();
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
      <g:if test="${flash?.error == 2}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
      </ul>
    </div>
  </g:if>
    <div class="info">
      <g:form name="profileSettings" controller="personal" action="saveAnkdescription">
        <fieldset class="noborder">
          <label for="description">О себе</label>
          <g:textArea name="description">${user?.description?:''}</g:textArea><br/>
          <label for="hobby">Мои хобби</label>
          <g:textArea name="hobby">${user?.hobby?:''}</g:textArea><br/>
          <label for="wishes">Мои пожелания</label>
          <g:textArea name="wishes">${user?.wishes?:''}</g:textArea><br/>
          <div style="margin-top:25px;">
          <input type="button" onclick="backToAnclocation()" value="<g:message code='button.back' />"/>
          <input type="submit" value="<g:message code='button.next' />"/></br/>
        </fieldset>
      </g:form>
    </div>
    <g:form name="backToAnclocationForm" controller="personal" action="anklocation">
    </g:form>
  </body>
</html>
