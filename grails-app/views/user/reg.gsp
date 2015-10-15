<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" /> 
    <g:javascript>      
      function deletepicuserphoto(){
        ${remoteFunction(controller:'user', action:'deleteuserphoto',
          params:"'name=file1'", onSuccess:'reloadImage(1)')}
      }
      function telCounter(sId,iMax,sNext){
        var symbols = $F(sId);
        var len = symbols.length;
        if(len >= iMax){
          symbols = symbols.substring(0,iMax);
          $(sId).value = symbols;
          $(sNext).focus();
        }
      }
      var j = jQuery.noConflict();
      j(document).ready(function(){
      <g:if test="${flash?.error}">
        <g:if test="${(flash?.error?:[]).contains(6)||(flash?.error?:[]).contains(10)}">
          j('#dk_container_birthday_year').find('.dk_toggle').addClass('red');
        </g:if>
        <g:if test="${(flash?.error?:[]).contains(7)}">
          j('#dk_container_gender_id').find('.dk_toggle').addClass('red');
        </g:if>
      </g:if>
      });
    </g:javascript>      
  </head>
  <body>
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${(flash?.error?:[]).contains(1)}"><li>Вы не заполнили обязательное поле &laquo;Имя пользователя&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(2)}"><li>Вы не заполнили обязательное поле &laquo;Email&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(3)}"><li>Некорректно заполнено поле &laquo;Email&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(4)}"><li>Слишком короткий пароль</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(5)}"><li>Такой пользователь уже существует. Измените email.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(6)}"><li>Некорректно заполнено поле &laquo;Дата рождения&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(10)}"><li>Ваш возраст слишком мал!</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(7)}"><li>Вы не заполнили обязательное поле &laquo;Пол&raquo;</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(8)}"><li>Ошибка БД. Попробуйте повторить позже.</li></g:if>
        <g:if test="${(flash?.error?:[]).contains(9)}"><li>Некорректно заполнено поле &laquo;Мобильный телефон&raquo;</li></g:if>
      </ul>
    </div>
  </g:if>    
    <div class="info">    
      <fieldset>
        <legend>Фото</legend>
        <g:form name='ff1' method="post" url="${[action:'saveuserphoto']}" enctype="multipart/form-data" target="upload_target">
          <div id="error1" style="display: none;"></div>
          <div id="uploaded1" class="upload" style="float:left">
          <g:if test="${inrequest?.picture}">
            <img width="140" height="140" src="${imageurl}${inrequest?.picture}" border="0"/>
          </g:if><g:else>
            <img width="140" height="140" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0"/>
          </g:else>
          </div>
          <div style="width:50%;padding-top:45px;float:right;">
            <input type="button" id="button1" value="Изменить" onclick="deletepicuserphoto()" <g:if test="${!inrequest?.picture}">style="display: none;"</g:if>>
            <input type="file" name="file1" id="file1" size="23" accept="image/jpeg,image/gif" onchange="startSubmit('ff1')" <g:if test="${inrequest?.picture}">style="display: none;"</g:if>/>
            <input type="hidden" name="is_uploaded1" id="is_uploaded1" value="${images?.photo_1?1:0}" />
            <input type="hidden" name="no_webcam" value="1"/>
          </div>
        </g:form>
        <div id="loader" style="position: absolute; top: 100px; display: none; width: 16px; height: 16px;">
          <img src="${resource(dir:'images',file:'spinner.gif')}" border="0">
        </div>
        <iframe id="upload_target" name="upload_target" src="#" style="width:0;height:0;border:0px solid #fff;"></iframe>
      </fieldset>
      <g:form name="addUser" controller="user" action="userAdd">
        <fieldset>
          <legend>Учетная запись</legend>
          <span class="select">
            <label for="name">Имя пользователя</label>
            <input type="text" name="firstname" value="${inrequest?.firstname?:''}" class="${((flash?.error?:[]).contains(1))?'red':''}"/>
          </span><br/>
          <span class="select">
            <label for="email">Email</label>
            <input type="text" name="email" value="${inrequest?.email?:''}" class="${((flash?.error?:[]).contains(2)||(flash?.error?:[]).contains(3)||(flash?.error?:[]).contains(5))?'red':''}"/>
          </span><br/>
          <span class="select">
            <label for="passw">Пароль</label>
            <input type="password" name="passw" value="${inrequest?.passw?:''}" class="${((flash?.error?:[]).contains(4))?'red':''}"/>
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
          <div class="select" style="clear:left">
            <label for="birthday">Дата рождения</label>  
            <g:datePicker name="birthday" precision="day" value="${(date?.birthday_day&&date?.birthday_month&&date?.birthday_year)?new Date(date?.birthday_year-1900,date?.birthday_month-1,date?.birthday_day):new Date()}" years="${((new Date()).getYear()+1900-min_user_age)..1940}" />
          </div>
          <br/>
          <label for="birthday">Мобильный телефон</label>
          <span nowrap>
            + <input type="text" id="ind" name="ind" value="${inrequest.ind?:''}" size="3" style="width:55px" onKeyUp="telCounter(this.id,1,'kod');" class="${((flash?.error?:[]).contains(9))?'red':''}"/>
            ( <input type="text" id="kod" name="kod" value="${inrequest.kod?:''}" size="7" style="width:55px" onKeyUp="telCounter(this.id,3,'telef');" class="${((flash?.error?:[]).contains(9))?'red':''}"/> )
            <input type="text" id="telef" name="telef" value="${inrequest.telef?:''}" size="15" style="width:100px" class="${((flash?.error?:[]).contains(9))?'red':''}"/>
          </span>
          <div style="margin-top: 25px;">
            <input type="submit" value="<g:message code='button.reg'/>"/>
          </div>
        </fieldset>
      </g:form>
    </div>

<!-- /Загрузка имиджей -->
<script language="javascript" type="text/javascript">
function reloadImage(iNum){
    $('uploaded'+iNum).update('<img width="140" height="140" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0"/>');
    $('button'+iNum).hide();
    $('file'+iNum).value='';
    $('file'+iNum).show();
    $('is_uploaded'+iNum).value=0;
  }

  function startSubmit(sName){
	  $(sName).submit();
    $('loader').show();
    return true;
  }

  function stopUpload(iNum,sFilename,sThumbname,iErrNo,sMaxWeight) {
	  if((iNum<=0)||(iNum>4)) iNum=1;
	  
	  $('loader').hide();
    if(iErrNo==0){
    	$('is_uploaded'+iNum).value=1;
      $('uploaded'+iNum).show();
      $('uploaded'+iNum).update('<img width="140" height="140" src="${imageurl}'+sFilename+'" border="0"/>');
	    $('file'+iNum).hide();
      $('error'+iNum).hide();
      $('button'+iNum).show();
    }else{
      var sText="Ошибка загрузки";
      switch(iErrNo){
        case 1: 
        case 2: sText="Ошибка загрузки"; break;
        case 3: sText="Слишком большой файл. Ограничение "+sMaxWeight+" Мб"; break;
        case 4: sText="Неверный тип файла. Используйте JPG или PNG"; break;
      } 
      $('is_uploaded'+iNum).value=0;
      $('error'+iNum).update(sText);  
    	$('error'+iNum).show();
    }
    return true;
  }
</script>
  </body>
</html>
