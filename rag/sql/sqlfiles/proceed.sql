USE [TranToro]
GO
/****** Object:  StoredProcedure [dbo].[spams_s_rept_uvis_proceeds]    Script Date: 3/22/2025 5:46:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
--SET ANSI_NULLS ON
--GO

ALTER PROCEDURE [dbo].[spams_s_rept_uvis_proceeds] ( @sale_dt           SMALLDATETIME,
                                              @tran_account_list   VARCHAR (20),
                                              @sale_type_id     SMALLINT      = NULL,
                                              @sale_type_id_2   SMALLINT      = NULL,
                                              @sale_dt_to           SMALLDATETIME = NULL, --Tracker 22711
                                              @select_type INT,
                                              @select_parm FLOAT,
                                              @vin_sale_line_id FLOAT = NULL,
                                              @SearchAsOwner        CHAR(1) = 'Y',
                                              @SearchAsRemarketer   CHAR(1) = 'N',
                                              @RemarketingIdList    VARCHAR(MAX) = NULL,
                                              @OrgProgramIdList     VARCHAR(MAX) = NULL)


WITH RECOMPILE AS

BEGIN
/*************************************************************************************/
/*  Created By:    Mark Bare/Kris Cook                                               */
/*  Creation Date: 06/04/2002                                                        */
/*  Purpose:       Tracker 13812 - Required report for Ford (UVIS Rewrite)           */
/*                 (Auction Proceeds).  Used only for Canadian auctions.             */
/*  Parameters:    @sale_dt          - sale date                                     */
/*                 @tran_account_id  - transmission account                          */
/*                 @sale_type_id     - sale type (Ford or FMCC)     */
/*                 @sale_dt_2        - second sale date (for FMCC)                   */
/*                 @sale_type_id_2   - second sale type (for FMCC)                   */
/*************************************************************************************/
-- Modified By: Aaron Christian
-- Modified On: 04/07/2016
-- DR Number:   DR 242255
-- Purpose:     Modifications for 3PR Project 3
/*************************************************************************************/
-- Modified By:  Martin Godin
-- Modify Date:  06/26/2015
-- Version:      DR 216044
-- Reason:       Added  @select_type, @select_parm,  @vin_sale_line_id parameters
/*************************************************************************************/
/* Modified By: Chad Gilezan                                                         */
/* Date: 02/21/2013                                                           */
/* Version:     AMS5.48.00                                                           */
/* Reason: DR 133445 - CML/CMR Category Code Changes.             */
/*************************************************************************************/
/* Modified By: Anju Bhattrai             */
/* Date: 01/12/2010     */
/* Version: AMS5.14.0     */
/* Reason: DR 56030 - removed logic to look at ARS     */
/*************************************************************************************/
/* Modified By: Ela Duraisamy */
/* Date: 06/01/2009 */
/* Version: AMS5.9.00     */
/* Reason: DR 36481 : Merged the Auction Proceeds Data Form for Ford, Ford Credit   */
/*          Mazda, Primus & Jaguar */
/*************************************************************************************/
/* Modified By: Anju Bhattrai             */
/* Date: 06/26/2008     */
/* Version: AMS5.3.03     */
/* Reason: DR 23918 - Added Car History Fee     */
/*************************************************************************************/
/* Modified By: Anju Bhattrai             */
/* Date: 05/23/2008     */
/* Version: AMS5.3.01     */
/* Reason: DR 22346 - Added ARS vehicles     */
/*************************************************************************************/
/* Modified By: Anju Bhattrai             */
/* Date: 02/08/2008     */
/* Version: AMS5.2.90     */
/* Reason: DR 19114 - Added Added Volvo     */
/*************************************************************************************/
/* Modified By: Chad Gilezan             */
/* Date: 07/12/2006     */
/* Version: AMS5.2.71     */
/* Reason: DR 1410 - Added COP category code group for FMCC & PRIMUS.           */
/*************************************************************************************/
/* Modified By: Chad Gilezan             */
/* Date: 12/08/2005     */
/* Version: AMS5.2.64     */
/* Reason: Tracker 25767 - Added MIS category code group for Ford and added     */
/* MIS & CML category code groups for FMCC.     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 03/16/2005     */
/* Version: AMS5.2.54     */
/* Reason: Tracker 24013 - Added Primus to get signature plans                  */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 08/12/2004     */
/* Version: AMS5.2.46     */
/* Reason: Tracker 22711 - Added code for retrieve cars with passed sale type   */
/*                    offering code.                                                 */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 07/23/2004     */
/* Version: AMS5.2     */
/* Reason: Tracker 22595 - Added Ford CSV (002) to this report     */
/* Added Primus (014) MIS and UNK to this report     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 07/21/2004     */
/* Version: AMS5.2     */
/* Reason: Tracker 22567 - Added Primus (014) to use this report     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 07/20/2004     */
/* Version: AMS5.2.46     */
/* Reason: Tracker 22549 - Added tran_type 295,297,299,301 Void taxes to be     */
/* included on report     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 05/03/2004     */
/* Version: AMS5.2.43     */
/* Reason: Tracker 21203 - Removed MIS and COP codes from report     */
/*************************************************************************************/
/* Modified By: Chad Gilezan             */
/* Date: 04/15/2004     */
/* Version: AMS5.2.43     */
/* Reason: Tracker 15379 - Fixed vehicles so they do not reflect previously     */
/* closed charges         */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 01/08/2004     */
/* Version: AMS5.2     */
/* Reason: Tracker 21132 - Removed tran_acct_list from arguments and instead    */
/* now use @tran_account_id since Volvo is not used anymore.     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 01/06/2004     */
/* Version: AMS5.2     */
/* Reason: Tracker 21154 - Filter out cutomer codes (3,4,9,11,13) when getting  */
/* the total count and amount.           */
/*************************************************************************************/
/* Modified By: Shri Bharathan             */
/* Date: 01/05/2004     */
/* Version: AMS5.2.37     */
/* Reason: Tracker 21112 - Removed Sale Type Filter ( 2,18)                     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 12/19/2003     */
/* Version: AMS5.2     */
/* Reason: Tracker 20811 - Fixed canadian taxes so report prints correctly      */
/* changed 'Buyer fee' in where to tran_type = 208     */
/*************************************************************************************/
/* Modified By: Brad Miller             */
/* Date: 11/13/2003     */
/* Version: AMS5.2     */
/* Reason: Tracker 20811 - Removed second sale date     */
/* added Dealer block to get buyer fee     */
/*************************************************************************************/
/* Modified By: Chad Gilezan             */
/* Date: 09/22/2003     */
/* Version: AMS5.1     */
/* Reason: Tracker 20255 - Added Trustmark Buyer's Fee.     */
/*************************************************************************************/
/* Modified By: Chad Gilezan             */
/* Date: 08/13/2003     */
/* Version: AMS5.2     */
/* Reason: Tracker 19770 - Added tran account list parameter to match USA.     */
/*************************************************************************************/
/* Modified By: Lance Tillman                                     */
/* Modify Date: 7/10/2003                                                            */
/* Version:     5.2                                                                 */
/* Reason:      Tracker 19303. Needed to check for nulls when concatenating gts      */
/*              strings 8 - 10.     */
/*************************************************************************************/
/* Modified By: Lance Tillman             */
/* Date: 06/06/03     */
/* Version: AMS5.2     */
/* Reason: Tracker 18565 - gts_vehicle needed more space.  Added       */
/* three more gts columns.     */
/*************************************************************************************/
/* Modified by:    Mark Bare / Kris Cook                                             */
/* Modified date:  10/29/2002                                                        */
/* Version:        52.4                                                              */
/* Purpose:        Tracker 16074 - Error in calculating QST buyer fee tax amount.    */
/*************************************************************************************/
/* Modified by:    Mark Bare / Kris Cook                                             */
/* Modified date:  09/16/2002                                                        */
/* Purpose:        Tracker 15527 - Error because IN was not used on a sub-select.    */
/*************************************************************************************/
/* Modified by:    Lance Tillman                                                     */
/* Modified date:  09/10/2002                                                        */
/* Purpose:        Tracker 15376 - Remove vehicles with invalid transaction accounts */
/*                 and customer code combinations.                     */
/*************************************************************************************/
/* Modified by:    Jenifer Brimmer                                                   */
/* Modified date:  08/19/2002                                                        */
/* Purpose:        Tracker 15062 - Remove vehicles with invalid category program     */
/*                 code/customer code combinations.                     */
/*************************************************************************************/
/*  Modified By:   Jenifer Brimmer                                                   */
/*  Creation Date: 08/12/2002                                                        */
/*  Version:       51.5                                                              */
/*  Tracker:       14915                                                             */
/*                 Remove US calculations and return values since this version of    */
/*   the stored procedure will only be used for Canada.                */
/*************************************************************************************/
/*  Modified By:   Kris Cook                                                         */
/*  Creation Date: 06/14/2002                                                        */
/*  Version:       51.2                                                              */
/*  Tracker:       14539                                                             */
/*                 - Correct typo leading to misaccumulation of totals.              */
/*************************************************************************************/
/*  Modified By:   Kris Cook                                                         */
/*  Creation Date: 06/05/2002                                                        */
/*  Version:       51.1                                                              */
/*  Tracker:       13812                                                             */
/*                 - Correct NULL value in proceeds calculation to $0.               */
/*                 - Change report name to 'UVIS Auction Proceeds Data Form' for     */
/*                   pulling report_id.                                              */
/*************************************************************************************/
-- tran_account_id values:
--    5  Ford
--    6  FMCC
--   20 Ford fmcc                       -- Obselete for new UVIS
--   21 Ford Credit fmcc                -- Obselete for new UVIS

SET NOCOUNT ON

DECLARE @co_id                TINYINT,
        @co_name              VARCHAR(50),
        @country              VARCHAR(30),
        @auction_code         VARCHAR(3),
        @inventory_id         FLOAT,
        @buy_fee_cnt          INT,
        @buy_fee_amt          MONEY,
        @buy_fee_TM_cnt       INT, -- Tracker #20255
        @buy_fee_TM_amt       MONEY, -- Tracker #20255
        @gst_tax_cnt          INT,
        @gst_tax_seller_amt   MONEY,
        @gst_tax_buyer_amt    MONEY,
        @gst_tax_for_one_amt  MONEY,
        @gst_tax_buyfee_amt   MONEY,
        @gst_tax_buyfee_tot   MONEY,
        @gst_tax_amt          MONEY,
        @pst_tax_cnt          INT,
        @pst_tax_seller_amt   MONEY,
        @pst_tax_buyer_amt    MONEY,
        @pst_tax_for_one_amt  MONEY,
        @pst_tax_buyfee_amt   MONEY,
        @pst_tax_buyfee_tot   MONEY,
        @pst_tax_amt          MONEY,
        @total_amt            MONEY,
        @proc_flr_exp         MONEY,
        @proc_flr_sale        MONEY,
        @proc_flr_buyer_fee   MONEY,
        @proceeds_floor       MONEY,
        @proc_dir_exp         MONEY,
        @proc_dir_sale        MONEY,
        @proceeds_direct      MONEY,
        @proc_eft_exp         MONEY,
        @proc_eft_sale        MONEY,
        @proceeds_eft         MONEY,
        @frac_exp             MONEY,
        @frac_sale            MONEY,
        @frac_cnt             INT,          -- Count of vehicles paid for by frac
        @frac_tot             MONEY,        -- @frac_sale + @frac_expense
        @signature_cnt        INT,          -- Count of vehicles paid for by signature plan
        @total_net            MONEY,        -- Proceeds distribution total for right hand side of report
        @total_units_sold     INT,          -- Total number of vehicles sold
        @ach_check            INT,          -- variable to check pay_types in ownership
        @rsk_check            INT,          -- If RSK cat program code pay_type has to be check
        @ars_cnt              INT,
        @ars_amt              MONEY,
        @ars_net              MONEY,
        @ars_tot              MONEY,
        @trd_cnt              INT,
        @trd_amt              MONEY,
        @trd_net              MONEY,
        @trd_tot              MONEY,
        @veh_id               FLOAT,
        @own_dtm              DATETIME,
        @org_id               INT,
        @buying_cust_id       INT,
        @cash_type_dsc        VARCHAR(35),  -- 9045 - round two
        @sale_id              INT,
        @str_report_id        VARCHAR (10),
        @cml_cnt              INT,
        @cml_amt              MONEY,        -- tracker 10696
        @cml_net              MONEY,
        @cml_tot              MONEY,        -- tracker 10696
        @afr_amc_cnt          INT,          -- tracker 10011
        @afr_amc_net          MONEY,        -- tracker 10011
        @afr_amc_amt          MONEY,        -- tracker 12183
        @afr_amc_tot          MONEY,        -- tracker 12183
        @contact_name         VARCHAR(50),
        @fax_number           VARCHAR(50),  -- tracker 13203
        @trade_net            MONEY,
        @trade_cnt            INT,          -- Tracker 13524
        @trade_tot            MONEY,
        @trade_amt            MONEY,        -- Tracker 13524
        @DEBUG_FLG            INTEGER,
        @report_id            INTEGER,
        @ford_cnt_accum       INT,  @ford_net_accum   MONEY,
        @mazda_cnt_accum      INT,  @mazda_net_accum  MONEY,
        @fairlane_cnt_accum   INT, @fairlane_net_accum MONEY,
        @jaguar_cnt_accum      INT,  @jaguar_net_accum MONEY,
        @primus_cnt_accum      INT,  @primus_net_accum MONEY,
        @volvo_cnt_accum       INT,  @volvo_net_accum  MONEY,
        @fmcc_cnt_accum        INT,  @fmcc_net_accum   MONEY,
        @proceeds_floor_primus MONEY,
        @signature_primus_cnt  INT,          -- Tracker #24013 - Count of vehicles paid for by PRIMUS signature plan
        @car_hist_fee_cnt      INT,        --DR 23918 added car_history fee
        @car_hist_fee_amt      MONEY,      --DR 23918 added car_history fee
@gst_tax_car_history_amt    MONEY, --DR 23918
        @gst_tax_one_carhist_amt    MONEY,
        @gst_tax_car_hist_amt       MONEY,
        @gst_tax_car_hist_tot       MONEY,
@pst_tax_car_history_amt    MONEY,
@pst_tax_one_carhist_amt    MONEY,
        @pst_tax_car_hist_amt        MONEY,
        @pst_tax_car_hist_tot        MONEY,
@dlen             INT,
    @slen             INT,
    @elen             INT,
    @tran_list_temp   VARCHAR(255),
@tran_acct_id  INT,
        @int_select_parm      INT   -- DR 242255

--SELECT @DEBUG_FLG = 1
SELECT @DEBUG_FLG = 0

--  Tracker 13706 Temp table to hold gts layout
CREATE TABLE #layout (col_nm         VARCHAR (30)     NOT NULL,                
                      start_pos      INT              NOT NULL,
                      length         INT              NOT NULL,
                      table_id       FLOAT            NOT NULL)

CREATE TABLE #table  (table_id       FLOAT            NOT NULL)

CREATE TABLE #tran_account_id  (tran_account_id       SMALLINT  NULL)

--SET ANSI_PADDING ON

--  Tracker 13706 Temp table to hold gts_data
CREATE TABLE #gts_data (gts_string        CHAR (2550) NOT NULL,    -- tracker 19303 increased to 2550                    
                        table_id          FLOAT       NOT NULL,
                        ID                FLOAT       NOT NULL)
SET ANSI_PADDING OFF

-- Create temp table to hold report_id of this report

CREATE TABLE #veh_det(sale_id              INT           NOT NULL,
                      veh_id               FLOAT         NOT NULL,
                      org_id               INT           NOT NULL,
                      buying_cust_id       integer       NULL,
                      inventory_id         FLOAT         NOT NULL,
                      own_dtm              DATETIME      NOT NULL,
                      sale_line_id         FLOAT         NOT NULL,
     block_dtm   DATETIME NULL,       --Tracker 15379
                      sale_amt             MONEY         NOT NULL,
                      cat_program          VARCHAR(10)   NULL,
                      cash_type_dsc        VARCHAR(35)   NOT NULL,
                      proceeds             VARCHAR(35)   NULL,
                      flr_sig_amt          MONEY         NULL,
                      flr_frac_amt         MONEY         NULL,
                      cust_code            INT            NULL,
                      tran_account_id      SMALLINT      NULL,
                      sale_type_id         SMALLINT      NULL,
                      remarketing_id       INT           NULL,
                      org_program_id       INT           NULL)

        -- Temp table to hold necessary gl_detail data
        -- Tracker 9005 - Adding 'orig_gl_event_id' and 'orig_gl_id', so can associate the tax for
        -- the fees in the "Buyer Fee" fee report grouping.
        -- Tracker 9045 - Adding 'orig_tran_type' to help in connecting taxes for 3rd Party Fee between
        -- the seller and the buyer

CREATE TABLE #temp_gl_detail(gl_event_id       FLOAT         NOT NULL,
                             gl_id             SMALLINT      NOT NULL,
                             org_id            INT           NOT NULL,
                             veh_id            FLOAT         NOT NULL,
                             own_dtm           DATETIME      NOT NULL,
                             sale_dt           SMALLDATETIME NULL,
                             gl_amt            MONEY         NULL,
                             fee_group         VARCHAR(40)   NULL,        -- tracker 10613 - changed to NULL from NOT NULL
                             cat_program       VARCHAR(10)   NULL,
                             tran_type         SMALLINT      NOT NULL,
                             orig_gl_event_id  FLOAT         NULL,
                             orig_gl_id        SMALLINT      NULL,
                             orig_tran_type    SMALLINT      NULL,
                             gl_acct_abbrev_nm VARCHAR (12)  NULL,
                             cust_code         INT           NULL)         -- Tracker 5681

CREATE TABLE #temp_flr_plan_sig(veh_id         FLOAT         NOT NULL,
                                own_dtm        DATETIME      NOT NULL,
                                flr_amt        MONEY         NULL)

-- Tracker #24013 - Added for Signature Primus Floor Plans
CREATE TABLE #temp_flr_plan_sig_primus(veh_id  FLOAT         NOT NULL,
                                own_dtm        DATETIME      NOT NULL,
                                flr_amt        MONEY         NULL)

CREATE TABLE #temp_flr_plan_frac(veh_id        FLOAT         NOT NULL,
                                own_dtm        DATETIME      NOT NULL,
                                flr_amt        MONEY         NULL)

-- Get valid sales for given tran account id within date range for tran_account_id
CREATE TABLE #valid_sales (sale_id INT NOT NULL,
            sale_type_id    SMALLINT   NOT NULL
)

-- get co_id for auction
SELECT @co_id = CONVERT (TINYINT, system_option_cd)
  FROM system_option WITH (NOLOCK)
 WHERE system_option_nm = "AuctionCoId"

-- get auction name
SELECT @co_name = (SELECT co_nm
                     FROM company WITH (NOLOCK)
                    WHERE co_id = @co_id)

        -- get auction's country
        -- Tracker 8783 - Needed when checking for requirements that are different for the Canadian
        -- Tracker 1793 - Since the auction can now have multiple addresses had to change where the
        -- address was stored.  So no longer in the 'company' table, but in the 'address' table.

SELECT @country = (SELECT country
                     FROM address WITH (NOLOCK)
                    WHERE co_id = @co_id
                      AND UPPER(address_type) = 'STREET')

-- DR 216044 - Get list of all tran accounts
INSERT INTO #tran_account_id (tran_account_id)
   (SELECT DISTINCT item FROM dbo.fn_parse_delimited_list_as_integer(@tran_account_list,'#'))

-- Getting uvis_location code out of GTS

EXEC spams_s_gts_parse_data 5, 5, @co_id, 'uvis_location_code', @auction_code OUTPUT

-- Select report_id
SELECT @report_id = report_id FROM report WITH (NOLOCK) WHERE report_name = 'UVIS Auction Proceeds Data Form'

--Tracker 22711 - If there is a date range for internet
IF @sale_dt_to = @sale_dt
        --  Get valid sale for the 1st sale type
        INSERT INTO #valid_sales(sale_id, sale_type_id)
        SELECT DISTINCT s.sale_id, s.sale_type_id
        FROM sale s WITH (NOLOCK)
        JOIN transmission_account_sale_type ta WITH (NOLOCK) ON s.sale_type_id = ta.sale_type_id
        JOIN #tran_account_id t ON ta.tran_account_id = t.tran_account_id
        WHERE s.sale_dt = @sale_dt AND s.sale_type_id = @sale_type_id
ELSE
        INSERT INTO #valid_sales(sale_id, sale_type_id)
        SELECT DISTINCT s.sale_id, s.sale_type_id
        FROM sale s WITH (NOLOCK)
        JOIN transmission_account_sale_type ta WITH (NOLOCK) ON s.sale_type_id = ta.sale_type_id
        JOIN #tran_account_id t ON ta.tran_account_id = t.tran_account_id
        WHERE s.sale_dt BETWEEN @sale_dt AND @sale_dt_to AND s.sale_type_id = @sale_type_id

-- Tracker 7536  - Added getting valid sales for given tran account id (6 - FMCC Tran Account
-- ID) within date range
IF @sale_type_id_2 = null
   SET @sale_type_id_2 = 0

-- Get valid sale for the 2nd sale type if possible
IF @sale_type_id <> @sale_type_id_2 AND @sale_type_id_2 > 0
BEGIN
        IF @sale_dt_to = @sale_dt  --Tracker 22711 - If there is a date range for internet  
                INSERT INTO #valid_sales(sale_id, sale_type_id)
                SELECT DISTINCT s.sale_id, s.sale_type_id
                FROM sale s WITH (NOLOCK)
                JOIN transmission_account_sale_type ta WITH (NOLOCK) ON s.sale_type_id = ta.sale_type_id
                JOIN #tran_account_id t ON ta.tran_account_id = t.tran_account_id
                WHERE s.sale_dt = @sale_dt AND s.sale_type_id = @sale_type_id_2
        ELSE
                INSERT INTO #valid_sales(sale_id, sale_type_id)
                SELECT DISTINCT s.sale_id, s.sale_type_id
                FROM sale s WITH (NOLOCK)
                JOIN transmission_account_sale_type ta WITH (NOLOCK) ON s.sale_type_id = ta.sale_type_id
                JOIN #tran_account_id t ON ta.tran_account_id = t.tran_account_id
                WHERE s.sale_dt BETWEEN @sale_dt AND @sale_dt_to AND s.sale_type_id = @sale_type_id_2
END

IF @DEBUG_FLG = 1
BEGIN
    SELECT * FROM #valid_sales
END

CREATE INDEX valid_sales_id ON #valid_sales (sale_id)

        -- Get vehicle data, for sold vehicles (event = 3), with passed tran account,
        -- and making sure we get the latest information in block_activity for a given sale_line_id *

INSERT INTO #veh_det(
    sale_id,
    inventory_id,
    veh_id,
    org_id,
    buying_cust_id,
    own_dtm,
    sale_line_id,
    block_dtm,
    sale_amt,
    cash_type_dsc,
    proceeds,
    tran_account_id,
    sale_type_id,
    remarketing_id,
    org_program_id
)
SELECT
    ba.sale_id,
    slo.inventory_id,
    slo.veh_id,
    slo.selling_owner_id,
    ba.buying_cust_id,
    slo.own_dtm,
    slo.sale_line_id,
    ba.block_dtm,
    ba.last_bid_amt,
    ct.cash_type_dsc,
    ct.cash_type_dsc,
    own.tran_account_id,
    vs.sale_type_id,
    own.remarketing_id,
    own.org_program_id
FROM block_activity ba WITH (NOLOCK)
JOIN sale_lineup_order slo WITH (NOLOCK) ON ba.sale_line_id = slo.sale_line_id
JOIN #valid_sales vs On ba.sale_id = vs.sale_id AND slo.sale_id = vs.sale_id
JOIN ownership own WITH (NOLOCK) ON slo.veh_id = own.veh_id AND slo.own_dtm = own.own_dtm
JOIN #tran_account_id tid ON own.tran_account_id = tid.tran_account_id
JOIN cash_type ct WITH (NOLOCK) ON own.pay_type = ct.cash_type
WHERE ba.event = 3

         -- Indexes for temp tables
CREATE INDEX inv_id1 ON #veh_det (inventory_id, veh_id, own_dtm)
CREATE INDEX veh_id1 ON #veh_det (veh_id, own_dtm, org_id)
CREATE INDEX org_id1 ON #veh_det (org_id, veh_id, own_dtm)

--------------------------------------------------------------
-- DR 216044: Remove unwanted record based on Search By Criteria
--------------------------------------------------------------
IF @select_type = 1 -- One Customer (DR 242255)
BEGIN
    SET @int_select_parm = CONVERT(INT, @select_parm)

    IF @SearchAsOwner = 'Y' AND @SearchAsRemarketer = 'Y'
        IF ISNULL(@OrgProgramIdList, '') <> ''
            DELETE r
            FROM #veh_det r
            WHERE (r.org_id <> @int_select_parm
                OR r.org_program_id IS NULL
                OR r.org_program_id NOT IN (
                    SELECT item
                    FROM dbo.fn_parse_delimited_list_as_integer(@OrgProgramIdList, ',')))
                AND @int_select_parm NOT IN (
                    SELECT tpr.remarketer_org_id
                    FROM organization_remarketing tpr WITH (NOLOCK)
                    WHERE r.remarketing_id = tpr.remarketing_id)
        ELSE
            DELETE r
            FROM #veh_det r
            WHERE r.org_id <> @int_select_parm AND @int_select_parm NOT IN (
                SELECT tpr.remarketer_org_id
                FROM organization_remarketing tpr WITH (NOLOCK)
                WHERE r.remarketing_id = tpr.remarketing_id)

    ELSE IF @SearchAsRemarketer = 'Y'
        DELETE r
        FROM #veh_det r
        WHERE @int_select_parm NOT IN (
            SELECT tpr.remarketer_org_id
            FROM organization_remarketing tpr WITH (NOLOCK)
            WHERE r.remarketing_id = tpr.remarketing_id)

    ELSE
        IF ISNULL(@OrgProgramIdList, '') <> ''
            DELETE #veh_det
            WHERE org_id <> @int_select_parm
            OR org_program_id IS NULL
            OR org_program_id NOT IN (
                SELECT item
                FROM dbo.fn_parse_delimited_list_as_integer(@OrgProgramIdList, ','))
        ELSE
            DELETE #veh_det
            WHERE org_id <> @int_select_parm
END
ELSE IF @select_type = 2 -- Customer Group
   DELETE #veh_det
 FROM #veh_det r
 WHERE NOT EXISTS (SELECT 1 FROM org_group og WITH (NOLOCK)
     WHERE og.org_id = r.org_id
           AND og.group_id =  CONVERT (INT, @select_parm))
ELSE IF @select_type = 3 --Customer Type
      DELETE #veh_det
        FROM #veh_det r
    WHERE NOT EXISTS (SELECT 1 FROM organization o WITH (NOLOCK)
        WHERE o.org_id = r.org_id
              AND o.org_type_id =  CONVERT (TINYINT, @select_parm) )
ELSE IF @select_type = 4 -- Vehicle is selected
DELETE #veh_det
    WHERE veh_id <> @select_parm
      AND sale_line_id <> @vin_sale_line_id
ELSE IF @select_type = 6 -- TPR (DR 242255)
    DELETE #veh_det
    WHERE remarketing_id IS NULL OR remarketing_id NOT IN (
        SELECT item
        FROM dbo.fn_parse_delimited_list_as_integer(@RemarketingIdList, ','))
-----------------------------------------------------------------------------




        -- Tracker 6967 - Category program change
--
EXEC ("
UPDATE #veh_det
   SET cat_program = cp.cat_prog_cd
  FROM #veh_det  vd,
        category_program cp WITH (NOLOCK)
 WHERE vd.inventory_id = cp.inventory_id
   AND vd.veh_id       = cp.veh_id
   AND vd.own_dtm      = cp.own_dtm")


INSERT INTO #table
     SELECT DISTINCT gtst.table_id
       FROM gts_vehicle     gtsv    WITH (NOLOCK),
            gts_table       gtst    WITH (NOLOCK),
            gts_entity      gtse    WITH (NOLOCK),
            #veh_det vd      WITH (NOLOCK),
#tran_account_id tid
      WHERE gtst.tran_account_id = tid.tran_account_id -- @tran_account_id         --  passed Tran Account ID
        AND gtse.gts_entity_id   = 1                        --  vehicle entity_id
        AND gtse.gts_entity_id   = gtst.gts_entity_id
        AND gtst.table_id        = gtsv.table_id
        AND gtst.current_flg     = 'Y'
        AND gtsv.inventory_id    = vd.inventory_id

INSERT INTO #layout                                    -- Tracker 13706 get non-intransit vehicles layout
     SELECT DISTINCT gc.col_nm, gtc.start_pos, gc.length, gtc.table_id
       FROM gts_table_column gtc WITH (NOLOCK),
            gts_column       gc  WITH (NOLOCK),
            #table           t
      WHERE gtc.col_id   = gc.col_id
        AND gtc.table_id = t.table_id

-- tracker 19303 added gts_strings 7, 8, 9, & 10
INSERT INTO #gts_data                                  -- Tracker 13706 get non-intransit vehicle data
     SELECT SUBSTRING(gtsv.gts_string_1, 1, DATALENGTH (gts_string_1)) + REPLICATE (' ', 255 - DATALENGTH (gts_string_1)) +
            SUBSTRING(gtsv.gts_string_2, 1, DATALENGTH (gts_string_2)) + REPLICATE (' ', 255 - DATALENGTH (gts_string_2)) +
            SUBSTRING(gtsv.gts_string_3, 1, DATALENGTH (gts_string_3)) + REPLICATE (' ', 255 - DATALENGTH (gts_string_3)) +
            SUBSTRING(gtsv.gts_string_4, 1, DATALENGTH (gts_string_4)) + REPLICATE (' ', 255 - DATALENGTH (gts_string_4)) +
            SUBSTRING(gtsv.gts_string_5, 1, DATALENGTH (gts_string_5)) + REPLICATE (' ', 255 - DATALENGTH (gts_string_5)) +
            gtsv.gts_string_6 + gtsv.gts_string_7 + gtsv.gts_string_8 + gtsv.gts_string_9 + gtsv.gts_string_10,
            gtsv.table_id,
            gtsv.inventory_id
       FROM gts_vehicle    gtsv    WITH (NOLOCK),
            gts_table      gtst    WITH (NOLOCK),
            gts_entity     gtse    WITH (NOLOCK),
            #veh_det       vd      WITH (NOLOCK)          
      WHERE gtst.tran_account_id = vd.tran_account_id -- @tran_account_id
        AND gtse.gts_entity_id   = 1                                --  GTS vehicle identity_id
        AND gtse.gts_entity_id   = gtst.gts_entity_id
        AND gtst.table_id        = gtsv.table_id
        AND gtst.current_flg     = 'Y'
        AND gtsv.inventory_id    = vd.inventory_id

UPDATE #veh_det
   SET cust_code = CONVERT (INT, SUBSTRING(ISNULL(RTRIM(LTRIM(SUBSTRING(gtd.gts_string, l.start_pos, l.length))), ''), 1, 3))
  FROM  #layout         l,
        #gts_data       gtd
 WHERE #veh_det.inventory_id = gtd.id
   AND l.table_id                   = gtd.table_id
   AND l.col_nm IN ('uvis_customer_code')        --  GTS column name

-- Tracker 15062 - Remove vehicles with invalid category program codes/customer code combinations
Delete From #veh_det
where tran_account_id = 5
    and cat_program NOT IN ('REP','CSV','MIS')  --TRACKER 21203, 25767
    and cust_code = 2

Delete From #veh_det
where tran_account_id = 6
    and cat_program NOT IN ('RCT','RTR','RCR','MIS','CML','COP','CMR')  --TRACKER 21203, 25767, DR 1410, DR 133445
    and cust_code = 8

-- Delete invalid vehicles for the Primus tran account and invalid category codes
Delete From #veh_det
Where tran_account_id = 8
    AND cat_program NOT IN ('COP', 'RCR', 'RCT', 'RTR', 'MIS', 'UNK')

--DR 19114 --Added Volvo
Delete From #veh_det
where tran_account_id = 39
    AND cat_program NOT IN ('REP','CSV','MIS', 'UNK')  
    AND cust_code = 15

-- Get all fees except the third party buyer fee 208 and car history fee 504 for AP & AR
INSERT INTO #temp_gl_detail(gl_event_id,
                            gl_id,
                            org_id,
                            veh_id,
                            own_dtm,
                            sale_dt,
                            gl_amt,
                            fee_group,
                            cat_program,
                            tran_type,
                            orig_gl_event_id,
                            orig_gl_id,
                            orig_tran_type,
                            gl_acct_abbrev_nm,
                            cust_code)
                     SELECT gd.gl_event_id,
                            gd.gl_id,
                            gd.org_id,
                            gd.veh_id,
                            gd.own_dtm,
                            gd.sale_dt,
                            gd.gl_amt,
                            fg.report_group_identifier,
                            vd.cat_program,
                            gd.tran_type,
                            NULL,
                            NULL,
                            NULL,
                            gd.gl_acct_abbrev_nm,
                            vd.cust_code
                       FROM gl_detail             gd WITH (NOLOCK),
                            #veh_det       vd,
                            fee_grouping_report_v fg WITH (NOLOCK),
                            gl_status             gs WITH (NOLOCK)
                      WHERE gd.org_id                   = vd.org_id
                        AND gd.veh_id                   = vd.veh_id
                        AND gd.own_dtm                  = vd.own_dtm
                        AND gs.status                  <> 'V'
                        AND gs.gl_valid_dtm             = (SELECT MAX(gl_valid_dtm)
                                                             FROM gl_status gs_in WITH (NOLOCK)
                                                            WHERE gs_in.gl_event_id = gs.gl_event_id
                                                              AND gs_in.gl_id       = gs.gl_id)
                        AND gs.gl_event_id              = gd.gl_event_id
                        AND gs.gl_id                    = gd.gl_id
                        AND gd.gl_acct_abbrev_nm        in ( 'AR Customer', 'AP Customer' )
                        AND fg.tran_type                = gd.tran_type
                        AND fg.tran_account_id          = vd.tran_account_id
                        AND fg.report_id                = @report_id
AND gd.tran_type not in (208, 504)
AND ( gs.status <> 'C' OR (gs.status = 'C' AND gs.gl_valid_dtm > vd.block_dtm))  --Tracker 15379
            UNION ALL

-- Get tax on third party buyer fee for AP & AR
                     SELECT gdt.gl_event_id,
                            gdt.gl_id,
                            gdt.org_id,
                            gdt.veh_id,
                            gdt.own_dtm,
                            gdt.sale_dt,
                            gdt.gl_amt,
                            fg.report_group_identifier,
                            vd.cat_program,
                            gdt.tran_type,
                            gdt.orig_gl_event_id,
                            gdt.orig_gl_id,
                            NULL,
                            gdt.gl_acct_abbrev_nm,
                            vd.cust_code
                       FROM gl_detail_tax         gdt WITH (NOLOCK),
                            #veh_det       vd,
                            fee_grouping_report_v fg WITH (NOLOCK),
                            gl_tax_status         gts WITH (NOLOCK)
                      WHERE gdt.org_id                  = vd.org_id
                        AND gdt.veh_id                  = vd.veh_id
                        AND gdt.own_dtm                 = vd.own_dtm
                        AND gts.status                 <> 'V'
                        AND gts.gl_valid_dtm            = (SELECT MAX(gl_valid_dtm)
                                                             FROM gl_tax_status gts_in WITH (NOLOCK)
                                                            WHERE gts_in.gl_event_id = gts.gl_event_id
                                                              AND gts_in.gl_id       = gts.gl_id)
                        AND gts.gl_event_id             = gdt.gl_event_id
                        AND gts.gl_id                   = gdt.gl_id
                        AND gdt.gl_acct_abbrev_nm       in ( 'AR Customer', 'AP Customer' )
                        AND fg.tran_type                = gdt.tran_type
                        AND fg.tran_account_id          = vd.tran_account_id
                        AND fg.report_id                = @report_id
AND gdt.tran_type in (208, 504)
AND ( gts.status <> 'C' OR (gts.status = 'C' AND gts.gl_valid_dtm > vd.block_dtm))  --Tracker 15379



-- Get gl_detail data for PASS Thru taxes, fee_group_id = 57 (GST ADJUSTED TAX) and
-- 58 (QST ADJUSTED TAX)  
-- Tracker 8783 - round two - GST/HST Pass Thru transactions aren't retrieved because for
-- Ford (seller) the charges are put against "AP Customer" and not "AR Customer".  So need
-- to retrieve the taxes that are in the "AP Customer" account.
-- Tracker 9005 - Adding 'orig_gl_event_id' and 'orig_gl_id', so can associate the tax for
-- the fees in the "Buyer Fee" fee report grouping.
-- Tracker 9045 - Adding 'orig_tran_type'

--Calculating GST & QST taxes
--  GST - 294 GST/HST Payable
-- - 298 GST/HST Pass thru
--  QST - 296 PST/TVQ Payable
-- - 300 PST/TVQ Pass Thru
INSERT INTO #temp_gl_detail(gl_event_id,
                            gl_id,
                            org_id,
                            veh_id,
                            own_dtm,
                            sale_dt,
                            gl_amt,
                            fee_group,
                            cat_program,
                            tran_type,
                            orig_gl_event_id,
                            orig_gl_id,
                            orig_tran_type,
                            gl_acct_abbrev_nm,
                            cust_code)
                     SELECT gdt.gl_event_id,
                            gdt.gl_id,
                            gdt.org_id,
                            gdt.veh_id,
                            gdt.own_dtm,
                            gdt.sale_dt,
                            gdt.gl_amt,
                            fg.report_group_identifier,
                            vd.cat_program,
                            gdt.tran_type,
                            gdt.orig_gl_event_id,
                            gdt.orig_gl_id,
                            NULL,
                            gdt.gl_acct_abbrev_nm,
                            vd.cust_code
                       FROM gl_detail_tax         gdt WITH (NOLOCK)
                            INNER JOIN #veh_det       vd ON gdt.org_id             = vd.org_id
 AND gdt.veh_id             = vd.veh_id
 AND gdt.own_dtm            = vd.own_dtm
                            INNER JOIN fee_grouping_report_v fg WITH (NOLOCK) ON gdt.tran_type = fg.tran_type
                            INNER JOIN gl_tax_status           gts WITH (NOLOCK) ON gdt.gl_event_id = gts.gl_event_id
  AND gdt.gl_id     = gts.gl_id
                      WHERE gts.gl_valid_dtm       = (SELECT MAX(gl_valid_dtm)
                                                        FROM gl_tax_status gts_in WITH (NOLOCK)
                                                       WHERE gts_in.gl_event_id = gts.gl_event_id
                                                         AND gts_in.gl_id       = gts.gl_id)
                        AND gdt.gl_acct_abbrev_nm  in ( 'AR Customer', 'AP Customer' )
                        AND fg.tran_account_id     = vd.tran_account_id
                        AND fg.report_id           = @report_id
AND gdt.tran_type   in ( 294, 295, 296, 297, 298, 299, 300, 301 )  --Tracker 22549
AND ( gts.status <> 'C' OR (gts.status = 'C' AND gts.gl_valid_dtm > vd.block_dtm))  --Tracker 15379


        -- Get gl_detail data
        -- Tracker 5681 - Add the buyer fee
        -- Tracker 6999 - using fee_grouping_report_v
        -- Tracker 9005 - Adding 'orig_gl_event_id' and 'orig_gl_id', so can associate the tax for
        -- the fees in the "Buyer Fee" fee report grouping.
        -- Tracker 9045 - Adding 'orig_tran_type'


--Get Buyer Fee and car history fee charged to AR & AP
INSERT INTO #temp_gl_detail (gl_event_id,
                             gl_id,
                             org_id,
                             veh_id,
                             own_dtm,
                             sale_dt,
                             gl_amt,
                             fee_group,
                             cat_program,
                             tran_type,
                             orig_gl_event_id,
                             orig_gl_id,
                             orig_tran_type,
                             gl_acct_abbrev_nm,
                             cust_code)
                         SELECT gd.gl_event_id,
                             gd.gl_id,
                             gd.org_id,
                             gd.veh_id,
                             gd.own_dtm,
                             gd.sale_dt,
                             gd.gl_amt,
                             fg.report_group_identifier,
                             vd.cat_program,
                             gd.tran_type,
                             NULL,
                             NULL,
                             NULL,
                             gd.gl_acct_abbrev_nm,
                             vd.cust_code
                           FROM gl_detail             gd WITH (NOLOCK),
                                #veh_det       vd,
                                fee_grouping_report_v fg WITH (NOLOCK),
                                transaction_type      tt WITH (NOLOCK),        
                                gl_status             gs WITH (NOLOCK)
                          WHERE gd.org_id                  = vd.buying_cust_id
                            AND gd.veh_id                  = vd.veh_id
                            AND gd.own_dtm                 = vd.own_dtm
                            AND gs.status                   <> 'V'
                            AND gs.gl_valid_dtm            = (SELECT MAX(gl_valid_dtm)
                                                                FROM gl_status gs_in WITH (NOLOCK)
                                                               WHERE gs_in.gl_event_id = gs.gl_event_id
                                                                 AND gs_in.gl_id       = gs.gl_id)
                            AND gs.gl_event_id             = gd.gl_event_id
                            AND gs.gl_id                   = gd.gl_id
                            AND gd.gl_acct_abbrev_nm       in ( 'AR Customer', 'AP Customer' )
                            AND gd.tran_type                    = tt.tran_type
                            AND tt.pymt_flg                    <> 'Y'
                            AND fg.tran_type               = gd.tran_type
                            AND fg.tran_account_id         = vd.tran_account_id
                            AND fg.report_id               = @report_id
   AND gd.tran_type   in (208, 504) --DR 23918 added 504
   AND ( gs.status <> 'C' OR (gs.status = 'C' AND gs.gl_valid_dtm > vd.block_dtm))  --Tracker 15379


        -- Tracker 9005 - Wasn't returning the taxes for fees in the "Buyer Fee" fee grouping with the
        -- "UNION ALL" with the above statement because there are no tran_types in the 'gl_detail_tax'
        -- table that are in the "Buyer Fee" fee grouping.  So removed the "UNION ALL" and created a
        -- "SELECT" statement that will retrieve the taxes only if they are "pass thru" taxes, because
        -- those are the only taxes that are owed to the seller and should be paid by "EFT".
        -- Tracker 9045 - Adding 'orig_tran_type'

        -- Tracker 16073 Slight modification of Julie's comment above.  Quebec needed a non-pass thru added for QST.

-- Get Tax on the buyer fee
INSERT INTO #temp_gl_detail (gl_event_id,
                             gl_id,
                             org_id,
                             veh_id,
                             own_dtm,
                             sale_dt,
                             gl_amt,
                             fee_group,
                             cat_program,
                             tran_type,
                             orig_gl_event_id,
                             orig_gl_id,
                             orig_tran_type,
                             gl_acct_abbrev_nm,
                             cust_code)
                         SELECT gdt.gl_event_id,
                             gdt.gl_id,
                             gdt.org_id,
                             gdt.veh_id,
                             gdt.own_dtm,
                             gdt.sale_dt,
                             gdt.gl_amt,
                             fgr.report_group_identifier,
                             vd.cat_program,
                             gdt.tran_type,
                             gdt.orig_gl_event_id,
                             gdt.orig_gl_id,
                             NULL,
                             gdt.gl_acct_abbrev_nm,
                             vd.cust_code
                           FROM #temp_gl_detail       tgd,
                                gl_detail_tax         gdt WITH (NOLOCK),
                                gl_tax_status         gts WITH (NOLOCK),
                                #veh_det       vd,
                                fee_grouping_report_v fgr WITH (NOLOCK)
                          WHERE --tgd.fee_group                = 'Buyer Fee'
tgd.tran_type     in ( 208, 294, 295, 296, 297, 298, 299, 300, 301, 504 )  --Tracker 22549, DR 23918 added 504
                            AND tgd.gl_event_id              = gdt.orig_gl_event_id
                            AND tgd.gl_id                    = gdt.orig_gl_id
                            AND gdt.gl_acct_abbrev_nm        in ( 'AR Customer', 'AP Customer' )
                            AND gts.status                     <> 'V'
                            AND gts.gl_valid_dtm             = (SELECT MAX(gl_valid_dtm)
                                                                  FROM gl_tax_status gts_in WITH (NOLOCK)
                                                                 WHERE gts_in.gl_event_id = gts.gl_event_id
                                                                   AND gts_in.gl_id       = gts.gl_id)
                            AND gts.gl_event_id              = gdt.gl_event_id
                            AND gts.gl_id                    = gdt.gl_id
                            AND gdt.veh_id                   = vd.veh_id
                            AND gdt.own_dtm                  = vd.own_dtm
                            AND gdt.tran_type                = fgr.tran_type
                            AND fgr.tran_account_id          = vd.tran_account_id
                            AND fgr.report_id                = @report_id
   AND ( gts.status <> 'C' OR (gts.status = 'C' AND gts.gl_valid_dtm > vd.block_dtm))  --Tracker 15379
--                             AND fgr.report_group_identifier in ('GST PASS THRU ADJUSTED TAX',
--                                                                 'QST PASS THRU ADJUSTED TAX',
--                                                                 'QST ADJUSTED TAX')                -- Tracker 16073 IN Quebec this needed to be added

DELETE from #temp_gl_detail
WHERE tran_type = 504
AND cust_code not in (008, 014)

        --  Tracker 10405  Pick up AR Floor Plan rows here to save time.
EXEC ("
INSERT INTO #temp_gl_detail (gl_event_id,
                             gl_id,
                             org_id,
                             veh_id,
                             own_dtm,
                             sale_dt,
                             gl_amt,
                             fee_group,
                             cat_program,
                             tran_type,
                             orig_gl_event_id,
                             orig_gl_id,
                             orig_tran_type,
                             gl_acct_abbrev_nm,
                             cust_code)
                      SELECT gd.gl_event_id,
                             gd.gl_id,
                             gd.org_id,
                             gd.veh_id,
                             gd.own_dtm,
                             gd.sale_dt,
                             gd.gl_amt,
                             null,
                             vd.cat_program,
                             gd.tran_type,
                             NULL,
                             NULL,
                             NULL,
                             gd.gl_acct_abbrev_nm,
                             vd.cust_code
                           FROM gl_detail_v           gd WITH (NOLOCK),
                                #veh_det       vd
                          WHERE vd.veh_id             = gd.veh_id
                            AND vd.own_dtm            = gd.own_dtm
                            AND gd.tran_type          = 16
                            AND gd.gl_acct_abbrev_nm  = 'AR Floor Pln'
                            AND gd.status            <> 'V'")

        -- Get vehicles paid for by signature plan of Ford Motor Credit using the "Signature" FMCC floor group id
        -- Tracker 8783 - Added the Canada "Signature" FMCC Floor Plan Group ID

EXEC ("
UPDATE #veh_det
   SET proceeds = 'signature'
  FROM #veh_det vd,
        gl_detail     gd  WITH (NOLOCK),
        groups        g   WITH (NOLOCK),
        org_group     og  WITH (NOLOCK),
        gl_status     gs  WITH (NOLOCK)
 WHERE vd.veh_id             = gd.veh_id
   AND vd.own_dtm            = gd.own_dtm
   AND gd.tran_type          = 16
   AND gd.gl_acct_abbrev_nm  = 'AR Floor Pln'
   AND g.group_id           IN (200000007, 200000055)
   AND g.group_id            = og.group_id
   AND og.org_id             = gd.org_id
   AND gs.status            <> 'V'
   AND gs.gl_valid_dtm       = (SELECT MAX(gl_valid_dtm)
                                  FROM gl_status gs_in WITH (NOLOCK)
                                 WHERE gs_in.gl_event_id = gs.gl_event_id
                                   AND gs_in.gl_id       = gs.gl_id)
   AND gs.gl_event_id        = gd.gl_event_id
   AND gs.gl_id              = gd.gl_id")

        -- Get vehicles paid for by frac plan of Ford Motor Company using the FRAC/LMCRS Floor Plan
        -- Group ID


EXEC ("
UPDATE #veh_det
   SET proceeds = 'frac'
  FROM #veh_det vd,
        gl_detail      gd  WITH (NOLOCK),
        groups         g   WITH (NOLOCK),
        org_group      og  WITH (NOLOCK),
        gl_status      gs  WITH (NOLOCK)
 WHERE vd.veh_id             = gd.veh_id
   AND vd.own_dtm            = gd.own_dtm
   AND gd.tran_type          = 16
   AND gd.gl_acct_abbrev_nm  = 'AR Floor Pln'
   AND g.group_id            = 200000005
   AND g.group_id            = og.group_id
   AND og.org_id             = gd.org_id
   AND gs.status            <> 'V'
   AND gs.gl_valid_dtm       = (SELECT MAX(gl_valid_dtm)
                                  FROM gl_status gs_in  WITH (NOLOCK)
                                 WHERE gs_in.gl_event_id = gs.gl_event_id
                                   AND gs_in.gl_id       = gs.gl_id)
   AND gs.gl_event_id        = gd.gl_event_id
   AND gs.gl_id              = gd.gl_id")

-- Tracker #24013 - Get vehicles paid for by a PRIMUS signature floor plan
EXEC ("
UPDATE #veh_det
   SET proceeds = 'signature primus'
  FROM #veh_det vd,
        gl_detail     gd  WITH (NOLOCK),
        groups        g   WITH (NOLOCK),
        org_group     og  WITH (NOLOCK),
        gl_status     gs  WITH (NOLOCK)
 WHERE vd.veh_id             = gd.veh_id
   AND vd.own_dtm            = gd.own_dtm
   AND gd.tran_type          = 16
   AND gd.gl_acct_abbrev_nm  = 'AR Floor Pln'
   AND g.group_id           IN (200000063)
   AND g.group_id            = og.group_id
   AND og.org_id             = gd.org_id
   AND gs.status            <> 'V'
   AND gs.gl_valid_dtm       = (SELECT MAX(gl_valid_dtm)
                                  FROM gl_status gs_in WITH (NOLOCK)
                                 WHERE gs_in.gl_event_id = gs.gl_event_id
                                   AND gs_in.gl_id       = gs.gl_id)
   AND gs.gl_event_id        = gd.gl_event_id
   AND gs.gl_id              = gd.gl_id")

        -- Indexes for temp tables

CREATE INDEX gl_event_id      ON #temp_gl_detail(gl_event_id, gl_id)
CREATE INDEX orig_gl_event_id ON #temp_gl_detail(orig_gl_event_id, orig_gl_id)
CREATE INDEX veh_id           ON #temp_gl_detail(veh_id, own_dtm)
CREATE INDEX org_id           ON #temp_gl_detail(org_id)

-- Tracker 9045 - Putting the value of the 'tran_type' column from the fee transaction into the
        -- 'orig_tran_type' column for the "tax" transaction that that fee is associated.

EXEC ("
UPDATE #temp_gl_detail
   SET orig_tran_type = gd.tran_type
  FROM #temp_gl_detail tgd,
        gl_detail      gd WITH (NOLOCK)
 WHERE tgd.orig_gl_event_id = gd.gl_event_id
   AND tgd.orig_gl_id       = gd.gl_id")

        -- Tracker 5681

EXEC ("
INSERT INTO #temp_flr_plan_sig(veh_id, own_dtm, flr_amt)
                        SELECT vd.veh_id, vd.own_dtm, ISNULL(SUM(tg.gl_amt), 0)
                          FROM  #veh_det vd,
                                #temp_gl_detail tg    --  Tracker 10405 Use temp table from above to save time
                         WHERE vd.proceeds          = 'signature'
                           AND vd.veh_id            = tg.veh_id
                           AND vd.own_dtm           = tg.own_dtm
                           AND tg.tran_type         = 16
                           AND tg.gl_acct_abbrev_nm = 'AR Floor Pln'
                  GROUP BY vd.own_dtm,
                           vd.veh_id")

-- Tracker #24013 - Added the Primus Signature Floor Plan
EXEC ("
INSERT INTO #temp_flr_plan_sig_primus(veh_id, own_dtm, flr_amt)
                        SELECT vd.veh_id, vd.own_dtm, ISNULL(SUM(tg.gl_amt), 0)
                          FROM  #veh_det vd,
                                #temp_gl_detail tg    --  Tracker 10405 Use temp table from above to save time
                         WHERE vd.proceeds          = 'signature primus'
                           AND vd.veh_id            = tg.veh_id
                           AND vd.own_dtm           = tg.own_dtm
                           AND tg.tran_type         = 16
                           AND tg.gl_acct_abbrev_nm = 'AR Floor Pln'
                  GROUP BY vd.own_dtm,
                           vd.veh_id")

EXEC ("
INSERT INTO #temp_flr_plan_frac(veh_id, own_dtm, flr_amt)
                         SELECT vd.veh_id, vd.own_dtm, ISNULL(SUM(tg.gl_amt), 0)
                           FROM #veh_det vd,
                                #temp_gl_detail tg    --  Tracker 10405 Use temp table from above to save time
                          WHERE vd.proceeds          = 'frac'
                            AND vd.veh_id            = tg.veh_id
                            AND vd.own_dtm           = tg.own_dtm
                            AND tg.tran_type         = 16
                            AND tg.gl_acct_abbrev_nm = 'AR Floor Pln'
                       GROUP BY vd.own_dtm,
                                vd.veh_id")

UPDATE #veh_det
   SET flr_sig_amt = t.flr_amt                        --  Tracker 9313  SQL 7 compatibility issue
  FROM #veh_det vd,
       #temp_flr_plan_sig t
 WHERE vd.veh_id   = t.veh_id
   AND vd.own_dtm  = t.own_dtm

UPDATE #veh_det
   SET flr_frac_amt = t.flr_amt                        --  Tracker 9313  SQL 7 compatibility issue
  FROM #veh_det vd,
       #temp_flr_plan_frac t
 WHERE vd.veh_id   = t.veh_id
   AND vd.own_dtm  = t.own_dtm

-- ---------------------------------------------------------------------------------------------------------
-- Ford Calculations for Canada
-- ---------------------------------------------------------------------------------------------------------
DECLARE @rep_ford_can_cnt   INT,  @rep_ford_can_amt   MONEY,  @rep_ford_can_net MONEY,  @rep_ford_can_tot MONEY,
@csv_ford_can_cnt   INT,  @csv_ford_can_amt   MONEY,  @csv_ford_can_net MONEY,  @csv_ford_can_tot MONEY,
@mis_ford_can_cnt   INT,  @mis_ford_can_amt   MONEY,  @mis_ford_can_net MONEY,  @mis_ford_can_tot MONEY,
        @ford_can_cnt_accum INT,  @ford_can_net_accum MONEY

-- REP
SELECT @rep_ford_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'REP' AND cust_code   = 2)
SELECT @rep_ford_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'REP' AND fee_group   = 'TOTAL FEE' AND cust_code   = 2)
SELECT @rep_ford_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'REP' AND cust_code      = 2)
SELECT @rep_ford_can_net = ISNULL((@rep_ford_can_tot - @rep_ford_can_amt),$0.0)

-- CSV  Tracker 22595
SELECT @csv_ford_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'CSV' AND cust_code   = 2)
SELECT @csv_ford_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'CSV' AND fee_group   = 'TOTAL FEE' AND cust_code   = 2)
SELECT @csv_ford_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'CSV' AND cust_code      = 2)
SELECT @csv_ford_can_net = ISNULL((@csv_ford_can_tot - @csv_ford_can_amt),$0.0)


-- MIS - Tracker #25767
SELECT @mis_ford_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'MIS' AND cust_code   = 2)
SELECT @mis_ford_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'MIS' AND fee_group   = 'TOTAL FEE' AND cust_code   = 2)
SELECT @mis_ford_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'MIS' AND cust_code      = 2)
SELECT @mis_ford_can_net = ISNULL((@mis_ford_can_tot - @mis_ford_can_amt),$0.0)


-- TRACKER 21203

-- section subtotal (internal only)
SELECT @ford_can_cnt_accum = ISNULL(@rep_ford_can_cnt, 0) + ISNULL(@csv_ford_can_cnt, 0) + ISNULL(@mis_ford_can_cnt, 0)
SELECT @ford_can_net_accum = ISNULL(@rep_ford_can_net, 0) + ISNULL(@csv_ford_can_net, 0) + ISNULL(@mis_ford_can_net, 0)

-- ---------------------------------------------------------------------------------------------------------
-- FMCC Calculations for Canada
-- ---------------------------------------------------------------------------------------------------------
DECLARE @rcr_fmcc_can_cnt   INT,  @rcr_fmcc_can_amt   MONEY,  @rcr_fmcc_can_net MONEY,  @rcr_fmcc_can_tot MONEY,
        @rct_fmcc_can_cnt   INT,  @rct_fmcc_can_amt   MONEY,  @rct_fmcc_can_net MONEY,  @rct_fmcc_can_tot MONEY,
        @rtr_fmcc_can_cnt   INT,  @rtr_fmcc_can_amt   MONEY,  @rtr_fmcc_can_net MONEY,  @rtr_fmcc_can_tot MONEY,
        @mis_fmcc_can_cnt   INT,  @mis_fmcc_can_amt   MONEY,  @mis_fmcc_can_net MONEY,  @mis_fmcc_can_tot MONEY,
        @cml_fmcc_can_cnt   INT,  @cml_fmcc_can_amt   MONEY,  @cml_fmcc_can_net MONEY,  @cml_fmcc_can_tot MONEY,
        @cmr_fmcc_can_cnt   INT,  @cmr_fmcc_can_amt   MONEY,  @cmr_fmcc_can_net MONEY,  @cmr_fmcc_can_tot MONEY,
        @cop_fmcc_can_cnt   INT,  @cop_fmcc_can_amt   MONEY,  @cop_fmcc_can_net MONEY,  @cop_fmcc_can_tot MONEY,
        @fmcc_can_cnt_accum INT,  @fmcc_can_net_accum MONEY

-- TRACKER 21203

-- RCR
SELECT @rcr_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RCR' AND cust_code   = 8)
SELECT @rcr_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RCR' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @rcr_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RCR' AND cust_code      = 8)
SELECT @rcr_fmcc_can_net = ISNULL((@rcr_fmcc_can_tot - @rcr_fmcc_can_amt),$0.0)

-- RCT
SELECT @rct_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RCT' AND cust_code   = 8)
SELECT @rct_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RCT' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @rct_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RCT' AND cust_code      = 8)
SELECT @rct_fmcc_can_net = ISNULL((@rct_fmcc_can_tot - @rct_fmcc_can_amt),$0.0)

-- RTR
SELECT @rtr_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RTR' AND cust_code   = 8)
SELECT @rtr_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RTR' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @rtr_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RTR' AND cust_code      = 8)
SELECT @rtr_fmcc_can_net = ISNULL((@rtr_fmcc_can_tot - @rtr_fmcc_can_amt),$0.0)

-- MIS - Tracker #25767
SELECT @mis_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'MIS' AND cust_code   = 8)
SELECT @mis_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'MIS' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @mis_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'MIS' AND cust_code      = 8)
SELECT @mis_fmcc_can_net = ISNULL((@mis_fmcc_can_tot - @mis_fmcc_can_amt),$0.0)

-- CML - Tracker #25767
SELECT @cml_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'CML' AND cust_code   = 8)
SELECT @cml_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'CML' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @cml_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'CML' AND cust_code      = 8)
SELECT @cml_fmcc_can_net = ISNULL((@cml_fmcc_can_tot - @cml_fmcc_can_amt),$0.0)

-- COP - DR 1410
SELECT @cop_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'COP' AND cust_code   = 8)
SELECT @cop_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'COP' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @cop_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'COP' AND cust_code      = 8)
SELECT @cop_fmcc_can_net = ISNULL((@cop_fmcc_can_tot - @cop_fmcc_can_amt),$0.0)

-- CMR - DR 133445
SELECT @cmr_fmcc_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'CMR' AND cust_code   = 8)
SELECT @cmr_fmcc_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'CMR' AND fee_group   = 'TOTAL FEE' AND cust_code   = 8)
SELECT @cmr_fmcc_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'CMR' AND cust_code      = 8)
SELECT @cmr_fmcc_can_net = ISNULL((@cmr_fmcc_can_tot - @cmr_fmcc_can_amt),$0.0)


-- TRACKER 21203

-- section subtotal (internal only)
-- TRACKER 21203
SELECT @fmcc_can_cnt_accum = ISNULL(@rct_fmcc_can_cnt, 0) + ISNULL(@rcr_fmcc_can_cnt, 0) + ISNULL(@rtr_fmcc_can_cnt, 0) + ISNULL(@mis_fmcc_can_cnt, 0) + ISNULL(@cml_fmcc_can_cnt, 0) + ISNULL(@cop_fmcc_can_cnt, 0)  + ISNULL(@cmr_fmcc_can_cnt, 0)
SELECT @fmcc_can_net_accum = ISNULL(@rct_fmcc_can_net, 0) + ISNULL(@rcr_fmcc_can_net, 0) + ISNULL(@rtr_fmcc_can_net, 0) + ISNULL(@mis_fmcc_can_net, 0) + ISNULL(@cml_fmcc_can_net, 0) + ISNULL(@cop_fmcc_can_net, 0) + ISNULL(@cmr_fmcc_can_net, 0)


-- TRACKER 22567 - PRIMUS CANADA 014

DECLARE @rcr_prim_can_cnt   INT,  @rcr_prim_can_amt   MONEY,  @rcr_prim_can_net MONEY,  @rcr_prim_can_tot MONEY,
        @rct_prim_can_cnt   INT,  @rct_prim_can_amt   MONEY,  @rct_prim_can_net MONEY,  @rct_prim_can_tot MONEY,
        @rtr_prim_can_cnt   INT,  @rtr_prim_can_amt   MONEY,  @rtr_prim_can_net MONEY,  @rtr_prim_can_tot MONEY,
        @mis_prim_can_cnt   INT,  @mis_prim_can_amt   MONEY,  @mis_prim_can_net MONEY,  @mis_prim_can_tot MONEY,
        @unk_prim_can_cnt   INT,  @unk_prim_can_amt   MONEY,  @unk_prim_can_net MONEY,  @unk_prim_can_tot MONEY,
        @cop_prim_can_cnt   INT,  @cop_prim_can_amt   MONEY,  @cop_prim_can_net MONEY,  @cop_prim_can_tot MONEY,
        @prim_can_cnt_accum INT,  @prim_can_net_accum MONEY

-- RCR
SELECT @rcr_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RCR' AND cust_code   = 14)
SELECT @rcr_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RCR' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @rcr_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RCR' AND cust_code      = 14)
SELECT @rcr_prim_can_net = ISNULL((@rcr_prim_can_tot - @rcr_prim_can_amt),$0.0)

-- RCT
SELECT @rct_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RCT' AND cust_code   = 14)
SELECT @rct_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RCT' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @rct_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RCT' AND cust_code      = 14)
SELECT @rct_prim_can_net = ISNULL((@rct_prim_can_tot - @rct_prim_can_amt),$0.0)

-- RTR
SELECT @rtr_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'RTR' AND cust_code   = 14)
SELECT @rtr_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'RTR' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @rtr_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'RTR' AND cust_code      = 14)
SELECT @rtr_prim_can_net = ISNULL((@rtr_prim_can_tot - @rtr_prim_can_amt),$0.0)

-- MIS  Tracker 22595
SELECT @mis_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'MIS' AND cust_code   = 14)
SELECT @mis_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'MIS' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @mis_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'MIS' AND cust_code      = 14)
SELECT @mis_prim_can_net = ISNULL((@mis_prim_can_tot - @mis_prim_can_amt),$0.0)

-- UNK  Tracker 22595
SELECT @unk_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'UNK' AND cust_code   = 14)
SELECT @unk_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'UNK' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @unk_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'UNK' AND cust_code      = 14)
SELECT @unk_prim_can_net = ISNULL((@unk_prim_can_tot - @unk_prim_can_amt),$0.0)

-- COP - DR 1410
SELECT @cop_prim_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'COP' AND cust_code   = 14)
SELECT @cop_prim_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'COP' AND fee_group   = 'TOTAL FEE' AND cust_code   = 14)
SELECT @cop_prim_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'COP' AND cust_code      = 14)
SELECT @cop_prim_can_net = ISNULL((@cop_prim_can_tot - @cop_prim_can_amt),$0.0)

-- section subtotal (internal only)
SELECT @prim_can_cnt_accum = ISNULL(@rct_prim_can_cnt,0) + ISNULL(@rcr_prim_can_cnt,0) + ISNULL(@rtr_prim_can_cnt,0)+
    ISNULL(@mis_prim_can_cnt,0) + ISNULL(@unk_prim_can_cnt,0) + ISNULL(@cop_prim_can_cnt,0)
SELECT @prim_can_net_accum = @rct_prim_can_net + @rcr_prim_can_net + @rtr_prim_can_net + @mis_prim_can_net + @unk_prim_can_net + @cop_prim_can_net


-- ---------------------------------------------------------------------------------------------------------
-- Volvo Calculations for Canada DR 19114
-- ---------------------------------------------------------------------------------------------------------
DECLARE @rep_volvo_can_cnt   INT,  @rep_volvo_can_amt   MONEY,  @rep_volvo_can_net MONEY,  @rep_volvo_can_tot MONEY,
@csv_volvo_can_cnt   INT,  @csv_volvo_can_amt   MONEY,  @csv_volvo_can_net MONEY,  @csv_volvo_can_tot MONEY,
@mis_volvo_can_cnt   INT,  @mis_volvo_can_amt   MONEY,  @mis_volvo_can_net MONEY,  @mis_volvo_can_tot MONEY,
        @volvo_can_cnt_accum INT,  @volvo_can_net_accum MONEY

-- REP  DR 19114
SELECT @rep_volvo_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'REP' AND cust_code   = 15)
SELECT @rep_volvo_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'REP' AND fee_group   = 'TOTAL FEE' AND cust_code   = 15)
SELECT @rep_volvo_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'REP' AND cust_code      = 15)
SELECT @rep_volvo_can_net = ISNULL((@rep_volvo_can_tot - @rep_volvo_can_amt),$0.0)

-- CSV  DR 19114
SELECT @csv_volvo_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'CSV' AND cust_code   = 15)
SELECT @csv_volvo_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'CSV' AND fee_group   = 'TOTAL FEE' AND cust_code   = 15)
SELECT @csv_volvo_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'CSV' AND cust_code      = 15)
SELECT @csv_volvo_can_net = ISNULL((@csv_volvo_can_tot - @csv_volvo_can_amt),$0.0)

-- MIS - DR 19114
SELECT @mis_volvo_can_cnt = (SELECT ISNULL(COUNT(*), 0) FROM #veh_det  
                            WHERE cat_program = 'MIS' AND cust_code   = 15)
SELECT @mis_volvo_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cat_program = 'MIS' AND fee_group   = 'TOTAL FEE' AND cust_code   = 15)
SELECT @mis_volvo_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE vd.cat_program = 'MIS' AND cust_code      = 15)
SELECT @mis_volvo_can_net = ISNULL((@mis_volvo_can_tot - @mis_volvo_can_amt),$0.0)

--DR 19114
-- section subtotal (internal only)
SELECT @volvo_can_cnt_accum = ISNULL(@rep_volvo_can_cnt, 0) + ISNULL(@csv_volvo_can_cnt, 0) + ISNULL(@mis_volvo_can_cnt, 0)
SELECT @volvo_can_net_accum = ISNULL(@rep_volvo_can_net, 0) + ISNULL(@csv_volvo_can_net, 0) + ISNULL(@mis_volvo_can_net, 0)

-- ---------------------------------------------------------------------------------------------------------
-- ARS Calculations for Canada DR 21883
-- ---------------------------------------------------------------------------------------------------------
DECLARE @ars_can_cnt   INT,  @ars_can_amt   MONEY,  @ars_can_net MONEY,  @ars_can_tot MONEY,
        @ars_can_cnt_accum INT,  @ars_can_net_accum MONEY

SELECT @ars_can_cnt = (SELECT ISNULL(COUNT(*), 0)
                       FROM #veh_det
                       WHERE cust_code >= 900 and cust_code <= 999)

/* DR 56030 removed logic to check ARS from category program code
                       AND cat_program IN (SELECT cat_prog_cd
  FROM cat_prog_cd_list
  WHERE SUBSTRING(cat_prog_dsc, 1, 4) = 'ARS '))*/

SELECT @ars_can_amt = (SELECT ISNULL(SUM(gl_amt), $0.0) FROM #temp_gl_detail
                             WHERE cust_code >= 900 and cust_code <= 999
    AND fee_group   = 'TOTAL FEE')

/* DR 56030 removed logic to check ARS from category program code
    AND cat_program IN (SELECT cat_prog_cd
  FROM cat_prog_cd_list
  WHERE SUBSTRING(cat_prog_dsc, 1, 4) = 'ARS ')) */

SELECT @ars_can_tot = (SELECT ISNULL(SUM(sale_amt), $0.0) FROM #veh_det vd
                            WHERE cust_code >= 900 and cust_code <= 999)

/*DR 56030 removed logic to check ARS from category program code
                           AND cat_program IN (SELECT cat_prog_cd
  FROM cat_prog_cd_list
  WHERE SUBSTRING(cat_prog_dsc, 1, 4) = 'ARS '))*/

SELECT @ars_can_net = ISNULL((@ars_can_tot - @ars_can_amt),$0.0)

/*
SELECT @afr_amc_cnt = (SELECT ISNULL(COUNT(*), 0)
                       FROM #veh_det
                      WHERE cat_program IN ('AMC','AFR','A52','AFM','A38','A59','APS',
                                            'A66','A68','A74','A80','A42','A84','A85',
                                            'A86','A87','A88','A87','A88','A89','A90',
                                            'A91','A92','A93','A94','ABH','A50','A64',
                                            'A32','A33','A95','A96','A97','ARD','A98',
                                            'T01','A99','ABL','A0A','ATH','ABU','A23'))
SELECT @afr_amc_amt = (SELECT ISNULL(SUM(gl_amt), $0.0)
                        FROM #temp_gl_detail
                       WHERE cat_program IN ('AMC','AFR','A52','AFM','A38','A59','APS',
                                            'A66','A68','A74','A80','A42','A84','A85',
                                            'A86','A87','A88','A87','A88','A89','A90',
                                            'A91','A92','A93','A94','ABH','A50','A64',
                                            'A32','A33','A95','A96','A97','ARD','A98',
                                            'T01','A99','ABL','A0A','ATH','ABU','A23')
                         AND fee_group = 'TOTAL FEE')
SELECT @afr_amc_tot = (SELECT ISNULL(SUM(sale_amt), $0.0)
                       FROM #veh_det vd
                      WHERE vd.cat_program IN ('AMC','AFR','A52','AFM','A38','A59','APS',
                                               'A66','A68','A74','A80','A42','A84','A85',
                                               'A86','A87','A88','A87','A88','A89','A90',
                                               'A91','A92','A93','A94','ABH','A50','A64',
                                               'A32','A33','A95','A96','A97','ARD','A98',
                                               'T01','A99','ABL','A0A','ATH','ABU','A23'))
SELECT @afr_amc_net = (@afr_amc_tot - @afr_amc_amt)
*/
-- ---------------------------------------------------------------------------------------------------------
-- Ford Buyer Fee Calculations
-- Tracker #20255 - Added new Trustmark Buyer Fee to be only for Cust Code equal to 003,004,009,011,or 013
-- Tracker #20255 - Changed Ford's Buyer Fee to be only for Cust Code NOT equal to 003,004,009,011,or 013
-- ---------------------------------------------------------------------------------------------------------

-- Initialize these values!
SELECT @buy_fee_cnt = 0,
       @buy_fee_amt = $0.00,
       @buy_fee_TM_cnt = 0, -- Tracker #20255 - Trustmark
       @buy_fee_TM_amt = $0.00, -- Tracker #20255 - Trustmark
       @car_hist_fee_cnt = 0,
       @car_hist_fee_amt = $0.00

--Tracker 20811 - added Dealer block to get buyer fee
-- Commented out for Tracker 21112
-- IF @sale_type_id = 2 OR @sale_type_id = 18         -- For Ford closed sales only
--

BEGIN
    -- How many vehicles had a buyer fee
    SELECT @buy_fee_cnt = (SELECT ISNULL(COUNT(*), 0)
                               FROM #temp_gl_detail tg,
                                    #veh_det vd
                              WHERE tg.tran_type = 208 --Tracker 20811
                                AND tg.veh_id    = vd.veh_id
                                AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code NOT IN (003,004,009,011,013)) -- Tracker #20255

    -- Total amount of buyer fees that were not purchased on frac
    SELECT @buy_fee_amt = (SELECT ISNULL(SUM(gl_amt), $0.0)
                                FROM #temp_gl_detail tg,
                                     #veh_det vd
                               WHERE tg.tran_type = 208 --Tracker 20811
                                 AND tg.veh_id    = vd.veh_id
                                 AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code NOT IN (003,004,009,011,013)) -- Tracker #20255

    -- Tracker #20255 - How many vehicles had a buyer fee for Trademark
    SELECT @buy_fee_TM_cnt = (SELECT ISNULL(COUNT(*), 0)
                               FROM #temp_gl_detail tg,
                                    #veh_det vd
                              WHERE --tg.fee_group = 'BUYER FEE'
   tg.tran_type = 208 --Tracker 20811
                                AND tg.veh_id    = vd.veh_id
                                AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code IN (003,004,009,011,013)) -- Tracker #20255

    -- Tracker #20255 - Total amount of buyer fees that were not purchased on frac for Trademark
    SELECT @buy_fee_TM_amt = (SELECT ISNULL(SUM(gl_amt), 0)
                                FROM #temp_gl_detail tg,
                                     #veh_det vd
                               WHERE --tg.fee_group = 'BUYER FEE'
    tg.tran_type = 208 --Tracker 20811
                                 AND tg.veh_id    = vd.veh_id
                                 AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code IN (003,004,009,011,013)) -- Tracker #20255
END
--DR 23918 --Added Car History Fee

    -- How many vehicles had a car history fee
    SELECT @car_hist_fee_cnt = (SELECT ISNULL(COUNT(*), 0)
                              FROM #temp_gl_detail tg,
                                    #veh_det vd
                              WHERE tg.tran_type = 504
                              AND tg.veh_id    = vd.veh_id
                              AND tg.own_dtm   = vd.own_dtm
     AND vd.cust_code IN (008, 014))

    -- Total amount of car history fees
    SELECT @car_hist_fee_amt = (SELECT ISNULL(SUM(gl_amt), $0.0)
                                FROM #temp_gl_detail tg,
                                #veh_det vd
                                WHERE tg.tran_type = 504
                                AND tg.veh_id    = vd.veh_id
                                AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code IN (008, 014))


-- ---------------------------------------------------------------------------------------------------------
-- Canadian Tax Calculations
-- ---------------------------------------------------------------------------------------------------------

-- How many vehicle had a GST/HST tax charged against it
-- Tracker 8783 - Added a section for taxes for the Canadian version on this report
-- Tracker 8783 - round two - needed to find distinct veh_id's and then count.  Otherwise, it
-- counted the number of tax rows
SELECT @gst_tax_cnt = (SELECT ISNULL(COUNT(DISTINCT tg.veh_id), 0)
               FROM #temp_gl_detail tg,
                #veh_det vd
              WHERE tg.tran_type in (294,295,298,299)  --Tracker 20811
                AND tg.veh_id    = vd.veh_id
                AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code NOT IN (003,004,009,011,013))  --Tracker 21154

    -- How many vehicle had a PST/TVQ tax charged against it
    -- Tracker 8783 - round two - needed to find distinct veh_id's and then count.  Otherwise, it
    --  counted the number of tax rows
SELECT @pst_tax_cnt = (SELECT ISNULL(COUNT(DISTINCT tg.veh_id), 0)
               FROM #temp_gl_detail tg,
                #veh_det vd
              WHERE tg.tran_type in (296,297,300,301) --Tracker 20811
                AND tg.veh_id    = vd.veh_id
                AND tg.own_dtm   = vd.own_dtm
AND vd.cust_code NOT IN (003,004,009,011,013))  --Tracker 21154

    -- Tracker 9005 - Added check for seller, since the taxes for expenses associated to the seller
    -- need to have the taxes for expenses associated to the buyer subtracted from them.  The only
    -- expenses that should be associated to the buyer are the fees in the "Buyer Fee" fee group.
    -- NOTE:  THERE IS AN ASSUMPTION BEING MADE THAT THE TAXES ASSOCIATED TO THE BUYER ARE CREDITS
    --        FOR THE SELLER EVEN THOUGH THE CREDIT WAS MADE TO A THIRD PARTY WHEN THE TAXES ARE OF
    --        "PASS THRU" TYPE.  THIS IS BECAUSE THE ONLY TAXES THAT SHOULD BE ASSOCIATED TO THE
    --        BUYER ARE FOR THE FEES IN THE "BUYER FEE" FEE GROUP (WHICH CURRENTLY ONLY HAS THE
    --        "THIRD PARTY BUYER FEE" IN IT).

SELECT @gst_tax_seller_amt = (SELECT ISNULL(SUM(gl_amt), $0.0)
                FROM #temp_gl_detail tg,
                     #veh_det vd
                   WHERE tg.tran_type in (294,295,298,299)  --Tracker 20811  & Tracker 22549
                 AND tg.veh_id    = vd.veh_id
                 AND tg.own_dtm   = vd.own_dtm
                 AND tg.org_id    = vd.org_id
AND vd.cust_code NOT IN (003,004,009,011,013))  --Tracker 21154

SELECT @pst_tax_seller_amt = (SELECT ISNULL(SUM(gl_amt), $0.0)
                FROM #temp_gl_detail tg,
                     #veh_det vd
                   WHERE tg.tran_type in (296,297,300,301) --Tracker 20811  & Tracker 22549
                 AND tg.veh_id    = vd.veh_id
                 AND tg.own_dtm   = vd.own_dtm
                 AND tg.org_id    = vd.org_id
AND vd.cust_code NOT IN (003,004,009,011,013))  --Tracker 21154

    -- Tracker 9045 - Changed to determine what amount of taxes should be credited to the seller
    -- for the fees in the "Buyer Fee" fee group.  The previous calculations didn't take into
    -- account that the seller could ended up getting paid for the Third Party Buyer Fee.  So now
    -- if the sum of the taxes for the fees in the "buyer Fee" fee group equals zero, then the
    -- taxes have already been included in the seller's tax amount and nothing needs to be done.
    -- If the sum doesn't equal zero, then the taxes went to a third party and haven't been
    -- included in the seller's tax amount and needs to be put in.

SELECT @gst_tax_buyer_amt = 0,
    @gst_tax_buyfee_tot = 0,
    @pst_tax_buyer_amt = 0,
    @pst_tax_buyfee_tot = 0,
    @gst_tax_car_history_amt = 0,
    @gst_tax_car_hist_tot = 0,
    @pst_tax_car_history_amt = 0,
    @pst_tax_car_hist_tot = 0

DECLARE vehicle_info CURSOR FOR SELECT veh_id,
                    own_dtm,
                    org_id,
                    buying_cust_id,
                    cash_type_dsc
                  FROM #veh_det
                  ORDER BY org_id
OPEN vehicle_info

FETCH NEXT FROM vehicle_info INTO @veh_id,
                  @own_dtm,
                  @org_id,
                  @buying_cust_id,
                  @cash_type_dsc
    -- Loop through all of the vehicles rows
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @gst_tax_for_one_amt = NULL

-- Getting GST & QST pass thru taxes (298) from the buying customer for 3rd Party Buyer Fee (208)


    SELECT @gst_tax_for_one_amt = (SELECT SUM(tgd.gl_amt)
                     FROM #temp_gl_detail tgd
                    WHERE tgd.veh_id           = @veh_id
                      AND tgd.own_dtm          = @own_dtm
                      AND (tgd.org_id          = @org_id
                       OR tgd.org_id           = @buying_cust_id)
                      AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                    FROM #temp_gl_detail tgd1
                                       WHERE tgd1.veh_id    = @veh_id
                                     AND tgd1.own_dtm   = @own_dtm
                                     AND tgd1.org_id    = @buying_cust_id
                                     AND tgd1.tran_type = 208)  --Tracker 20811
                      AND tgd.orig_tran_type IN (SELECT tgd2.tran_type                                -- Tracker 15521
                                    FROM #temp_gl_detail tgd2
                                       WHERE tgd2.veh_id    = @veh_id
                                     AND tgd2.own_dtm   = @own_dtm
                                     AND tgd2.org_id    = @buying_cust_id
                                     AND tgd2.tran_type = 208)
                      AND tgd.tran_type       = 298 )  -- Tracker 20811

    IF @gst_tax_for_one_amt IS NOT NULL
        SELECT @gst_tax_buyer_amt = @gst_tax_buyer_amt + @gst_tax_for_one_amt

        -- Tracker 9045 - round two - Need to know what the tax amount is that is associated
        -- to the fees that are in the 'Buyer Fee' fee group, so they can be removed for the
        -- "Pay Direct" total.

    IF @gst_tax_for_one_amt = 0
    BEGIN
        SELECT @gst_tax_buyfee_amt = NULL

        SELECT @gst_tax_buyfee_amt = (SELECT ISNULL(tgd.gl_amt, $0.0)
                         FROM #temp_gl_detail tgd
                        WHERE tgd.veh_id           = @veh_id
                          AND tgd.own_dtm          = @own_dtm
                          AND tgd.org_id           = @buying_cust_id
                          AND @cash_type_dsc       = 'check'
                          AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                        FROM #temp_gl_detail tgd1
                                           WHERE tgd1.veh_id    = @veh_id
                                         AND tgd1.own_dtm   = @own_dtm
                                         AND tgd1.org_id    = @buying_cust_id
                                         AND tgd1.tran_type = 208)  --Tracker 20811
                          AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        -- Tracker 15521
                                        FROM #temp_gl_detail tgd2
                                           WHERE tgd2.veh_id    = @veh_id
                                         AND tgd2.own_dtm   = @own_dtm
                                         AND tgd2.org_id    = @buying_cust_id
                                         AND tgd2.tran_type = 208)  --Tracker 20811
                          AND tgd.tran_type       = 298 )

        IF @gst_tax_buyfee_amt IS NOT NULL                --  Tracker 10209 Check for null in SQL 7
            SELECT @gst_tax_buyfee_tot = @gst_tax_buyfee_tot + @gst_tax_buyfee_amt

    END

    SELECT @pst_tax_for_one_amt = NULL

    SELECT @pst_tax_for_one_amt = (SELECT SUM(tgd.gl_amt)
                     FROM #temp_gl_detail tgd
                    WHERE tgd.veh_id           = @veh_id
                      AND tgd.own_dtm          = @own_dtm
                      AND (tgd.org_id          = @org_id
                       OR tgd.org_id           = @buying_cust_id)
                      AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                    FROM #temp_gl_detail tgd1
                                       WHERE tgd1.veh_id    = @veh_id
                                     AND tgd1.own_dtm   = @own_dtm
                                     AND tgd1.org_id    = @buying_cust_id
                                     AND tgd1.tran_type = 208)  --Tracker 20811
                      AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        -- Tracker 15521
                                    FROM #temp_gl_detail tgd2
                                       WHERE tgd2.veh_id    = @veh_id
                                     AND tgd2.own_dtm   = @own_dtm
                                     AND tgd2.org_id    = @buying_cust_id
                                     AND tgd2.tran_type = 208)  --Tracker 20811
                      AND tgd.tran_type       = 300)

--done
    IF @pst_tax_for_one_amt IS NOT NULL
        SELECT @pst_tax_buyer_amt = @pst_tax_buyer_amt + @pst_tax_for_one_amt

    IF @pst_tax_for_one_amt = 0
    BEGIN
        SELECT @pst_tax_buyfee_amt = NULL

        SELECT @pst_tax_buyfee_amt = (SELECT ISNULL(SUM(tgd.gl_amt), $0.0)
                         FROM #temp_gl_detail tgd
                        WHERE tgd.veh_id           = @veh_id
                          AND tgd.own_dtm          = @own_dtm
                          AND tgd.org_id           = @buying_cust_id
                          AND @cash_type_dsc       = 'check'
                          AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                        FROM #temp_gl_detail tgd1
                                           WHERE tgd1.veh_id    = @veh_id
                                         AND tgd1.own_dtm   = @own_dtm
                                         AND tgd1.org_id    = @buying_cust_id
                                         AND tgd1.tran_type = 208)  --Tracker 20811
                          AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        -- Tracker 15521
                                        FROM #temp_gl_detail tgd2
                                           WHERE tgd2.veh_id    = @veh_id
                                         AND tgd2.own_dtm   = @own_dtm
                                         AND tgd2.org_id    = @buying_cust_id
                                         AND tgd2.tran_type = 208)  --Tracker 20811
                          AND tgd.tran_type       = 300 )

        SELECT @pst_tax_buyfee_tot = @pst_tax_buyfee_tot + @pst_tax_buyfee_amt

    END
   

--DR 23918 -- ADDING PST AND GST for Car History Fee

-- Getting GST & QST pass thru taxes (298) from the buying customer for Car History Fee (504)

    SELECT @gst_tax_one_carhist_amt = (SELECT SUM(tgd.gl_amt)
                     FROM #temp_gl_detail tgd
                    WHERE tgd.veh_id           = @veh_id
                      AND tgd.own_dtm          = @own_dtm
                      AND (tgd.org_id          = @org_id
                       OR tgd.org_id           = @buying_cust_id)
                      AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                    FROM #temp_gl_detail tgd1
                                       WHERE tgd1.veh_id    = @veh_id
                                     AND tgd1.own_dtm   = @own_dtm
                                     AND tgd1.org_id    = @buying_cust_id
                                     AND tgd1.tran_type = 504
                                     AND tgd1.cust_code in (008, 014))
                      AND tgd.orig_tran_type IN (SELECT tgd2.tran_type                                -- Tracker 15521
                                    FROM #temp_gl_detail tgd2
                                       WHERE tgd2.veh_id    = @veh_id
                                     AND tgd2.own_dtm   = @own_dtm
                                     AND tgd2.org_id    = @buying_cust_id
                                     AND tgd2.tran_type = 504
                                     AND tgd2.cust_code in (008, 014))
                      AND tgd.tran_type       = 298 )

    IF @gst_tax_one_carhist_amt IS NOT NULL
       SELECT @gst_tax_car_history_amt = @gst_tax_car_history_amt + @gst_tax_one_carhist_amt

        -- round two - Need to know what the tax amount is that is associated
        -- to the fees that are in the 'car history fee' fee group, so they can be removed for the
        -- "Pay Direct" total.

    IF @gst_tax_one_carhist_amt = 0
    BEGIN
        SELECT @gst_tax_car_hist_amt = NULL

        SELECT @gst_tax_car_hist_amt = (SELECT ISNULL(tgd.gl_amt, $0.0)
                         FROM #temp_gl_detail tgd
                        WHERE tgd.veh_id           = @veh_id
                          AND tgd.own_dtm          = @own_dtm
                          AND tgd.org_id           = @buying_cust_id
                          AND @cash_type_dsc       = 'check'
                          AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                
                                        FROM #temp_gl_detail tgd1
                                           WHERE tgd1.veh_id    = @veh_id
                                         AND tgd1.own_dtm   = @own_dtm
                                         AND tgd1.org_id    = @buying_cust_id
                                         AND tgd1.tran_type = 504)  
                          AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        
                                        FROM #temp_gl_detail tgd2
                                           WHERE tgd2.veh_id    = @veh_id
                                         AND tgd2.own_dtm   = @own_dtm
                                         AND tgd2.org_id    = @buying_cust_id
                                         AND tgd2.tran_type = 504)  
                          AND tgd.tran_type       = 298 )

        IF @gst_tax_car_hist_amt IS NOT NULL              
            SELECT @gst_tax_car_hist_tot = @gst_tax_car_hist_tot + @gst_tax_car_hist_amt

    END

    SELECT @pst_tax_one_carhist_amt = NULL

    SELECT @pst_tax_one_carhist_amt = (SELECT SUM(tgd.gl_amt)
                     FROM #temp_gl_detail tgd
                    WHERE tgd.veh_id           = @veh_id
                      AND tgd.own_dtm          = @own_dtm
                      AND (tgd.org_id          = @org_id
                       OR tgd.org_id           = @buying_cust_id)
                      AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                -- Tracker 15521
                                    FROM #temp_gl_detail tgd1
                                       WHERE tgd1.veh_id    = @veh_id
                                     AND tgd1.own_dtm   = @own_dtm
                                     AND tgd1.org_id    = @buying_cust_id
                                     AND tgd1.tran_type = 504)  
                      AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        
                                    FROM #temp_gl_detail tgd2
                                       WHERE tgd2.veh_id    = @veh_id
                                     AND tgd2.own_dtm   = @own_dtm
                                     AND tgd2.org_id    = @buying_cust_id
                                     AND tgd2.tran_type = 504)  
                      AND tgd.tran_type       = 300)


    IF @pst_tax_one_carhist_amt IS NOT NULL
        SELECT @pst_tax_car_history_amt = @pst_tax_car_history_amt + @pst_tax_one_carhist_amt

    IF @pst_tax_one_carhist_amt = 0
    BEGIN
        SELECT @pst_tax_car_hist_amt = NULL

        SELECT @pst_tax_car_hist_amt = (SELECT ISNULL(SUM(tgd.gl_amt), $0.0)
                         FROM #temp_gl_detail tgd
                        WHERE tgd.veh_id           = @veh_id
                          AND tgd.own_dtm          = @own_dtm
                          AND tgd.org_id           = @buying_cust_id
                          AND @cash_type_dsc       = 'check'
                          AND tgd.orig_gl_event_id IN (SELECT DISTINCT tgd1.gl_event_id                
                                        FROM #temp_gl_detail tgd1
                                           WHERE tgd1.veh_id    = @veh_id
                                         AND tgd1.own_dtm   = @own_dtm
                                         AND tgd1.org_id    = @buying_cust_id
                                         AND tgd1.tran_type = 504)  
                          AND tgd.orig_tran_type   IN (SELECT tgd2.tran_type                        -- Tracker 15521
                                        FROM #temp_gl_detail tgd2
                                           WHERE tgd2.veh_id    = @veh_id
                                         AND tgd2.own_dtm   = @own_dtm
                                         AND tgd2.org_id    = @buying_cust_id
                                         AND tgd2.tran_type = 504)  
                          AND tgd.tran_type       = 300 )

        SELECT @pst_tax_car_hist_tot = @pst_tax_car_hist_tot + @pst_tax_car_hist_amt

    END

----END DR 23918 -- adding car history fee  


    FETCH NEXT FROM vehicle_info INTO @veh_id,
                      @own_dtm,
                      @org_id,
                      @buying_cust_id,
                      @cash_type_dsc
END

DEALLOCATE vehicle_info
--DR 23918 -- added car history fee

    -- Total amount of GST/HST taxes
IF @gst_tax_buyer_amt = 0 and @gst_tax_car_history_amt = 0
   SELECT @gst_tax_amt = @gst_tax_seller_amt
ELSE
   SELECT @gst_tax_amt = @gst_tax_seller_amt - @gst_tax_buyer_amt - @gst_tax_car_history_amt

    -- Total amount of PST/TVQ taxes
IF @pst_tax_buyer_amt = 0 and @pst_tax_car_history_amt = 0
   SELECT @pst_tax_amt = @pst_tax_seller_amt
ELSE
    SELECT @pst_tax_amt = @pst_tax_seller_amt - @pst_tax_buyer_amt - @pst_tax_car_history_amt

    -- End of Tracker 8783


-- ---------------------------------------------------------------------------------------------------------
--  Total Calculations
-- ---------------------------------------------------------------------------------------------------------
    -- Tracker 8783 - Since the USA and Canadian versions of this report don't put all the same
    -- category program codes in the same row, the totals needs to be calculated differently.
    -- NOTE:  THE TOTAL NEEDS TO BE CALCULATED BY ADDING UP THE TOTALS FROM ALL THE ROWS ON THE
    --        REPORT.  THIS IS TO INSURE THAT THE REPORT BALANCES.  In theory, the total could be
    --        calculated by doing a sum on the temp table, #temp_gl_detail, and that SHOULD match
    --        the total of adding up all the rows.  But if it doesn't, the user will not notice
    --        it since they aren't going to manually add up the rows and see if it matches the
    --        grand total
    -- NOTE:  IF NEW ROWS GET ADDED TO THE REPORT, THEN MAKE SURE THOSE NEW ROWS GET ADDED INTO
    --        BOTH TOTALS CORRECTLY.

    -- DR 21883 -Added ars totals
    -- DR 23918 --Added car history fee
    -- DO NOT include Buyer Fee for Trademark into this calculation per Tracker #20255  
    SELECT @total_amt = (@ford_can_net_accum + @fmcc_can_net_accum + @prim_can_net_accum + @volvo_can_net_accum + @ars_can_net  + @buy_fee_amt + @car_hist_fee_amt - @gst_tax_amt - @pst_tax_amt)

    SELECT @total_units_sold = (ISNULL(@ford_can_cnt_accum,0) + ISNULL(@fmcc_can_cnt_accum, 0) + ISNULL(@prim_can_cnt_accum, 0)
                                + ISNULL(@volvo_can_cnt_accum,0) + ISNULL(@ars_can_cnt, 0))

SELECT @total_net = @total_amt
-- ---------------------------------------------------------------------------------------------------------
--  Proceeds Calculations
-- ---------------------------------------------------------------------------------------------------------
    -- Tracker 5681

SELECT @proceeds_floor = (SELECT ISNULL(SUM(flr_sig_amt), $0.0)
               FROM #veh_det  
              WHERE proceeds = 'signature' )

SELECT @proceeds_floor_primus = (SELECT ISNULL(SUM(flr_amt), $0.0)
                FROM #temp_flr_plan_sig_primus )
           

    -- All expenses for direct cars  except buyer fees
    -- Tracker 9005 - Added check for seller, so the taxes associated to the fees in the "Buyer
    -- Fee" fee group won't get picked up.  Those taxes belong to the buyer and should not be an
    -- expense to the seller.  They are really a credit to the seller since dealing with 3rd Party
    -- Buyer fee.

SELECT @proc_dir_exp = (SELECT ISNULL(SUM (gl_amt), $0.0)
              FROM #temp_gl_detail  tg,
                #veh_det vd
             WHERE tg.veh_id         = vd.veh_id
               AND tg.own_dtm        = vd.own_dtm
               AND tg.org_id         = vd.org_id
               AND vd.cash_type_dsc  = 'check'
               AND tg.tran_type     not in (208, 504))  --Tracker 20811, DR 23918 added 504

    -- Total sale amount for direct cars

SELECT @proc_dir_sale = (SELECT ISNULL(SUM(sale_amt), $0.0)
               FROM #veh_det vd
              WHERE vd.cash_type_dsc  = 'check')

    -- direct proceeds after expenses
    -- Tracker 9045 - round two - Needed to remove the taxes associated with the fees in the "Buyer
    -- Fee" fee group from the "Pay Direct" total if the vehicle is a pay type of check, since they
    -- are to be paid by "EFT", just like their fees.

--DR 23918 added car history fee
SELECT @proceeds_direct = @proc_dir_sale - @proc_dir_exp - @gst_tax_buyfee_tot - @pst_tax_buyfee_tot - @gst_tax_car_hist_tot - @pst_tax_car_hist_tot

--TRK 24013
SELECT @proceeds_eft = @total_net - @proceeds_floor - IsNull(@proceeds_floor_primus,0) - @proceeds_direct

    -- Tracker 9005 - Removed code for calculating the "EFT" amount, since it was commented out.
    -- Tracker 9005 - Removed code for calculating the "FRAC" amount, since it was commented out.

    -- Tracker 5681

SELECT @frac_tot = (SELECT ISNULL(SUM(flr_frac_amt), $0.0)
            FROM #veh_det  
               WHERE proceeds = 'frac' )

SELECT @frac_cnt = (SELECT COUNT(*)
            FROM #veh_det vd
               WHERE vd.proceeds = 'frac')

SELECT @signature_cnt = (SELECT COUNT(*)
                 FROM #veh_det vd
                WHERE vd.proceeds = 'signature')

-- Tracker #24013 - Added Primus Signature Floor Plan
SELECT @signature_primus_cnt = (SELECT COUNT(*)
                 FROM #veh_det vd
                WHERE vd.proceeds = 'signature primus')

-- ---------------------------------------------------------------------------------------------------------
-- Final data return
-- ---------------------------------------------------------------------------------------------------------
IF @DEBUG_FLG = 1
BEGIN
DECLARE @dummy int


END
ELSE
BEGIN
-- TRACKER 21203
    SELECT @auction_code        'auction_code',
           @co_name             'co_name',
           @sale_dt             'sale_dt',
           @sale_type_id        'sale_type',
           --@tran_account_id     'tran_acct', --DR36481
0 'tran_acct', --DR36481
           @rep_ford_can_cnt    'ca_f_rep_count',  
  @rep_ford_can_net    'ca_f_rep_net',
           @csv_ford_can_cnt    'ca_f_csv_count',  
  @csv_ford_can_net    'ca_f_csv_net',
           @mis_ford_can_cnt    'ca_f_mis_count',   -- Tracker #25767
  @mis_ford_can_net    'ca_f_mis_net', -- Tracker #25767
           @rcr_fmcc_can_cnt    'ca_fc_rcr_count',  
  @rcr_fmcc_can_net    'ca_fc_rct_net',
           @rct_fmcc_can_cnt    'ca_fc_rtc_count',  
  @rct_fmcc_can_net    'ca_fc_rtc_net',
           @rtr_fmcc_can_cnt    'ca_fc_rtr_count',  
  @rtr_fmcc_can_net    'ca_fc_rtr_net',
           @mis_fmcc_can_cnt    'ca_fc_mis_count', -- Tracker #25767  
  @mis_fmcc_can_net    'ca_fc_mis_net', -- Tracker #25767
           @cml_fmcc_can_cnt    'ca_fc_cml_count',   -- Tracker #25767
  @cml_fmcc_can_net    'ca_fc_cml_net', -- Tracker #25767
           @cop_fmcc_can_cnt    'ca_fc_cop_count',   -- DR 1410
  @cop_fmcc_can_net    'ca_fc_cop_net', -- DR 1410
  @rcr_prim_can_cnt    'ca_prim_rcr_count',  
  @rcr_prim_can_net    'ca_prim_rcr_net',
           @rct_prim_can_cnt    'ca_prim_rct_count',  
  @rct_prim_can_net    'ca_prim_rct_net',
           @rtr_prim_can_cnt    'ca_prim_rtr_count',  
  @rtr_prim_can_net    'ca_prim_rtr_net',
  @mis_prim_can_cnt    'ca_prim_mis_count',  
  @mis_prim_can_net    'ca_prim_mis_net',
  @unk_prim_can_cnt    'ca_prim_unk_count',  
  @unk_prim_can_net    'ca_prim_unk_net',
  @cop_prim_can_cnt    'ca_prim_cop_count',    -- DR 1410  
  @cop_prim_can_net    'ca_prim_cop_net',      -- DR 1410
           @rep_volvo_can_cnt   'ca_volf_rep_count',       -- DR 19114
  @rep_volvo_can_net   'ca_volf_rep_net',
           @csv_volvo_can_cnt   'ca_volf_csv_count',  
  @csv_volvo_can_net   'ca_volf_csv_net',
           @mis_volvo_can_cnt   'ca_volf_mis_count',  
  @mis_volvo_can_net   'ca_volf_mis_net',          -- DR 19114
           @gst_tax_cnt         'gst_tax_count',    
  @gst_tax_amt         'gst_tax_amount',
           @pst_tax_cnt         'pst_tax_count',    
  @pst_tax_amt         'pst_tax_amount',
           @total_units_sold    'total_units_sold',
  @total_amt           'total_amt',
           @proceeds_floor      'proceeds_floor',
           @proceeds_floor_primus 'proceeds_floor_primus',
           @proceeds_direct     'proceeds_direct',
           @proceeds_eft        'proceeds_eft',
           @total_net           'total_net',
           @buy_fee_cnt         'buy_fee_count',    
  @buy_fee_amt         'buy_fee_amount',
           @ars_can_cnt         'ars_count',          --DR 21883
           @ars_can_net         'ars_net',            --DR 21883
           @car_hist_fee_cnt    'car_hist_fee_count', --DR 23918
           @car_hist_fee_amt    'car_hist_fee_amount', --DR 23918
           @cmr_fmcc_can_cnt    'ca_fc_cml_count',   -- DR 133445
  @cmr_fmcc_can_net    'ca_fc_cml_net' -- DR 133445

END

END