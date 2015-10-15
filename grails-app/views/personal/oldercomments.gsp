<g:each in="${comments.records}" var="record" status="i">
  <li id="commli_${record.id}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
    <div class="actions col" style="float:right;display:${(user?.id==Userphoto.get(lId)?.user_id)?'block':'none'}">
      <span class="action_button i">
        <a class="icon delete" title="Удалить" href="javascript:void(0)" onclick="deleteComment(${record.id});"></a>
      </span>
    </div>
  <g:if test="${record?.smallpicture}">
    <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.smallpicture}" border="0" />
  </g:if><g:else>
    <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
  </g:else>
    <div class="username">
      <g:link controller="user" action="view" id="${record?.user_id}">${record?.username}</g:link>  
    </div>
    <div class="lastvisit">
      <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.comdate)}</span>
    </div>        
    <div id="desc_${i}" class="desc">${record?.comtext}</div>
  </li>
</g:each>
<g:if test="${comments?.count > offset+5 }">
  <div class="seemore">
    <a href="javascript:void(0)" onclick="$('oldCommentsFormSubmitButton').click()">Смотреть ещё</a>
  </div>
</g:if>
