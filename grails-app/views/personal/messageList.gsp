<%@ page contentType="text/html;charset=UTF-8" %>

<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${data.count}</label>
  <div class="${(data.count > 10)?'action_button p':''}">
    <g:paginate controller="personal" action="messageList" prev=" " next=" " params="${inrequest}"
      max="10" total="${data.count}"/>
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
  </div>
</div>
<div id="tableAJAX" style="clear:both">
  <ul class="list">
  <g:each in="${data.records}" var="record" status="i">   
    <g:if test="${(user.id==record.fromuser && record.modstatus==-1)||(user.id==record.touser && record.modstatus==1)}">
      <g:javascript>
      jQuery('#limsg_${i}').animate({opacity: 0.1}, 1500).animate({opacity: 1}, 1500).animate({opacity: 0.5}, 1500).animate({opacity: 1}, 1500);
      </g:javascript>
    </g:if><g:else>
      <g:javascript>
      jQuery('#limsg_${i}').css({opacity: 0.4});
      </g:javascript>
    </g:else>
    <li id="limsg_${i}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')" onclick="opendetails(event,${record.user_id});">
    <g:if test="${record?.picture}">
      <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.picture}" border="0" />
    </g:if><g:else>
      <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
    </g:else>
      <div class="username">
        <g:link controller="user" action="view" id="${record?.user_id}">${record?.username}</g:link><br/>
      <g:each in="${city}" var="item"> 
        <g:if test="${record?.city_id==item?.id}">
          ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
        </g:if>
      </g:each>
        <br/><span class="bold">${record?.age}</span>
      </div>        
      <div class="lastvisit" style="padding: 6px 0">          
      <g:if test="${record?.online}">
        <span class="action_button s" style="padding-top:8px">
          <a class="icon active">онлайн</a>
        </span>
      </g:if>          
        <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.lastdate)}</span>
      </div>        
      <div id="desc_${i}" class="desc" style="width:170px">
        <g:shortString text="${record?.lastmessage}" length="132"/><br/>
      </div>
      <div class="actions" style="float:right">
        <span class="action_button i">
          <a class="icon edit" title="Написать сообщение" href="javascript:void(0)"></a>
        </span>
        <span class="action_button i">
          <a id="meeting_lbox_link${record.user_id}" class="icon send" title="Назначить встречу" href="javascript:void(1)" onclick="$('interlocutor_id').value=${record.user_id}"></a>
        </span>
        <span class="action_button i">
          <a id="tofoe_lbox_link${i}" class="icon ignore" title="Игнорировать" href="javascript:void(1)" onclick="$('relationship_user_id').value=${record.user_id}"></a>
        </span>
      </div>        
    </li>
    <g:javascript>
      j('#tofoe_lbox_link'+${i}).colorbox({
        inline: true,
        href: '#tofoe_lbox',
        scrolling: false,
        onLoad: function(){
          j('#tofoe_lbox').show();
        },
        onCleanup: function(){
          j('#tofoe_note').value = '';
          j('#tofoe_error').hide();
          j('#tofoe_lbox').hide();
        }
      });
      j('#meeting_lbox_link'+${record.user_id}).colorbox({
        inline: true,
        href: '#meeting_lbox',
        scrolling: false,
        onLoad: function(){
          j('#meeting_lbox').show();
        },
        onCleanup: function(){
          j('#meeting_lbox').hide();
        }
      });
      j('#datetime').datetimepicker({minDate: new Date(),stepMinute: 5});
    </g:javascript>
  </g:each>
  </ul>
</div>

  <div id="meeting_lbox" class="new-modal" style="width:585px;height:auto;display:none">
    <h2 class="blue clearfix">Назначить встречу:</h2>
    <div id="meeting_lbox_segment" class="segment nopadding">
      <div id="meeting_lbox_container" class="lightbox_filter_container">
        <div id="message_data"></div>
        <div id="meeting_error" class="notice" style="display:none">
          <span id="meeting_errorText"></span>
        </div>
        <fieldset>
          <g:formRemote name="meetingAddForms" url="[controller: 'personal', action: 'meetingAdd']" onSuccess="meetingAddResponse(e)">
          <div id="meetingmap_view" style="display:none">
            <label for="geoAddress"><a href="javascript:void(0)" onclick="findMeetAdr($('geoAddress').value);">Найти</a> адрес:</label>
            <input type="text" id="geoAddress" value="" />
            <div id="meetingmap_container" style="visibility:hidden;width:530px;"></div>
          </div>
          <span class="select">
            <label for="meetname">Что:</label>
            <input type="text" name="meetname" id="meetname" maxlength="135" value="" />
          </span><br/>
          <div class="select" nowrap>
            <label for="meetwhere">Где:</label>
            <input type="text" name="meetwhere" maxlength="230" id="meetwhere" value="" />
            <input type="checkbox" name="mapwhere" id="mapwhere" value="0" onclick="togglemeetingMap();" />
          </div><br/>
          <div class="select">
            <label for="datetime">Когда:</label>
            <span class="dpicker">
              <input type="text" name="datetime" id="datetime" style="width:155px" value="" />
              <img src="${resource(dir:'images',file:'calendar.png')}" border="0" />
            </span>
          </div><br/>
          <input type="hidden" id="interlocutor_id" name="interlocutor_id" value="" />
          <input type="hidden" id="meetX" name="meetX" value="" />
          <input type="hidden" id="meetY" name="meetY" value="" />
          <input type="submit" id="meetingSubmitButton" style="display:none" value="${message(code:'button.add')}" />
          </g:formRemote>
        </fieldset>
      </div>
    </div>
    <div class="segment buttons">
      <input type="button" onclick="$('meetingSubmitButton').click();" value="${message(code:'button.add')}" />
    </div>
  </div>