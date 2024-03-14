page 80126 "Customer Trends"
{
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CustomerTrends;
    DelayedInsert = true;
    Editable = true;
    InsertAllowed = true;
    DeleteAllowed = true;
    ModifyAllowed = true;

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
                    Editable = Edit_SalesPersonCodeFilter;
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
                        Clear(DeliveryDate);
                        Clear(LocationCodeFilter);
                        Clear(OrderDateFilter);

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
                    begin
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
                            Clear(WeekendShippingAgentServiceCodeFilter);
                            Clear(DeliveryDate);
                            Clear(LocationCodeFilter);
                            Clear(OrderDateFilter);
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
                                        CTFunctions.FromCustomerNumberFIlte_InsertAndModifyTrendsForPromostion(L_PriceListLine, CustomerAccountNoFilter, SalesPersonCodeFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter);
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
                            //         CTFunctions.FromCustomerNumberFilter_InsertAndModifyTrends(CH_ILE, SalesPersonCodeFilter, CustomerAccountNoFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter);
                            //     until CH_ILE.Next() = 0;
                            // end;

                            //Apply Filter++
                            FilterOnAfterValidate;
                        end;
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
                        L_ConfimationMessage: Label 'Customer trend lines are exist.\\Do you want to modify Shipping Agent Service Code?';
                    begin
                        if CustomerAccountNoFilter = '' then
                            Error('Sell-to Customer No. should not be blank.');

                        if SalesPersonCodeFilter = '' then
                            Error('SalesPerson/Purchaser Code should not be blank.');

                        //Confimation++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if not L_Customertrends.IsEmpty then begin
                            if not Confirm(L_ConfimationMessage, false) then
                                exit;
                        end;

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
                            ShippingAgent.Reset();
                            ShippingAgent.SetRange(code, ShippingAgentCodeFilter);
                            ShippingAgent.SetRange(Status, ShippingAgent.Status::Released);
                            if Not ShippingAgent.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent.');
                        end else begin
                            Clear(ShippingAgentServiceCodeFilter);
                            Clear(WeekendShippingAgentServiceCodeFilter);
                        end;

                        //Update Shipping Agent Code to existing lines++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Shipping Agent Code", ShippingAgentCodeFilter);
                            L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
                            L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
                        end;

                    end;
                }
                field(ShippingAgentServiceCodeFilter; ShippingAgentServiceCodeFilter)
                {
                    ApplicationArea = All;
                    //Editable = EditDeliveryDate;
                    Caption = 'Shipping Agent Service Code';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Page_ShippingAgentServices: Page "Shipping Agent Services";
                        Table_ShippingAgentServices: Record "Shipping Agent Services";
                    begin
                        Clear(Page_ShippingAgentServices);
                        Table_ShippingAgentServices.Reset();
                        Page_ShippingAgentServices.LookupMode := true;
                        if ShippingAgentCodeFilter <> '' then
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
                        L_Funcion: Codeunit "CT Functions";
                    begin
                        if ShippingAgentServiceCodeFilter <> '' then begin
                            //Check Mater APproval++
                            ShippingAgentServices.Reset();
                            ShippingAgentServices.SetRange(code, ShippingAgentServiceCodeFilter);
                            ShippingAgentServices.SetRange(Status, ShippingAgentServices.Status::Released);
                            if Not ShippingAgentServices.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent Service.');


                            //Check Shipping Restriction for existing Lines++
                            L_Customertrends.Reset();
                            L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                            L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                            if not L_Customertrends.IsEmpty then begin
                                if not Confirm(L_ConfimationMessage, false) then
                                    exit
                                else begin
                                    L_Customertrends.Reset();
                                    L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                                    L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                                    if L_Customertrends.FindSet() then begin
                                        repeat
                                            L_Funcion.CheckShippingAgentServiceRestriction(L_Customertrends."Item No.", ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter)
                                        until L_Customertrends.Next() = 0;
                                    end;
                                end;
                            end;
                        end;

                        //Upadte "Shipping Agent Service Code" on customer trends if line is exist++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
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
                        if ShippingAgentCodeFilter <> '' then
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
                        L_Funcion: Codeunit "CT Functions";
                    begin
                        if WeekendShippingAgentServiceCodeFilter <> '' then begin
                            //Check Master Approval+++
                            ShippingAgentServices.Reset();
                            ShippingAgentServices.SetRange(code, WeekendShippingAgentServiceCodeFilter);
                            ShippingAgentServices.SetRange(Status, ShippingAgentServices.Status::Released);
                            if Not ShippingAgentServices.FindFirst() then
                                Error('Status must be equal to Released in Shipping Agent Service.');

                            //Check Shipping Restriction for existing Lines++
                            L_Customertrends.Reset();
                            L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                            L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                            if not L_Customertrends.IsEmpty then begin
                                if not Confirm(L_ConfimationMessage, false) then
                                    exit
                                else begin
                                    L_Customertrends.Reset();
                                    L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                                    L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                                    if L_Customertrends.FindSet() then begin
                                        repeat
                                            L_Funcion.CheckShippingAgentServiceRestriction(L_Customertrends."Item No.", ShippingAgentCodeFilter, WeekendShippingAgentServiceCodeFilter)
                                        until L_Customertrends.Next() = 0;
                                    end;
                                end;
                            end;
                        end;


                        //Upadte "Weekend Shipping Agent Service Code" on customer trends if line is exist++
                        L_Customertrends.Reset();
                        L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
                        L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
                        if L_Customertrends.FindSet() then begin
                            L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
                        end;

                    end;
                }
                field(LocationCodeFilter; LocationCodeFilter)
                {
                    Caption = 'Location Code';
                    ApplicationArea = All;
                    Editable = false;
                    TableRelation = Location.Code where("Customer Trend Default Loc" = const(true));
                }

            }
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    //Editable = false;
                    StyleExpr = ColorCode;
                    TableRelation = Item;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                        L_Item: Record Item;
                        SalesPrice: Record "Price List Line";
                        CH_SShip: Record "Sales Shipment Line";
                        L_SalesLine: Record "Sales Line";
                        L_ItemUnitofMeasure: Record "Item Unit of Measure";
                        L_Funcion: Codeunit "CT Functions";
                        L_Location: Record Location;
                        CompanyLicenseValidation: Codeunit "Check Item License";
                        CalledFrom: Option "Sales","Purchase";
                        L_Customer: Record Customer;
                        L_ShiptoAddress: Record "Ship-to Address";
                        EventAndSubscriber: Codeunit EventSub;
                    begin

                        if SalesPersonCodeFilter = '' then
                            Error('SalesPerson/Purchaser Code should not be blank.');

                        if CustomerAccountNoFilter = '' then
                            Error('Customer Account No. should not be blank.');

                        //Check Shipping Restriction for existing Lines++
                        L_Funcion.CheckShippingAgentServiceRestriction(Rec."Item No.", ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter);

                        L_Item.Reset();
                        L_Item.SetRange("No.", Rec."Item No.");
                        if L_Item.FindFirst() then begin
                            //Check Master Approval++
                            L_Item.TestField("QAU Approved", true);
                            L_Item.TestField(Status, L_Item.Status::Released);


                            Rec."Units of Measure" := L_Item."Sales Unit of Measure";
                            Rec.Validate("Min Sell Price", L_Item."Min Sell Price");
                            Rec."Special Promotion" := false;
                            Rec."Item Category Code" := L_Item."Item Category Code";
                            //Rec.Validate("Unit Price", L_Item."Unit Price");
                            Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", 0));


                            Rec.Validate("Created By", UserId);
                            Rec.Validate("Created On", CurrentDateTime);
                            Rec.Validate("Updated By", UserId);
                            Rec.Validate("Updated On", CurrentDateTime);
                            Rec."Order Date" := WorkDate();
                            Rec."Salesperson Code" := SalesPersonCodeFilter;
                            Rec."Customer No." := CustomerAccountNoFilter;
                            Rec."Delivery Date" := DeliveryDate;
                            // Rec."Shipping Agent Code" := G_ShippingAgentCode;
                            // Rec."Shipping Agent Service Code" := G_ShippingAgentServiceCode;
                            Rec."Shipping Agent Code" := ShippingAgentCodeFilter;
                            Rec."Shipping Agent Service Code" := ShippingAgentServiceCodeFilter;
                            Rec."Weekend Ship. Agnt. Serv. Code" := WeekendShippingAgentServiceCodeFilter;


                            //GHet the last unit price from sales shipment table++
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

                                if L_Customer."Ship-to Code" <> '' then begin
                                    L_ShiptoAddress.Reset();
                                    L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                                    L_ShiptoAddress.SetRange("Customer No.", CustomerAccountNoFilter);
                                    if L_ShiptoAddress.FindFirst() then begin
                                        CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", DeliveryDate, Rec."Item No.", L_ShiptoAddress."Post Code");
                                    end;
                                end else begin
                                    CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", DeliveryDate, Rec."Item No.", L_Customer."Post Code");
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
                    StyleExpr = ColorCode;

                }
                field("Units of Measure"; Rec."Units of Measure")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;
                    Visible = false;
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;
                    Visible = false;
                }

                field("Min Sell Price"; Rec."Min Sell Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = ColorCode;
                }

                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    StyleExpr = ColorCode;
                }

                field("Last Unit Price"; Rec."Last Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = ColorCode;
                    ToolTip = 'Last sales unit price';
                }

                field(Inventory; Rec.Inventory)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Total Inventory';
                    Caption = 'Total Physical';
                }
                field("Physical"; Rec."Saleable Inventory")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Qty available in HD and SH';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Physical';
                }
                field("Allocated on SO"; Rec."Qty on SO(Saleable)")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Sum of Outstanding SO Qty in HD and SH';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Allocated on SO';
                }

                //Moved this code on Ochannel Extension for calculation++
                // field("Free (Saleable)"; TotalAvailableQtyForSealable(Rec))
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Saleable Inventory – Sum of Outstanding Qty on SO (Saleable)';
                //     //Caption = 'Total Available Quantity(Saleable)';
                //     Caption = 'Free (Saleable)';
                // }
                //Moved this code on Ochannel Extension for calculation++

                // field("Back Orders (Saleable)"; Rec."Back Orders (Saleable)")
                // {
                //     Caption = 'Back Orders (Saleable)';
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Unshipped Qty in HD and SH';

                //     trigger OnAssistEdit()
                //     var
                //         L_SalesLine: Record "Sales Line";
                //         Page_SalesLinePage: Page "Sales Lines";
                //     begin
                //         Clear(Page_SalesLinePage);
                //         L_SalesLine.Reset();
                //         L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                //         L_SalesLine.SetRange("No.", Rec."Item No.");
                //         L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
                //         L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                //         L_SalesLine.SetRange("Saleable Location", true);
                //         L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
                //         Page_SalesLinePage.SetTableView(L_SalesLine);
                //         Page_SalesLinePage.Run();
                //     end;
                // }
                // field("Total Back Orders"; Rec."Total Back Orders")
                // {
                //     Caption = 'Back Orders (Saleable)';
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Unshipped Qty across ALL Locations';
                //     trigger OnAssistEdit()
                //     var
                //         L_SalesLine: Record "Sales Line";
                //         Page_SalesLinePage: Page "Sales Lines";
                //     begin
                //         Clear(Page_SalesLinePage);
                //         L_SalesLine.Reset();
                //         L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                //         L_SalesLine.SetRange("No.", Rec."Item No.");
                //         L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
                //         L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                //         //L_SalesLine.SetRange("Saleable Location", true);
                //         L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
                //         Page_SalesLinePage.SetTableView(L_SalesLine);
                //         Page_SalesLinePage.Run();
                //     end;
                // }
                field("Shipper Qty"; Rec."Shipper Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = all;
                    StyleExpr = ColorCode;
                    DecimalPlaces = 0 : 5;

                    //Code Moved into Ochannel+++
                    // trigger OnValidate()
                    // begin
                    //     if Rec."Qty. to be added to SO" > 0 then begin
                    //         Rec.CalcFields("Saleable Inventory");
                    //         if Rec."Qty. to be added to SO" > Rec."Saleable Inventory" then
                    //             Error('Qty. to be added to SO should not be less than Saleable Inventory');
                    //     end;
                    // end;
                    //Code Moved into Ochannel+++
                }

            }
            part("Special Promotions"; "Special Promotions")
            {
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(true), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part("Lot-Number-by-Item"; "Lot-Number-by-Item")
            {
                SubPageLink = "Item No." = field("Item No.");
                ApplicationArea = all;
                //Provider = PurchLines;
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Customer No.");
            }
            part(Control1900316107; "Customer Details FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Customer No.");
            }
            part(Control1901314507; "Item Invoicing FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("Item No.");
            }
        }
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
                    CustomerTrendDetails.GetFilters(SalesPersonCodeFilter, CustomerAccountNoFilter, DeliveryDate, ShippingAgentCodeFilter, ShippingAgentServiceCodeFilter, WeekendShippingAgentServiceCodeFilter);
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

        //Update Existing Delivery Date++
        L_CustomerTrends.Reset();
        L_CustomerTrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
        L_CustomerTrends.SetRange("Customer No.", CustomerAccountNoFilter);
        if L_CustomerTrends.FindFirst() then begin
            DeliveryDate := L_CustomerTrends."Delivery Date";
            ShippingAgentCodeFilter := L_CustomerTrends."Shipping Agent Code";
            ShippingAgentServiceCodeFilter := L_CustomerTrends."Shipping Agent Service Code";
            WeekendShippingAgentServiceCodeFilter := L_CustomerTrends."Weekend Ship. Agnt. Serv. Code";
            LocationCodeFilter := L_CustomerTrends."Location Code";
            OrderDateFilter := L_CustomerTrends."Order Date";
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
        //Filter Promotion Item++
        Rec.SetFilter("Special Promotion", '%1', false);

        if G_IsopenFromCallDistribution = true then begin
            //Get Data ++
            SalesPersonCodeFilter := G_SalesPersonCode;
            CustomerAccountNoFilter := G_CustomerAccountNo;

            //Make Editable/UnEditable++
            Edit_CustomerAccountNo := false;
            Edit_SalesPersonCodeFilter := false;
            EditDeliveryDate := false;

            //Aply Filter++
            SetRecFilters;
        end else begin
            //Get Data ++
            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                if L_UserSetup."Salespers./Purch. Code" <> '' then
                    SalesPersonCodeFilter := L_UserSetup."Salespers./Purch. Code";
            end;

            //Make Editable/UnEditable++
            EditDeliveryDate := true;
            Edit_SalesPersonCodeFilter := true;
            Edit_CustomerAccountNo := true;


            //Aply Filter++
            SetRecFilters;
        end;

        //Clear Global Variable++
        Clear(G_IsopenFromCallDistribution);
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
            L_CutomerTrend.SetFilter("Qty. to be added to SO", '>%1', 0);
            if not L_CutomerTrend.IsEmpty then
                if not Confirm('Sales Order has not been Registered. Are you sure you want to close the page?', false) then
                    Error('')

        end;
    end;

    // trigger OnAfterGetRecord()
    // var
    //     L_SalesLine: Record "Sales Line";
    // begin
    //     L_SalesLine.Reset();
    //     L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
    //     L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //     L_SalesLine.SetRange("No.", Rec."Item No.");
    //     L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
    //     L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
    //     L_SalesLine.SetRange("Saleable Location", true);
    //     L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
    //     L_SalesLine.CalcSums("Outstanding Quantity");
    //     Rec."Back Orders (Saleable)" := L_SalesLine."Outstanding Quantity";

    //     L_SalesLine.Reset();
    //     L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
    //     L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
    //     L_SalesLine.SetRange("No.", Rec."Item No.");
    //     L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
    //     L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
    //     L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
    //     L_SalesLine.CalcSums("Outstanding Quantity");
    //     Rec."Total Back Orders" := L_SalesLine."Outstanding Quantity";
    //     Rec.Modify();
    // end;

    var
        Edit_SalesPersonCodeFilter: Boolean;
        Edit_CustomerAccountNo: Boolean;
        G_IsopenFromCallDistribution: Boolean;
        OrderNo: Code[20];
        Flag: Boolean;
        [InDataSet]
        ColorCode: Text;
        EnableWeekWise: Boolean;
        EnableMonthWise: Boolean;
        LocationCode: code[20];
        SalesPersonCodeFilter: Text;
        CustomerAccountNoFilter: Text;
        CustomerAccountName: Text;
        DeliveryDate: Date;
        G_DeliveryDate: Date;
        EditDeliveryDate: Boolean;
        G_ShippingAgentCode: Code[20];
        G_ShippingAgentServiceCode: Code[20];
        ShippingAgentCodeFilter: Code[20];
        ShippingAgentServiceCodeFilter: Code[20];
        WeekendShippingAgentServiceCodeFilter: Code[20];
        G_SalesPersonCode: Code[20];
        G_CustomerAccountNo: Code[20];

        LocationCodeFilter: Code[20];
        OrderDateFilter: Date;

}