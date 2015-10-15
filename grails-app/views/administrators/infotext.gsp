<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение StayToday.ru</title>
    <meta name="layout" content="admin" />
    <style type="text/css">
      .info .select label	{ min-width: 10px; padding: 5px 15px !important; }
      .info .select .dk_container { margin: 5px 0 !important; }
    </style>
    <g:javascript>
    function initialize(iParam){
      switch(iParam){
        case 0:
          sectionColor('infotext');
          $('homelist').show();
          $('placeList').hide();          
          $('user_submit_button').click();
          $('companystat').setStyle({height: '450px'}); 
          break;
        case 1:
          sectionColor('mail');
          $('homelist').hide();
          $('placeList').show();
          $('mail_submit_button').click();
          $('companystat').setStyle({height: '575px'}); 
          break;
      }
      jQuery('a.bold').css({'text-decoration':'underline','margin-right': '10px'});
	  }
	  
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
      
	  function resetData(){
      $('inf_action').setValue('');
      $('inf_controller').setValue('');
      $('itemplate_id').selectedIndex = 0;
      j('#itemplate_id').dropkick("setValue", 0);
    }
    
    function sectionColor(sSection){
      $('infotext').style.color = 'black';
      $('mail').style.color = 'black';
      $(sSection).style.color = '#0080F0 !important';
    }
    </g:javascript>  
  </head>  

	<body onload="initialize(${type})">
    <div class="info" style="min-height:730px">
      <div align="center">
        <a class="bold" href="javascript:void(0)" onclick="initialize(0)" id="infotext">Инфотексты</a>
        <a class="bold" href="javascript:void(0)" onclick="initialize(1)" id="mail">Шаблоны писем</a>       
      </div>
      <div id="homelist">
        <g:formRemote name="allForm" url="[action:'infotextlist']" update="[success:'companystat']">
          <fieldset style="background:rgba(0,0,0,0.03)">
            <div style="height:45px">
              <span class="select">
                <label for="itemplate_id" style="min-width:10px">Группа:</label>
                <select id="itemplate_id" name="itemplate_id">
                  <option value="-1" <g:if test="${inrequest?.itemplate_id==-1}">selected="selected"</g:if>>&nbsp;</option>
                  <option value="0" <g:if test="${inrequest?.itemplate_id==0}">selected="selected"</g:if>>Без группы</option>
                <g:each in="${itemplate}" var="item">            
                  <option value="${item?.id}" <g:if test="${inrequest?.itemplate_id==item?.id}">selected="selected"</g:if>>
                    ${item?.name}
                  </option>
                </g:each>              
                </select>
              </span>
              <span class="select">
                <label for="inf_controller">Контроллер:</label>
                <input type="text" id="inf_controller" name="inf_controller" value="${inrequest?.inf_controller}" style="width:100px">
              </span>
              <span class="select">
                <label for="inf_action">Экшен:</label>
                <input type="text" id="inf_action" name="inf_action" value="${inrequest?.inf_action}" style="width:150px">
              </span>
            </div>
            <div style="clear:left;float:right;margin-top:10px">            
              <g:link class="button" controller="administrators" action="infotextadd">Добавить страницу</g:link>
              <input type="submit" id="user_submit_button" value="Показать" style="margin:0 5px">
              <input type="reset" value="Сброс" onClick="resetData();$('user_submit_button').click();"/>
            </div>
          </fieldset>
        </g:formRemote>
      </div>
      <div id="placeList" align="center">
        <g:formRemote name="allForm" url="[action:'infotextlist', id:1]" update="[success:'companystat']">
        <fieldset style="background:rgba(0,0,0,0.03)">
          <div style="height:45px">
            <span class="select">
              <label for="e_action">Экшен:</label>
              <input type="text" id="e_action" name="inf_action" value="${inrequest?.inf_action}" style="width:150px">
            </td>
          </div>
          <div style="clear:left;float:right">
            <g:link controller="administrators" action="infotextadd" params="[type:'1']" class="button-glossy orange">Добавить шаблон</g:link>
            <input type="submit" class="button-glossy green" id="mail_submit_button" value="Показать" style="margin:0 10px">
            <input type="button" class="button-glossy grey" value="Сброс" onClick="$('e_action').setValue('');"/>
          </div>
        </fieldset>
        </g:formRemote>
      </div>    
      <div id="companystat"></div>
    </div>
  </body>
</html>
