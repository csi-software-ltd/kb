<%@ page contentType="text/html;charset=UTF-8" %>

<ul class="list-items">
  <li class="${(user?.geocodestatus==0)?'checked':''}" onclick="changeGeoStatus(-2,'Автоопределение',this);">
    <a class="geo" href="javascript:void(0)"><span class="list-item-icon"> </span> Определять автоматически</a>
  </li>
  <li class="${(user?.geocodestatus==1)?'checked':''} separator" onclick="changeGeoStatus(-1,'Слежение',this);">
    <a class="geo" href="javascript:void(0)"><span class="list-item-icon"> </span> Отслеживать автоматически</a>
  </li>
  <g:each in="${placelist}" var="place">
  <li class="${(user?.geocodestatus==2 && place?.is_main)?'checked':''}" onclick="changeGeoStatus(${place?.id},'${place?.name}',this);">
    <a class="geo"  href="javascript:void(0)"><span class="list-item-icon"> </span> ${place?.name}</a>
  </li>
  </g:each>
</ul>

