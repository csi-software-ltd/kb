<%@ page contentType="text/html;charset=UTF-8" %>
<div class="info">
  <fieldset>
    <legend>${inrequest?.part?'Пользователи':'Группы'}</legend>
    <g:each in="${groupusers}" var="item" status="i">
      <a <g:if test="${i==0}">id="first"</g:if> href="javascript:void(0)" onclick="updateDetails(${item.id},${inrequest?.part})">${inrequest?.part?item.login:item.name}</a><br>
    </g:each>
    <div align="right" style="margin-top: 50px">
    <g:if test="${inrequest?.part}">
      <input type="button" class="button-glossy orange" value="Добавить" onclick="showUserWindow()"/>
    </g:if><g:else>
      <input type="button" class="button-glossy orange" value="Добавить" onclick="showGroupWindow()"/>
    </g:else>
    </div>    
  </fieldset>
</div>
