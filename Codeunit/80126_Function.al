codeunit 80126 "CT Functions"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;
        G_SalesHeaderCreated: Boolean;
        G_SNo: Code[20];
        InsertedSalesHeader: Record "Sales Header";


    procedure CheckShippingAgentServiceRestriction(_ItemNo: Code[20]; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        L_ShippingAgent: Record "Shipping Agent";
        L_RecItemAttValMap: Record "Item Attribute Value Mapping";
        L_ItemAttribute: Record "Item Attribute";
        L_ItemAttributeValue: Record "Item Attribute Value";

        L_WarehouseClassCode: Record "Warehouse Class";
        L_Item: Record Item;
        ShippingAgentRestrictItem: Record "Shipping Agent Restrict Item";
    begin
        L_RecItemAttValMap.Reset();
        L_RecItemAttValMap.SetRange("Table ID", 27);
        L_RecItemAttValMap.SetRange("No.", _ItemNo);
        if L_RecItemAttValMap.FindSet() then begin
            repeat
                L_ItemAttribute.Reset();
                L_ItemAttribute.SetRange(ID, L_RecItemAttValMap."Item Attribute ID");
                if L_ItemAttribute.FindFirst() then begin
                    L_ItemAttributeValue.SetRange("Attribute ID", L_ItemAttribute.ID);
                    L_ItemAttributeValue.SetRange(ID, L_RecItemAttValMap."Item Attribute Value ID");
                    if L_ItemAttributeValue.FindFirst() then begin
                        if L_ItemAttributeValue.Value <> '' then begin
                            ShippingAgentRestrictItem.Reset();
                            ShippingAgentRestrictItem.SetRange("Shipping Agent Code", _ShippingAgentCode);
                            ShippingAgentRestrictItem.SetRange("Shipping Agent Service Code", _ShippingAgentServiceCode);
                            ShippingAgentRestrictItem.SetRange("Attribute ID", L_ItemAttribute.ID);
                            ShippingAgentRestrictItem.SetRange("Attribute value ID", L_RecItemAttValMap."Item Attribute Value ID");
                            if ShippingAgentRestrictItem.FindFirst() then begin
                                Error('CD and Fridge items are not allowed');
                            end;
                        end;
                    end;
                end;
            until L_RecItemAttValMap.Next() = 0;
        end;
    end;

    procedure CreateCustomertrends(CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    var
        L_PriceListLine: Record "Price List Line";
        L_SalesPriceHeader: Record "Price List Header";
        L_SpecialPromotions: Page "Special Promotions";
        CH_ILE: Record "Item Ledger Entry";
        CH_CustTrends: Record CustomerTrends;
        PgCutTr: page "Customer Trends";
    begin
        //Insert Special Promotions Item++
        L_SalesPriceHeader.Reset();
        L_SalesPriceHeader.SetRange("Special Price Daily", true);
        if L_SalesPriceHeader.FindFirst() then begin
            L_PriceListLine.Reset();
            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
            if L_PriceListLine.FindSet() then begin
                repeat
                    InsertAndModifyTrendsForPromostion(L_PriceListLine, CustNumber, SalesPersonCode, _DeliveryDate, _ShippingAgentCode, _ShippingAgentServiceCode, _WeekendShippingAgentServiceCode);
                until L_PriceListLine.Next() = 0;
            end;
        end;


        // //Insert last 1 week data++
        // CH_ILE.Reset();
        // //CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-1W>', Today), TODAY);
        // CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-1W>', Today), TODAY);
        // CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
        // CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
        // CH_ILE.SetRange("Source No.", CustNumber);
        // if CH_ILE.FindSet() then begin
        //     repeat
        //         InsertAndModifyTrends(CH_ILE, SalesPersonCode, CustNumber, _DeliveryDate, _ShippingAgentCode, _ShippingAgentServiceCode, _WeekendShippingAgentServiceCode);
        //     until CH_ILE.Next() = 0;
        // end;


        //Open Page++
        clear(CH_CustTrends);
        CH_CustTrends.SetCurrentKey("Customer No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        CH_CustTrends.SetRange("Salesperson Code", SalesPersonCode);
        if CH_CustTrends.FindSet() then begin
            PgCutTr.GetFilters(CustNumber, SalesPersonCode, CH_CustTrends."Delivery Date", true, CH_CustTrends."Shipping Agent Code", CH_CustTrends."Shipping Agent Service Code");
            PgCutTr.SetTableView(CH_CustTrends);
        end else begin
            PgCutTr.GetFilters(CustNumber, SalesPersonCode, _DeliveryDate, true, _ShippingAgentCode, _ShippingAgentServiceCode);
            PgCutTr.SetTableView(CH_CustTrends);
        end;
        PgCutTr.Run();
    end;



    procedure GetCustomertrendDetails(L_Months: Option " ","1W","2W","1M","3M","6M"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShiipingAgentServiceCode: Code[20]; _WeekendShiipingAgentServiceCode: Code[20])
    var
        CH_ILE: Record "Item Ledger Entry";
        Routine: Report Populate_CustomerTrends;
        SHRec: Record "Sales Header";
        L_Item: Record Item;
    begin
        //Last 1 Week++
        if L_Months = L_Months::"1W" then begin
            CH_ILE.Reset();
            CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-1W>', Today), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            CH_ILE.SetRange("Source No.", _CustomerAccount);
            if CH_ILE.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", CH_ILE."Item No.");
                    if L_Item.FindFirst() then begin
                        //Skip if Not QAU Approved and Not Released++
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;

        //Last 2 Week++
        if L_Months = L_Months::"2W" then begin
            CH_ILE.Reset();
            CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-2W>', Today), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            CH_ILE.SetRange("Source No.", _CustomerAccount);
            if CH_ILE.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", CH_ILE."Item No.");
                    if L_Item.FindFirst() then begin
                        //Skip if Not QAU Approved and Not Released++
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;

        //Last 1 Month++
        if L_Months = L_Months::"1M" then begin
            CH_ILE.Reset();
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-1M>', Today), Today);
            CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-1M>', Today), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            CH_ILE.SetRange("Source No.", _CustomerAccount);
            if CH_ILE.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", CH_ILE."Item No.");
                    if L_Item.FindFirst() then begin
                        //Skip if Not QAU Approved and Not Released++
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;


        //Last 3 Month++
        if L_Months = L_Months::"3M" then begin
            CH_ILE.Reset();
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), CalcDate('CM', CalcDate('CM-2M', Today)));
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), Today);
            CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-3M>', Today), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            CH_ILE.SetRange("Source No.", _CustomerAccount);
            if CH_ILE.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", CH_ILE."Item No.");
                    if L_Item.FindFirst() then begin
                        //Skip if Not QAU Approved and Not Released++
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;

        //Last 6 Month++
        if L_Months = L_Months::"6M" then begin
            CH_ILE.Reset();
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), CalcDate('CM', CalcDate('CM-2M', Today)));
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), Today);
            CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-6M>', Today()), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            CH_ILE.SetRange("Source No.", _CustomerAccount);
            if CH_ILE.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", CH_ILE."Item No.");
                    if L_Item.FindFirst() then begin
                        //Skip if Not QAU Approved and Not Released++
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;
    end;

    procedure FromCustomerNumberFilter_InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Location: Record Location;
        CompanyLicenseValidation: Codeunit "Check Item License";
        CalledFrom: Option "Sales","Purchase";
        L_Customer: Record Customer;
        L_ShiptoAddress: Record "Ship-to Address";
        EventAndSubscriber: Codeunit EventSub;
    begin
        //This code execute from Customer No. On Validate of Customer Trends screen++
        //Get Last Sales Item from ILE++
        //1 Week, 2 Week, 1M, 3M, and 6M++
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        CH_CustTrends.SetRange("Salesperson Code", _SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", false);
        if not CH_CustTrends.FindFirst() then begin
            CH_Items.Reset();
            CH_Items.SetRange("No.", CH_ILE."Item No.");
            if CH_Items.FindFirst() then begin
                //Skip if Not QAU Approved and Not Released++
                if (CH_Items."QAU Approved" = true) AND (CH_Items.Status = CH_Items.Status::Released) then begin
                    //Skip Promotion Item. As dicussed we will enter Promotion item manually on Top Screen of Customer Trends with few condition++
                    if CheckPromotionItem(CH_ILE."Item No.") = false then begin
                        CH_CustTrends.Init();
                        CH_CustTrends.Validate("Item No.", CH_ILE."Item No.");
                        CH_CustTrends.Validate("Customer No.", CH_ILE."Source No.");
                        CH_CustTrends.Validate("Salesperson Code", _SalesPersonCode);
                        CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                        CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                        CH_CustTrends."Special Promotion" := false;
                        CH_CustTrends.Validate("Item Category Code", CH_Items."Item Category Code");
                        CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                        CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                        CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);
                        CH_CustTrends.Validate("Weekend Ship. Agnt. Serv. Code", _WeekendShippingAgentServiceCode);
                        CH_CustTrends."Updated By" := UserId;
                        CH_CustTrends."Updated On" := CurrentDateTime;
                        CH_CustTrends."Created By" := UserId;
                        CH_CustTrends."Created On" := CurrentDateTime;
                        CH_CustTrends."Order Date" := WorkDate();

                        //Get Price From Sale price table based on all default combination and filter. (Only on Top Screen of Customer Trends)++
                        CH_CustTrends.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(CH_ILE."Source No.", CH_ILE."Item No.", 0));

                        //Get Shipper Qty From Item Unit of Measure table++
                        L_ItemUnitofMeasure.Reset();
                        L_ItemUnitofMeasure.SetRange("Item No.", CH_ILE."Item No.");
                        L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                        if L_ItemUnitofMeasure.FindFirst() then
                            CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                        //Get Last Unit Price from Sales Shipment table++
                        CH_SShip.Reset();
                        CH_SShip.SetRange("Sell-to Customer No.", CH_ILE."Source No.");
                        CH_SShip.SetRange("No.", CH_ILE."Item No.");
                        CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                        if CH_SShip.FindLast() then
                            CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                        //Get Default Location++
                        L_Location.Reset();
                        L_Location.SetRange("Customer Trend Default Loc", true);
                        if L_Location.FindFirst() then
                            CH_CustTrends."Location Code" := L_Location.Code;

                        //Company License Validatio++
                        L_Customer.Reset();
                        L_Customer.SetRange("No.", _CustomerAccount);
                        if L_Customer.FindFirst() then begin
                            CH_CustTrends.Validate("Ship-to Code", L_Customer."Ship-to Code");
                            CH_CustTrends.Validate("Customer Price Group", L_Customer."Customer Price Group");

                            if L_Customer."Ship-to Code" <> '' then begin
                                L_ShiptoAddress.Reset();
                                L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                                L_ShiptoAddress.SetRange("Customer No.", _CustomerAccount);
                                if L_ShiptoAddress.FindFirst() then begin
                                    CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, _CustomerAccount, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_ShiptoAddress."Post Code");
                                end;
                            end else begin
                                CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, _CustomerAccount, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_Customer."Post Code");
                            end;
                        end;
                        CH_CustTrends.Insert(true);
                    end;
                end;
            end;
        end;
    end;

    local procedure CheckPromotionItem(_ItemNumber: Code[20]): Boolean
    var
        L_SalesPriceHeader: Record "Price List Header";
        L_PriceListLine: Record "Price List Line";
    begin
        L_SalesPriceHeader.Reset();
        L_SalesPriceHeader.SetRange("Special Price Daily", true);
        if L_SalesPriceHeader.FindFirst() then begin
            L_PriceListLine.Reset();
            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
            L_PriceListLine.SetRange("Product No.", _ItemNumber);
            if L_PriceListLine.FindFirst() then
                exit(true)
            else
                exit(false);
        end;
        exit(false);

    end;

    procedure InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Location: Record Location;
        CompanyLicenseValidation: Codeunit "Check Item License";
        CalledFrom: Option "Sales","Purchase";
        L_Customer: Record Customer;
        L_ShiptoAddress: Record "Ship-to Address";
        EventAndSubscriber: Codeunit EventSub;
    begin
        //This code execute From Call log and Past Month Details button of Customer Trends++
        //Get Last Sales Item from ILE++
        //1 Week, 2 Week, 1M, 3M, and 6M++
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        CH_CustTrends.SetRange("Salesperson Code", _SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", false);
        if not CH_CustTrends.FindFirst() then begin
            CH_Items.Reset();
            CH_Items.SetRange("No.", CH_ILE."Item No.");
            if CH_Items.FindFirst() then begin
                //Skip if Not QAU Approved and Not Released++
                if (CH_Items."QAU Approved" = true) AND (CH_Items.Status = CH_Items.Status::Released) then begin
                    //Skip Promotion Item. As dicussed we will enter Promotion item manually on Top Screen of Customer Trends with few condition++
                    if CheckPromotionItem(CH_ILE."Item No.") = false then begin
                        CH_CustTrends.Init();
                        CH_CustTrends.Validate("Item No.", CH_ILE."Item No.");
                        CH_CustTrends.Validate("Customer No.", CH_ILE."Source No.");
                        CH_CustTrends.Validate("Salesperson Code", _SalesPersonCode);
                        CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                        CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                        CH_CustTrends."Special Promotion" := false;
                        CH_CustTrends.Validate("Item Category Code", CH_Items."Item Category Code");
                        //CH_CustTrends.Validate("Unit Price", CH_Items."Unit Price");

                        //Get Price From Sale price table based on all default combination and filter. (Only on Top Screen of Customer Trends)++
                        CH_CustTrends.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(CH_ILE."Source No.", CH_ILE."Item No.", 0));
                        CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                        CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                        CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);
                        CH_CustTrends.Validate("Weekend Ship. Agnt. Serv. Code", _WeekendShippingAgentServiceCode);
                        CH_CustTrends."Updated By" := UserId;
                        CH_CustTrends."Updated On" := CurrentDateTime;
                        CH_CustTrends."Created By" := UserId;
                        CH_CustTrends."Created On" := CurrentDateTime;
                        CH_CustTrends."Order Date" := WorkDate();

                        //Get Shipper Qty From Item Unit of Measure table++
                        L_ItemUnitofMeasure.Reset();
                        L_ItemUnitofMeasure.SetRange("Item No.", CH_ILE."Item No.");
                        L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                        if L_ItemUnitofMeasure.FindFirst() then
                            CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                        //Get Last Unit Price from Sales Shipment table++
                        CH_SShip.Reset();
                        CH_SShip.SetRange("Sell-to Customer No.", CH_ILE."Source No.");
                        CH_SShip.SetRange("No.", CH_ILE."Item No.");
                        CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                        if CH_SShip.FindLast() then
                            CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                        //Get Default Location++
                        L_Location.Reset();
                        L_Location.SetRange("Customer Trend Default Loc", true);
                        if L_Location.FindFirst() then
                            CH_CustTrends."Location Code" := L_Location.Code;

                        //Company License Validatio++
                        L_Customer.Reset();
                        L_Customer.SetRange("No.", _CustomerAccount);
                        if L_Customer.FindFirst() then begin
                            CH_CustTrends.Validate("Ship-to Code", L_Customer."Ship-to Code");
                            CH_CustTrends.Validate("Customer Price Group", L_Customer."Customer Price Group");

                            if L_Customer."Ship-to Code" <> '' then begin
                                L_ShiptoAddress.Reset();
                                L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                                L_ShiptoAddress.SetRange("Customer No.", _CustomerAccount);
                                if L_ShiptoAddress.FindFirst() then begin
                                    CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, _CustomerAccount, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_ShiptoAddress."Post Code");
                                end;
                            end else begin
                                CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, _CustomerAccount, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_Customer."Post Code");
                            end;
                        end;
                        CH_CustTrends.Insert(true);
                    end;
                end;
            end else begin
                CH_CustTrends."Updated By" := UserId;
                CH_CustTrends."Updated On" := CurrentDateTime;
                CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                CH_CustTrends.Modify(true);
            end;
        end;
    end;

    procedure GetCustomertrendDetailsForPromostion(_SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: date; _ShippingAgentCode: Code[20]; _ShiipingAgentServiceCode: Code[20]; _WeekendShiipingAgentServiceCode: Code[20])
    var
        L_PriceListLine: Record "Price List Line";
        L_SalesPriceHeader: Record "Price List Header";
        L_Item: Record Item;
    begin
        //Insert Special Promotions Item++
        L_SalesPriceHeader.Reset();
        L_SalesPriceHeader.SetRange("Special Price Daily", true);
        if L_SalesPriceHeader.FindFirst() then begin
            L_PriceListLine.Reset();
            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
            if L_PriceListLine.FindSet() then begin
                repeat
                    L_Item.Reset();
                    L_Item.SetRange("No.", L_PriceListLine."Product No.");
                    if L_Item.FindFirst() then begin
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrendsForPromostion(L_PriceListLine, _CustomerAccount, _SalesPersonCode, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode, _WeekendShiipingAgentServiceCode)
                    end;
                until L_PriceListLine.Next() = 0;
            end;
        end;
    end;


    procedure FromCustomerNumberFIlte_InsertAndModifyTrendsForPromostion(_PriceListLine: Record "Price List Line"; CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
        L_Date: Record Date;
        L_Location: Record Location;
        CompanyLicenseValidation: Codeunit "Check Item License";
        CalledFrom: Option "Sales","Purchase";
        L_Customer: Record Customer;
        L_ShiptoAddress: Record "Ship-to Address";
        EventAndSubscriber: Codeunit EventSub;
    begin
        //This code execute from Customer No. On Validate of Customer Trends screen (Only Special Promotion Item)++
        //Get Special promotion items from Sales Price list+++
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", _PriceListLine."Product No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        CH_CustTrends.SetRange("Salesperson Code", SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", true);
        if not CH_CustTrends.FindFirst() then begin
            L_Item.Reset();
            L_Item.SetRange("No.", _PriceListLine."Product No.");
            if L_Item.FindFirst() then begin
                //Skip if Not QAU Approved and Not Released++
                if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends."Special Promotion" := true;
                    CH_CustTrends.Validate("Item No.", _PriceListLine."Product No.");
                    CH_CustTrends.Validate("Customer No.", CustNumber);
                    CH_CustTrends.Validate("Salesperson Code", SalesPersonCode);
                    if CH_Items.Get(_PriceListLine."Product No.") then;
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Item Category Code", L_Item."Item Category Code");
                    //CH_CustTrends.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(CustNumber, _PriceListLine."Product No.", 0));
                    CH_CustTrends.Validate("Unit Price", _PriceListLine."Unit Price");
                    CH_CustTrends.Validate("Minimum Quantity", _PriceListLine."Minimum Quantity");
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);
                    CH_CustTrends.Validate("Weekend Ship. Agnt. Serv. Code", _WeekendShippingAgentServiceCode);
                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
                    CH_CustTrends."Order Date" := WorkDate();

                    //Update Shipmet date++
                    L_Date.Reset();
                    L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                    L_Date.SetRange(L_Date."Period Start", Today);
                    if L_Date.FindFirst() then
                        if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                            if _WeekendShippingAgentServiceCode <> '' then
                                //Update Saturday++
                                CH_CustTrends.Validate("Delivery Date", CalcDate('<+1D>', Today))
                            else begin
                                //Update Monday
                                CH_CustTrends.Validate("Delivery Date", CalcDate('<+3D>', Today))
                            end;
                        end else
                            CH_CustTrends.Validate("Delivery Date", CalcDate('<+1D>', Today));

                    //Get Shipper Qty From Item Unit of Measure table++
                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", _PriceListLine."Product No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                    //Get Last Unit Price from Sales Shipment table++
                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CustNumber);
                    CH_SShip.SetRange("No.", _PriceListLine."Product No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    //Get Default Location++
                    L_Location.Reset();
                    L_Location.SetRange("Customer Trend Default Loc", true);
                    if L_Location.FindFirst() then
                        CH_CustTrends."Location Code" := L_Location.Code;

                    //Company License Validatio++
                    L_Customer.Reset();
                    L_Customer.SetRange("No.", CustNumber);
                    if L_Customer.FindFirst() then begin
                        CH_CustTrends.Validate("Ship-to Code", L_Customer."Ship-to Code");
                        CH_CustTrends.Validate("Customer Price Group", L_Customer."Customer Price Group");

                        if L_Customer."Ship-to Code" <> '' then begin
                            L_ShiptoAddress.Reset();
                            L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                            L_ShiptoAddress.SetRange("Customer No.", CustNumber);
                            if L_ShiptoAddress.FindFirst() then begin
                                CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustNumber, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_ShiptoAddress."Post Code");
                            end;
                        end else begin
                            CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustNumber, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_Customer."Post Code");
                        end;
                    end;
                    CH_CustTrends.Insert(true);
                end;
            end;
        end;
    end;

    procedure InsertAndModifyTrendsForPromostion(_PriceListLine: Record "Price List Line"; CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
        L_Location: Record Location;
        CompanyLicenseValidation: Codeunit "Check Item License";
        CalledFrom: Option "Sales","Purchase";
        L_Customer: Record Customer;
        L_ShiptoAddress: Record "Ship-to Address";
        EventAndSubscriber: Codeunit EventSub;
    begin
        //This code execute From Call log and Past Month Details button of Customer Trends++
        //Get Special Promotion Item from Sales Price table++
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", _PriceListLine."Product No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        CH_CustTrends.SetRange("Salesperson Code", SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", true);
        if not CH_CustTrends.FindFirst() then begin
            L_Item.Reset();
            L_Item.SetRange("No.", _PriceListLine."Product No.");
            if L_Item.FindFirst() then begin
                //Skip if Not QAU Approved and Not Released++
                if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends.Validate("Item No.", _PriceListLine."Product No.");
                    CH_CustTrends.Validate("Customer No.", CustNumber);
                    CH_CustTrends."Special Promotion" := true;
                    CH_CustTrends.Validate("Salesperson Code", SalesPersonCode);
                    if CH_Items.Get(_PriceListLine."Product No.") then;
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Item Category Code", CH_Items."Item Category Code");
                    //CH_CustTrends.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(CustNumber, _PriceListLine."Product No.", 0));
                    CH_CustTrends.Validate("Unit Price", _PriceListLine."Unit Price");
                    CH_CustTrends.Validate("Minimum Quantity", _PriceListLine."Minimum Quantity");
                    CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);
                    CH_CustTrends.Validate("Weekend Ship. Agnt. Serv. Code", _WeekendShippingAgentServiceCode);
                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
                    CH_CustTrends."Order Date" := WorkDate();

                    //Get Shipper Qty From Item Unit of Measure table++
                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", _PriceListLine."Product No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                    //Get Last Unit Price from Sales Shipment table++
                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CustNumber);
                    CH_SShip.SetRange("No.", _PriceListLine."Product No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    //Get Default Location++
                    L_Location.Reset();
                    L_Location.SetRange("Customer Trend Default Loc", true);
                    if L_Location.FindFirst() then
                        CH_CustTrends."Location Code" := L_Location.Code;

                    //Company License Validatio++
                    L_Customer.Reset();
                    L_Customer.SetRange("No.", CustNumber);
                    if L_Customer.FindFirst() then begin
                        CH_CustTrends.Validate("Ship-to Code", L_Customer."Ship-to Code");
                        CH_CustTrends.Validate("Customer Price Group", L_Customer."Customer Price Group");

                        if L_Customer."Ship-to Code" <> '' then begin
                            L_ShiptoAddress.Reset();
                            L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                            L_ShiptoAddress.SetRange("Customer No.", CustNumber);
                            if L_ShiptoAddress.FindFirst() then begin
                                CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustNumber, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_ShiptoAddress."Post Code");
                            end;
                        end else begin
                            CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustNumber, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", CH_CustTrends."Delivery Date", CH_CustTrends."Item No.", L_Customer."Post Code");
                        end;
                    end;
                    CH_CustTrends.Insert(true);
                end;
            end;
        end else begin
            CH_CustTrends."Updated By" := UserId;
            CH_CustTrends."Updated On" := CurrentDateTime;
            CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
            CH_CustTrends.Modify(true);
        end;
    end;

    //Moved this button to KNAPP extension becuase of KNAPP Code++
    // procedure CreateAndUpdateSalesOrder(_CustNumber: Code[100]; _SalesPersonCode: Code[20])
    // var
    //     CustmerTrend: Record CustomerTrends;
    //     L_ExistSalesHeader: Record "Sales Header";
    //     L_SalesOrderCard: Page "Sales Order";
    //     L_SalesH: Record "Sales Header";
    // begin
    //     Clear(G_SalesHeaderCreated);
    //     CustmerTrend.Reset();
    //     CustmerTrend.SetRange("Customer No.", _CustNumber);
    //     CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
    //     CustmerTrend.SetFilter("Qty. to be added to SO", '<>%1', 0);
    //     if CustmerTrend.FindSet() then begin
    //         if Not CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(CustmerTrend) then begin
    //             Clear(G_SalesHeaderCreated);
    //             Clear(G_SNo);
    //         end;

    //         repeat
    //             if Not G_SalesHeaderCreated then
    //                 CreateSalesHeader(CustmerTrend);

    //             if G_SNo <> '' then begin
    //                 L_ExistSalesHeader.Reset();
    //                 L_ExistSalesHeader.SetRange("No.", G_SNo);
    //                 L_ExistSalesHeader.SetRange("Document Type", L_ExistSalesHeader."Document Type"::Order);
    //                 if L_ExistSalesHeader.FindFirst() then begin
    //                     // //Open Existing Order If Released++
    //                     // if L_ExistSalesHeader.Status = L_ExistSalesHeader.Status::Released then begin
    //                     //     ReleaseSalesDoc.PerformManualReopen(L_ExistSalesHeader);
    //                     // end;

    //                     //Create Lines++
    //                     CreateSalesLine(L_ExistSalesHeader, CustmerTrend);

    //                 end;
    //             end else begin
    //                 // //Open Sales Order If released++
    //                 // if InsertedSH.Status = InsertedSH.Status::Released then
    //                 //     ReleaseSalesDoc.PerformManualReopen(InsertedSH);

    //                 //Create Line++    
    //                 CreateSalesLine(InsertedSalesHeader, CustmerTrend);
    //             end;

    //         until CustmerTrend.Next() = 0;

    //         if G_SNo <> '' then begin
    //             If Confirm('Sales Order %1 Updated, Do you want to open?', true, G_SNo) then begin
    //                 Clear(L_SalesOrderCard);
    //                 L_SalesH.Reset();
    //                 L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
    //                 L_SalesH.SetRange("No.", G_SNo);
    //                 if L_SalesH.FindFirst() then begin
    //                     L_SalesOrderCard.SetTableView(L_SalesH);
    //                     L_SalesOrderCard.Run();
    //                 end;
    //             end Else
    //                 exit;
    //         end else begin
    //             If Confirm('Sales Order %1 Created, Do you want to open?', true, InsertedSalesHeader."No.") then begin
    //                 Clear(L_SalesOrderCard);
    //                 L_SalesH.Reset();
    //                 L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
    //                 L_SalesH.SetRange("No.", InsertedSalesHeader."No.");
    //                 if L_SalesH.FindFirst() then begin
    //                     L_SalesOrderCard.SetTableView(L_SalesH);
    //                     L_SalesOrderCard.Run();
    //                 end;
    //             end Else
    //                 exit;
    //         end;
    //     end;

    //     //Delete Customer Trends++
    //     //if GetLastErrorText() = '' then begin
    //     CustmerTrend.Reset();
    //     CustmerTrend.SetRange("Customer No.", _CustNumber);
    //     CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
    //     if CustmerTrend.FindSet() then
    //         CustmerTrend.DeleteAll();
    //     //end;

    // end;

    // local procedure CreateSalesLine(_SalesHeader: Record "Sales Header"; _Customertrend: Record CustomerTrends)
    // var
    //     InsertedSL: Record "Sales Line";

    // begin
    //     InsertedSL.Reset();
    //     InsertedSL.SetRange("Document Type", InsertedSL."Document Type"::Order);
    //     InsertedSL.SetRange("Document No.", _SalesHeader."No.");
    //     InsertedSL.SetRange("No.", _Customertrend."Item No.");
    //     InsertedSL.SetRange(Type, InsertedSL.Type::Item);
    //     if InsertedSL.FindFirst() then begin
    //         InsertedSL.Validate(Quantity, InsertedSL.Quantity + _Customertrend."Qty. to be added to SO");
    //         InsertedSL.Modify(true);
    //     end else begin
    //         InsertedSL.Init();
    //         InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
    //         InsertedSL.VALIDATE("Document No.", _SalesHeader."No.");
    //         InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesHeader."No."));
    //         InsertedSL.VALIDATE(Type, InsertedSL.Type::Item);
    //         InsertedSL.VALIDATE("No.", _Customertrend."Item No.");
    //         InsertedSL.VALIDATE(Quantity, _Customertrend."Qty. to be added to SO");
    //         InsertedSL.Validate("Location Code", _SalesHeader."Location Code");
    //         // //Knapp Customer++
    //         // if CU_KnappGenerateDocument.CheckKnappCustomer(Rec."Sell-to Customer No.") = true then begin
    //         //     if CU_KnappGenerateDocument.CheckKnappItem(Rec."No.") = false then begin
    //         //         L_Location.Reset();
    //         //         L_Location.SetRange("Manual Picking", true);
    //         //         if L_Location.FindFirst() then begin
    //         //             Rec.Validate("Location Code", L_Location.Code);
    //         //         end;
    //         //     end;
    //         //     if CU_KnappGenerateDocument.CheckKnappItem(Rec."No.") = true then begin
    //         //         L_Location.Reset();
    //         //         L_Location.SetRange("Knapp Location", true);
    //         //         if L_Location.FindFirst() then begin
    //         //             Rec.Validate("Location Code", L_Location.Code);
    //         //         end;
    //         //     end;
    //         // end;


    //         InsertedSL.Validate("Unit Price", _Customertrend."Unit Price");
    //         InsertedSL."Last Price" := _Customertrend."Last Price";
    //         //InsertedSL."Shipper Qty" := _Customertrend."Shipper Qty";
    //         InsertedSL.Insert(true);
    //     end;
    // end;

    // local procedure GetLastLineNo(HeaderNo: Code[20]): Integer
    // var
    //     L_SalesLine: Record "Sales Line";
    // begin
    //     L_SalesLine.RESET;
    //     L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
    //     L_SalesLine.SETRANGE("Document No.", HeaderNo);
    //     IF L_SalesLine.FINDLAST THEN
    //         EXIT(L_SalesLine."Line No." + 10000)
    //     ELSE
    //         EXIT(10000);
    // end;

    // local procedure CreateSalesHeader(_CustmerTrend: Record CustomerTrends)
    // var
    //     NoSeriesManagement: Codeunit NoSeriesManagement;
    //     SalesRecSetup: Record "Sales & Receivables Setup";
    //     L_DocumetNo: Code[20];
    // begin
    //     SalesRecSetup.Get();
    //     InsertedSalesHeader.Reset();
    //     InsertedSalesHeader.Init();
    //     InsertedSalesHeader.Validate("Document Type", InsertedSalesHeader."Document Type"::Order);
    //     Clear(L_DocumetNo);
    //     L_DocumetNo := NoSeriesManagement.GetNextNo(SalesRecSetup."Order Nos.", WORKDATE, TRUE);
    //     InsertedSalesHeader."No." := L_DocumetNo;
    //     InsertedSalesHeader.Validate("Sell-to Customer No.", _CustmerTrend."Customer No.");
    //     InsertedSalesHeader.Validate("Posting Date", WorkDate());
    //     InsertedSalesHeader.Validate("Order Date", WorkDate());
    //     InsertedSalesHeader.Validate("Document Date", WorkDate());
    //     InsertedSalesHeader.Validate("Shipping Agent Code", _CustmerTrend."Shipping Agent Code");
    //     InsertedSalesHeader.Validate("Shipping Agent Service Code", _CustmerTrend."Shipping Agent Service Code");
    //     InsertedSalesHeader.Validate("Location Code", _CustmerTrend."Location Code");
    //     InsertedSalesHeader.Insert(true);

    //     //Update Shipment date++
    //     InsertedSalesHeader.Validate("Shipment Date", _CustmerTrend."Delivery Date");
    //     InsertedSalesHeader.Modify();
    //     G_SalesHeaderCreated := true;
    // end;



    // local procedure CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(_CustomerTrends: Record CustomerTrends): Boolean
    // var
    //     L_SalesHeader: Record "Sales Header";
    // begin
    //     Clear(G_SNo);
    //     L_SalesHeader.Reset();
    //     L_SalesHeader.SetRange("Sell-to Customer No.", _CustomerTrends."Customer No.");
    //     L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
    //     L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
    //     L_SalesHeader.SetRange("Shipment Date", _CustomerTrends."Delivery Date");
    //     L_SalesHeader.SetRange("Location Code", _CustomerTrends."Location Code");
    //     //Need to check one for filter Order Sent to KNAPP if KNAPP customer++
    //     //Will Check with SHubham++
    //     if L_SalesHeader.FindSet() then begin
    //         repeat
    //             //Check Shipment is available
    //             if not CheckShipmetExist(L_SalesHeader) then begin

    //                 //Check Posted Pick is Availabel or not+++
    //                 if not CheckPostedShipmentExist(L_SalesHeader) then begin
    //                     G_SalesHeaderCreated := true;
    //                     G_SNo := L_SalesHeader."No.";
    //                     exit(true);
    //                 end;
    //             end;
    //         until L_SalesHeader.Next() = 0;

    //         exit(false);
    //     end;
    // end;

    // local procedure CheckShipmetExist(_SalesHeader: Record "Sales Header"): Boolean
    // var
    //     WarehouseShipmentLine: Record "Warehouse Shipment Line";
    // begin
    //     WarehouseShipmentLine.Reset();
    //     WarehouseShipmentLine.SetRange("Source Document", WarehouseShipmentLine."Source Document"::"Sales Order");
    //     WarehouseShipmentLine.SetRange("Source No.", _SalesHeader."No.");
    //     if not WarehouseShipmentLine.IsEmpty then
    //         exit(true)
    //     else
    //         exit(false);
    // end;

    // local procedure CheckPostedShipmentExist(_SalesHeader: Record "Sales Header"): Boolean
    // var
    //     L_SalesShipmentHeader: Record "Sales Shipment Header";
    // begin
    //     L_SalesShipmentHeader.Reset();
    //     L_SalesShipmentHeader.SetRange("Order No.", _SalesHeader."No.");
    //     if not L_SalesShipmentHeader.IsEmpty then
    //         exit(true)
    //     else
    //         exit(false);
    // end;
    //Moved this button to KNAPP extension becuase of KNAPP Code++

}