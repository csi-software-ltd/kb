<%@ page contentType="text/html;charset=UTF-8" %>

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
          <div id="desc_${i}" class="desc" style="width:230px">
            ${record?.ctext}
          </div>
        </li>
      </g:each>
      <g:if test="${controllerName=='personal' && actionName=='chatUpd'}">
        <div class="online">${online?(interlocutor?.nickname?:interlocutor?.firstname)+' сейчас онлайн':(interlocutor?.nickname?:interlocutor?.firstname)+' последний раз замечен'+(interlocutor?.gender_id==1?' ':'а ')+String.format("%td.%<tm.%<tY %<tH:%<tM",interlocutor?.lastdate)}</div>
      </g:if>
