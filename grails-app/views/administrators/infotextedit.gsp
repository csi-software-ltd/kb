<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
  <title>Административное приложение StayToday.ru</title>
  <meta name="layout" content="admin" />
  <style type="text/css">
    .info .select label { min-width: 120px; padding: 5px 15px !important; }
    .info .select .dk_container { margin: 5px 0 !important; }
    .info .select textarea { text-indent: 14px !important; }
  </style>
  <g:javascript>  
    function selectOnchange(el){
      var objSel = document.getElementById(el); 
      var statusID = objSel.options[objSel.selectedIndex].value;      
      if (statusID == 1)
        objSel.className = 'icon active always';
      else if(statusID == 0)
        objSel.className = 'icon inactive always';
    }	
    function returnToList(){
      $("returnToListForm").submit();
    }
	</g:javascript>
  </head>  
  <body>
  <g:if test="${flash?.save_error}">
    <div class="notice">
      <ul>
        <g:if test="${(flash?.save_error?:[]).contains(101)}"><li>Непоправимая ошибка. Данные не сохранены.</li></g:if>
      </ul>
    </div>
  </g:if>
    <div class="info">
      <g:form name="infotexteditForm" url="[controller:'administrators',action:'infotextedit', id:inrequest.id]" method="POST">
    <g:if test="${type!=1}">
      <h1 class="blue" style="padding-left:15px">Информационный текст &laquo;${inrequest.title}&raquo;</h1></td>
      <fieldset>
        <legend>Метатеги</legend>
        <span class="select">
          <label for="title">Title:</label>
          <textarea rows="5" cols="40" name="title" style="width:760px">${inrequest?.title}</textarea>
        </span>
        <span class="select">
          <label for="keywords">Keywords:</label>
          <textarea rows="5" cols="40" name="keywords" style="width:760px">${inrequest?.keywords?:''}</textarea>
        </span>
        <span class="select">
          <label for="description">Description:</label>
          <textarea rows="5" cols="40" name="description" style="width:760px">${inrequest?.description?:''}</textarea>
        </span>
      </fieldset>
      <fieldset>
        <legend>Заголовки</legend>
        <span class="select">
          <label for="header">H1:</label>
          <input type="text" name="header" style="width:760px" value="${inrequest?.header?:''}"/>
        </span>
        <span class="select">
          <label for="promotext1">К промо-тексту 1:</label>
          <input type="text" name="promotext1" style="width:760px" value="${inrequest?.promotext1?:''}"/>
        </span>
        <span class="select">
          <label for="promotext2">К промо-тексту 2:</label>
          <input type="text" name="promotext2" style="width:760px" value="${inrequest?.promotext2?:''}"/>
        </span>
      </fieldset>
      <fieldset>
        <legend>Промо-тексты</legend>
        <span class="select">
          <label for="stext1">Промотекст 1:</label>
          <select id="stext1" onChange="selectOnchange('stext1');$('text1').toggle()">
            <option value="0" selected="selected">скрыт</option>
            <option value="1">показан</option>
          </select>
        </span><br/>
        <div class="select" id="text1" style="display:none">
          <fckeditor:editor name="itext" width="900" height="300" toolbar="KB" fileBrowser="default">
            <g:rawHtml>${inrequest?.itext}</g:rawHtml>
          </fckeditor:editor>
        </div>
        <span class="select" style="clear:left">
          <label for="stext2">Промотекст 2:</label>
          <select id="stext2" onChange="selectOnchange('stext2');$('text2').toggle()" style="border:none;">
            <option class="icon inactive" value="0" selected="selected">скрыт</option>
            <option class="icon active" value="1">показан</option>
          </select>
        </span>
        <div class="select" id="text2" style="display:none">
          <fckeditor:editor name="itext2" width="900" height="300" toolbar="KB" fileBrowser="default">
            <g:rawHtml>${inrequest?.itext2?:''}</g:rawHtml>
          </fckeditor:editor>
        </div>
        <span class="select" style="clear:left">
          <label for="stext3">Промотекст 3:</label>
          <select id="stext3" class="icon inactive" onChange="selectOnchange('stext3');$('text3').toggle()" style="border:none;">
            <option class="icon inactive" value="0" selected="selected">скрыт</option>
            <option class="icon active" value="1">показан</option>
          </select>
        </span>
        <div class="select" id="text3" style="display:none">
          <fckeditor:editor name="itext3" width="900" height="300" toolbar="KB" fileBrowser="default">
            <g:rawHtml>${inrequest?.itext3?:''}</g:rawHtml>
          </fckeditor:editor>
        </div>
      </fieldset>
    </g:if><g:else>
        <h1 class="blue">Шаблон письма &laquo;${inrequest.name}&raquo;</h1>
        <fieldset>
          <span class="select">
            <label for="name">Название:</label>
            <textarea rows="5" cols="40" name="name" style="width:760px">${inrequest?.name}</textarea>
          </span>
          <span class="select">
            <label for="title">Тема письма:</label>
            <textarea rows="5" cols="40" name="title" style="width:760px">${inrequest?.title}</textarea>
          </span>
          <span class="select">
            <label for="itext">Текст письма:</label>
            <fckeditor:editor name="itext" width="900" height="300" toolbar="KB" fileBrowser="default">
              <g:rawHtml>${inrequest?.itext}</g:rawHtml>
            </fckeditor:editor>
          </span>
      </fieldset>
    </g:else>
      <div style="margin:25px 15px">
        <input type="submit" value="<g:message code='button.save' />"/>
        <input type="button" onclick="returnToList();" value="Назад к списку"/>
      </div>
      <input type="hidden" id="save" name="save" value="1" />
      <input type="hidden" id="type" name="type" value="${type?:0}" />
    </g:form>
    </div>
    <g:form name="returnToListForm" url="${[controller:'administrators',action:'infotext', params:[fromEdit:1, type:type?:0]]}">
    </g:form>
  </body>
</html>
