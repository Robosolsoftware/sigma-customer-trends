report 80125 Populate_CustomerTrends
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = true;



    local procedure PopulateTrendsForRecurringIfNotILE(Ch_RecuLine: Record "Standard Sales Line"; var CustNo: Code[20])

    begin
        CH_CustTrends.Init();
        CH_CustTrends.Validate("Item No.", Ch_RecuLine."No.");
        CH_CustTrends.Validate("Customer No.", CustNo);
        if CH_Items.Get(Ch_RecuLine."No.") then;

        CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");
        SalesPrice.Reset();
        SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::Customer);
        SalesPrice.SetRange("Source No.", CustNo);
        SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        SalesPrice.SetRange("Asset No.", Ch_RecuLine."No.");
        SalesPrice.SetRange(Status, SalesPrice.Status::Active);
        SalesPrice.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if SalesPrice.FindLast() then
            CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
        else begin
            Clear(SalesPrice);
            SalesPrice.Reset();
            SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
            SalesPrice.SetRange("Asset No.", Ch_RecuLine."No.");
            SalesPrice.SetRange(Status, SalesPrice.Status::Active);
            if SalesPrice.FindLast() then
                CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
            else
                CH_CustTrends."Unit Price" := 0;

            //CH_CustTrends.Updated := true; //Test
            CH_CustTrends."Updated By" := UserId;
            CH_CustTrends."Updated On" := CurrentDateTime;

            CH_CustTrends.Insert(true);
        end;
    end;





    // procedure AssignCustNo(CustTble: Record Customer)
    // begin
    //     // CH_CustTrends.ModifyAll(Updated, false); //Test
    //     CH_ILE.Reset();
    //     CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-1M>', Today()), CalcDate('<CM>', Today()));
    //     CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
    //     CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
    //     CH_ILE.SetRange("Source No.", CustTble."No.");
    //     if CH_ILE.FindSet() then begin
    //         repeat
    //             CH_CustTrends.Reset();
    //             CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
    //             CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
    //             if not CH_CustTrends.FindFirst() then
    //                 PopulateTrends(CH_ILE)
    //             else
    //                 //if not CH_CustTrends.Updated then //Test
    //                     ModifyTrends(CH_ILE);
    //         until CH_ILE.Next() = 0;

    //     end;
    //     clear(CH_CustTrends);
    //     CH_CustTrends.SetCurrentKey("Customer No.");
    //     CH_CustTrends.SetRange("Customer No.", CustTble."No.");
    //     PgCutTr.ResetFlag();
    //     PgCutTr.SetTableView(CH_CustTrends);
    //     PgCutTr.Run();
    // end;

    // procedure AssignCustNofromSO(SalesH: Record "Sales Header")
    // begin

    //     //CH_CustTrends.ModifyAll(Updated, false); //Test
    //     CH_ILE.Reset();
    //     CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-8W>', Today), TODAY);
    //     CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
    //     CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
    //     CH_ILE.SetRange("Source No.", SalesH."Sell-to Customer No.");
    //     if CH_ILE.FindSet() then begin
    //         repeat
    //             InsertAndModifyTrends(CH_ILE);
    //         until CH_ILE.Next() = 0;
    //     end;


    //     CH_RecuH.Reset();
    //     CH_RecuH.SetRange("Customer No.", SalesH."Sell-to Customer No.");
    //     if CH_RecuH.FindSet() then begin
    //         repeat
    //             Ch_RecuLine.Reset();
    //             Ch_RecuLine.SetRange("Standard Sales Code", CH_RecuH.Code);
    //             Ch_RecuLine.SetRange(Type, Ch_RecuLine.Type::Item);
    //             if Ch_RecuLine.FindSet() then begin
    //                 repeat
    //                     InsertAndModifyTrends(CH_ILE); //if ILE is created
    //                     PopulateTrendsForRecurringIfNotILE(Ch_RecuLine, CH_RecuH."Customer No.");
    //                 until Ch_RecuLine.Next() = 0;
    //             end;
    //         until CH_RecuH.Next() = 0;
    //     end;

    //     clear(CH_CustTrends);
    //     CH_CustTrends.SetCurrentKey("Customer No.");
    //     CH_CustTrends.SetRange("Customer No.", SalesH."Sell-to Customer No.");
    //     PgCutTr.ResetFlag();
    //     PgCutTr.GetSODetails(SalesH);
    //     PgCutTr.SetTableView(CH_CustTrends);
    //     PgCutTr.Run();
    // end;

    procedure Calculate8WeeksSales(L_StartDate: Date; L_EndDate: Date; L_Location: Code[20]; P_ItemNo: Code[20]; P_SourceNo: Code[100]) L_TotalQty: Decimal
    var
        myInt: Integer;
        Rec_ILE: Record "Item Ledger Entry";
    begin
        //Week
        Clear(L_TotalQty);
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", P_ItemNo);
        Rec_ILE.SetRange("Source No.", P_SourceNo);
        Rec_ILE.SetFilter("Posting Date", '%1..%2', L_StartDate, L_EndDate);
        if Rec_ILE.FindSet() then begin
            repeat
                L_TotalQty += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;
    end;

    procedure CalculateFreeStockQuantity(ItemNo: Code[250]; LocationCode: code[10]): Decimal
    var
        L_WhseQty: Decimal;
        L_Item: Record Item;
    begin
        Clear(L_WhseQty);
        L_Item.Reset();
        L_Item.SetRange("No.", ItemNo);
        L_Item.SetRange(L_Item."Location Filter", LocationCode);
        if L_Item.FindFirst() then begin
            L_Item.CalcFields(Inventory, "Qty. on Sales Order");
            L_WhseQty := L_Item.Inventory - L_Item."Qty. on Sales Order";
        end;
        exit(L_WhseQty);
    end;

    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        CH_ILE: Record "Item Ledger Entry";
        SalesPrice: Record "Price List Line";

        CH_RecuH: Record "Standard Customer Sales Code";

        Ch_RecuLine: Record "Standard Sales Line";
}

