<%@ taglib uri="dsp" prefix="dsp" %>
<%@ page contentType="text/html; charset=Shift_JIS" %>
<dsp:page>

<dsp:importbean bean="/atg/dynamo/droplet/Switch"/>
<dsp:importbean bean="/atg/dynamo/droplet/ForEach"/>

<declareparam name="order"
class="atg.commerce.order.Order"
description="the current order">


<dsp:droplet name="ForEach">
  <dsp:param name="array" param="order.paymentGroups"/>
  <dsp:param name="elementName" value="pGroup"/>
  <dsp:oparam name="output">
    <dsp:droplet name="Switch">
      <dsp:param name="value" param="pGroup.paymentMethod"/>
      <dsp:oparam name="giftCertificate">
      </dsp:oparam>
      <dsp:oparam name="creditCard">
        <tr valign=top>
          <td></td>
              <td align=right><span class=smallb>�x�������@
              <dsp:valueof param="count"/></span></td>
              <td width=75%><dsp:valueof param="pGroup.creditCardType"/>
              <dsp:valueof converter="creditcard" param="pGroup.creditCardNumber"/></td>
        </tr>
        <tr valign=top>
          <td></td>
              <td align=right><span class=smallb>���z</span></td>
              <td width=75%>
              <dsp:getvalueof id="pval0" param="pGroup.amount"><dsp:include page="../common/DisplayCurrencyType.jsp"><dsp:param name="currency" value="<%=pval0%>"/></dsp:include></dsp:getvalueof>
          </td>
        </tr>
        
        <tr><td><dsp:img src="../images/d.gif" vspace="0"/></td></tr>
        <tr valign=top>
          <td></td>
              <td align=right><span class=smallb>������Z��</span></td>
              <td width=75%>
							<dsp:getvalueof id="pval0" param="pGroup.billingAddress"><dsp:include page="../common/DisplayAddress.jsp"><dsp:param name="address" value="<%=pval0%>"/></dsp:include></dsp:getvalueof>

          </td>
        </tr>
        <dsp:droplet name="ForEach">
          <dsp:param name="array" param="pGroup.CommerceItemRelationships"/>
          <dsp:param name="elementName" value="CiRel"/>
          <dsp:oparam name="outputStart">
            <tr>
            <td></td>
            <td align=right><span class=smallb>�A�C�e��</span></td>
            <td>
          </dsp:oparam>
          <dsp:oparam name="output">
            <dsp:valueof param="CiRel.quantity"/>
            <dsp:valueof param="CiRel.commerceItem.auxiliaryData.productRef.displayName"/>
            <br>
          </dsp:oparam>
          <dsp:oparam name="outputEnd">
            </td>
            </tr>
          </dsp:oparam>
        </dsp:droplet>

  </dsp:oparam>
  <dsp:oparam name="invoiceRequest">
    <tr><td><dsp:img src="../images/d.gif" vspace="0"/></td></tr>
    <tr valign=top>
      <td></td>
          <td align=right><span class=smallb>�x�������@
          <dsp:valueof param="count"/></span></td>
          <dsp:droplet name="IsEmpty">
            <dsp:param name="value" param="pGroup.PONumber"/>
            <dsp:oparam name="false">
              <td width=75%>�����ԍ� &nbsp;<dsp:valueof param="pGroup.PONumber"/>&nbsp;</td>
            </dsp:oparam>
            <dsp:oparam name="true">
              <td width=75%>�����ԍ�&nbsp;<dsp:valueof param="pGroup.requisitionNumber"/>&nbsp;</td>
            </dsp:oparam>
          </dsp:droplet>
    </tr>
        <tr valign=top>
          <td></td>
              <td align=right><span class=smallb>���z</span></td>
              <td width=75%>
              <dsp:getvalueof id="pval0" param="pGroup.amount"><dsp:include page="../common/DisplayCurrencyType.jsp"><dsp:param name="currency" value="<%=pval0%>"/></dsp:include></dsp:getvalueof>
              </td>
        </tr>

    <tr valign=top>
      <td></td>
          <td align=right><span class=smallb>������Z��</span></td>
          <td width=75%>

          <dsp:getvalueof id="pval0" param="pGroup.billingAddress"><dsp:include page="../common/DisplayAddress.jsp"><dsp:param name="address" value="<%=pval0%>"/></dsp:include></dsp:getvalueof>
      </td>
    </tr>
        <dsp:droplet name="ForEach">
          <dsp:param name="array" param="pGroup.CommerceItemRelationships"/>
          <dsp:param name="elementName" value="CiRel"/>
          <dsp:oparam name="outputStart">
            <tr>
            <td></td>
            <td align=right><span class=smallb>�A�C�e��</span></td>
            <td>
          </dsp:oparam>
          <dsp:oparam name="output">
            <dsp:valueof param="CiRel.quantity"/>
            <dsp:valueof param="CiRel.commerceItem.auxiliaryData.productRef.displayName"/>
            <br>
          </dsp:oparam>
          <dsp:oparam name="outputEnd">
            </td>
            </tr>
          </dsp:oparam>
          </dsp:droplet>

</dsp:oparam>
</dsp:droplet><%/*Switch*/%>
</dsp:oparam>
</dsp:droplet><%/*ForEach*/%>

</dsp:page>
<%-- @version $Id: //product/B2BCommerce/version/10.0.3/release/MotorpriseJSP/j2ee-apps/motorprise/web-app/ja/checkout/pmtGroupWithLineItems.jsp#2 $$Change: 651448 $--%>
