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

    procedure CreateCustomertrends(CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
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
                    InsertAndModifyTrendsForPromostion(L_PriceListLine, CustNumber, SalesPersonCode, _DeliveryDate, _ShippingAgentCode, _ShippingAgentServiceCode);
                until L_PriceListLine.Next() = 0;
            end;
        end;


        //Insert last 1 week data++
        CH_ILE.Reset();
        //CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-1W>', Today), TODAY);
        CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-1W>', Today), TODAY);
        CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
        CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
        CH_ILE.SetRange("Source No.", CustNumber);
        if CH_ILE.FindSet() then begin
            repeat
                InsertAndModifyTrends(CH_ILE, SalesPersonCode, CustNumber, _DeliveryDate, _ShippingAgentCode, _ShippingAgentServiceCode);
            until CH_ILE.Next() = 0;
        end;


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



    procedure GetCustomertrendDetails(L_Months: Option " ","1W","2W","1M","3M","6M"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShiipingAgentServiceCode: Code[20])
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
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode);
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
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode);
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
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode);
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
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode);
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
                        if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then
                            InsertAndModifyTrends(CH_ILE, _SalesPersonCode, _CustomerAccount, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode);
                    end;
                until CH_ILE.Next() = 0;
            end;
        end;
    end;

    procedure FromCustomerNumberFilter_InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        CH_CustTrends.SetRange("Salesperson Code", _SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", false);
        if not CH_CustTrends.FindFirst() then begin
            CH_Items.Reset();
            CH_Items.SetRange("No.", CH_ILE."Item No.");
            if CH_Items.FindFirst() then begin
                if (CH_Items."QAU Approved" = true) AND (CH_Items.Status = CH_Items.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends.Validate("Item No.", CH_ILE."Item No.");
                    CH_CustTrends.Validate("Customer No.", CH_ILE."Source No.");
                    CH_CustTrends.Validate("Salesperson Code", _SalesPersonCode);
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Unit Price", CH_Items."Unit Price");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);

                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", CH_ILE."Item No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";


                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CH_ILE."Source No.");
                    CH_SShip.SetRange("No.", CH_ILE."Item No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
                    CH_CustTrends."Special Promotion" := false;
                    CH_CustTrends.Insert(true);
                end;
            end;
        end;
    end;

    procedure InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        CH_CustTrends.SetRange("Salesperson Code", _SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", false);
        if not CH_CustTrends.FindFirst() then begin
            CH_Items.Reset();
            CH_Items.SetRange("No.", CH_ILE."Item No.");
            if CH_Items.FindFirst() then begin
                if (CH_Items."QAU Approved" = true) AND (CH_Items.Status = CH_Items.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends.Validate("Item No.", CH_ILE."Item No.");
                    CH_CustTrends.Validate("Customer No.", CH_ILE."Source No.");
                    CH_CustTrends.Validate("Salesperson Code", _SalesPersonCode);
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Unit Price", CH_Items."Unit Price");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);

                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", CH_ILE."Item No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                    //Dont Need In Sigma++
                    // //Week
                    // Rec_ILE.Reset();
                    // Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                    // Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                    // Rec_ILE.SetRange("Item No.", ILE."Item No.");
                    // Rec_ILE.SetRange("Source No.", ILE."Source No.");
                    // Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CW', Today()), CalcDate('CW', Today()));
                    // if Rec_ILE.FindSet() then begin
                    //     repeat
                    //         CH_CustTrends."Quantity purchased this Week" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    //     until Rec_ILE.Next() = 0;
                    // end;

                    // //Current Month
                    // Rec_ILE.Reset();
                    // Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                    // Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                    // Rec_ILE.SetRange("Item No.", ILE."Item No.");
                    // Rec_ILE.SetRange("Source No.", ILE."Source No.");
                    // Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', Today()), CalcDate('CM', Today()));
                    // if Rec_ILE.FindSet() then begin
                    //     repeat
                    //         CH_CustTrends."Quantity purchased this Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    //     until Rec_ILE.Next() = 0;
                    // end;

                    // //Last Month
                    // Rec_ILE.Reset();
                    // Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                    // Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                    // Rec_ILE.SetRange("Item No.", ILE."Item No.");
                    // Rec_ILE.SetRange("Source No.", ILE."Source No.");
                    // Rec_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-2M+1D>', Today), CALCDATE('CM', CALCDATE('-CM-1D', TODAY)));
                    // if Rec_ILE.FindSet() then begin
                    //     repeat
                    //         CH_CustTrends."Qty purchased Last Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    //     until Rec_ILE.Next() = 0;
                    // end;


                    // SalesPrice.Reset();
                    // SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::Customer);
                    // SalesPrice.SetRange("Source No.", ILE."Source No.");
                    // SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
                    // SalesPrice.SetRange("Asset No.", ILE."Item No.");
                    // SalesPrice.SetRange(Status, SalesPrice.Status::Active);
                    // SalesPrice.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    // if SalesPrice.FindLast() then
                    //     CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
                    // else begin
                    //     Clear(SalesPrice);
                    //     SalesPrice.Reset();
                    //     SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
                    //     SalesPrice.SetRange("Asset No.", ILE."Item No.");
                    //     SalesPrice.SetRange(Status, SalesPrice.Status::Active);
                    //     if SalesPrice.FindLast() then
                    //         CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
                    //     else
                    //         CH_CustTrends."Unit Price" := 0;
                    // end;
                    //++++++++++++++


                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CH_ILE."Source No.");
                    CH_SShip.SetRange("No.", CH_ILE."Item No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
                    CH_CustTrends."Special Promotion" := false;
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

    procedure GetCustomertrendDetailsForPromostion(_SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: date; _ShippingAgentCode: Code[20]; _ShiipingAgentServiceCode: Code[20])
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
                            InsertAndModifyTrendsForPromostion(L_PriceListLine, _CustomerAccount, _SalesPersonCode, _DeliveryDate, _ShippingAgentCode, _ShiipingAgentServiceCode)
                    end;
                until L_PriceListLine.Next() = 0;
            end;
        end;
    end;


    procedure FromCustomerNumberFIlte_InsertAndModifyTrendsForPromostion(_PriceListLine: Record "Price List Line"; CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", _PriceListLine."Product No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        CH_CustTrends.SetRange("Salesperson Code", SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", true);
        if not CH_CustTrends.FindFirst() then begin
            L_Item.Reset();
            L_Item.SetRange("No.", _PriceListLine."Product No.");
            if L_Item.FindFirst() then begin
                if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends.Validate("Item No.", _PriceListLine."Product No.");
                    CH_CustTrends.Validate("Customer No.", CustNumber);
                    CH_CustTrends.Validate("Salesperson Code", SalesPersonCode);
                    if CH_Items.Get(_PriceListLine."Product No.") then;
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Unit Price", CH_Items."Unit Price");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);

                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", _PriceListLine."Product No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CustNumber);
                    CH_SShip.SetRange("No.", _PriceListLine."Product No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    CH_CustTrends."Special Promotion" := true;
                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
                    CH_CustTrends.Insert(true);
                end;
            end;
        end;
    end;

    procedure InsertAndModifyTrendsForPromostion(_PriceListLine: Record "Price List Line"; CustNumber: Code[100]; SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        L_ItemUnitofMeasure: Record "Item Unit of Measure";
        L_Item: Record Item;
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", _PriceListLine."Product No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        CH_CustTrends.SetRange("Salesperson Code", SalesPersonCode);
        CH_CustTrends.SetRange("Special Promotion", true);
        if not CH_CustTrends.FindFirst() then begin
            L_Item.Reset();
            L_Item.SetRange("No.", _PriceListLine."Product No.");
            if L_Item.FindFirst() then begin
                if (L_Item."QAU Approved" = true) AND (L_Item.Status = L_Item.Status::Released) then begin
                    CH_CustTrends.Init();
                    CH_CustTrends.Validate("Item No.", _PriceListLine."Product No.");
                    CH_CustTrends.Validate("Customer No.", CustNumber);
                    CH_CustTrends.Validate("Salesperson Code", SalesPersonCode);
                    if CH_Items.Get(_PriceListLine."Product No.") then;
                    CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
                    CH_CustTrends.Validate("Unit Price", CH_Items."Unit Price");
                    CH_CustTrends.Validate("Min Sell Price", CH_Items."Min Sell Price");
                    CH_CustTrends.Validate("Delivery Date", _DeliveryDate);
                    CH_CustTrends.Validate("Shipping Agent Code", _ShippingAgentCode);
                    CH_CustTrends.Validate("Shipping Agent Service Code", _ShippingAgentServiceCode);

                    L_ItemUnitofMeasure.Reset();
                    L_ItemUnitofMeasure.SetRange("Item No.", _PriceListLine."Product No.");
                    L_ItemUnitofMeasure.SetRange(Code, CH_Items."Sales Unit of Measure");
                    if L_ItemUnitofMeasure.FindFirst() then
                        CH_CustTrends."Shipper Qty" := L_ItemUnitofMeasure."Shipper Qty.";

                    CH_SShip.Reset();
                    CH_SShip.SetRange("Sell-to Customer No.", CustNumber);
                    CH_SShip.SetRange("No.", _PriceListLine."Product No.");
                    CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
                    if CH_SShip.FindLast() then
                        CH_CustTrends."Last Price" := CH_SShip."Unit Price";

                    CH_CustTrends."Special Promotion" := true;
                    CH_CustTrends."Updated By" := UserId;
                    CH_CustTrends."Updated On" := CurrentDateTime;
                    CH_CustTrends."Created By" := UserId;
                    CH_CustTrends."Created On" := CurrentDateTime;
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


    procedure CreateAndUpdateSalesOrder(_CustNumber: Code[100]; _SalesPersonCode: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20])
    var
        CustmerTrend: Record CustomerTrends;
        L_ExistSalesHeader: Record "Sales Header";
        L_SalesOrderCard: Page "Sales Order";
        L_SalesH: Record "Sales Header";
    begin
        Clear(G_SalesHeaderCreated);
        CustmerTrend.Reset();
        CustmerTrend.SetRange("Customer No.", _CustNumber);
        CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
        CustmerTrend.SetFilter("Qty. to be added to SO", '<>%1', 0);
        if CustmerTrend.FindSet() then begin
            if Not CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(_CustNumber, _DeliveryDate) then begin
                Clear(G_SalesHeaderCreated);
                Clear(G_SNo);
            end;

            repeat
                if Not G_SalesHeaderCreated then
                    CreateSalesHeader(CustmerTrend);

                if G_SNo <> '' then begin
                    L_ExistSalesHeader.Reset();
                    L_ExistSalesHeader.SetRange("No.", G_SNo);
                    L_ExistSalesHeader.SetRange("Document Type", L_ExistSalesHeader."Document Type"::Order);
                    if L_ExistSalesHeader.FindFirst() then begin
                        // //Open Existing Order If Released++
                        // if L_ExistSalesHeader.Status = L_ExistSalesHeader.Status::Released then begin
                        //     ReleaseSalesDoc.PerformManualReopen(L_ExistSalesHeader);
                        // end;

                        //Create Lines++
                        CreateSalesLine(L_ExistSalesHeader, CustmerTrend);

                    end;
                end else begin
                    // //Open Sales Order If released++
                    // if InsertedSH.Status = InsertedSH.Status::Released then
                    //     ReleaseSalesDoc.PerformManualReopen(InsertedSH);

                    //Create Line++    
                    CreateSalesLine(InsertedSalesHeader, CustmerTrend);
                end;

            until CustmerTrend.Next() = 0;

            if G_SNo <> '' then begin
                If Confirm('Sales Order %1 Updated, Do you want to open?', true, G_SNo) then begin
                    Clear(L_SalesOrderCard);
                    L_SalesH.Reset();
                    L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
                    L_SalesH.SetRange("No.", G_SNo);
                    if L_SalesH.FindFirst() then begin
                        L_SalesOrderCard.SetTableView(L_SalesH);
                        L_SalesOrderCard.Run();
                    end;
                end Else
                    exit;
            end else begin
                If Confirm('Sales Order %1 Created, Do you want to open?', true, InsertedSalesHeader."No.") then begin
                    Clear(L_SalesOrderCard);
                    L_SalesH.Reset();
                    L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
                    L_SalesH.SetRange("No.", InsertedSalesHeader."No.");
                    if L_SalesH.FindFirst() then begin
                        L_SalesOrderCard.SetTableView(L_SalesH);
                        L_SalesOrderCard.Run();
                    end;
                end Else
                    exit;
            end;
        end;

        //Delete Customer Trends++
        //if GetLastErrorText() = '' then begin
        CustmerTrend.Reset();
        CustmerTrend.SetRange("Customer No.", _CustNumber);
        CustmerTrend.SetRange("Salesperson Code", _SalesPersonCode);
        if CustmerTrend.FindSet() then
            CustmerTrend.DeleteAll();
        //end;

    end;

    local procedure CreateSalesLine(_SalesHeader: Record "Sales Header"; _Customertrend: Record CustomerTrends)
    var
        InsertedSL: Record "Sales Line";

    begin
        InsertedSL.Reset();
        InsertedSL.SetRange("Document Type", InsertedSL."Document Type"::Order);
        InsertedSL.SetRange("Document No.", _SalesHeader."No.");
        InsertedSL.SetRange("No.", _Customertrend."Item No.");
        InsertedSL.SetRange(Type, InsertedSL.Type::Item);
        if InsertedSL.FindFirst() then begin
            InsertedSL.Validate(Quantity, InsertedSL.Quantity + _Customertrend."Qty. to be added to SO");
            InsertedSL.Modify(true);
        end else begin
            InsertedSL.Init();
            InsertedSL.VALIDATE("Document Type", InsertedSL."Document Type"::Order);
            InsertedSL.VALIDATE("Document No.", _SalesHeader."No.");
            InsertedSL.VALIDATE("Line No.", GetLastLineNo(_SalesHeader."No."));
            InsertedSL.VALIDATE(Type, InsertedSL.Type::Item);
            InsertedSL.VALIDATE("No.", _Customertrend."Item No.");
            InsertedSL.VALIDATE(Quantity, _Customertrend."Qty. to be added to SO");
            InsertedSL.Validate("Location Code", _SalesHeader."Location Code");
            InsertedSL.Validate("Unit Price", _Customertrend."Unit Price");
            InsertedSL."Last Price" := _Customertrend."Last Price";
            //InsertedSL."Shipper Qty" := _Customertrend."Shipper Qty";
            InsertedSL.Insert(true);
        end;
    end;

    local procedure GetLastLineNo(HeaderNo: Code[20]): Integer
    var
        L_SalesLine: Record "Sales Line";
    begin
        L_SalesLine.RESET;
        L_SalesLine.SETRANGE("Document Type", L_SalesLine."Document Type"::Order);
        L_SalesLine.SETRANGE("Document No.", HeaderNo);
        IF L_SalesLine.FINDLAST THEN
            EXIT(L_SalesLine."Line No." + 10000)
        ELSE
            EXIT(10000);
    end;

    local procedure CreateSalesHeader(_CustmerTrend: Record CustomerTrends)
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SalesRecSetup: Record "Sales & Receivables Setup";
        L_DocumetNo: Code[20];
    begin
        SalesRecSetup.Get();
        InsertedSalesHeader.Reset();
        InsertedSalesHeader.Init();
        InsertedSalesHeader.Validate("Document Type", InsertedSalesHeader."Document Type"::Order);
        Clear(L_DocumetNo);
        L_DocumetNo := NoSeriesManagement.GetNextNo(SalesRecSetup."Order Nos.", WORKDATE, TRUE);
        InsertedSalesHeader."No." := L_DocumetNo;
        InsertedSalesHeader.Validate("Sell-to Customer No.", _CustmerTrend."Customer No.");
        InsertedSalesHeader.Validate("Posting Date", WorkDate());
        InsertedSalesHeader.Validate("Order Date", WorkDate());
        InsertedSalesHeader.Validate("Document Date", WorkDate());
        InsertedSalesHeader.Validate("Shipping Agent Code", _CustmerTrend."Shipping Agent Code");
        InsertedSalesHeader.Validate("Shipping Agent Service Code", _CustmerTrend."Shipping Agent Service Code");
        InsertedSalesHeader.Insert(true);

        //Update Shipment date++
        InsertedSalesHeader.Validate("Shipment Date", _CustmerTrend."Delivery Date");
        InsertedSalesHeader.Modify();
        G_SalesHeaderCreated := true;
    end;



    local procedure CheckSalesHeaderExist_But_InventoryPick_And_PostedInventoryPickNotExist(_SellToCustomerNo: Code[50]; _DeliveryDate: Date): Boolean
    var
        L_SalesHeader: Record "Sales Header";
    begin
        Clear(G_SNo);
        L_SalesHeader.Reset();
        L_SalesHeader.SetRange("Sell-to Customer No.", _SellToCustomerNo);
        L_SalesHeader.SetRange(Status, L_SalesHeader.Status::Open);
        L_SalesHeader.SetRange("Document Type", L_SalesHeader."Document Type"::Order);
        L_SalesHeader.SetRange("Shipment Date", _DeliveryDate);
        if L_SalesHeader.FindSet() then begin
            repeat
                //Check Shipment is available
                if not CheckShipmetExist(L_SalesHeader) then begin

                    //Check Posted Pick is Availabel or not+++
                    if not CheckPostedShipmentExist(L_SalesHeader) then begin
                        G_SalesHeaderCreated := true;
                        G_SNo := L_SalesHeader."No.";
                        exit(true);
                    end;
                end;
            until L_SalesHeader.Next() = 0;

            exit(false);
        end;
    end;

    local procedure CheckShipmetExist(_SalesHeader: Record "Sales Header"): Boolean
    var
        WarehouseShipmentLine: Record "Warehouse Shipment Line";
    begin
        WarehouseShipmentLine.Reset();
        WarehouseShipmentLine.SetRange("Source Document", WarehouseShipmentLine."Source Document"::"Sales Order");
        WarehouseShipmentLine.SetRange("Source No.", _SalesHeader."No.");
        if not WarehouseShipmentLine.IsEmpty then
            exit(true)
        else
            exit(false);
    end;

    local procedure CheckPostedShipmentExist(_SalesHeader: Record "Sales Header"): Boolean
    var
        L_SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        L_SalesShipmentHeader.Reset();
        L_SalesShipmentHeader.SetRange("Order No.", _SalesHeader."No.");
        if not L_SalesShipmentHeader.IsEmpty then
            exit(true)
        else
            exit(false);
    end;


}