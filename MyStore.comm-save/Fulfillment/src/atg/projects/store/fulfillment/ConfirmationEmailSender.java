/*<ATGCOPYRIGHT>
 * Copyright (C) 2006-2010 Art Technology Group, Inc.
 * All Rights Reserved.  No use, copying or distribution of this
 * work may be made except in accordance with a valid license
 * agreement from Art Technology Group.  This notice must be
 * included on all copies, modifications and derivatives of this
 * work.
 *
 * Art Technology Group (ATG) MAKES NO REPRESENTATIONS OR WARRANTIES
 * ABOUT THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ATG SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
 *
 * "Dynamo" is a trademark of Art Technology Group, Inc.
 </ATGCOPYRIGHT>*/
package atg.projects.store.fulfillment;

import atg.commerce.order.Order;

import atg.nucleus.GenericService;

import atg.projects.store.logging.LogUtils;

import atg.repository.RepositoryItem;

import atg.userprofiling.email.*;

import java.util.HashMap;
import java.util.Map;


/**
 * This class is responsible for sending order confirmation emails.
 * @author ATG
 */
public class ConfirmationEmailSender extends GenericService {

  /** Class version string. */
  public static String CLASS_VERSION = "$Id: //edu/ILT-Courses/main/COMM/StudentFiles/COM/setup/copy-files/apps/MyStore/Fulfillment/src/atg/projects/store/fulfillment/ConfirmationEmailSender.java#3 $$Change: 635816 $";

  /**
   * Order constant.
   */
  protected static final String ORDER = "order";

  /**
   * Message content processor.
   */
  protected MessageContentProcessor mContentProcessor;

  /**
   * Template e-mail sender.
   */
  protected TemplateEmailSender mTemplateEmailSender;

  /**
   * E-mail message sender address.
   */
  protected String mEmailMessageFrom;

  /**
   * E-mail message subject.
   */
  protected String mEmailMessageSubject;

  /**
   * Should fill from template.
   */
  protected boolean mFillFromTemplate = true;

  /**
   * @return the content processor.
   */
  public MessageContentProcessor getContentProcessor() {
    return mContentProcessor;
  }

  /**
   * @param pContentProcessor - content processor.
   */
  public void setContentProcessor(MessageContentProcessor pContentProcessor) {
    mContentProcessor = pContentProcessor;
  }

  /**
   * The template email sender to use to send the order confirm email.
   * @param pTemplateEmailSender - template e-mail sender
   */
  public void setTemplateEmailSender(TemplateEmailSender pTemplateEmailSender) {
    mTemplateEmailSender = pTemplateEmailSender;
  }

  /**
   * The template email sender used to send the order confirm email.
   * @return template e-mail sender
   */
  public TemplateEmailSender getTemplateEmailSender() {
    return mTemplateEmailSender;
  }

  /**
   * The email address to set the message from for the order confirm email.
   * @param pEmailMessageFrom - e-mail address sender
   */
  public void setEmailMessageFrom(String pEmailMessageFrom) {
    mEmailMessageFrom = pEmailMessageFrom;
  }

  /**
   * The email address to set the message from for the order confirm email.
   * @return e-mail message sender address
   */
  public String getEmailMessageFrom() {
    return mEmailMessageFrom;
  }

  /**
   * The subject to use for the order confirmation emails.
   * @param pEmailMessageSubject - e-mail message subject
   */
  public void setEmailMessageSubject(String pEmailMessageSubject) {
    mEmailMessageSubject = pEmailMessageSubject;
  }

  /**
   * The subject to use for the order confirmation emails.
   * @return e-mail message subject
   */
  public String getEmailMessageSubject() {
    return mEmailMessageSubject;
  }

  /**
   * @return true if we should try to extract email information from
   * the &lt;meta&gt; tags in the template.
   **/
  public boolean getFillFromTemplate() {
    return mFillFromTemplate;
  }

  /**
   * Sets the flag indicating whether we should try to extract email
   * information from the &lt;meta&gt; tags in the template.
   * @param pFillFromTemplate - true if should be filled, false - otherwise
   **/
  public void setFillFromTemplate(boolean pFillFromTemplate) {
    mFillFromTemplate = pFillFromTemplate;
  }

  /**
   * This method sends the order confirmation emails.
   * @param pOrder - order
   * @param pProfile - user profile
   * @param pTemplateUrl - template URL
   */
  public void sendConfirmationEmail(Order pOrder, RepositoryItem pProfile, String pTemplateUrl) {
    TemplateEmailSender tes = getTemplateEmailSender();
    String emailAddress = (String) pProfile.getPropertyValue(tes.getEmailAddressPropertyName());

    Object[] recipient = { pProfile };
    TemplateEmailInfo emailInfo = createTemplateEmailInfo(emailAddress, pTemplateUrl);

    Map params = new HashMap();
    params.put(ORDER, pOrder);
    emailInfo.setTemplateParameters(params);

    try {
      // set true to run in separate thread
      // set true to persist
      tes.sendEmailMessage(emailInfo, recipient, true, true);

      if (isLoggingDebug()) {
        logDebug("Sending order confirmation for order: " + pOrder.getId());
      }
    } catch (TemplateEmailException tee) {
      if (isLoggingError()) {
        logError(LogUtils.formatMajor("Error sending order confirmation email."), tee);
      }
    }
  }

  /**
   * Creates the template email info for the template we need to use
   * for order confirmation.
   *
   * @param pEmailTo - e-mail recipient address
   * @param pEmailTemplate - e-mail template
   * @return template e-mail information
   */
  protected TemplateEmailInfo createTemplateEmailInfo(String pEmailTo, String pEmailTemplate) {
    // make a copy of the default email info
    TemplateEmailInfoImpl emailInfo = new TemplateEmailInfoImpl();

    // set the template url
    emailInfo.setTemplateURL(pEmailTemplate);
    emailInfo.setMessageFrom(getEmailMessageFrom());
    emailInfo.setMessageTo(pEmailTo);
    emailInfo.setMessageSubject(getEmailMessageSubject());
    emailInfo.setContentProcessor(getContentProcessor());
    emailInfo.setFillFromTemplate(getFillFromTemplate());

    return emailInfo;
  }
}
