page 80126 "Customer Trends"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Tasks;
    SourceTable = CustomerTrends;
    DelayedInsert = true;



    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(SalesPersonCodeFilter; SalesPersonCodeFilter)
                {
                    Caption = 'SalesPerson/Purchaser Code';
                    Editable = false;
                    ShowMandatory = true;
                    TableRelation = "Salesperson/Purchaser";
                    trigger OnValidate()
                    var
                        L_SpecialPromotions: Page "Special Promotions";
                    begin
                        //Clear Filters++
                        Clear(CustomerAccountNoFilter);
                        Clear(CustomerAccountName);
                        Clear(ShippingAgentCodeFilter);
                        Clear(ShippingAgentServiceCodeFilter);
                        Clear(WeekendShippingAgentServiceCodeFilter);
                        Clear(WeekendShippingAgentCodeFilter);
                        Clear(DeliveryDate);
                        Clear(LocationCodeFilter);
                        Clear(OrderDateFilter);
                        Clear(WorkDescription);
                        Clear(MinOrderValue);

                        //Aply Filter++
                        FilterOnAfterValidate;
                    end;
                }
                field(CustomerAccountNoFilter; CustomerAccountNoFilter)
                {
                    Caption = 'Sell-to Customer No.';
                    ShowMandatory = true;
                    Editable = Edit_CustomerAccountNo;
                    TableRelation = Customer;
                    trigger OnValidate()
                    var
                        L_SpecialPromotions: Page "Special Promotions";
                        L_Customer: Record Customer;
                        L_SalesPriceHeader: Record "Price List Header";
                        L_PriceListLine: Record "Price List Line";
                        CH_ILE: Record "Item Ledger Entry";
                        CTFunctions: Codeunit "CT Functions";
                        L_Location: Record Location;
                        L_Date: Record Date;
                    begin
                        L_Customer.Reset();
                        L_Customer.SetRange("No.", CustomerAccountNoFilter);
                        if L_Customer.FindFirst() then begin
                            //Check Master Approval++
                            L_Customer.TestField("QAU Approved");
                            L_Customer.TestField(Status, L_Customer.Status::Released);

                            CustomerAccountName := L_Customer.Name;

                            //Update Shipping details from customer if customer trends are not available++
                            //If Customer trends exist then shipping details updating FilterOnAfterValidate
                            ShippingAgentCodeFilter := L_Customer."Shipping Agent Code";
                            ShippingAgentServiceCodeFilter := L_Customer."Shipping Agent Service Code";
                            WeekendShippingAgentCodeFilter := L_Customer."Weekend Shipping Agent Code";
                            WeekendShippingAgentServiceCodeFilter := L_Customer."Weekend Ship. Agnt. Serv. Code";


                            //Get Default Location++
                            L_Location.Reset();
                            L_Location.SetRange("Customer Trend Default Loc", true);
                            if L_Location.FindFirst() then
                                LocationCodeFilter := L_Location.Code
                            else
                                Clear(LocationCodeFilter);
                        end else begin
                            //Clear Filters++
                            Clear(CustomerAccountName);
                            Clear(ShippingAgentCodeFilter);
                            Clear(ShippingAgentServiceCodeFilter);
                            Clear(WeekendShippingAgentCodeFilter);
                            Clear(WeekendShippingAgentServiceCodeFilter);
                            Clear(DeliveryDate);
                            Clear(LocationCodeFilter);
                            Clear(OrderDateFilter);
                            Clear(WorkDescription);
                            Clear(MinOrderValue);
                        end;

                        //Inset customer trends for 1 week and Promotion Items++
                        if CustomerAccountNoFilter <> '' then begin
                            if SalesPersonCodeFilter = '' then
                                Error('SalesPerson/Purchaser Code should not be blank.');

                            //Insert Special Promotions Item++
                            L_SalesPriceHeader.Reset();
                            L_SalesPriceHeader.SetRange("Special Price Daily", true);
                            if L_SalesPriceHeader.FindFirst() then begin
                                L_PriceListLine.Reset();
                                L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                                L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                                if L_PriceListLine.FindSet() then begin
                                    repeat
                                        CTFunctions.FromCustomerNumberFIlte_InsertAndModifyTrendsForPromostion(L_PriceListLine, CustomerAccountNoFilter, SalesPersonCodeFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter, WeekendShippingAgentCodeFilter, WorkDescription);
                                    until L_PriceListLine.Next() = 0;
                                end;
                            end;

                            // //Insert last 1 week data++
                            // CH_ILE.Reset();
                            // CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-1W>', Today), TODAY);
                            // CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
                            // CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
                            // CH_ILE.SetRange("Source No.", CustomerAccountNoFilter);
                            // if CH_ILE.FindSet() then begin
                            //     repeat
                            //         CTFunctions.FromCustomerNumberFilter_InsertAndModifyTrends(CH_ILE, SalesPersonCodeFilter, CustomerAccountNoFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter, WeekendShippingAgentCodeFilter, WorkDescription);
                            //     until CH_ILE.Next() = 0;
                            // end;

                            //Update Shipment Date, Order Date, and Min Order Value++
                            L_Customer.Reset();
                            L_Customer.SetRange("No.", CustomerAccountNoFilter);
                            if L_Customer.FindFirst() then begin
                                MinOrderValue := L_Customer."Min Order Value";

                                //Update Shipmet date++
                                L_Date.Reset();
                                L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                                L_Date.SetRange(L_Date."Period Start", Today);
                                if L_Date.FindFirst() then
                                    if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                                        if L_Customer."Weekend Ship. Agnt. Serv. Code" <> '' then
                                            //Update Saturday++
                                            DeliveryDate := CalcDate('<+1D>', Today)
                                        else
                                            //Update Monday
                                            DeliveryDate := CalcDate('<+3D>', Today);
                                    end else
                                        DeliveryDate := CalcDate('<+1D>', Today);
                            end;

                            //Update Order Date++
                            OrderDateFilter := WorkDate();
                        end;
                        //Apply Filter++
                        FilterOnAfterValidate;
                    end;
                }
                field(CustomerAccountName; CustomerAccountName)
                {
                    Caption = 'Sell-to Customer Name';
                    Editable = false;
                }
                field(OrderDateFilter; OrderDateFilter)
                {
                    Caption = 'Order Date';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(DeliveryDate; DeliveryDate)
                {
                    Caption = 'Shipment Date';
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                    begin
                        if CustomerAccountNoFilter = '' then
                            Error('Sell-to Customer No. should not be blank.');

                        if SalesPersonCodeFilter = '' then
                            Error('SalesPerson/Purchaser Code should not be blank.');

                        //Update Shipmet date to existing lines++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Delivery Date", DeliveryDate);
                        end;
                    end;
                }
                field(ShippingAgentCodeFilter; ShippingAgentCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Code';
                    TableRelation = "Shipping Agent";
                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                        ShippingAgent: Record "Shipping Agent";
                    begin
                        //Check Master Approval++
                        if ShippingAgentCodeFilter <> '' then begin
                            if CustomerAccountNoFilter = '' then
                                Error('Sell-to Customer No. should not be blank.');

                            if SalesPersonCodeFilter = '' then
                                Error('SalesPerson/Purchaser Code should not be blank.');


                            ShippingAgent.Reset();
                            ShippingAgent.SetRange(code, ShippingAgentCodeFilter);
                            ShippingAgent.SetRange(Status, ShippingAgent.Status::Released);
                            if Not ShippingAgent.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent.');
                        end;


                        //Update Lines+++
                        ShippingAgentServiceCodeFilter := '';


                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Shipping Agent Code", ShippingAgentCodeFilter);
                            L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
                        end;
                    end;
                }
                field(ShippingAgentServiceCodeFilter; ShippingAgentServiceCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Service Code';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Page_ShippingAgentServices: Page "Shipping Agent Services";
                        Table_ShippingAgentServices: Record "Shipping Agent Services";
                    begin
                        Clear(Page_ShippingAgentServices);
                        Table_ShippingAgentServices.Reset();
                        Page_ShippingAgentServices.LookupMode := true;
                        Table_ShippingAgentServices.SetRange("Shipping Agent Code", ShippingAgentCodeFilter);
                        Page_ShippingAgentServices.SetTableView(Table_ShippingAgentServices);
                        if Page_ShippingAgentServices.RunModal() = Action::LookupOK then begin
                            Page_ShippingAgentServices.GetRecord(Table_ShippingAgentServices);
                            Text := Table_ShippingAgentServices.Code;
                        end else
                            exit(false);
                        exit(true);
                    end;

                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                        ShippingAgentServices: Record "Shipping Agent Services";
                        L_ConfimationMessage: Label 'Customer trend lines are exist.\\Do you want to modify Shipping Agent Service Code?';
                        L_SalesEventAndFunction: Codeunit "Sales Event & Function";
                    begin
                        if ShippingAgentServiceCodeFilter <> '' then begin
                            if CustomerAccountNoFilter = '' then
                                Error('Sell-to Customer No. should not be blank.');

                            if SalesPersonCodeFilter = '' then
                                Error('SalesPerson/Purchaser Code should not be blank.');



                            if ShippingAgentCodeFilter = '' then
                                Error('Shipping Agent Code should not be blank');

                            //Check Mater APproval++
                            ShippingAgentServices.Reset();
                            ShippingAgentServices.SetRange(code, ShippingAgentServiceCodeFilter);
                            ShippingAgentServices.SetRange(Status, ShippingAgentServices.Status::Released);
                            if Not ShippingAgentServices.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent Service.');

                            //Check Shipping Agent Service COde Restriction++
                            L_Customertrends.Reset();
                            L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                            L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                            L_Customertrends.SetRange("Special Promotion", false);
                            if L_Customertrends.FindSet() then begin
                                repeat
                                    L_SalesEventAndFunction.CheckShippingAgentServiceRestriction(L_Customertrends."Item No.", ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter)
                                until L_Customertrends.Next() = 0;
                            end;

                        end;

                        //Update Lines+++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
                        end;
                    end;
                }

                field(WeekendShippingAgentCodeFilter; WeekendShippingAgentCodeFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Weekend Shipping Agent Code';
                    TableRelation = "Shipping Agent";
                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                        ShippingAgent: Record "Shipping Agent";
                    begin
                        //Check Master Approval++
                        if WeekendShippingAgentCodeFilter <> '' then begin
                            if CustomerAccountNoFilter = '' then
                                Error('Sell-to Customer No. should not be blank.');

                            if SalesPersonCodeFilter = '' then
                                Error('SalesPerson/Purchaser Code should not be blank.');


                            ShippingAgent.Reset();
                            ShippingAgent.SetRange(code, WeekendShippingAgentCodeFilter);
                            ShippingAgent.SetRange(Status, ShippingAgent.Status::Released);
                            if Not ShippingAgent.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent.');
                        end;


                        //Update Lines+++
                        WeekendShippingAgentServiceCodeFilter := '';


                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Weekend Shipping Agent Code", WeekendShippingAgentCodeFilter);
                            L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
                        end;
                    end;
                }
                field(WeekendShippingAgentServiceCodeFilter; WeekendShippingAgentServiceCodeFilter)
                {
                    ApplicationArea = All;
                    //Editable = EditDeliveryDate;
                    Caption = 'Weekend Shipping Agent Service Code';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Page_ShippingAgentServices: Page "Shipping Agent Services";
                        Table_ShippingAgentServices: Record "Shipping Agent Services";
                    begin
                        Clear(Page_ShippingAgentServices);
                        Table_ShippingAgentServices.Reset();
                        Page_ShippingAgentServices.LookupMode := true;
                        Table_ShippingAgentServices.SetRange("Shipping Agent Code", WeekendShippingAgentCodeFilter);
                        Page_ShippingAgentServices.SetTableView(Table_ShippingAgentServices);
                        if Page_ShippingAgentServices.RunModal() = Action::LookupOK then begin
                            Page_ShippingAgentServices.GetRecord(Table_ShippingAgentServices);
                            Text := Table_ShippingAgentServices.Code;
                        end else
                            exit(false);

                        exit(true);
                    end;

                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                        ShippingAgentServices: Record "Shipping Agent Services";
                    begin
                        if WeekendShippingAgentServiceCodeFilter <> '' then begin
                            if CustomerAccountNoFilter = '' then
                                Error('Sell-to Customer No. should not be blank.');

                            if SalesPersonCodeFilter = '' then
                                Error('SalesPerson/Purchaser Code should not be blank.');


                            if ShippingAgentCodeFilter = '' then
                                Error('Shipping Agent Code should not be blank');

                            //Check Master Approval+++
                            ShippingAgentServices.Reset();
                            ShippingAgentServices.SetRange(code, WeekendShippingAgentServiceCodeFilter);
                            ShippingAgentServices.SetRange(Status, ShippingAgentServices.Status::Released);
                            if Not ShippingAgentServices.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent Service.');
                        end;


                        //Update Lines+++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
                        end;
                    end;
                }
                field(MinOrderValue; MinOrderValue)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Min Order Value';
                }
                field(LocationCodeFilter; LocationCodeFilter)
                {
                    Caption = 'Location Code';
                    ApplicationArea = All;
                    Editable = false;
                    TableRelation = Location.Code where("Customer Trend Default Loc" = const(true));
                    Visible = false;
                }

                field(WorkDescription; WorkDescription)
                {
                    ApplicationArea = All;
                    MultiLine = true;
                    Caption = 'Work Description';
                    Editable = (CustomerAccountNoFilter <> '') AND (SalesPersonCodeFilter <> '');

                    trigger OnValidate()
                    var
                        L_Customertrends: Record CustomerTrends;
                    begin
                        //Update Lines+++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Work Description", WorkDescription);
                        end;
                    end;
                }
            }
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
                    begin

                        if SalesPersonCodeFilter = '' then
                            Error('SalesPerson/Purchaser Code should not be blank.');

                        if CustomerAccountNoFilter = '' then
                            Error('Customer Account No. should not be blank.');

                        //Check Shipping Restriction for existing Lines++
                        L_SalesAndEvent.CheckShippingAgentServiceRestriction(Rec."Item No.", ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter);

                        L_Item.Reset();
                        L_Item.SetRange("No.", Rec."Item No.");
                        if L_Item.FindFirst() then begin
                            //Check Master Approval++
                            L_Item.TestField("QAU Approved", true);
                            L_Item.TestField(Status, L_Item.Status::Released);
                            L_Item.TestField("Special Product", false);


                            Rec."Item Description" := L_Item.Description;
                            Rec."Units of Measure" := L_Item."Sales Unit of Measure";
                            Rec.Validate("Min Sell Price", L_Item."Min Sell Price");
                            Rec.RRP := L_Item.RRP;
                            Rec."Special Promotion" := false;
                            Rec."Item Category Code" := L_Item."Item Category Code";
                            Rec."Order Date" := WorkDate();
                            //Rec.Validate("Unit Price", L_Item."Unit Price");
                            Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", 0, Rec."Order Date"));
                            Rec.Validate("Line Disc %", EventAndSubscriber.CustomerTrend_GetLineDiscount(Rec."Customer No.", Rec."Item No.", 0, Rec."Order Date"));

                            Rec."Work Description" := WorkDescription;
                            Rec.Validate("Created By", UserId);
                            Rec.Validate("Created On", CurrentDateTime);
                            Rec.Validate("Updated By", UserId);
                            Rec.Validate("Updated On", CurrentDateTime);

                            Rec."Salesperson Code" := SalesPersonCodeFilter;
                            Rec."Customer No." := CustomerAccountNoFilter;
                            Rec."Delivery Date" := DeliveryDate;
                            Rec."Shipping Agent Code" := ShippingAgentCodeFilter;
                            Rec."Shipping Agent Service Code" := ShippingAgentServiceCodeFilter;
                            Rec."Weekend Shipping Agent Code" := WeekendShippingAgentCodeFilter;
                            Rec."Weekend Ship. Agnt. Serv. Code" := WeekendShippingAgentServiceCodeFilter;


                            //Get the last unit price from sales shipment table++
                            CH_SShip.Reset();
                            CH_SShip.SetRange("Sell-to Customer No.", Rec."Customer No.");
                            CH_SShip.SetRange("No.", Rec."Item No.");
                            CH_SShip.SetRange("Unit of Measure Code", Rec."Units of Measure");
                            if CH_SShip.FindLast() then
                                Rec."Last Price" := CH_SShip."Unit Price";


                            //Get Shipper Quantity from Item unit measure table++
                            L_ItemUnitofMeasure.Reset();
                            L_ItemUnitofMeasure.SetRange("Item No.", Rec."Item No.");
                            L_ItemUnitofMeasure.SetRange(Code, Rec."Units of Measure");
                            if L_ItemUnitofMeasure.FindFirst() then
                                Rec."Shipper Qty" := L_ItemUnitofMeasure."Qty. per Unit of Measure";


                            //Get Default Location++
                            L_Location.Reset();
                            L_Location.SetRange("Customer Trend Default Loc", true);
                            if L_Location.FindFirst() then
                                Rec."Location Code" := L_Location.Code;


                            //Company License Validatio++
                            L_Customer.Reset();
                            L_Customer.SetRange("No.", CustomerAccountNoFilter);
                            if L_Customer.FindFirst() then begin
                                Rec."Ship-to Code" := L_Customer."Ship-to Code";
                                Rec."Customer Price Group" := L_Customer."Customer Price Group";
                                Rec."Min Order Value" := L_Customer."Min Order Value";

                                if L_Customer."Ship-to Code" <> '' then begin
                                    L_ShiptoAddress.Reset();
                                    L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                                    L_ShiptoAddress.SetRange("Customer No.", CustomerAccountNoFilter);
                                    if L_ShiptoAddress.FindFirst() then begin
                                        CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", Rec."Order Date", Rec."Item No.", L_ShiptoAddress."Post Code");
                                    end;
                                end else begin
                                    CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", Rec."Order Date", Rec."Item No.", L_Customer."Post Code");
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

                            //Update flow fields Description, Inventory etc.++
                            CurrPage.Update();
                        end;
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

                field("Min Sell Price"; Rec."Min Sell Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                }
                field("Line Disc %"; Rec."Line Disc %")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = G_Colour;
                }

                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    StyleExpr = G_Colour;
                    Editable = Rec."Item No." <> '';
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
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = all;

                    DecimalPlaces = 0 : 5;
                    Editable = Rec."Item No." <> '';
                    StyleExpr = G_Colour;
                    trigger OnValidate()
                    var
                        RecUserSetup: Record "User Setup";
                        CustomerTrendSalesQuota: Codeunit "Customer Trend Sales Quota";
                    begin
                        //Check Item Sales Quota (For Both Promotion and Normal Item)++
                        CurrPage.Update();
                        IF RecUserSetup.GET(USERID) THEN BEGIN
                            IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                                CustomerTrendSalesQuota.CheckExceededQty(Rec);
                            END;
                        END ELSE BEGIN
                            CustomerTrendSalesQuota.CheckExceededQty(Rec);
                        END;
                    end;
                }

            }
            part("Special Promotions"; "Special Promotions")
            {
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(true), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No.");
                UpdatePropagation = Both;
            }
        }
        // area(factboxes)
        // {
        //     systempart(Control1905767507; Notes)
        //     {
        //         ApplicationArea = Notes;
        //     }
        //     part(Control1902018507; "Customer Statistics FactBox")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         SubPageLink = "No." = FIELD("Customer No.");
        //     }
        //     part(Control1900316107; "Customer Details FactBox")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         SubPageLink = "No." = FIELD("Customer No.");
        //     }
        //     part(Control1901314507; "Item Invoicing FactBox")
        //     {
        //         ApplicationArea = Basic, Suite;
        //         SubPageLink = "No." = FIELD("Item No.");
        //     }
        // }
    }


    actions
    {
        area(Processing)
        {

            //Moved this button to KNAPP extension becuase of KNAPP Code++
            // action("Register Sales Order")
            // {
            //     ApplicationArea = All;
            //     Image = Register;

            //     trigger OnAction()
            //     var
            //         CTFunctions: Codeunit "CT Functions";
            //         L_Customertrends: Record CustomerTrends;
            //     begin
            //         if not Confirm('Do you want to register?', false) then
            //             Error('');

            //         if SalesPersonCodeFilter = '' then
            //             Error('SalesPerson/Purchaser Code should not be blank');

            //         if CustomerAccountNoFilter = '' then
            //             Error('Customer Account No. should not be blank');

            //         //Update Latest Delivery Date, and Shipping details++
            //         L_Customertrends.Reset();
            //         L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
            //         L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
            //         if L_Customertrends.FindSet() then begin
            //             L_Customertrends.ModifyAll("Delivery Date", DeliveryDate);
            //             L_Customertrends.ModifyAll("Shipping Agent Code", ShippingAgentCodeFilter);
            //             L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
            //             L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
            //             L_Customertrends.ModifyAll("Location Code", LocationCodeFilter);
            //         end;

            //         //Create and Update SO++
            //         CTFunctions.CreateAndUpdateSalesOrder(CustomerAccountNoFilter, SalesPersonCodeFilter);
            //     end;
            // }
            //Moved this button to KNAPP extension becuase of KNAPP Code++

            action(Clear)
            {
                ApplicationArea = All;
                Image = Delete;

                trigger OnAction()
                var
                    L_CustTrends: Record CustomerTrends;
                begin
                    if not Confirm('Do you want to Delete?', false) then
                        Error('');

                    L_CustTrends.Reset();
                    L_CustTrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                    L_CustTrends.SetRange("Customer No.", CustomerAccountNoFilter);
                    if L_CustTrends.FindSet() then begin
                        L_CustTrends.DeleteAll();
                    end;

                    Clear(CustomerAccountNoFilter);
                    Clear(CustomerAccountName);
                    Clear(OrderDateFilter);
                    Clear(DeliveryDate);
                    Clear(ShippingAgentCodeFilter);
                    Clear(ShippingAgentServiceCodeFilter);
                    Clear(WeekendShippingAgentServiceCodeFilter);
                    Clear(WeekendShippingAgentCodeFilter);
                    Clear(LocationCodeFilter);
                    Clear(WorkDescription);
                    Clear(MinOrderValue);
                    CurrPage.Update();
                end;
            }
            action(Comments)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = ViewComments;
                ToolTip = 'View or add comments for the record.';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    L_CommentLine: Record "Comment Line";
                    CommentSheet: Page "Comment Sheet";
                begin
                    Clear(CommentSheet);
                    L_CommentLine.Reset();
                    L_CommentLine.SetRange("No.", CustomerAccountNoFilter);
                    if L_CommentLine.FindFirst() then begin
                        CommentSheet.SetTableView(L_CommentLine);
                        CommentSheet.Run();
                    end;

                end;
            }
            action("Past Months Details")
            {
                ApplicationArea = All;
                Image = Report;
                trigger OnAction();
                var
                    CustomerTrendDetails: report "Customer Trend Details";
                begin
                    if SalesPersonCodeFilter = '' then
                        Error('SalesPerson/Purchaser Code should not be blank.');

                    if CustomerAccountNoFilter = '' then
                        Error('Customer Account No. should not be blank.');

                    if DeliveryDate = 0D then
                        Error('Delivery Date should not be blank.');

                    Clear(CustomerTrendDetails);
                    CustomerTrendDetails.GetFilters(SalesPersonCodeFilter, CustomerAccountNoFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter, WorkDescription, WeekendShippingAgentCodeFilter);
                    CustomerTrendDetails.Run();
                end;

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


    local procedure FilterOnAfterValidate()
    var
        myInt: Integer;
    begin
        SetRecFilters;
    end;

    procedure SetRecFilters()
    var
        L_CustomerTrends: Record CustomerTrends;
        L_Customer: Record Customer;
    begin
        if SalesPersonCodeFilter <> '' then
            Rec.SetFilter("Salesperson Code", SalesPersonCodeFilter)
        else
            Rec.SetRange("Salesperson Code", '');

        if CustomerAccountNoFilter <> '' then
            Rec.SetFilter("Customer No.", CustomerAccountNoFilter)
        else
            Rec.SetRange("Customer No.", '');

        //Update Variables filter+++
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
        L_CustomerTrends.SetRange("Customer No.", CustomerAccountNoFilter);
        L_CustomerTrends.SetRange("Special Promotion", true);
        if L_CustomerTrends.FindFirst() then begin
            DeliveryDate := L_CustomerTrends."Delivery Date";
            ShippingAgentCodeFilter := L_CustomerTrends."Shipping Agent Code";
            ShippingAgentServiceCodeFilter := L_CustomerTrends."Shipping Agent Service Code";
            WeekendShippingAgentCodeFilter := L_CustomerTrends."Weekend Shipping Agent Code";
            WeekendShippingAgentServiceCodeFilter := L_CustomerTrends."Weekend Ship. Agnt. Serv. Code";
            LocationCodeFilter := L_CustomerTrends."Location Code";
            OrderDateFilter := L_CustomerTrends."Order Date";
            WorkDescription := L_CustomerTrends."Work Description";
            MinOrderValue := L_CustomerTrends."Min Order Value";
        end;

        //Update Customer Name++
        Clear(CustomerAccountName);
        L_Customer.SetRange("No.", CustomerAccountNoFilter);
        if L_Customer.FindFirst() then
            CustomerAccountName := L_Customer.Name;

        CurrPage.Update(false);
    end;

    trigger OnOpenPage()
    var
        L_UserSetup: Record "User Setup";
    begin
        Rec.SetFilter("Date Filter", '>=%1', WorkDate());


        //Filter Promotion Item++
        Rec.SetFilter("Special Promotion", '%1', false);

        Clear(SalesPersonCodeFilter);
        Clear(CustomerAccountNoFilter);
        Clear(CustomerAccountName);
        Clear(OrderDateFilter);
        Clear(DeliveryDate);
        Clear(ShippingAgentCodeFilter);
        Clear(ShippingAgentServiceCodeFilter);
        Clear(WeekendShippingAgentCodeFilter);
        Clear(WeekendShippingAgentServiceCodeFilter);
        Clear(LocationCodeFilter);
        Clear(WorkDescription);
        Clear(MinOrderValue);
        if G_IsopenFromCallDistribution = true then begin
            SalesPersonCodeFilter := G_SalesPersonCode;
            CustomerAccountNoFilter := G_CustomerAccountNo;

            Edit_CustomerAccountNo := false;

            //Aply Filter++
            SetRecFilters;
        end else begin
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Salespers./Purch. Code" <> '' then
                    SalesPersonCodeFilter := L_UserSetup."Salespers./Purch. Code";
            end;

            Edit_CustomerAccountNo := true;

            //Aply Filter++
            SetRecFilters;
        end;

        //Clear Global Variable++
        Clear(G_IsopenFromCallDistribution);
    end;

    trigger OnAfterGetCurrRecord()
    var
        L_CustomerTrends: Record CustomerTrends;
    begin
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
    begin
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

    procedure GetFilters(_CustomerNo: Code[20]; _SalesPersonCode: Code[20]; _DeliveryDate: Date; _IsopenFromCallDistribution: Boolean; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    begin
        Clear(G_CustomerAccountNo);
        Clear(G_SalesPersonCode);
        Clear(G_DeliveryDate);
        Clear(G_IsopenFromCallDistribution);
        Clear(G_ShippingAgentCode);
        Clear(G_ShippingAgentServiceCode);
        G_IsopenFromCallDistribution := _IsopenFromCallDistribution;
        G_DeliveryDate := _DeliveryDate;
        G_ShippingAgentCode := _ShippingAgentCode;
        G_ShippingAgentServiceCode := _ShippingAgentServiceCode;
        G_CustomerAccountNo := _CustomerNo;
        G_SalesPersonCode := _SalesPersonCode;
    end;



    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        L_CutomerTrend: Record CustomerTrends;
    begin
        if (CustomerAccountNoFilter <> '') AND (SalesPersonCodeFilter <> '') then begin
            L_CutomerTrend.Reset();
            L_CutomerTrend.SetRange("Salesperson Code", SalesPersonCodeFilter);
            L_CutomerTrend.SetRange("Customer No.", CustomerAccountNoFilter);
            //L_CutomerTrend.SetFilter("Qty. to be added to SO", '>%1', 0);
            if not L_CutomerTrend.IsEmpty then
                if not Confirm('Sales Order has not been Registered. Are you sure you want to close the page?', false) then
                    Error('')
                else begin
                    L_CutomerTrend.Reset();
                    L_CutomerTrend.SetRange("Salesperson Code", SalesPersonCodeFilter);
                    L_CutomerTrend.SetRange("Customer No.", CustomerAccountNoFilter);
                    if L_CutomerTrend.FindSet() then begin
                        L_CutomerTrend.DeleteAll();
                    end;
                end;

        end;
    end;


    var
        Edit_CustomerAccountNo: Boolean;
        G_IsopenFromCallDistribution: Boolean;
        OrderNo: Code[20];
        ColorCode: Text;
        EnableWeekWise: Boolean;
        EnableMonthWise: Boolean;
        LocationCode: code[20];
        SalesPersonCodeFilter: Text;
        CustomerAccountNoFilter: Text;
        CustomerAccountName: Text;
        DeliveryDate: Date;
        G_DeliveryDate: Date;
        G_ShippingAgentCode: Code[20];
        G_ShippingAgentServiceCode: Code[20];
        ShippingAgentCodeFilter: Code[20];
        ShippingAgentServiceCodeFilter: Code[20];
        WeekendShippingAgentServiceCodeFilter: Code[20];
        WeekendShippingAgentCodeFilter: Code[20];
        G_SalesPersonCode: Code[20];
        G_CustomerAccountNo: Code[20];

        LocationCodeFilter: Code[20];
        OrderDateFilter: Date;

        WorkDescription: Text[2048];

        G_Colour: Text;
        MinOrderValue: Decimal;

}