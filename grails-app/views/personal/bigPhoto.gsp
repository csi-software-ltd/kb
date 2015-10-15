<g:if test="${photo}">
<table class="photoSnowPopup" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td class="photo_container" style="width:900px;height:600px">
      <img id="tets" onload="jQuery.colorbox.resize();" src="${photo.is_local?imageurl:''}${photo.is_local?'o_'+photo.picture:photo.picture}" border="0" />
    </td>
    <td class="comments_container">
      <div class="info">
      <g:if test="${user && photo.is_tender==curTenderId}">
        <fieldset id="ratingFormSet${photo.id}" style="display:${alreadyVoting?'none':'block'}">
          <legend>Оцените фото:</legend>
          <g:formRemote name="ratingForm" url="[controller: 'index', action: 'tenderRatingPhoto']" onSuccess="ratingPhotoResponse(e,${photo.id})">
            <div class="dialog dk_toggle" align="center">
              <span class="rlink">
                <a href="javascript:void(0);" onclick="reduceRating(${photo.id})">-</a>
              </span>
              <b class="select" style="line-height:32px;width:20px;margin:0 6px">5</b>
              <span class="rlink">
                <a href="javascript:void(0);" onclick="increaseRating(${photo.id})">+</a>
              </span>
            </div>
            <div class="col">
              <input type="submit" id="chat_submit_button" value="${message(code:'button.send')}" />
            </div>
            <input type="hidden" name="user_id" value="${tendmember?.user_id}"/>
            <input id="ratingValue${photo.id}" type="hidden" name="rating" value="5"/>
          </g:formRemote>
        </fieldset>
        <fieldset id="ratingSet${photo.id}" style="height:72px;display:${alreadyVoting?'block':'none'}">
          <legend>Рейтинг фото:</legend>
          <span class="select">
            <h1>${tendmember?.overall_rating?:0}</h1>
          </span><br/>
        </fieldset>
      </g:if>      
        <div id="scrollarea" style="width:285px;height:200px;overflow-y:auto;border:1px solid #e2e2e2">
          <ul class="list" style="height:200px">
          <g:each in="${comments.records}" var="record" status="i">
            <li id="commli_${record.id}" onmouseout="this.removeClassName('selected')" onmouseover="this.addClassName('selected')">
              <div class="actions col" style="display:${(user?.id==photo.user_id)?'block':'none'}">
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
              <div class="desc">${record?.comtext}</div>
            </li>
          </g:each>
          <g:if test="${comments?.count > 5 }">
            <div class="seemore">
              <a href="javascript:void(0)" onclick="$('oldCommentsFormSubmitButton').click()">Смотреть ещё</a>
              <g:formRemote name="oldCommentsForm" url="[action: 'oldercomments', id:photo.id]" onSuccess="oldCommentsResponse(e)">
                <input type="hidden" name="offset" value="5"/>
                <input id="oldCommentsFormSubmitButton" type="submit" style="display:none"/>
              </g:formRemote>
            </div>
          </g:if>
          </ul>
        </div>      
      <g:if test="${user && maycomment}">
        <fieldset>
          <legend>Оставить комментарий:</legend>
          <g:formRemote name="commentAddForm" url="[controller: 'personal', action: 'addnewPhotoComment']" onSuccess="newCommentsResponse(e)">
            <ul class="list">
              <li>
                <div class="desc" style="margin:0;width:100%">
                  <textarea id="newcommentstext" name="comtext"></textarea>
                </div>
              </li>
            </ul>
            <div style="float:left;margin-top:20px">
              <input type="submit" id="chat_submit_button" value="${message(code:'button.send')}" />
            </div>
            <input type="hidden" name="photo_id" value="${photo?.id}"/>
          </g:formRemote>
        </fieldset>
      </g:if>
      </div>
    </td>
  </tr>  
</table>
</g:if><g:else>
  <h1>Фото не найдено!</h1>
</g:else>
