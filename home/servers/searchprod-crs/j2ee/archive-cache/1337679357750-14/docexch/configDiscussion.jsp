<%@ taglib uri="/dsp" prefix="dsp" %>
<%@ taglib uri="/core-taglib" prefix="core" %>
<%@ taglib uri="/paf-taglib" prefix="paf" %>
<%@ taglib uri="/docexch-taglib" prefix="dex" %>
<%@ taglib uri="/jakarta-i18n-1.0" prefix="i18n" %>

<dsp:page>
<paf:InitializeGearEnvironment id="pafEnv">
<dex:DocExchPage id="dexpage" gearEnv="<%= pafEnv %>">
<dsp:importbean bean="/atg/portal/gear/docexch/DocExchConfigFormHandler"/>

<i18n:bundle baseName="<%= dexpage.getResourceBundle() %>" localeAttribute="userLocale" changeResponseLocale="false" />
<i18n:message id="finishButton" key="finishButton"/>
<i18n:message id="formTitle" key="configDiscussionFormTitle"/>
<i18n:message id="formInstructions" key="configDiscussionFormInstructions"/>

<dsp:form method="post" action="<%= pafEnv.getOriginalRequestURI() %>">

  <core:CreateUrl id="successUrl" url="<%= pafEnv.getOriginalRequestURI() %>">
    <core:UrlParam param="config_page" value="discussion"/>
    <core:UrlParam param="paf_gear_id" value="<%= pafEnv.getGear().getId() %>"/>
    <core:UrlParam param="paf_community_id" value='<%= request.getParameter("paf_community_id") %>'/>
    <core:UrlParam param="paf_page_id" value='<%= request.getParameter("paf_page_id") %>'/>
    <paf:encodeUrlParam param="paf_page_url" value='<%= request.getParameter("paf_page_url") %>'/>
    <core:UrlParam param="paf_dm" value="<%=pafEnv.getDisplayMode() %>"/>
    <core:UrlParam param="paf_gm" value="instanceConfig"/>
    <dsp:input type="hidden" bean="DocExchConfigFormHandler.successUrl" value="<%= successUrl.getNewUrl() %>"/>
  </core:CreateUrl>

  <%-- required parameters to get back to community settings --%>
  <input type="hidden" name="paf_community_id" value='<%= request.getParameter("paf_community_id") %>'/>
  <input type="hidden" name="paf_page_url" value='<%= request.getParameter("paf_page_url") %>'/>    
  <input type="hidden" name="paf_page_id" value='<%= request.getParameter("paf_page_id") %>'/>
  <input type="hidden" name="paf_dm" value="<%=pafEnv.getDisplayMode() %>"/>
  <input type="hidden" name="paf_gm" value="<%=pafEnv.getGearMode() %>"/>	  
  <input type="hidden" name="paf_gear_id" value="<%= pafEnv.getGear().getId() %>"/>
  <input type="hidden" name="config_page" value="discussion"/>
  
  <%-- These settings tell which parameters to set --%> 
  <dsp:input type="hidden" bean="DocExchConfigFormHandler.paramType" value="instance"/>
  <dsp:input type="hidden" bean="DocExchConfigFormHandler.settingDefaultValues" value="false"/>
  <dsp:setvalue bean="DocExchConfigFormHandler.paramNames" 
	        value="enableDiscussion"/>
  
  <%@ include file="configPageTitleBar.jspf" %>

  <!-- form table -->
  <table cellpadding="4" cellspacing="0" border="0" bgcolor="#BAD8EC" width="98%">
  <tr><td>
    <table cellpadding="1" cellspacing="0" border="0">

    <TR>
      <TD><font class="smaller"><i18n:message key="shouldUsersDiscussLabel"/></font></TD>
    </TR>
	
    <TR> 
      <TD width="75%"><font class="smaller"><br>
         <dsp:input type="radio"
               bean="DocExchConfigFormHandler.values.enableDiscussion" 
               value="true"/><i18n:message key="enableDiscussion"/>&nbsp;&nbsp;
         <dsp:input type="radio"
               bean="DocExchConfigFormHandler.values.enableDiscussion" 
               value="false"/><i18n:message key="disableDiscussion"/>&nbsp;&nbsp;&nbsp;
      </font></td>
    </TR>



    <TR>
      <TD colspan=2 ><img src='<%= dexpage.getRelativeUrl("/images/clear.gif") %>' height="10" width="1" border=0></TD>
    </TR>
    <TR VALIGN="top" ALIGN="left"> 

      <TD colspan=2>
        <dsp:input type="submit" value="<%= finishButton %>" bean="DocExchConfigFormHandler.confirm"/>
      </TD>
    </TR>
    <TR>
      <TD colspan=2><img src='<%= dexpage.getRelativeUrl("/images/clear.gif") %>' height=10 width=1 border=0></TD>
    </TR>
  </TABLE>
  
  </td></tr></table><br><br>

</dsp:form>
</dex:DocExchPage>
</paf:InitializeGearEnvironment>
</dsp:page>
<%-- @version $Id: //app/portal/version/10.0.3/docexch/docexch.war/configDiscussion.jsp#2 $$Change: 651448 $--%>
