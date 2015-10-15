<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>Административное приложение StayToday.ru</title>
    <meta name="layout" content="admin" />   
  </head>  
  <body>
  <g:if test="${flash?.error}">
    <div class="notice drop_shadow">
      <div class="button-glossy orange header form">
        <h1>Ошибки</h1>
      </div>
      <ul>
        <g:if test="${flash?.error==1}"><li>Вы не заполнили обязательное поле &laquo;Контроллер&raquo;</li></g:if>
        <g:if test="${flash?.error==2}"><li>Вы не заполнили обязательное поле &laquo;Экшен&raquo;</li></g:if>
        <g:if test="${flash?.error==3}"><li>Вы не заполнили обязательное поле &laquo;Название&raquo;</li></g:if>
      </ul>
    </div>
  </g:if>
  
    <div class="your-space drop_shadow" style="padding-top:10px">
      <div class="button-glossy green header form">
        <g:if test="${!inrequest?.type}">
        <h1>Добавление новой страницы</h1>
        </g:if><g:else>
        <h1>Добавление шаблона письма</h1>
        </g:else>
      </div>
      <g:form name="saveInfotextForm" url="[controller:'administrators',action:'saveinfotext']" method="POST" useToken="true">      
      <table width="100%" cellpadding="5" cellspacing="5" border="0">
<g:if test="${!inrequest?.type}">
        <tr>
          <td width="200">Шаблон меню</td>
          <td>
            <select id="itemplate_id" name="itemplate_id">
              <option value="0" <g:if test="${inrequest?.itemplate_id==0}">selected="selected"</g:if>>без шаблона</option>
              <g:each in="${itemplate}" var="item">            
              <option value="${item?.id}" <g:if test="${inrequest?.itemplate_id==item?.id}">selected="selected"</g:if>>
                ${item?.name}
              </option>
              </g:each>
            </select>
          </td>
        </tr>
        <tr>
          <td>Порядковый номер в меню</td>
          <td><input type="text" class="price" id="npage" name="npage" placeholder="0" value=""/></td>
        </tr>
        <tr>
          <td>Контроллер</td>
          <td><input type="text" id="tcontroller" name="tcontroller" value="" style="width:100%"/></td>
        </tr>
</g:if>
        <tr>
          <td>Экшен</td>
          <td><input type="text" id="taction" name="taction" value="" style="width:100%"/></td>
        </tr>
        <tr>
          <td>Название</td>
          <td><input type="text" id="name" name="name" value="" style="width:100%"/></td>
        </tr>
        <tr>
          <td colspan="2" align="right">            
            <input type="submit" class="button-glossy green" value="Добавить" style="margin-right:10px;"/>
            <input type="reset" class="button-glossy grey" onclick="javascript:history.back()" value="Отмена">
          </td>
        </tr>
      </table>
      <input type="hidden" id="type" name="type" value="${inrequest?.type?:0}" />
      </g:form>   
    </div>
  </body>
</html>
