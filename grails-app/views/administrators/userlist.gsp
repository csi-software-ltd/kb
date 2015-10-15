<%@ page contentType="text/html;charset=UTF-8" %>
<style type="text/css">
  .dotted { border: none; }
  .dotted th { padding:5px; border-top:none; background:#404040; color:#fff }
  .dotted td { padding:12px 5px; }
  #resultList { margin:0px 12px 10px 12px; height:540px; border-top:1px solid #333; border-bottom:1px solid #333 }
  .action_button { margin-bottom: 3px; }
  .action_button.s { margin-left: 15px }
</style>
<div id="ajax_wrap" style="clear:both">
  <div class="select">
    <label>Найдено:&nbsp;&nbsp;${count}</label>
    <div class="${(count > 20)?'action_button p':''}">    
      <g:paginate controller="administrators" action="${actionName}" prev=" " next=" " params="${inrequest}"
        max="20" total="${count}"/> 
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>				  
    </div>
  </div>
<g:if test="${records}">
  <div id="resultList" style="clear:left;overflow-y:auto">
    <table class="dotted" width="100%" cellpadding="0" cellspacing="0" border="0" rules="all" frame="none">
      <thead>
        <tr>
          <th rowspan="2" width="50">Фото</th>
          <th rowspan="2">Код</th>
          <th rowspan="2">Ник [пользователь]</th> 
          <th rowspan="2">Провайдер</th>
          <th colspan="2" width="105">Статус подтв.</th>        
          <th rowspan="2">Телефон</th>          
          <th colspan="2" width="100">Дата</th>
          <th rowspan="2">Действия</th>
        </tr>
        <tr>
          <th width="35">email</th>
          <th width="35">тел.</th>
          <th width="50">регист.</th>
          <th width="50">посещ.</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${records}" status="i" var="record">
        <tr id="tr+${i}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
          <td>
            <img src="${(record?.picture && record?.is_local)?imageurl:''}${(record?.smallpicture)?record?.smallpicture:resource(dir:'images',file:'user-default-picture.png')}" align="absmiddle" width="50" style="border:1px solid silver">
          </td>
          <td align="right">${record.id}</td>
          <td style="line-height:17px">${record.nickname?:record.firstname?:'none'}<br/><font color="#1D95CB">${record.name}</font></td>
          <td>${record.provider}</td>
          <td align="center">
            <span class="action_button s">
              <g:if test="${record.modstatus==0}"><span class="icon inactive" alt="неподтвержден" title="неподтвержден">&nbsp;</span></g:if>
              <g:elseif test="${record.modstatus==1}"><span class="icon active" alt="активен" title="активен">&nbsp;</span></g:elseif>
            </span>
          </td>
          <td align="center">
            <span class="action_button s">
              <g:if test="${record.is_telcheck==0}"><span class="icon inactive" alt="не подтвержден" title="не подтвержден">&nbsp;</span></g:if>
              <g:else><span class="icon active" alt="подтвержден" title="подтвержден">&nbsp;</span></g:else>
            </span>
          </td>
          <td align="right">${record.tel?:''}</td>
          <td>${String.format('%td.%<tm.%<ty',record.inputdate)}</td>
          <td>${String.format('%td.%<tm.%<ty',record.lastdate)}</td>          
          <td>
            <span class="action_button">
              <g:if test="${record.banned==0}"><span class="icon inactive" onClick="setMain(${record.id},1);">забанить аккаунт</span></g:if>
              <g:else><span class="icon active" onClick="setMain(${record.id},0);">активировать аккаунт</span></g:else>              
            </span>            
            <span class="action_button">
              <g:if test="${record.is_telcheck==1}"><span class="icon inactive" onClick="setTel(${record.id},0);">отменить телефон</span></g:if>
              <g:else><span class="icon active" onClick="setTel(${record.id},1);">подтвердить телефон</span></g:else>              
            </span>            
            <g:if test="${record.password}">
              <span class="action_button">
                <span class="icon none" onClick="changePass(${record.id})">сменить пароль</span>
              </span>
            </g:if>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</g:if>
</div>
