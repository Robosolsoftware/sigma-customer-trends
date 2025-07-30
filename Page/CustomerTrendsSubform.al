page 80130 "Customer Trends Subform"
{
    PageType = ListPart;
    SourceTable = CustomerTrends;
    DelayedInsert = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    TableRelation = Item;
                    StyleExpr = G_Colour;
                    trigger OnValidate()
                    var
                        myInt: Page "Req. Worksheet";
                        L_Item: Record Item;
                        SalesPrice: Record "Price List Line";
                        CH_SShip: Record "Sales Shipment Line";
                        L_SalesLine: Record "Sales Line";
                        L_ItemUnitofMeasure: Record "Item Unit of Measure";
                        L_SalesAndEvent: Codeunit "Sales Event & Function";
                        L_Location: Record Location;
                        CompanyLicenseValidation: Codeunit "Check Item License";
                        CalledFrom: Option "Sales","Purchase";
                        L_Customer: Record Customer;
                        L_ShiptoAddress: Record "Ship-to Address";
                        EventAndSubscriber: Codeunit EventSub;
                        L_PriceListLine: Record "Price List Line";
                        L_SalesPriceHeader: Record "Price List Header";
                        L_CustomerTrendLine: Record CustomerTrends;
                        L_CustomerTrendsHeader: Record "Customer Trend Header";
                        Last_CustomerTrendLine: Record CustomerTrends;
                        L_ShipperPalletData: Record "Shipper/Pallet Data";
                    begin
                        //Check Duplicate Item++
                        L_CustomerTrendLine.Reset();
                        L_CustomerTrendLine.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrendLine.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrendLine.SetRange("Special Promotion", false);
                        L_CustomerTrendLine.SetFilter("Entry Number", Rec."Entry Number");
                        L_CustomerTrendLine.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrendLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
                        if L_CustomerTrendLine.FindFirst() then begin
                            if not Confirm(StrSubstNo('Item No. %1 already exists. Do you want to proceed??', Rec."Item No."), false) then
                                Error('');
                        end;

                        L_CustomerTrendsHeader.Reset();
                        L_CustomerTrendsHeader.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrendsHeader.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrendsHeader.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomerTrendsHeader.FindFirst() then begin
                            Rec."Entry Number" := L_CustomerTrendsHeader."Entry Number";

                            //GetLast Line No++
                            Last_CustomerTrendLine.Reset();
                            Last_CustomerTrendLine.SetRange("Entry Number", L_CustomerTrendsHeader."Entry Number");
                            if Last_CustomerTrendLine.FindLast() then begin
                                Rec."Line No." := Last_CustomerTrendLine."Line No." + 10000;
                            end else
                                Rec."Line No." := 10000;

                            Rec."Salesperson Code" := L_CustomerTrendsHeader."Salesperson Code";
                            Rec."Customer No." := L_CustomerTrendsHeader."Customer No.";
                            Rec."Special Promotion" := false;
                            Rec."Shipping Agent Code" := L_CustomerTrendsHeader."Shipping Agent Code";
                            Rec."Shipping Agent Service Code" := L_CustomerTrendsHeader."Shipping Agent Service Code";
                            Rec."Weekend Shipping Agent Code" := L_CustomerTrendsHeader."Weekend Shipping Agent Code";
                            Rec."Weekend Ship. Agnt. Serv. Code" := L_CustomerTrendsHeader."Weekend Ship. Agnt. Serv. Code";
                            Rec."Min Order Value" := L_CustomerTrendsHeader."Min Order Value";
                            Rec."Order Date" := L_CustomerTrendsHeader."Order Date";
                            Rec."Delivery Date" := L_CustomerTrendsHeader."Delivery Date";
                            Rec."Work Description" := L_CustomerTrendsHeader."Work Description";
                            Rec."Location Code" := L_CustomerTrendsHeader."Location Code";
                            Rec.Validate("Created By", UserId);
                            Rec.Validate("Created On", CurrentDateTime);
                            Rec.Validate("Updated By", UserId);
                            Rec.Validate("Updated On", CurrentDateTime);

                            L_Item.Reset();
                            L_Item.SetRange("No.", Rec."Item No.");
                            if L_Item.FindFirst() then begin
                                //Check Master Approval++
                                L_Item.TestField("QAU Approved", true);
                                L_Item.TestField(Status, L_Item.Status::Released);
                                L_Item.TestField("Special Product", false);
                                L_Item.TestField(Blocked, false);
                                L_Item.TestField("Sales Blocked", false);
                                L_Item.TestField("Ops Sales Blocked", false);

                                //Check Shipping Restriction for existing Lines++
                                L_SalesAndEvent.CheckShippingAgentServiceRestriction(Rec."Item No.", L_CustomerTrendsHeader."Shipping Agent Code", L_CustomerTrendsHeader."Shipping Agent Service Code");

                                Rec."Item No." := L_Item."No.";
                                Rec."Item Description" := L_Item.Description;
                                Rec."Units of Measure" := L_Item."Sales Unit of Measure";
                                Rec.Validate("Min Sell Price", L_Item."Min Sell Price");
                                Rec.RRP := L_Item.RRP;
                                Rec."Item Category Code" := L_Item."Item Category Code";

                                //Update Price and Percentage++
                                Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", 0, Rec."Order Date"));
                                Rec.Validate("Line Disc %", EventAndSubscriber.CustomerTrend_GetLineDiscount(Rec."Customer No.", Rec."Item No.", 0, Rec."Order Date"));

                                //Get the last unit price from sales shipment table++
                                CH_SShip.Reset();
                                CH_SShip.SetRange("Sell-to Customer No.", Rec."Customer No.");
                                CH_SShip.SetRange("No.", Rec."Item No.");
                                CH_SShip.SetRange("Unit of Measure Code", Rec."Units of Measure");
                                if CH_SShip.FindLast() then
                                    Rec."Last Price" := CH_SShip."Unit Price";


                                //Get Shipper Quantity from Item unit measure table++
                                // L_ItemUnitofMeasure.Reset();
                                // L_ItemUnitofMeasure.SetRange("Item No.", Rec."Item No.");
                                // L_ItemUnitofMeasure.SetRange(Code, Rec."Units of Measure");
                                // if L_ItemUnitofMeasure.FindFirst() then
                                //     Rec.Validate("Shipper Qty", L_ItemUnitofMeasure."Qty. per Unit of Measure");
                                L_ShipperPalletData.Reset();
                                L_ShipperPalletData.SetRange("Item No.", Rec."Item No.");
                                if L_ShipperPalletData.FindFirst() then begin
                                    Rec.Validate("Shipper Qty", L_ShipperPalletData."Shipper Qty.");

                                end;
                                //Company License Validatio++
                                L_Customer.Reset();
                                L_Customer.SetRange("No.", Rec."Customer No.");
                                if L_Customer.FindFirst() then begin
                                    Rec."Ship-to Code" := L_Customer."Ship-to Code";
                                    Rec."Customer Price Group" := L_Customer."Customer Price Group";

                                    if L_Customer."Ship-to Code" <> '' then begin
                                        L_ShiptoAddress.Reset();
                                        L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                                        L_ShiptoAddress.SetRange("Customer No.", Rec."Customer No.");
                                        if L_ShiptoAddress.FindFirst() then begin
                                            CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, Rec."Customer No.", L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", Rec."Order Date", Rec."Item No.", L_ShiptoAddress."Post Code", '');
                                        end;
                                    end else begin
                                        CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, Rec."Customer No.", L_Customer."Customer Posting Group", L_Customer."Country/Region Code", Rec."Order Date", Rec."Item No.", L_Customer."Post Code", '');
                                    end;
                                end;

                                //Check Special Promotion Item on Top Screen++
                                L_SalesPriceHeader.Reset();
                                L_SalesPriceHeader.SetRange("Special Price Daily", true);
                                if L_SalesPriceHeader.FindFirst() then begin
                                    L_PriceListLine.Reset();
                                    L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                                    L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                                    L_PriceListLine.SetRange("Product No.", Rec."Item No.");
                                    if L_PriceListLine.FindFirst() then begin
                                        Rec.Validate("Special Item on Top SCreen", true);
                                    end;
                                end;

                                //Rec.Insert();
                            end;
                        end;

                        //Update flow fields Description, Inventory etc.++
                        CurrPage.Update();
                    end;

                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = G_Colour;
                }
                field("Units of Measure"; Rec."Units of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = G_Colour;
                    Visible = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = G_Colour;
                    Visible = false;
                }


                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = all;

                    DecimalPlaces = 0 : 5;
                    Editable = Rec."Item No." <> '';
                    StyleExpr = G_Colour;

                    //This Code Moved to Ochannel Extension++
                    // trigger OnValidate()
                    // var
                    //     RecUserSetup: Record "User Setup";
                    //     CustomerTrendSalesQuota: Codeunit "Customer Trend Sales Quota";
                    // begin
                    //     //Check Item Sales Quota (For Both Promotion and Normal Item)++
                    //     CurrPage.Update();
                    //     if Rec."Qty. to be added to SO" > 0 then begin
                    //         IF RecUserSetup.GET(USERID) THEN BEGIN
                    //             IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                    //                 CustomerTrendSalesQuota.CheckExceededQty(Rec);
                    //             END;
                    //         END ELSE BEGIN
                    //             CustomerTrendSalesQuota.CheckExceededQty(Rec);
                    //         END;
                    //     end;
                    // end;
                }

                field("Min Sell Price"; Rec."Min Sell Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    StyleExpr = G_Colour;

                }
                field("Line Disc %"; Rec."Line Disc %")
                {
                    ApplicationArea = all;
                    StyleExpr = G_Colour;
                    Editable = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                }
                field("Line Amount"; Rec.Amount)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("VAT amount"; Rec."VAT amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                }

                field("Last Unit Price"; Rec."Last Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                    ToolTip = 'Last sales unit price';
                }

                // field("Total Physical"; Rec."Total Physical")
                // {
                //     Editable = false;
                //     ApplicationArea = All;
                //     ToolTip = 'Total Inventory';
                //     Caption = 'Total Physical';
                //     StyleExpr = G_Colour;
                // }
                // field("Total Allocated on SO"; Rec."Total Allocated on SO")
                // {
                //     Editable = false;
                //     ApplicationArea = All;
                //     ToolTip = 'Sum of Outstanding Qty on SO across ALL Locations';
                //     DecimalPlaces = 0 : 5;
                //     Caption = 'Total Allocated on SO';
                //     StyleExpr = G_Colour;
                // }
                // field(Physical; Rec.Physical)
                // {
                //     Editable = false;
                //     ApplicationArea = All;
                //     ToolTip = 'Qty available';
                //     DecimalPlaces = 0 : 5;
                //     Caption = 'Physical';
                //     StyleExpr = G_Colour;
                // }
                // field("Allocated on SO"; Rec."Allocated on SO")
                // {
                //     Editable = false;
                //     ApplicationArea = All;
                //     ToolTip = 'Sum of Outstanding SO Qty.';
                //     DecimalPlaces = 0 : 5;
                //     Caption = 'Allocated on SO';
                //     StyleExpr = G_Colour;
                // }
                field("Shipper Qty"; Rec."Shipper Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = G_Colour;
                }
                // field("Pallet Qty"; Rec."Pallet Qty")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }


                // field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("VAT %"; Rec."VAT %")
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                // }

            }
            group(Control51)
            {
                ShowCaption = false;
                // group(Control45)
                // {
                //     ShowCaption = false;

                //     field(LineAmount; LineAmount)

                //     {
                //         ApplicationArea = Basic, Suite;
                //         Caption = 'Subtotal Excl. VAT (GBP)';
                //         Editable = false;
                //         ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document.';
                //     }
                //     field("Invoice Discount Amount"; InvoiceDiscountAmount)
                //     {
                //         ApplicationArea = Basic, Suite;
                //         Caption = 'Inv. Discount Amount Excl. VAT (GBP)';
                //         Editable = false;

                //     }
                //     field("Invoice Disc. Pct."; InvoiceDiscountPct)
                //     {
                //         ApplicationArea = Basic, Suite;
                //         Caption = 'Invoice Discount %';

                //         Editable = false;


                //     }
                // }
                group(Control28)
                {
                    ShowCaption = false;
                    field(Amount; Amount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Total Excl. VAT (GBP)';
                        DrillDown = false;
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Excl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                    field("Total VAT Amount"; VATAmount)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Total VAT (GBP)';
                        Editable = false;
                        ToolTip = 'Specifies the sum of VAT amounts on all lines in the document.';
                    }
                    field(AmountIncVat; AmountIncVat)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Total Incl. VAT (GBP)';
                        Editable = false;
                        ToolTip = 'Specifies the sum of the value in the Line Amount Incl. VAT field on all lines in the document minus any discount amount in the Invoice Discount Amount field.';
                    }
                }
            }
        }

    }




    //Moved this code on Ochannel Extension for calculation++
    // local procedure TotalAvailableQtyForSealable(_Rec: Record CustomerTrends): Decimal
    // var
    //     ItemVariant: Record "Item Variant";
    //     _LocationCode: Code[20];
    //     L_ILE: Record "Item Ledger Entry";
    //     SaleableInventory: Decimal;
    //     L_SalesLine: Record "Sales Line";
    //     SaleableQtyOnSO: Decimal;
    //     item: Record Item;
    // begin
    //     _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory");
    //     if _Rec."Saleable Inventory" > 0 then
    //         if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
    //             exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
    //         else
    //             exit(0)
    //     else
    //         exit(0);
    // end;
    //Moved this code on Ochannel Extension for calculation++






    trigger OnAfterGetCurrRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
        Clear(LineAmount);
        Clear(Amount);
        Clear(AmountIncVat);
        Clear(VATAmount);
        Clear(InvoiceDiscountAmount);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Entry Number", Rec."Entry Number");
        if L_CustomerTrends.FindSet() then begin
            repeat
                //LineAmount += (L_CustomerTrends.Amount - L_CustomerTrends."Line Discount Amount");
                AmountIncVat += L_CustomerTrends."Amount Including VAT";
                VATAmount += L_CustomerTrends."VAT amount";
                Amount += L_CustomerTrends.Amount;
                LineAmount += L_CustomerTrends.Amount;
            //InvoiceDiscountAmount += L_CustomerTrends."Line Discount Amount";
            until L_CustomerTrends.Next() = 0;
        end;

        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;

    trigger OnAfterGetRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
        L_CustomerTrendHeader: Record "Customer Trend Header";
    begin
        Clear(LineAmount);
        Clear(Amount);
        Clear(AmountIncVat);
        Clear(VATAmount);
        Clear(InvoiceDiscountAmount);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Entry Number", Rec."Entry Number");
        if L_CustomerTrends.FindSet() then begin
            repeat
                //LineAmount += (L_CustomerTrends.Amount - L_CustomerTrends."Line Discount Amount");
                AmountIncVat += L_CustomerTrends."Amount Including VAT";
                VATAmount += L_CustomerTrends."VAT amount";
                Amount += L_CustomerTrends.Amount;
                LineAmount += L_CustomerTrends.Amount;
            //InvoiceDiscountAmount += L_CustomerTrends."Line Discount Amount";
            until L_CustomerTrends.Next() = 0;
        end;


        //Set Color For Special Items on Top Screen++
        Clear(G_Colour);
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CustomerTrends.SetRange("Customer No.", Rec."Customer No.");
        L_CustomerTrends.SetRange("Special Promotion", false); //For Top SCreen
        L_CustomerTrends.SetRange("Item No.", Rec."Item No.");
        if L_CustomerTrends.FindFirst() then begin
            if L_CustomerTrends."Special Item on Top SCreen" = true then
                G_Colour := 'Favorable';
        end;
    end;




    var
        G_Colour: Text;
        InvDiscAmountEditable: Boolean;
        InvoiceDiscountAmount: Decimal;
        InvoiceDiscountPct: Decimal;
        VATAmount: Decimal;
        LineAmount: Decimal;
        Amount: Decimal;
        AmountIncVat: Decimal;

}