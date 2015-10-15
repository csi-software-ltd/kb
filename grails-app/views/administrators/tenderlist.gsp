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
          <th rowspan="2">Код</th>
          <th rowspan="2">Название</th>
          <th rowspan="2" width="50">Статус</th>
          <th colspan="2" width="100">Дата</th>
          <th rowspan="2">Действия</th>
        </tr>
        <tr>
          <th width="50">начала</th>
          <th width="50">оконч.</th>
        </tr>
      </thead>
      <tbody>
      <g:each in="${records}" status="i" var="record">
        <tr id="tr+${i}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
          <td align="right">${record.id}</td>
          <td style="line-height:17px"><g:link action="tenderdetails" params="[tender_id:record.id]">${record.name}</g:link></td>
          <td align="center">
            <span class="action_button s">
              <g:if test="${record.modstatus==0}"><span class="icon inactive" alt="неактивен" title="неактивен">&nbsp;</span></g:if>
              <g:elseif test="${record.modstatus==1}"><span class="icon active" alt="активен" title="активен">&nbsp;</span></g:elseif>
            </span>
          </td>
          <td>${String.format('%td.%<tm.%<ty',record.date_start)}</td>
          <td>${String.format('%td.%<tm.%<ty',record.date_end)}</td>
          <td>
            <span class="action_button">
              <g:if test="${record.modstatus==1}"><span class="icon inactive" onClick="changestatus(${record.id},0);">отменить активацию</span></g:if>
              <g:else><span class="icon active" onClick="changestatus(${record.id},1);">активировать</span></g:else>
            </span><br/>
            <span class="action_button">
              <span class="icon inactive" onClick="deleteTender(${record.id});">удалить</span>
            </span>
          </td>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</g:if>
</div>  
