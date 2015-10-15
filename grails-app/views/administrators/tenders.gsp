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
      function resetDate(){
        $('tender_date').setValue('');
        $('tender_date_year').setValue('');
        $('tender_date_month').setValue('');
        $('tender_date_day').setValue('');
      }
      function changestatus(iId,status){
        ${remoteFunction(controller:'administrators',
          action:'changeTendstatus',
          params:"'id='+iId+'&modstatus='+status",
          onSuccess:"\$('tender_submit_button').click();")}
      }
      function deleteTender(iId){
        if (confirm('Точно удалить?')){
          ${remoteFunction(controller:'administrators',
            action:'deleteTender',
            params:"'id='+iId",
            onSuccess:"\$('tender_submit_button').click();")}
        }
      }
    </g:javascript>  
  </head>  
  <body onload="\$('tender_submit_button').click();">
    <div class="info" id="tenderlist">
      <g:formRemote name="allForm" url="[action:'tenderlist']" update="[success:'list_view']">
        <input type="hidden" name="stat" id="stat" value="direction" />
        <fieldset style="background:rgba(0,0,0,0.03)">
          <div style="height:45px">
            <span class="select">
              <label for="tender_id">Код:</label>
              <input type="text" name="tender_id" style="width:70px"/>
            </span>
            <span class="select">
              <label for="name">Название:</label>
              <input type="text" name="name" style="width:200px">
            </span>
            <span class="select">
              <label for="modstatus">Cтатус:</label>
              <select name="modstatus">
                <option value="-1">любой</option>
                <option value="0">неактивный</option>
                <option value="1">активный</option>
              </select>
            </span>
            <span class="select">
              <label for="tender_date" style="margin-right:5px">Дата:</label>
              <calendar:datePicker name="tender_date" needDisable="false" dateFormat="%d-%m-%Y" value=""/>
            </span>
          </div>
          <div style="clear:left;float:right;margin-top:10px">
            <input type="button" onclick="$('newTenderForm').submit();" value="Создать новый"/>
            <input type="submit" id="tender_submit_button" value="Показать" style="margin:0 5px">
            <input type="reset" value="Сброс" onClick="resetDate();return true;"/>
          </div>    
        </fieldset>      
      </g:formRemote>
      <div id="list_view">
      </div>
    </div>
    <g:form name="newTenderForm" controller="administrators" action="tenderdetails">
    </g:form>
  </body>
</html>
