<g:if test="${openchats}">
  <g:each in="${openchats}" var="chats" status="i">
    <span id="sasdasdaxxzczx${chats.id}" class="dialog dk_toggle">
      <g:remoteLink action="messageDetails" id="${chats.id}" update="messageDetail_view">${chats.name}</g:remoteLink>
      <span class="action_button i">
        <a class="icon delete" title="Удалить" href="javascript:void(0)" onclick="closeChat(${chats.id})"></a>            
      </span>
      <span class="action_button s">
        <a class="icon active" title="Новое сообщение"></a>
      </span>      
    </span>
  </g:each>
  <g:javascript>
    processResponseOpenchats(${lId});
  </g:javascript>
</g:if><g:else>
  <g:javascript>
    toggleDetail(0,1);
  </g:javascript>
</g:else>
