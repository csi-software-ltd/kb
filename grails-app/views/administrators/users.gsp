<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение KtoBlizko.ru</title>
    <meta name="layout" content="admin" />
    <style type="text/css">
      .info .select label	{ min-width: 10px; padding: 5px 15px !important; }
      .info .select .dk_container { margin: 5px 0 !important; }
    </style>
    <g:javascript library="jquery.colorbox" />    
    <g:javascript>
      function clickPaginate(event){
        event.stop();
        var link = event.element();
        if(link.href == null){
          return;
        }
  
        new Ajax.Updater(
          { success: $('ajax_wrap') },
          link.href,
          { evalScripts: true });		  
      }
      function setTel(iId,telchek){
        ${remoteFunction(controller:'administrators',
	        action:'telchek',
          params:"'id='+iId+'&telchek='+telchek",
					onSuccess:'location.reload(true)')}
      }
      function changePass(iId){
        ${remoteFunction(controller:'administrators',
	        action:'getUserPass',
          params:"'id='+iId",
					onSuccess:"processResponsePass(e)")}
      }
      function changeUserPass(iId){
        $("main_id").value=iId;
        $("main_pass2").value=$("pass2form").value;
        $("main_pass").value=$("passform").value;
        $("main_pass_submit_button").click();
      }
      function processResponsePass(e){           
        var template ='<div id="filters_lightbox" class="new-modal">'+                      
                      '  <div id="lightbox_filters" class="segment nopadding">'+
                      '    <div class="lightbox_filter_container">'+
                      '      <table width="100%" cellpadding="0" cellspacing="0" border="0">'+
                      '        <tr>'+
                      '	         <td>'+
                      '	           <div width="68" style="float:left;margin-right:15px">'+
                      '		           <div class="glossy drop_shadow" style="background:#d1d1d1;width:68px;height:68px;padding:8px">'+
                      ((e.responseJSON.smallpicture!='')?
                      '		             <img class="slideshow" width="68" height="68" alt="'+e.responseJSON.nickname+'" title="'+e.responseJSON.nickname+'"'+
                      '			             src="'+((e.responseJSON.smallpicture && !e.responseJSON.is_external)?'${imageurl}':'')+((e.responseJSON.smallpicture)?e.responseJSON.smallpicture:'')+'">'
                      :'${resource(dir:"images",file:"user-default-picture.png")}')+
                      '		           </div>'+
                      '		           <div class="user" style="width:68px">'+
                      '		             <small style="white-space:normal"><a href="${(context.is_dev)?'/'+context.appname:''}/profile/view/'+e.responseJSON.id+'">'+e.responseJSON.nickname+'</a></small><br/>'+
                      '		           </div>'+
                      '	           </div>'+
                      '          </td>'+
                      '        </tr>'+
                      '      </table>'+                      
                      '      <div id="pass_error" class="notice" style="margin:5px 0;width:95%;display:none;">'+
                      '        <span id="pass_errorText" style="font-size:12px"></span>'+
                      '      </div>'+
                      '      <table width="100%" cellpadding="5" cellspacing="0" border="0">'+
                      '        <tr>'+
                      '          <td colspan="4" valign="top">'+
                      '            <h2 class="toggle border"><span class="edit_icon password"></span>Смена пароля</h2>'+
                      '          </td>'+
                      '        </tr>'+     
                      '        <tr>'+
                      '          <td nowrap>Новый пароль:</td>'+
                      '          <td><input type="password" id="passform" value="" style="width:95%"/></td>'+
                      '          <td nowrap>Повтор пароля:</td>'+
                      '          <td><input type="password" id="pass2form" value="" style="width:100%"/></td>'+
                      '        </tr>'+
                      '      </table>'+
                      '    </div>'+
                      '  </div>'+
                      '  <div class="segment buttons">'+
                      '    <input type="button" onclick="changeUserPass('+e.responseJSON.id+')" class="button-glossy green mini" value="Сменить"/>'+
                      '  </div>'+                      
                      '</div>';                     
        jQuery.colorbox({
          html: template
        });        
			}	
      function changepassResponse(e){
        if(e.responseJSON.error){
          
          $('pass_error').show();
          $('pass_errorText').update(e.responseJSON.message);
        } else {
          alert('Пароль успешно изменен.');
          location.reload(true);
        }
      }
      function resetDate(){
        $('enter_date_from').setValue('');
        $('enter_date_to').setValue('');	
        $('registr_date_from').setValue('');
        $('registr_date_to').setValue('');
        $('enter_date_from_year').setValue('');
        $('enter_date_to_year').setValue('');
        $('enter_date_from_month').setValue('');
        $('enter_date_to_month').setValue('');
        $('enter_date_from_day').setValue('');
        $('enter_date_to_day').setValue('');
        $('registr_date_from_year').setValue('');
        $('registr_date_to_year').setValue('');
        $('registr_date_from_month').setValue('');
        $('registr_date_to_month').setValue('');
        $('registr_date_from_day').setValue('');
        $('registr_date_to_day').setValue('');
      }
    </g:javascript>  
  </head>  
  <body onload="\$('user_submit_button').click();">
    <div class="info" id="userlist">
      <g:formRemote name="allForm" url="[action:'userlist']" update="[success:'list_view']">
        <fieldset style="background:rgba(0,0,0,0.03)">
          <div style="height:45px">
            <span class="select">
              <label for="user_id">Код:</label>
              <input type="text" name="user_id" style="width:80px"/>
            </span>
            <span class="select">
              <label for="name">Пользователь:</label>
              <input type="text" name="name" style="width:170px">
            </span>
            <span class="select">        
              <label for="provider">Провайдер:</label>
              <select name="provider">
                <option value="">любой</option> 
              <g:each in="${provider}" var="item">
                <option value="${item.provider}">${item.provider}</option>
              </g:each>
              </select>
            </span>
          </div>
          <div style="height:45px;clear:left">
            <span class="select">
              <label for="registr_date_from" style="margin-right:5px">Дата регистрации с:</label>
              <calendar:datePicker name="registr_date_from" needDisable="false" dateFormat="%d-%m-%Y" value=""/>
            </span>
            <span class="select">
              <label for="registr_date_to">по:</label>
              <calendar:datePicker name="registr_date_to" needDisable="false" dateFormat="%d-%m-%Y" value=""/>
            </span>
            <span class="select">
              <label for="enter_date_from">Дата посл. посещ. с:</label>
              <calendar:datePicker name="enter_date_from" needDisable="false" dateFormat="%d-%m-%Y" value=""/>
            </span>
            <span class="select">
              <label for="enter_date_to">по:</label>
              <calendar:datePicker name="enter_date_to" needDisable="false" dateFormat="%d-%m-%Y"  value=""/>
            </span>            
          </div>      
          <div style="height:45px;clear:left">
            <span class="select">
              <label for="modstatus">Cтатус аккаунта:</label>
              <select name="modstatus">
                <option value="-1">любой</option>
                <option value="0">неподтвержден</option>
                <option value="1">активен</option>
              </select>
            </span>
            <span class="select" id="telchek_status">
              <label for="telchek">Cтатус тел.:</label>
              <select name="telchek">
                <option value="-1">любой</option>
                <option value="1">подтвержден</option>
                <option value="0">неподтвержден</option>
              </select>
            </span>          
            <span class="select">
              <label for="order">Сортировать по:</label>
              <select name="order">
                <option value="0">дате регистрации</option>   
                <option value="1">дате посл. посещ.</option>
                <option value="2">коду пользователя</option>  
              </select>
            </span>           
          </div>
          <div style="clear:left;float:right">
            <input type="submit" id="user_submit_button" value="Показать" style="margin-right:5px">        
            <input type="reset" value="Сброс" onClick="resetDate();return true;"/>
          </div>    
        </fieldset>      
      </g:formRemote>
        
      <div id="list_view">
      </div>
    </div>    
    <g:formRemote name="changepassForm" url="[controller: 'administrators', action: 'changeUserPass']" onSuccess="changepassResponse(e)">      
      <input type="hidden" id="main_id" name="id" value="0">
      <input type="hidden" id="main_pass2" name="pass2" value="">
      <input type="hidden" id="main_pass" name="pass" value="">
      <input type="submit" id="main_pass_submit_button" style="display:none" value="">
    </g:formRemote>
  </body>
</html>
