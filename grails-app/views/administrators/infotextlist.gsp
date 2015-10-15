<%@ page contentType="text/html;charset=UTF-8" %>
<style type="text/css">
  .dotted { border: none; }
  .dotted th { padding:5px; border-top:none; background:#404040; color:#fff }
  .dotted td { padding:12px 5px; }
  #resultList { margin:0px 12px 10px 12px; height:540px; border-top:1px solid #333; border-bottom:1px solid #333 }
  .action_button { margin-bottom: 3px; }
  .action_button.s { margin-left: 15px }
</style>
<div id="ajax_wrap" style="clear:both;min-heigth:500px">
  <div class="select">
    <label>Найдено:&nbsp;&nbsp;${count}</label>
    <div class="${(count > 20)?'action_button p':''}">    
      <g:paginate controller="administrators" action="${actionName}" prev=" " next=" " params="${params}"
        max="20" total="${count}"/> 
      <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>         
    </div>
  </div>
<g:if test="${records}">
  <div id="resultList" style="clear:left;overflow-y:auto">
    <table class="dotted" width="100%" cellpadding="0" cellspacing="0" rules="all" frame="none">
      <thead>
        <tr>
        <g:if test="${inrequest.id!=1}">
          <th>Код</th>
          <th>Группа</th>
          <th>№ п/п</th>
          <th>Название в меню</th>
          <th>Title</th>
          <th>Контроллер</th>
          <th>Экшен</th>
          <th>Дата модификац.</th>
        </g:if>
        <g:else>
          <th>Код</th>
          <th>Экшен</th>
          <th>Название</th>
          <th>Тема письма</th>
        </g:else>
        </tr>
      </thead>
      <tbody>
      <g:each in="${records}" status="i" var="record">
        <tr id="tr_${i}"  onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
          <td>${record.id}</td>
        <g:if test="${inrequest.id!=1}">
          <td nowrap>
          <g:each in="${itemplate}" var="item">
            ${(record.itemplate_id==item.id)?item.name:''}
          </g:each>  
          </td>
          <td>${record?.npage}</td>
          <td>${record.header}</td>
          <td><g:link action="infotextedit" id="${record.id}">${record.title}</g:link></td>
          <td>${record.controller}</td>
          <td>${record.action}</td>
          <td>${String.format('%td.%<tm.%<tY',record.moddate)}</td>
        </g:if>
        <g:else>
          <td><g:link action="infotextedit" id="${record.id}" params="[type:'1']">${record.action}</g:link></td>
          <td>${record.name}</td>
          <td>${record.title}</td>
        </g:else>
        </tr>
      </g:each>
      </tbody>
    </table>
  </div>
</g:if>
</div>
