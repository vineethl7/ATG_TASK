/*
 * <ATGCOPYRIGHT> Copyright (C) 1997-2011 Art Technology Group, Inc. All Rights
 * Reserved. No use, copying or distribution of this work may be made except in
 * accordance with a valid license agreement from Art Technology Group. This
 * notice must be included on all copies, modifications and derivatives of this
 * work. Art Technology Group (ATG) MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT
 * THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
 * LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 * PARTICULAR PURPOSE, OR NON-INFRINGEMENT. ATG SHALL NOT BE LIABLE FOR ANY
 * DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING
 * THIS SOFTWARE OR ITS DERIVATIVES. "Dynamo" is a trademark of Art Technology
 * Group, Inc. </ATGCOPYRIGHT>
 */

package atg.sqljmsadmin;

import java.rmi.RemoteException;
import java.util.Collection;

import javax.ejb.EJBHome;
import javax.ejb.FinderException;

/****************************************
 * The home interface for the DMSClient entity bean.
 * 
 * @author Stephen Abramson <stephena@atg.com>
 * @version $Id:
 *          //product/DAS/main/release/SQLJMSAdmin/j2ee-apps/sqlJmsAdmin/ejbModule
 *          /atg/sqljmsadmin/DMSClientHome.java#8 $$Change: 651448 $
 * @updated $DateTime: 2011/06/07 13:55:45 $$Author: rbarbier $
 ****************************************/

public interface DMSClientHome extends EJBHome {
  // ----------------------------------------
  /** Class version string */
  public static String CLASS_VERSION = "$Id: //product/DAS/version/10.0.3/release/SQLJMSAdmin/j2ee-apps/sqlJmsAdmin/ejbModule/atg/sqljmsadmin/DMSClientHome.java#2 $$Change: 651448 $";

  // ----------------------------------------
  /**
   * find all the clients
   */
  public Collection findAll() throws FinderException, RemoteException,
      DMSAdminException;

  // ----------------------------------------
  /**
   * find by primary key
   */
  public DMSClient findByPrimaryKey(String pPrimaryKey) throws FinderException,
      RemoteException, DMSAdminException;

  // ----------------------------------------
  /**
   * find by client id
   */
  public DMSClient findByClientId(Long pClientId) throws FinderException,
      RemoteException, DMSAdminException;

  // ----------------------------------------
  /**
   * find by queue
   */
  public Collection findByQueue(Long pQueueId, Long pClientId)
      throws FinderException, RemoteException, DMSAdminException;

} // end of class

