<%@ page contentType="text/html;charset=UTF-8" %>

<g:javascript>  
	removeAllMarkers();
</g:javascript>
<div id="ajax_wrap">
<g:if test="${userplace}">  
  <fieldset>
    <legend>Список моих мест</legend>  
    <ul class="list">
    <g:each in="${userplace}" var="record" status="i">
      <g:javascript>
        addMarker(${record.x},${record.y},'${i+1}',${record.id},${record.is_main});
      </g:javascript>
      <li onmouseout="this.removeClassName('selected');deHighlightPlace();" onmouseover="this.addClassName('selected');highlightPlace(${record.id},'${i+1}');" onclick="setCenter(${record.id});">      
        <span style="float:left">
          <p><b>${i+1}. ${record.name}</b><br/>
          <small>${record.address}</small>
          <small>${City.get(record.city_id?:0)?.name?:''}</small>
          <small>${Metro.get(record.metro_id?:0)?.name?:''}</small></p>                    
        </span>      
        <span class="actions" style="float:right">
        <g:if test="${record.is_main}">
          <span class="action_button i">
            <a class="icon location" title="Текущее место" href="javascript:void(0)"></a>
          </span>
        </g:if>
          <span class="action_button i">
            <a class="icon edit" title="Редактировать" href="javascript:void(0);" onclick="edit(${record.x},${record.y},${record.id},'${record.name}',${record.city_id},${record.metro_id},'${record.address}','${i+1}');$('place').update('Редактирование места');javascript:scroll(0,0);"></a>
          </span>
          <span class="action_button i">
            <a class="icon delete" title="Удалить" href="javascript:void(0);" onclick="deletePlace(${record.id})"></a>
          </span>
        </span>
      </li>
    </g:each>
    <g:javascript>
      renderCollection();
    </g:javascript>
    </ul>
  </fieldset>
</g:if>
</div>
