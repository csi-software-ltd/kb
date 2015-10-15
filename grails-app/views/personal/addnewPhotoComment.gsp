<g:if test="${pcomment}">
  <li onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
  <g:if test="${user?.smallpicture}">
    <img width="70" height="70" src="${user?.is_local?imageurl:''}${user?.smallpicture}" border="0" />
  </g:if><g:else>
    <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
  </g:else>
    <div class="username">
      <g:link controller="user" action="view" id="${user.id}">${user?.nickname?:user?.firstname}</g:link>
    </div>
    <div class="lastvisit">
      <span class="date">${String.format("%td/%<tm %<tH:%<tM",pcomment?.comdate)}</span>
    </div>        
    <div id="desc_${i}" class="desc">${pcomment?.comtext}</div>
  </li>
</g:if><g:else>
</g:else>
