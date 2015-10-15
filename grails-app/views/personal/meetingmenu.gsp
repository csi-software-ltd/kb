<g:if test="${lId==1}">
    <span id="meetingMe" class="dialog dk_toggle checked">
      <g:remoteLink action="meetingList" id="${lId}" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Меня приглашали</g:remoteLink>
    </span>
    <span id="meetingI" class="dialog dk_toggle">
      <g:remoteLink action="meetingList" id="${lId}" params="[type:1]" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Я приглашал${user?.gender_id==1?'':'а'}</g:remoteLink>
    </span>
</g:if><g:elseif test="${lId==2}">
    <span id="meetingMe" class="dialog dk_toggle checked">
      <g:remoteLink action="meetingList" id="${lId}" params="[type:1]" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Мое предложение отклонили</g:remoteLink>
    </span>
    <span id="meetingI" class="dialog dk_toggle">
      <g:remoteLink action="meetingList" id="${lId}" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Я отклонил${user?.gender_id==1?'':'а'}</g:remoteLink>
    </span>
    <span id="meetingC" class="dialog dk_toggle">
      <g:remoteLink action="meetingList" id="3" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Отмененные</g:remoteLink>
    </span>
</g:elseif><g:else>
    <span id="meetingMe" class="dialog dk_toggle checked">
      <g:remoteLink action="meetingList" id="${lId}" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Меня приглашают</g:remoteLink>
    </span>
    <span id="meetingI" class="dialog dk_toggle">
      <g:remoteLink action="meetingList" id="${lId}" params="[type:1]" before="toggleChecked('meeting_menu',this.parentElement,'span')" update="meeting_list">Я приглашаю</g:remoteLink>
    </span>
</g:else>
