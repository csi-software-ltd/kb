<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение KtoBlizko.ru</title>
    <meta name="layout" content="admin" />
    <style type="text/css">
      .info .select label	{ min-width: 110px; padding: 5px 15px !important; }
      .info .select .dk_container { margin: 5px 0 !important; }
      .info .select textarea { text-indent: 14px !important; }
    </style>
  </head>
  <body>
  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${(flash?.error?:[]).contains(1)}"><li>Вы не заполнили обязательное поле &laquo;Название&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(2)}"><li>Вы не заполнили обязательное поле &laquo;Дата начала&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(3)}"><li>Вы не заполнили обязательное поле &laquo;Дата окончания&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(4)}"><li>Дата начала больше даты окончания</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(5)}"><li>Даты заняты другим конкурсом.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(10)}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
      </ul>
    </div>
  </g:if>
    <div class="info">
      <g:form name="tendersDetails" controller="administrators" action="tendersave">
        <fieldset>
          <legend>Общее</legend>
          <span class="select">
            <label for="name">Название</label>
            <input type="text" style="width:760px" name="name" value="${inrequest?.name?:''}"/>
          </span>
        </fieldset>
        <fieldset>
          <legend>Описание</legend>
          <span class="select">
            <label for="slogan">Слоган</label>
            <input type="text" style="width:760px" name="slogan" value="${inrequest?.slogan?:''}"/>
          </span><br/>
          <span class="select">
            <label for="info">Информация</label>
            <g:textArea style="width:760px" name="info">${inrequest?.info?:''}</g:textArea>
          </span>
        </fieldset>
        <fieldset>
          <legend>Даты проведения</legend>
            <span class="select" style="margin-right:25px">
              <label for="tender_date_start" style="margin-right:5px">Дата начала:</label>
              <calendar:datePicker name="tender_date_start" needDisable="false" dateFormat="%d-%m-%Y" value="${inrequest?.date_start?:''}"/>
            </span>
            <span class="select">
              <label for="tender_date_end" style="margin-right:5px">Дата окончания:</label>
              <calendar:datePicker name="tender_date_end" needDisable="false" dateFormat="%d-%m-%Y" value="${inrequest?.date_end?:''}"/>
            </span>
        </fieldset>
        <input type="hidden" name="tender_id" value="${inrequest?.id?:0}"/>
        <div style="margin:25px 15px">
          <input type="submit" value="<g:message code='button.save' />"/>
          <input type="button" onclick="$('backToTendersForm').submit();" value="Назад к списку"/>
        </div>
      </g:form>
    </div>
    <g:form name="backToTendersForm" controller="administrators" action="tenders">
    </g:form>
  </body>
</html>
