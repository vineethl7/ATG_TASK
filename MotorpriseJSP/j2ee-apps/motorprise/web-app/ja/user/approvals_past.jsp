<%@ taglib uri="dsp" prefix="dsp" %>
<%@ page contentType="text/html; charset=Shift_JIS" %>
<dsp:page>

<dsp:importbean bean="/atg/userprofiling/Profile"/>
<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>
<dsp:importbean bean="/atg/dynamo/droplet/ForEach"/>
<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>
<dsp:importbean bean="/atg/dynamo/droplet/IsEmpty"/>
<dsp:importbean bean="/atg/dynamo/droplet/Compare"/>
<dsp:importbean bean="/atg/commerce/approval/ApprovedDroplet"/>

<%/*
  Displays all the orders that has been approved by the approver in the
  past. Uses ApprovedDroplet to display orders approved passing profileId as
  input param. Also uses various output params of ApprovedDroplet to provide
  page navigation.
*/%>


<dsp:include page="../common/HeadBody.jsp"><dsp:param name="pagetitle" value="私のアカウント"/></dsp:include>

<table border=0 cellpadding=0 cellspacing=0 width=800>
  <tr>
    <td colspan=2><dsp:include page="../common/BrandNav.jsp"></dsp:include></td>
  </tr>
  <tr bgcolor="#DBDBDB" > 
    <td colspan=2 height=18> &nbsp; <span class=small>
    <dsp:a href="my_account.jsp">私のアカウント</dsp:a> &gt; 承認待ちのオーダー
    </td>

    <tr valign=top> 
      <td width=55><img src="../images/d.gif" hspace=27></td>  
      <td valign="top" width=745>  
      <table border=0 cellpadding=4 width=80%>
      <tr><td><img src="../images/d.gif" vspace=0></td>
      </tr>

      <tr valign=top>
        <td colspan=2>
        <span class=big>私のアカウント</span></td>
      </tr>

      <tr><td><img src="../images/d.gif" vspace=0></td></tr>

      <tr>
        <td colspan=2><table width=100% cellpadding=3 cellspacing=0 border=0>
        <tr><td class=box-top>&nbsp;解決済み承認要求</td></tr></table></td>
      </tr>
      <tr>
        <td>
        <div align=center>
        <table border=0 width=100%>
          <%/*Get all the orders that have been approved inthe past by this user */%>
          <dsp:droplet name="ApprovedDroplet">
            <dsp:param bean="Profile.id" name="approverid"/>
            <dsp:param name="startIndex" param="startIndex"/>
            <dsp:oparam name="output">
              <tr valign=top>
              <td width=33%><span class="small"><b>オーダー番号</b></span></td>
              <td width=33%><span class="small"><b>オーダーした日</b></span></td>
              <td width=33%><span class="small"><b>ステータス</b></span></td>
              </tr>
              <tr>
               <td colspan=3><hr size=1 color="#666666"></td>
              </tr>

              <%/*Iterate through the orders displaying info about the orders */%>
              <dsp:droplet name="ForEach">
                <dsp:param name="array" param="result"/>

                <dsp:oparam name="output">
                  <tr>
                    <td><dsp:a href="order.jsp">
                        <dsp:param name="orderId" param="element.id"/>
                        <dsp:valueof param="element.id"/></dsp:a>
                    </td>
                    <td><dsp:valueof date="yyyy'年' MM'月' dd'日'" param="element.submittedDate"/></td>
                    <td><dsp:valueof param="element.state"/></td>
                  </tr>
                </dsp:oparam> <%/* End output of ForEach oparam*/%>

                <dsp:oparam name="outputEnd">
                  <tr>
                    <td colspan=3>
                      <hr size=1 color="#666666">


                      <%/* see if paging thru results is necessary */%>
                      <dsp:droplet name="Compare">
                        <dsp:param name="obj1" param="totalCount"/>
                        <dsp:param name="obj2" bean="ApprovedDroplet.defaultNumOrders"/>
                      
                        <dsp:oparam name="default">
                          <dsp:droplet name="Switch">
                            <dsp:param name="value" param="totalCount"/> 
                            <dsp:oparam name="1"> 
                              解決済みの承認要求が１件あります。
                            </dsp:oparam>
                            <dsp:oparam name="default">
                               解決済みの承認要求が <dsp:valueof param="totalCount"></dsp:valueof> 件あります。
                            </dsp:oparam>
                          </dsp:droplet>
                        </dsp:oparam>  

                        <%/* page through results if there are more than 10.*/%>
                        <dsp:oparam name="greaterthan">
                          次のオーダーの一部
                          <dsp:valueof param="startRange"></dsp:valueof> - 
                          <dsp:valueof param="endRange"></dsp:valueof>を表示しています。
                          <dsp:valueof param="totalCount"></dsp:valueof>

                          &nbsp; &nbsp;
                          <dsp:droplet name="IsEmpty">
                            <dsp:param name="value" param="previousIndex"/>
                            <dsp:oparam name="false">
                              <dsp:a href="approvals_past.jsp">
                                <dsp:param name="startIndex" param="previousIndex"/>
                                &lt;&lt;戻る</dsp:a>
                            </dsp:oparam>
                          </dsp:droplet>
                          <dsp:droplet name="IsEmpty">
                            <dsp:param name="value" param="nextIndex"/>
                            <dsp:oparam name="false">
                              <dsp:a href="">
                                <dsp:param name="startIndex" param="endRange"/>
                                次へ&gt;&gt;</dsp:a>
                            </dsp:oparam>
                          </dsp:droplet>
                        </dsp:oparam> 
                      </dsp:droplet><%/* End Compare droplet */%>


                    </td>
                  </tr>
                </dsp:oparam><%/* End outputEnd of ForEach */%>
              </dsp:droplet><%/* End ForEach Droplet*/%>
            </dsp:oparam><%/* End output oparam of ApprovedDroplet*/%>

            <dsp:oparam name="empty">
              <tr><td colspan=3>
                解決済みの承認要求はありません。
                </td>
              </tr>
            </dsp:oparam>

            <dsp:oparam name="error">
              <dsp:valueof param="errorMsg"/>
            </dsp:oparam>
          </dsp:droplet>  <%/* End Printing out Each order to be approved */%>
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
<%-- @version $Id: //product/B2BCommerce/version/10.0.3/release/MotorpriseJSP/j2ee-apps/motorprise/web-app/ja/user/approvals_past.jsp#2 $$Change: 651448 $--%>
