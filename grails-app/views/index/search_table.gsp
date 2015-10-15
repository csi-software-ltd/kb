<%@ page contentType="text/html;charset=UTF-8" %>

<div id="pagination" class="select">
  <label style="line-height:26px">Найдено:&nbsp;&nbsp;${data.count}</label>
  <div class="${(data.count > inrequest?.max)?'action_button p':''}">    
    <g:paginate controller="index" action="search_table" prev=" " next=" " params="${inrequest}"
      max="${inrequest?.max}" total="${data.count}"/> 
    <g:observe classes="${['step','prevLink','nextLink']}" event="click" function="clickPaginate"/>				  
  </div>
</div>
<div id="tableAJAX" style="clear:both;display:none;">
<g:if test="${(inrequest?.view?:'list')!='map'}">
  <g:javascript>
    if(!bFlag)
      $('tableAJAX').show();
  </g:javascript>    
    <ul class="list">
    <g:each in="${data.records}" var="record" status="i">   
      <li onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
      <g:if test="${record?.smallpicture}">
        <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.smallpicture}" border="0" />
      </g:if><g:else>
        <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
      </g:else>        
        <div id="username_${i}" class="username">
          <g:link controller="user" action="view" id="${record?.id}">${record?.nickname?:record?.firstname?:''}</g:link><br/>
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
          $('desc_${i}').setStyle({ width: "${user?'220':'140'}px" });
          if(${(record?.nickname?:record?.firstname?:'').size()>10})
            $('username_${i}').setStyle({ marginTop: '-9px'});
        </g:javascript>
        <div class="preference">
          Хочет познакомиться<br/>
          <span id="sexstatus_${i}" class="sexstatus"></span><br/>
          <span class="age">${record?.visagefrom}-${(record?.visageto!=100)?record?.visageto:max_user_age+'+'} лет</span>
        </div>
        <g:if test="${user}">
        <div class="lastvisit" style="display:${user?'block':'none'}">        
        <g:if test="${record?.online}">
          <span class="action_button s" style="padding-top:8px">
            <a class="icon active">онлайн</a>
          </span>
        </g:if><g:else>
          Был${(record?.gender_id==1)?'':'а'} на сайте<br/>
          <span class="date">${String.format("%td/%<tm %<tH:%<tM",record?.lastdate)}</span>
        </g:else>
        </div>
        </g:if>
        <div id="desc_${i}" class="desc">
          <g:if test="${record?.statusmessage}">
            <b>Статус:</b> <g:shortString text="${record?.statusmessage}" length="${user?'32':'18'}"/><br/>
          </g:if>
          <g:if test="${record?.wishes}">
            <b>Ищу:</b> <g:shortString text="${record?.wishes}" length="${user?'35':'20'}"/><br/>
          </g:if>
          <g:if test="${record?.description}">
            <b>О себе:</b> <g:shortString text="${record?.description}" length="${user?'35':'20'}"/><br/>
          </g:if>
          <g:if test="${record?.hobby}">
            <b>Хобби:</b> <g:shortString text="${record?.hobby}" length="${user?'35':'20'}"/>
          </g:if>
        </div>
        <g:if test="${user}">
        <div class="actions" style="float:right;display:${user?'block':'none'}">
          <span class="action_button i">
          <g:if test="${record.fav!=1}">
            <a id="tofriend_lbox_link${i}" class="icon favorite" title="Добавить в друзья" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.id}"></a>
          </g:if>
          <g:else>
            <a class="icon delete" title="Убрать из друзей" href="javascript:void(0)" onclick="$('relationship_user_id').value=${record.id};expressRelation(0);"></a>
          </g:else>
          </span>
          <span id="sasdasdaxxzczx${record?.id}" class="action_button i">
            <g:remoteLink class="icon edit" controller="personal" action="messageDetails" id="${record?.id}" title="Написать сообщение" update="chat_lbox_container" onComplete="openChat();"></g:remoteLink>
          </span>
        </div>
        </g:if>
      </li>
  <g:if test="${user}">
  <g:javascript>
    j('#tofriend_lbox_link'+${i}).colorbox({
      inline: true,
      href: '#tofriend_lbox',
      scrolling: false,
      onLoad: function(){
        j('#tofriend_lbox').show();
      },
      onCleanup: function(){
        j('#tofriend_error').hide();
        j('#tofriend_lbox').hide();
      }
    });
  </g:javascript>
  </g:if>
    </g:each>
    </ul>
</g:if><g:else>
  <g:javascript>
    removeAllMarkers();
  </g:javascript>
  <g:each in="${data.records}" var="record" status="i">
    <g:javascript>
      addMarker(${record.x/100000},${record.y/100000},${record.is_local},"${record.ultrasmallpicture}","${record.firstname}",${record.age},${record.id});
    </g:javascript>
  </g:each>
  <g:javascript>
    addUmarkers();
  </g:javascript>
</g:else>
</div>
