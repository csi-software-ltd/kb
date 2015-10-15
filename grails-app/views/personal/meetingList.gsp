<%@ page contentType="text/html;charset=UTF-8" %>

<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${data.count}</label>
  <div class="${(data.count > 10)?'action_button p':''}">
    <g:paginate controller="personal" action="${actionName}" prev=" " next=" " params="${inrequest}"
      max="10" total="${data.count}"/> 
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
  </div>
</div>
<div id="tableAJAX" style="clear:both">
  <ul class="list">
  <g:each in="${data.records}" var="record" status="i">   
    <li id="meetli_${record.id}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
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
      <div class="lastvisit" style="padding:3px;width:95px">
        <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.mdate)}</span><br/>
        <span class="action_button s">
          <a id="st_${record.id}" class="icon ${(record.modstatus==1)?'active':(record.modstatus==0)?'inactive':'inactive'}">
            ${(record.modstatus==1)?'подтверждена':(record.modstatus==0)?'запрос':'отклонена'}
          </a>
        </span>
      </div>    
    <g:if test="${inrequest.id==1 && !inrequest.type}"><!-- Прошедшие меня-->
      <div class="ratingstar float">
        <div class="rating_jq_${record.id}" id="${record.torating}_${record.id}"></div>
      </div>
      <g:javascript>
        j('.rating_jq_'+${record.id}).jRating({
          rateMax: 10,
          bigStarsPath: '../images/stars.png',
          onSuccess : function(lId,rate){
              ${remoteFunction(controller:'personal', action:'meetRating',
                             params:"'id='+lId+'&rating='+rate"
              )};
            }
        });
      </g:javascript>          
    </g:if><g:elseif test="${inrequest.id==1 && inrequest.type==1}"><!-- Прошедшие мои-->
      <div class="ratingstar float">
        <div class="rating_jq_${record.id}" id="${record.fromrating}_${record.id}"></div>
      </div>
      <g:javascript>
        j('.rating_jq_'+${record.id}).jRating({
          rateMax: 10,
          bigStarsPath: '../images/stars.png',
          onSuccess : function(lId,rate){
              ${remoteFunction(controller:'personal', action:'meetRating',
                             params:"'id='+lId+'&rating='+rate"
              )};
            }
        });
      </g:javascript>
    </g:elseif>            
      <div class="actions col">
      <g:if test="${!inrequest.id && !inrequest.type}"><!-- Предстоящие меня -->
        <g:if test="${record.modstatus==0}"><!-- Если неподтверждено -->
        <span class="action_button i">
          <a id="stbutton_${record.id}" class="icon confirm" title="Подтвердить" href="javascript:void(0)" onclick="confirmMeeting(${record.id})"></a>
        </span>
        </g:if>
        <span class="action_button i">
          <a id="meeting_lbox_link${record.id}" class="icon send" title="Переназначить" href="javascript:void(0)" onclick="$('reassign_meeting_id').value=${record.id};$('reassign_interlocutor_id').value=${record.user_id};$('reassign_tab_id').value='meetingMe';"></a>
        </span>
        <span class="action_button i">
          <a class="icon delete" title="Отказать" href="javascript:void(0)" onclick="declineMeeting(${record.id})"></a>
        </span>
      </g:if><g:elseif test="${!inrequest.id && inrequest.type==1}"><!-- Предстоящие мои -->
        <span class="action_button i">
          <a id="meeting_lbox_link${record.id}" class="icon send" title="Переназначить" href="javascript:void(0)" onclick="$('reassign_meeting_id').value=${record.id};$('reassign_interlocutor_id').value=${record.user_id};$('reassign_tab_id').value='meetingI'"></a>
        </span>
        <span class="action_button i">
          <a class="icon delete" title="Отмена" href="javascript:void(0)" onclick="cancelMeeting(${record.id})"></a>
        </span>
      </g:elseif><g:elseif test="${inrequest.id==1 && !inrequest.type}"><!-- Прошедшие меня-->
        <span class="action_button i">
          <a id="meeting_lbox_link${record.id}" class="icon send" title="Назначить новую встречу" href="javascript:void(0)" onclick="$('reassign_meeting_id').value=0;$('reassign_interlocutor_id').value=${record.user_id};$('reassign_tab_id').value='meetingMe';"></a>
        </span>
      </g:elseif><g:elseif test="${inrequest.id==1 && inrequest.type==1}"><!-- Прошедшие мои-->        
        <span class="action_button i">
          <a id="meeting_lbox_link${record.id}" class="icon send" title="Назначить новую встречу" href="javascript:void(0)" onclick="$('reassign_meeting_id').value=0;$('reassign_interlocutor_id').value=${record.user_id};$('reassign_tab_id').value='meetingI';"></a>
        </span>
      </g:elseif><g:elseif test="${inrequest.id==2 && !inrequest.type}"><!-- Отклоненные мной -->
        <span class="action_button i">
          <a id="meeting_lbox_link${record.id}" class="icon send" title="Назначить новую встречу" href="javascript:void(0)" onclick="$('reassign_meeting_id').value=0;$('reassign_interlocutor_id').value=${record.user_id};$('reassign_tab_id').value='meetingI';"></a>
        </span>
      </g:elseif>
        <span class="action_button i">
          <a class="icon detail down" title="Подробнее" href="javascript:void(0)" onclick="toggleDesc(${i},this)"></a>
        </span>
      </div>
    </li>
    <li id="desc_${i}" class="selected" style="display:none">
      <div class="desc" style="width:85%">
        <span class="bold">${record?.name}</span><br/>
        <span class="bold">${record?.place}</span>
      </div>
    <g:if test="${record.x}">
      <div class="actions col">
        <span class="action_button i">
          <a id="mapdetail_lbox_link${i}" class="icon location" title="Смотреть на карте" href="javascript:void(0)"></a>
        </span>
        <g:javascript>
          j('#mapdetail_lbox_link'+${i}).colorbox({
            inline: true,
            href: '#mapdetail_lbox',
            scrolling: false,
            onLoad: function(){
              j('#mapdetail_lbox').show();
              renderMap(${record.x},${record.y});
            },
            onCleanup: function(){
              j('#mapdetail_lbox').hide();
            }
          });
        </g:javascript>
      </div>
    </g:if>
    </li>
    <g:javascript>
      j('#meeting_lbox_link'+${record.id}).colorbox({
        inline: true,
        href: '#meeting_lbox',
        scrolling: false,
        onLoad: function(){
          $('meetId').value = ${record.id};
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
