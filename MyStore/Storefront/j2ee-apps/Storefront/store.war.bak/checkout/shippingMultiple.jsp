<%--
  This page includes the gadgets for the shipping page for multiple shipping groups.
  (That is, items may be shipped to different shipping addresses)
--%>

<dsp:page>
  <crs:pageContainer divId="atg_store_cart"
                     index="false" 
                     follow="false"
                     levelNeeded="SHIPPING"
                     redirectURL="../cart/cart.jsp"
                     bodyClass="atg_store_shippingMultiple atg_store_checkout atg_store_rightCol">
    <jsp:body>
      <dsp:include page="gadgets/shippingInitialize.jsp" flush="true">
        <dsp:param name="oneInfoPerUnit" value="true"/>
        <dsp:param name="initMultipleShippingForm" value="true"/>
      </dsp:include>
      
      <dsp:form id="atg_store_checkoutMultiShippingAddress" formid="atg_store_checkoutMultiShippingAddress"
              action="${pageContext.request.requestURI}" method="post">
        <dsp:param name="skipCouponFormDeclaration" value="true"/>
        <fmt:message key="checkout_title.checkout" var="title"/>
        <crs:checkoutContainer currentStage="shipping"
                               showOrderSummary="true" 
                               title="${title}">
          <jsp:attribute name="formErrorsRenderer">
            <dsp:importbean bean="/atg/commerce/order/purchase/ShippingGroupFormHandler"/>
            <dsp:importbean bean="/atg/store/order/purchase/CouponFormHandler"/>
            <fmt:message  var="submitText" key="checkout_shippingAddresses.button.shipToThisAddress"/>
            <dsp:include page="/checkout/gadgets/checkoutErrorMessages.jsp">
              <dsp:param name="formhandler" bean="ShippingGroupFormHandler"/>
              <dsp:param name="submitFieldText" value="${submitText}"/>
            </dsp:include>
          
            <dsp:include page="/checkout/gadgets/checkoutErrorMessages.jsp">
              <dsp:param name="formhandler" bean="CouponFormHandler"/>
              <dsp:param name="submitFieldText" value="${submitText}"/>
            </dsp:include>
          </jsp:attribute>
          <jsp:body>
            <div id="atg_store_checkout" class="atg_store_main">
              <dsp:include page="gadgets/shippingMultipleForm.jsp" flush="true"/>
            </div>
          </jsp:body>
        </crs:checkoutContainer>
      </dsp:form>
    </jsp:body>
  </crs:pageContainer>
</dsp:page>
<%-- @version $Id: //edu/ILT-Courses/main/COMM/StudentFiles/COM/setup/copy-files/apps/MyStore/Storefront/j2ee-apps/Storefront/store.war/checkout/shippingMultiple.jsp#3 $$Change: 635816 $--%>
