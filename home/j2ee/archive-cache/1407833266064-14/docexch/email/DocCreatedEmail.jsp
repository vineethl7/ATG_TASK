<%@ taglib uri="/dsp" prefix="dsp" %>
<%@ taglib uri="/jakarta-i18n-1.0" prefix="i18n" %>

<dsp:page>

<i18n:bundle baseName="atg.portal.gear.docexch.email_template" 
             localeAttribute="userLocale" changeResponseLocale="false" />

<i18n:message id="title"            key="EMAIL_HTML_TITLE"  />
<i18n:message id="emailSubject"     key="SUBJECT_NEW_EVENT"  />
<i18n:message id="emailSubject2"    key="SUBJECT_DOC_ADDED" />
<i18n:message id="emailMailingName" key="EMAIL_NOTICE_NAME"  />
<i18n:message id="fromEmail"        key="FROM_ADDRESS"       />
<i18n:message id="replyEmail"       key="REPLY_TO_ADDRESS"   />

<dsp:setvalue param="messageSubject"      value='<%= emailSubject + " " + emailSubject2 %>' />
<dsp:setvalue param="messageFrom"         value="<%= fromEmail %>"/>
<dsp:setvalue param="messageReplyTo"      value="<%= replyEmail %>"/>
<dsp:setvalue param="mailingName"         value="<%= emailMailingName %>"/>

<dsp:getvalueof id="docName"     param="alertMsg.documentName">
<dsp:getvalueof id="commName"    param="alertMsg.communityName">
<dsp:getvalueof id="authorName"  param="alertMsg.authorName">

<HTML><HEAD><TITLE><%= title %></TITLE></HEAD>

<BODY BGCOLOR="#FFFFFF">

<h3><i18n:message  key="BODY_HEADER_ADDED"/></h3>

 <i18n:message  key="BODY_CONTENT_ADDED">
  <i18n:messageArg value="<%=docName %>"   />
  <i18n:messageArg value="<%=commName%>" />
  <i18n:messageArg value="<%=authorName%>" />
 </i18n:message>

<br /><br /><br />

<font color="#666666" size="-1">
<i18n:message  key="BODY_FOOTER_EVENT"/><br />
</font>

</BODY> </HTML>


</dsp:getvalueof><%-- authorName  --%>
</dsp:getvalueof><%-- commName  --%>
</dsp:getvalueof><%-- docName --%>

</dsp:page>
<%-- @version $Id: //app/portal/version/10.0.3/docexch/docexch.war/email/DocCreatedEmail.jsp#2 $$Change: 651448 $--%>
