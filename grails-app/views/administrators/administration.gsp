<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение KtoBlizko.ru</title>
    <meta name="layout" content="admin"/>
    <style type="text/css">
      .left  { width: 200px }
      .right { width: 696px }
      .info .select label.lab	{ min-width: 95px; padding: 5px 15px !important; }
      .info .select input[type="text"], .info .select input[type="password"] { width: 195px }
    </style>
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
      
      function deleteUser(lId){
        if (confirm('Вы уверены?')){
          ${remoteFunction(controller:'administrators',
                           action:'deleteuser',
                           params:'\'id=\'+lId',
                           onSuccess:'processDeleteUserResponse(e);'
          )};
        }
      }
      
      function processDeleteUserResponse(e){
        if (e.responseJSON.done){
          $('details').update('');
          selectGroupUser(1);
        }else{
          if (e.responseJSON.message)
            $('mess').update(e.responseJSON.message);
          $('message').style.display = 'block';
        }
      }
      
      function updateDetails(lId,iPart){
        hideAll();		
        $('details').show();
        ${remoteFunction(controller:'administrators',action:'groupuserdetails',params:"'id='+lId+'&part='+iPart", update:'details') };
      }
      
      function selectGroupUser(lId){
        hideAll();
        ${remoteFunction(controller:'administrators',action:'groupuserlist',params:'\'id=\'+lId', update:'groupuser')};
        if (lId) {
          user();
        }else{
          group();
        }
      }
      
      function showGroupWindow(){
        hideAll();
        $('details').hide();
        $('creategroup').style.display = 'block';
      }
      
      function showUserWindow(){
        hideAll();
        $('details').hide();
        $('createuser').style.display = 'block';		
      }
      
      function hideGroupWindow(){
        $('creategroup').style.display = 'none';
        $('name').value = '';
        $('groupmess').update('');
        $('groupmess').hide();
      }
      
      function hideUserWindow(){
        $('createuser').style.display = 'none';
        $('login').value = '';
        $('usermess').update('');
        $('usermess').hide();
      }
      
      function hideAll(){
        $('details').update('');
        hideGroupWindow();
        hideUserWindow();
        closeMessage();
        hidePassWindow();		
      }
      
      function processGroupResponse(e){
        if (e.responseJSON.done){
          if (e.responseJSON.message){
            $('mess').update(e.responseJSON.message);
            hideGroupWindow();
            $('message').style.display = 'block';
          }else{
            selectGroupUser(0);
            hideGroupWindow();
            if(e.responseJSON.id)
              updateDetails(e.responseJSON.id,0);
          }
        }else{
          $('groupmess').update(e.responseJSON.message);
          $('groupmess').show();
        }
      }
      
      function processUserResponse(e){
        if (e.responseJSON.done){
          if (e.responseJSON.message){
            $('mess').update(e.responseJSON.message);
            hideUserWindow();
            $('message').style.display = 'block';
          }else{
            selectGroupUser(1);
            hideUserWindow();
            if(e.responseJSON.id)
              updateDetails(e.responseJSON.id,1);
          }
        }else{
          $('usermess').update(e.responseJSON.message);
          $('usermess').show();
        }
      }
      
      function selectGuestbook(iCheked){
        if (iCheked){
          $('gbmain').enable();
          $('gberrors').enable();
          $('gbcall').enable();
          $('gbpcrequest').enable();
        }else{
          $('gbmain').disable();
          $('gberrors').disable();
          $('gbcall').disable();
          $('gbpcrequest').disable();
        }
      }      
      
      function closeMessage(){
        $('message').style.display = 'none';
      }
      
      function showPassWindow(lId){
        hideAll();              
      }
      
      function hidePassWindow(){ /*    
        $('pass').value='';
        $('confirm_pass').value='';
        $('passmess').update('');*/
      }
      
      function processPassResponse(e){
        if (e.responseJSON.done){
          $('mess').update(e.responseJSON.message);
          hidePassWindow();
          $('message').style.display = 'block';
        }else{
          $('passmess').update(e.responseJSON.message);
          $('passmess').show();
        }
      }
      
      function group(){
        $('userlink').style.color = 'black';
        $('grouplink').style.color = '#0080F0';
      }
      
      function user(){
        $('userlink').style.color = '#0080F0';
        $('grouplink').style.color = 'black';
      }
    </g:javascript>
  </head>
  
  <body onload="selectGroupUser(0);">
    <h2 align="center">
      <g:remoteLink id="grouplink" url="${[controller:'administrators', action:'groupuserlist',id:0]}" update="[success:'groupuser']" onSuccess="hideAll();group();" style="margin-right:15px;">Группы</g:remoteLink>
      <g:remoteLink id="userlink" url="${[controller:'administrators', action:'groupuserlist',id:1]}" update="[success:'groupuser']" onSuccess="hideAll();user();">Пользователи</g:remoteLink>
    </h2>
    
    <div class="left" id="groupuser">              
    </div>      
    <div class="right" id="details">              
    </div>      
    
    <div class="right" id="creategroup" style="display:none">              
      <h2 class="blue">Добавить группу</h2>
      <div id="groupmess" class="notice" style="display:none"></div>      
      <div class="info"> 
        <g:formRemote url="[controller:'administrators',action:'creategroup']" onSuccess="processGroupResponse(e)" method="POST" name="createGroupForm">
          <fieldset class="noborder">
            <span class="select">
              <label for="name">Введите имя группы:</label>
              <input type="text" name="name" id="name"/>
            </span>
            <div style="margin:25px 15px 0 0;float:right;">
              <input type="submit" value="Добавить" style="margin-right:10px"/>
              <input type="reset" value="Отмена" onclick="hideGroupWindow();"/>
            </div>
          </fieldset>
        </g:formRemote>        
      </div>    
    </div>
      
    <div class="right" id="createuser" style="display:none">
      <h2 class="blue">Добавить пользователя</h2>
      <div id="usermess" class="notice" style="display:none"></div>
      <div class="info">
        <g:formRemote url="[controller:'administrators',action:'createuser']" onSuccess="processUserResponse(e)" method="POST" name="createUserForm">
          <fieldset class="noborder">
            <span class="select">
              <label for="login">Введите логин:</label>
              <input type="text" name="login" id="login"/>
            </span><br/>
            <span class="select">
              <label for="pass">Задайте пароль:</label>
              <input type="password" name="pass" id="pass"/>
            </span><br/>
            <span class="select">
              <label for="confirm_pass">Повторите пароль:</label>
              <input type="password" name="confirm_pass" id="confirm_pass"/>
            </span>
            <div style="margin:25px 15px 0 0;float:right">
              <input type="submit" value="Добавить" style="margin-right:10px"/>
              <input type="reset" value="Отмена" onclick="hideUserWindow();"/>
            </div>
          </fieldset>
        </g:formRemote>                          
      </div>
    </div>
      
    <div class="left" id="message" style="display:none">
      <div class="notice">
        <div id="mess"></div>
        <input type="button" value="ОК" style="width:80px" onclick="closeMessage()"/>
      </div>
    </div>
    
  </body>
</html>
