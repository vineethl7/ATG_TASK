<!-- BEGIN FILE action_revert_site.jsp -->
<%@ taglib prefix="c"       uri="http://java.sun.com/jstl/core" %>
<%@ taglib prefix="fmt"     uri="http://java.sun.com/jstl/fmt" %>
<%@ taglib prefix="dspel"   uri="http://www.atg.com/taglibs/daf/dspjspELTaglib1_0" %>
<%@ taglib prefix="pws"     uri="http://www.atg.com/taglibs/pws" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<dspel:page>

<fmt:setBundle var="depBundle" basename="atg.epub.portlet.DeploymentPortlet.Resources"/>
<html>
<head>
	<dspel:include page='/includes/head.jsp' flush="false"/>
</head>
<body class="actionContent">
	<div id="confirmHeader"><h2>    <fmt:message key="confirmation" bundle="${depBundle}"/></h2></div>
<pws:getTargetDef targetId="${param.undelete_target_id}" var="targetDef"/>
<pws:getTarget targetId="${param.undelete_target_id}" var="targetPrimary"/>
	<div id="actionContent">
	<h3>    <fmt:message key="sure-revert-changes" bundle="${depBundle}"> 
                  <fmt:param value="${targetDef.displayName}"/></fmt:message></h3>
	</div>

	<div class="confirmOK">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
	<td width="100%">&nbsp;</td>
  <c:set var="undeleteFormId" value="undeleteTargetForm-${targetDef.ID}"/>
	<td class="buttonImage"><a href="javascript:parent.submitForm('<c:out value="${undeleteFormId}"/>');" class="mainContentButton go" onmouseover="status='';return true;">    <fmt:message key="ok" bundle="${depBundle}"/></a></td>		
	<td class="buttonImage"><a href="javascript:parent.showIframe('revertSiteAction')" class="mainContentButton delete" onmouseover="status='';return true;">    <fmt:message key="cancel" bundle="${depBundle}"/></a></td>		
	<td class="blankSpace"></td>
	</tr>
	</table>
	</div>
</body>
</html>
</dspel:page>
<!-- END FILE action_revert_site.jsp -->
<%-- @version $Id: //product/PubPortlet/version/10.0.3/portlets.war/html/DeploymentPortlet/config/iframes/action_revert_site.jsp#2 $$Change: 651448 $--%>
