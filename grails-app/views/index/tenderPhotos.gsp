<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${count}</label>
  <div class="${(count > 10)?'action_button p':''}">
    <g:paginate controller="index" action="tenderPhotos" prev=" " next=" " params="${inrequest}"
      max="10" maxsteps="2" total="${count}"/>
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
  </div>
</div>
<div class="am-container" id="am-container" style="clear:both;width:100%;float:right">
  <g:each in="${imges}" var="img" status="i">
    <g:link controller="personal" action="bigPhoto" id="${img?.id}-${img?.user_id}">
      <img onload="montImg();" src="${img?.is_local?imageurl:''}${img?.picture}"></img>
    </g:link>
  </g:each>
</div>
