<%@ taglib uri="dsp" prefix="dsp" %>
<dsp:page>

<dsp:importbean bean="/atg/userprofiling/Profile"/>
<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>
<dsp:importbean bean="/atg/dynamo/droplet/ForEach"/>
<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>
<dsp:importbean bean="/atg/dynamo/droplet/Compare"/>
<dsp:importbean bean="/atg/dynamo/droplet/IsEmpty"/>
<dsp:importbean bean="/atg/commerce/approval/ApprovalRequiredDroplet"/>

<%/*
  Display all the pending approvals of the given user.  ApprovalRequiredDroplet takes
  user id and state giving all the approvals for the user with the given state. Also
  the various output params of ApprovalRequiredDroplet are used to allow page navigation.
*/%>

<dsp:include page="../common/HeadBody.jsp"><dsp:param name="pagetitle" value=" Mein Konto"/></dsp:include>

<table border=0 cellpadding=0 cellspacing=0 width=800>
  <tr>
    <td colspan=2><dsp:include page="../common/BrandNav.jsp"></dsp:include></td>
  </tr>
  <tr bgcolor="#DBDBDB" > 
    <td colspan=2 height=18> &nbsp; <span class=small>
    <dsp:a href="my_account.jsp">Mein Konto</dsp:a> &gt;Bewilligungspflichtige Bestellungen
    </td>

    <tr valign=top> 
      <td width=55><img src="../images/d.gif" hspace=27></td>  
      <td valign="top" width=745>  
      <table border=0 cellpadding=4 width=80%>
        <tr><td><img src="../images/d.gif" vspace=0></td>
        </tr>

        <tr valign=top>
          <td colspan=2>
          <span class=big>Mein Konto</span></td>
        </tr>

        <tr><td><img src="../images/d.gif" vspace=0></td></tr>

        <tr>
          <td colspan=2><table width=100% cellpadding=3 cellspacing=0 border=0>
          <tr><td class=box-top>&nbsp;Bestellungen, die eine Bewilligung erfordern</td></tr></table></td>
        </tr>

        <tr>
          <td>
          <div align=center>
          <table border=0 width=100%>

            <%/* Pass profile id and state values to ApprovalRequiredDroplet to get all
              the orders*/%>
              
            <dsp:droplet name="ApprovalRequiredDroplet">
              <dsp:param bean="Profile.id" name="approverid"/>
              <dsp:param name="state" value="open"/>
              <dsp:param name="startIndex" param="startIndex"/>
              <dsp:oparam name="output">
                <tr valign=top>
                  <td width=33%><span class="small"><b>Bestellnr.</b></span></td>
                  <td width=33%><span class="small"><b>Bestelldatum</b></span></td>
                  <td width=33%><span class="small"><b>Status</b></span></td>
                </tr>
                <tr>
                 <td colspan=3><hr size=1 color="#666666"></td>
                </tr>
                <%/* Iterate through each order and display order info */%>

                <dsp:droplet name="ForEach">
                  <dsp:param name="array" param="result"/>
                  <dsp:oparam name="output">
                    <tr>
                      <td><dsp:a href="order_pending_approval.jsp">
                          <dsp:param name="orderId" param="element.id"/>
                          <dsp:valueof param="element.id"/></dsp:a>
                      </td>
                      <td><dsp:valueof date="MMMMM d, yyyy" param="element.submittedDate"/></td>
                      <td><dsp:valueof param="element.state"/></td>
                    </tr>
                  </dsp:oparam>
                  <dsp:oparam name="outputEnd">
                    <tr><td><br></td></tr>
                    <tr>
                      <td colspan=3>
                      <hr size=1 color="#666666">
                      <%/* see if paging thru results is necessary */%>
                      <dsp:droplet name="Compare">
                        <dsp:param name="obj1" param="totalCount"/>
                        <dsp:param name="obj2" bean="ApprovalRequiredDroplet.defaultNumOrders"/>
                      
                        <dsp:oparam name="default">
                          <dsp:droplet name="Switch">
                            <dsp:param name="value" param="totalCount"/> 
                            <dsp:oparam name="1"> 
                              There is 1 order requiring approval.
                            </dsp:oparam>
                            <dsp:oparam name="default">
                               There are <dsp:valueof param="totalCount"></dsp:valueof>
                               orders requiring approval.                        
                            </dsp:oparam>
                          </dsp:droplet>
                        </dsp:oparam>  

                        <%/* page through results if there are more than 10.*/%>
                        <dsp:oparam name="greaterthan">
                          Auftr�ge 
                          <dsp:valueof param="startRange"/> -
                          <dsp:valueof param="endRange"/> von
                          <dsp:valueof param="total_count"/> werden angezeigt
                         </td>
                         <td>
                           <dsp:droplet name="IsEmpty">
                             <dsp:param name="value" param="previousIndex"/>
                             <dsp:oparam name="false">
                               <dsp:a href="approvals.jsp">
                               <dsp:param name="startIndex" param="previousIndex"/>
                               Vorherige</dsp:a>
                             </dsp:oparam>
                           </dsp:droplet>
                           <dsp:droplet name="IsEmpty">
                             <dsp:param name="value" param="nextIndex"/>
                             <dsp:oparam name="false">
                               <dsp:a href="">
                                  <dsp:param name="startIndex" param="endRange"/>
                               N�chste</dsp:a>
                             </dsp:oparam>
                           </dsp:droplet>
                         </dsp:oparam> 
                       </dsp:droplet><%/* End Compare droplet */%>

                      </td>
                    </tr>
                  </dsp:oparam><%/* End outputEnd oparam of ForEach */%>
                </dsp:droplet><%/* End  ForEach Droplet */%>
              </dsp:oparam><%/* End output OPARAM of ApprovalRequiredDroplet */%>
              <dsp:oparam name="empty">
                <tr><td colspan=3>
                  Es gibt keine Bestellungen, die Ihre Bewilligung erfordern.
                  </td>
                </tr>
              </dsp:oparam>
              <dsp:oparam name="error">
                <dsp:valueof param="errorMsg"/>
              </dsp:oparam>
            </dsp:droplet><%/* End ApprovalRequiredDroplet droplet */%>
            <%/* End Printing out Each order to be approved */%>
           </table>
           </td>
         </tr>
       </div>
    </table>
    </td>
  </tr>

</table>

</body>
</html>
</dsp:page>
<%-- @version $Id: //product/B2BCommerce/version/10.0.3/release/MotorpriseJSP/j2ee-apps/motorprise/web-app/de/user/approvals.jsp#2 $$Change: 651448 $--%>
