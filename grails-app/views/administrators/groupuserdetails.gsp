<%@ page contentType="text/html;charset=UTF-8" %>

<g:if test="${inrequest?.part}">
  <div class="content">
    <h2 class="blue">${user?.login?:'' }</h2>
    <div id="passmess" class="notice" style="display:none"></div>
    <div class="info">
      <g:formRemote url="[controller:'administrators',action:'usersave']" name="userForm" update="[success:'details']">
        <input type="hidden" name="id" value="${user?.id?:0}">
        <fieldset>
          <legend>Изменение профиля</legend>
          <div style="width:50%;float:left">           
            <span class="select">
              <label for="login" class="lab">Логин:</label>
              <input type="text" name="login" value="${user?.login?:''}"/>
            </span>          
            <span class="select">
              <label for="name" class="lab">Полное имя:</label>
              <input type="text" name="name" value="${user?.name?:''}"/>
            </span>
          </div>
          <div style="width:50%;float:right">           
            <span class="select">
              <label for="email" class="lab">Email:</label>
              <input type="text" name="email" value="${user?.email?:''}"/>
            </span>
            <span class="select">
              <label for="group" class="lab">Группа:</label>
              <select name="group">
              <g:if test="${!user?.admingroup_id?:0}"><option value="0">не определена</option></g:if>
              <g:each in="${groups}" var="group">
                <option value="${group.id}" <g:if test="${group.id==user?.admingroup_id?:0 }">selected</g:if>>${group.name}</option>
              </g:each>
              </select>
            </span>
          </div>
          <div style="clear:both;margin-top:25px;float:right">        			
            <input type="button" class="button-glossy red mini" value="Удалить" onclick="deleteUser(${user?.id?:0})" style="margin:0 5px"/>            
            <input type="submit" class="button-glossy green mini" value="Сохранить" style="margin:0 5px;"/>            
            <input type="reset" class="button-glossy grey mini" value="Отмена" onclick="$('details').update('')" style="margin:0 5px"/>
          </div>
        </fieldset>
      </g:formRemote>
      <g:formRemote url="[controller:'administrators',action:'changepass']" onSuccess="processPassResponse(e)" method="POST" name="changePassForm">
        <input type="hidden" name="ajax" value="1"/>				  
        <input type="hidden" name="id" id="change_pass_id" value="${user?.id?:0}"/>
        <fieldset>
          <legend>Изменение пароля</legend>
          <span class="select">
            <label for="pass" class="lab">Новый пароль:</label>
            <input type="password" name="pass" id="pass"/>
          </span>
          <span class="select">
            <label for="confirm_pass" class="lab">Повторить:</label>
            <input type="password" name="confirm_pass" id="confirm_pass"/>
          </span>
          <div style="margin-top:25px;float:right">        			
            <input type="submit" value="Изменить"/>                        
          </div>
        </fieldset>
      </g:formRemote>                        
    </div>
  </div>
</g:if>
<g:elseif test="${group}">
  <div class="content">
    <h2 class="blue">${group.name}</h2>
    <div class="info">
      <g:formRemote url="[controller:'administrators',action:'groupsave']" name="groupForm" update="[success:'details']">
        <input type="hidden" name="id" value="${group.id}">
        <fieldset class="noborder">
          <input type="checkbox" name="is_profile" value="1" <g:if test="${group.is_profile}">checked</g:if>/>
          <label for="is_profile">Профиль пользователя</label><br/>
          <input type="checkbox" name="is_users" value="1" <g:if test="${group.is_users}">checked</g:if>/>
          <label for="is_users">Пользователи</label><br/>
          <input type="checkbox" name="is_tenders" value="1" <g:if test="${group.is_tenders}">checked</g:if>/>
          <label for="is_tenders">Конкурсы</label>
          <div style="margin:25px 15px 0 0;float:right">        			
            <input type="reset" value="Отмена" onclick="$('details').update('')" style="margin-right:10px"/>
            <input type="submit" value="Сохранить"/>
          </div>        
        </fieldset>
      </g:formRemote>
    </div>
  </div>
</g:elseif>
