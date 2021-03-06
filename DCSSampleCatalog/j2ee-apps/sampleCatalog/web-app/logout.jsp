<%@ taglib uri="/dspTaglib" prefix="dsp" %>
<dsp:page>

<HTML>
<HEAD>
<TITLE>Logout</TITLE>
</HEAD>

<dsp:importbean bean="/atg/userprofiling/Profile"/>
<dsp:importbean bean="/atg/userprofiling/ProfileFormHandler"/>
<dsp:importbean bean="/atg/userprofiling/ProfileErrorMessageForEach"/>
<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>


<BODY>
<dsp:a href="index.jsp">Catalog Home</dsp:a> - 
<dsp:a href="product_search.jsp">Product Search</dsp:a> - 
<dsp:a href="shoppingcart.jsp">Shopping Cart</dsp:a> - 
<dsp:a href="lists.jsp">My Lists</dsp:a> - 
<dsp:a href="comparison.jsp">Product Comparison</dsp:a> -
<dsp:a href="giftlist_search.jsp">Gift List Search</dsp:a> - 
<dsp:droplet name="Switch">
  <dsp:param bean="Profile.transient" name="value"/>
  <dsp:oparam name="false">
    Logout
  </dsp:oparam>
  <dsp:oparam name="true">
    <dsp:a href="login.jsp">Login</dsp:a> or <dsp:a href="register.jsp">Register</dsp:a>
  </dsp:oparam>
</dsp:droplet>
<BR>

<dsp:form action="logout.jsp" method="POST">
<dsp:input bean="ProfileFormHandler.logoutSuccessURL" type="HIDDEN" value="index.jsp"/>

<strong><font size=+1>
<dsp:droplet name="Switch">
<dsp:param bean="Profile.transient" name="value"/>
<dsp:oparam name="false">
  Thank you for visiting <dsp:valueof bean="Profile.Login"/>
</dsp:oparam>
<dsp:oparam name="default">
  Thank you for visiting!
</dsp:oparam>
</dsp:droplet>
</font></strong>
<BR>Click on the button below to logout.<P>

<dsp:droplet name="Switch">
<dsp:param bean="ProfileFormHandler.formError" name="value"/>
<dsp:oparam name="true">
  <font color=cc0000><STRONG><UL>
    <dsp:droplet name="ProfileErrorMessageForEach">
      <dsp:param bean="ProfileFormHandler.formExceptions" name="exceptions"/>
      <dsp:oparam name="output">
	<LI> <dsp:valueof param="message"/>
      </dsp:oparam>
    </dsp:droplet>
    </UL></STRONG></font>
</dsp:oparam>
</dsp:droplet>

<dsp:input bean="ProfileFormHandler.logout" type="SUBMIT" value="logout"/>

</dsp:form>

</BODY>
</HTML>


</dsp:page>
<%-- @version $Id: //product/DCS/version/10.0.3/release/DCSSampleCatalog/j2ee-apps/sampleCatalog/web-app/logout.jsp#2 $$Change: 651448 $--%>
