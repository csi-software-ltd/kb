<%@ page contentType="text/html;charset=UTF-8" %>

  <div id="tableAJAXDetails">
    <div id="scrollarea" style="margin:0 -10px;height:300px;overflow-y: scroll;border:1px solid #e2e2e2">
      <ul class="list" style="margin:7px 9px;height:280px;">
      <g:each in="${data.records}" var="record" status="i">
        <li onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
        <g:if test="${record.fromuser==interlocutor?.id}">
          <g:if test="${interlocutor?.picture}">
          <img width="70" height="70" src="${interlocutor?.is_local?imageurl:''}${interlocutor?.picture}" border="0" />
          </g:if><g:else>
          <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
          </g:else>
          <div class="username">
            <g:link controller="user" action="view" id="${interlocutor?.id}">${interlocutor?.nickname?:interlocutor?.firstname}</g:link><br/>
          <g:each in="${city}" var="item"> 
            <g:if test="${interlocutor?.city_id==item?.id}">
            ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
            </g:if>
          </g:each>
            <br/><span class="bold">${interlocutor?.age}</span>
          </div>        
        </g:if><g:else>
          <g:if test="${user?.picture}">
          <img width="70" height="70" src="${user?.is_local?imageurl:''}${user?.picture}" border="0" />
          </g:if><g:else>
          <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
          </g:else>        
          <div class="username">
            <g:link controller="user" action="view" id="${user?.id}">${user?.nickname?:user?.firstname}</g:link><br/>
          <g:each in="${city}" var="item"> 
            <g:if test="${user?.city_id==item?.id}">
            ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
            </g:if>
          </g:each>            
            <br/><span class="bold">${user?.age}</span>
          </div>  
        </g:else>    
          <div class="lastvisit" style="padding: 6px 0">          
            <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.inputdate)}</span>
          </div>        
          <div id="desc_${i}" class="desc" style="width:225px">
            ${record?.ctext}
          </div>
        </li>
      </g:each>      
        <div class="online">${online?(interlocutor?.nickname?:interlocutor?.firstname)+' сейчас онлайн':(interlocutor?.nickname?:interlocutor?.firstname)+' последний раз замечен'+(interlocutor?.gender_id==1?' ':'а ')+String.format("%td.%<tm.%<tY %<tH:%<tM",interlocutor?.lastdate)}</div>        
      </ul>
    </div>
    <div class="info clearfix" style="margin-top:10px">
      <fieldset>
        <legend>Написать сообщение</legend>
        <g:formRemote name="sendMessageForm" url="[controller: 'personal', action: 'newMessage']" onSuccess="newMessageResponse(e, ${interlocutor?.id})">
        <ul class="list">
          <li>
            <div class="img">
            <g:if test="${user?.picture}">
              <img width="70" height="70" src="${user?.is_local?imageurl:''}${user?.picture}" border="0" />
            </g:if><g:else>
              <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
            </g:else>
              <b>вы</b>
            </div>
            <div class="desc" style="display:inline-block;width:67%">
              <textarea id="newmessagetext" name="ctext" autofocus style="width:94%"></textarea>
            </div>
            <div class="img">
            <g:if test="${interlocutor?.picture}">
              <img width="70" height="70" src="${interlocutor?.is_local?imageurl:''}${interlocutor?.picture}" border="0" />
            </g:if><g:else>
              <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
            </g:else>
              <b>${interlocutor?.nickname?:interlocutor?.firstname}</b>
            </div>
          </li>
        </ul>
        <div style="float:left;margin-top:20px">
          <input type="submit" id="chat_submit_button" value="${message(code:'button.send')}" style="margin-right:5px" />
          <input type="hidden" name="interlocutor_id" value="${interlocutor?.id}"/>
          <input type="button" id="meeting_button" onclick="jQuery('#meeting_lbox_link').click();" value="Назначить встречу" />
        </div>
      </g:formRemote>
      </fieldset>
    </div>
  </div>

  <a id="meeting_lbox_link" style="display:none"></a>
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
          <input type="hidden" name="interlocutor_id" value="${interlocutor?.id}" />
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

  <g:javascript>
    toggleChecked('openchats',j('#sasdasdaxxzczx'+${interlocutor?.id}),'span');
    j('#sasdasdaxxzczx'+${interlocutor?.id}).removeClass('new');
    j('#messageDetail_view').show();
    offsetChat = 10;
    container = j('#scrollarea');
    container[0].scrollTop = container[0].scrollHeight;
    container.scroll(function() {
        if  (container[0].scrollTop == 0){
            getOldChats(${interlocutor?.id},(container[0].scrollHeight-1));
        }
    });
    srfr();
    rfr(${interlocutor?.id});
    j('#meeting_lbox_link').colorbox({
      inline: true,
      href: '#meeting_lbox',
      scrolling: false,
      onLoad: function(){
        if(j('#chat_lbox')) {
          j('#chat_lbox').hide();
        }
        j('#meeting_lbox').show();
      },
      onCleanup: function(){
        if(j('#chat_lbox')) {
          j('#chat_lbox_link').click();
        }
        j('#meeting_lbox').hide();
      },
      onClosed: function(){
        if(j('#chat_lbox')) {
          j('#chat_lbox_link').click();
        }
      }
    });
    j('#datetime').datetimepicker({minDate: new Date(),stepMinute: 5});
  </g:javascript>
