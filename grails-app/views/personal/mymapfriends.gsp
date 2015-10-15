<%@ page contentType="text/html;charset=UTF-8" %>

<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${data.count}</label>
  <div class="${(data.count > max)?'action_button p':''}">
    <g:paginate controller="personal" action="myfriends" prev=" " next=" " params="${inrequest}"
      max="${max}" total="${data.count}"/>
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
  </div>
</div>
<div id="tableAJAX" style="clear:both;">
<g:javascript>
  removeAllMarkers();
</g:javascript>
  <g:each in="${data.records}" var="record" status="i">   
    <g:javascript>
      addMarker(${record.x/100000},${record.y/100000},${record.is_local},"${record.picture}","${record.firstname}",${record.age},${record.mid});
    </g:javascript>
  </g:each>
<g:javascript>
  addUmarkers();
</g:javascript>
</div>
