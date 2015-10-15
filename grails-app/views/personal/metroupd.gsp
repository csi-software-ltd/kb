<%@ page contentType="text/html;charset=UTF-8" %>


<g:if test="${metro}">
            <label for="metro_id">Метро</label>
            <select name="metro_id" id="metro_id" style="width:260px">
              <option value="0" <g:if test="${user?.metro_id==0}">selected="selected"</g:if>>Выберите метро</option>
              <g:each in="${metro}" var="item">
              <option value="${item?.id}" <g:if test="${user?.metro_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
              </g:each>
            </select>          
    <script type="text/javascript">
        jQuery('#metro_id').dropkick({
          change: function(){
            $(this).change();
          }
        });
        jQuery('#metro_id').dropkick("setValue", ${dValue?:0});
        for (var i=0; i<$('metro_id').length;i++){
          if ($('metro_id').options[i].value==${dValue?:0})
            $('metro_id').options[i].selected = true;
        }
    </script>
</g:if>

