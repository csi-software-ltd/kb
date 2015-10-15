<%@ page contentType="text/html;charset=UTF-8" %>

<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${data.count}</label>
  <div class="${(data.count > max)?'action_button p':''}">
    <g:paginate controller="personal" action="myfriends" prev=" " next=" " params="${inrequest}"
      max="${max}" total="${data.count}"/>
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>
  </div>
</div>
<div id="tableAJAX" style="clear:both;">
    <ul class="list">
    <g:each in="${data.records}" var="record" status="i">   
      <li onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
      <g:if test="${record?.picture}">
        <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.picture}" border="0" />
      </g:if><g:else>
        <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
      </g:else>
        <div class="username">
          <g:link controller="user" action="view" id="${record?.mid}">${record?.nickname?:record?.firstname?:''}</g:link><br/>
        <g:each in="${city}" var="item"> 
          <g:if test="${record?.city_id==item?.id}">
          ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
          </g:if>
        </g:each>
          <br/><span class="bold">${record?.age}</span>
        </div>
        <div class="gender ${(record?.gender_id==1)?'male':'female'}"></div>
        <g:javascript>
          var gender, color;
          switch(${record?.vissexstatus}){
            case 1:  gender='c парнем';  color='#0099ff'; break;
            case 2:  gender='c девушкой';color='#ff6699'; break;
            default: gender='c любым';   color='#999';
          }
          $('sexstatus_${i}').setStyle({ color: color });
          $('sexstatus_${i}').update( gender );
        </g:javascript>
        <div class="preference">
          Хочет познакомиться<br/>
          <span id="sexstatus_${i}" class="sexstatus"></span><br/>
          <span class="age">${record?.visagefrom}-${(record?.visageto!=100)?record?.visageto:max_user_age+'+'} лет</span>
        </div>
        <div class="lastvisit" style="display:block">
        <g:if test="${record?.online}">
          <span class="action_button s" style="padding-top:8px">
            <a class="icon active">онлайн</a>
          </span>
        </g:if><g:else>
          Был${(record?.gender_id==1)?'':'а'} на сайте<br/>
          <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.lastdate)}</span>
        </g:else>
        </div>
        <div class="actions" style="float:right;display:${user?'block':'none'}">
        <g:if test="${(inrequest?.type?:1)==1}">
          <span class="action_button i">
            <a class="icon delete" title="Убрать из друзей" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.mid};$('relationship_type').value=1;expressRelation(0);"></a>
          </span>
        </g:if><g:elseif test="${(inrequest?.type?:1)==2}">
          <span class="action_button i">
            <a id="tofriend_lbox_link${i}" class="icon favorite" title="Добавить в друзья" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.mid};$('relationship_type').value=3;"></a>
          </span>
          <span class="action_button i">
            <a id="tofoe_lbox_link${i}" class="icon edit" title="Добавить в список игнорирования" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.mid};$('relationship_type').value=3;"></a>
          </span>
        </g:elseif><g:elseif test="${(inrequest?.type?:1)==3}">
          <span class="action_button i">
            <a class="icon delete" title="Убрать из списка игнорирования" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.mid};$('relationship_type').value=2;expressRelation(0);"></a>
          </span>
        </g:elseif>
        <g:if test="${(inrequest?.type?:1)!=3}">
          <span id="sasdasdaxxzczx${record?.mid}" class="action_button i">
            <g:remoteLink class="icon edit" action="messageDetails" id="${record?.mid}" title="Написать письмо" update="chat_lbox_container" onComplete="openChat();"></g:remoteLink>
            <!--a class="icon edit" title="Отослать письмецо" href="javascript:void(0)"></a-->
          </span>
        </g:if>
        </div>
      </li>
  <g:if test="${(inrequest?.type?:1)==2}">
  <g:javascript>
    j('#tofriend_lbox_link'+${i}).colorbox({
      inline: true,
      href: '#tofriend_lbox',
      scrolling: false,
      onLoad: function(){
        j('#tofriend_lbox').show();
      },
      onCleanup: function(){
        j('#tofriend_lbox').hide();
      }
    });
    j('#tofoe_lbox_link'+${i}).colorbox({
      inline: true,
      href: '#tofoe_lbox',
      scrolling: false,
      onLoad: function(){
        j('#tofoe_lbox').show();
      },
      onCleanup: function(){
        j('#tofoe_lbox').hide();
      }
    });
  </g:javascript>
  </g:if>
    </g:each>
    </ul>
</div>
