codeunit 80125 EventSub
{
    trigger OnRun()
    begin

    end;

    procedure PopulateTrendsForRecurringIfNotILE(Ch_RecuLine: Record "Standard Sales Line"; var CustNo: Code[20])
    var
        Rec_ILE: Record "Item Ledger Entry";
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Customer No.", CustNo);
        CH_CustTrends.SetRange("Item No.", Ch_RecuLine."No.");
        if NOT CH_CustTrends.FindFirst() then begin
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

                //Week
                Rec_ILE.Reset();
                Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                Rec_ILE.SetRange("Item No.", Ch_RecuLine."No.");
                Rec_ILE.SetRange("Source No.", CustNo);
                Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CW', Today()), CalcDate('CW', Today()));
                if Rec_ILE.FindSet() then begin
                    repeat
                        CH_CustTrends."Quantity purchased this Week" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    until Rec_ILE.Next() = 0;
                end;

                //Current Month
                Rec_ILE.Reset();
                Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                Rec_ILE.SetRange("Item No.", Ch_RecuLine."No.");
                Rec_ILE.SetRange("Source No.", CustNo);
                Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', Today()), CalcDate('CM', Today()));
                if Rec_ILE.FindSet() then begin
                    repeat
                        CH_CustTrends."Quantity purchased this Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    until Rec_ILE.Next() = 0;
                end;

                //Last Month
                Rec_ILE.Reset();
                Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
                Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
                Rec_ILE.SetRange("Item No.", Ch_RecuLine."No.");
                Rec_ILE.SetRange("Source No.", CustNo);
                Rec_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-2M+1D>', Today), CALCDATE('CM', CALCDATE('-CM-1D', TODAY)));
                if Rec_ILE.FindSet() then begin
                    repeat
                        CH_CustTrends."Qty purchased Last Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
                    until Rec_ILE.Next() = 0;
                end;
                CH_CustTrends."Last 1 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-2W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 2 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-3W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 3 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-4W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 4 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-5W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 5 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-6W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 6 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-7W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 7 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-8W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 8 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-9W+1D>'), CALCDATE('<CW-1W>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 3 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-3M>'), CALCDATE('<-CM-2M-1D>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Last 6 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-6M>'), CALCDATE('<-CM-2M-1D>'), '', Ch_RecuLine."No.", CH_CustTrends."Customer No.");
                CH_CustTrends."Free Stock Quanyity" := G_Routine.CalculateFreeStockQuantity(Ch_RecuLine."No.", '');

                if CH_CustTrends."Last 8 Week Sales" = 0 then begin
                    CH_CustTrends."Not Sold for Last 8 Weeks" := true;
                end;

                CH_CustTrends.Insert(true);
            end;
        end;
    end;

    local procedure PopulateTrends(ILE: Record "Item Ledger Entry")
    var
        Rec_ILE: Record "Item Ledger Entry";
    begin
        CH_CustTrends.Init();
        CH_CustTrends.Validate("Item No.", ILE."Item No.");
        CH_CustTrends.Validate("Customer No.", ILE."Source No.");
        if CH_Items.Get(ILE."Item No.") then;

        CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");

        //Week
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CW', Today()), CalcDate('CW', Today()));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Quantity purchased this Week" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;

        //Current Month
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', Today()), CalcDate('CM', Today()));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Quantity purchased this Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;

        //Last Month
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-2M+1D>', Today), CALCDATE('CM', CALCDATE('-CM-1D', TODAY)));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Qty purchased Last Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;
        CH_CustTrends."Last 1 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-2W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 2 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-3W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 3 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-4W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 4 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-5W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 5 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-6W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 6 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-7W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 7 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-8W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 8 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-9W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 3 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-3M>'), CALCDATE('<-CM-2M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 6 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-6M>'), CALCDATE('<-CM-2M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Free Stock Quanyity" := G_Routine.CalculateFreeStockQuantity(ILE."Item No.", ILE."Location Code");

        SalesPrice.Reset();
        SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::Customer);
        SalesPrice.SetRange("Source No.", ILE."Source No.");
        SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        SalesPrice.SetRange("Asset No.", ILE."Item No.");
        SalesPrice.SetRange(Status, SalesPrice.Status::Active);
        SalesPrice.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if SalesPrice.FindLast() then
            CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
        else begin
            Clear(SalesPrice);
            SalesPrice.Reset();
            SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
            SalesPrice.SetRange("Asset No.", ILE."Item No.");
            SalesPrice.SetRange(Status, SalesPrice.Status::Active);
            if SalesPrice.FindLast() then
                CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
            else
                CH_CustTrends."Unit Price" := 0;
        end;

        CH_SShip.Reset();
        CH_SShip.SetRange("Sell-to Customer No.", ILE."Source No.");
        CH_SShip.SetRange("No.", ILE."Item No.");
        CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if CH_SShip.FindLast() then
            CH_CustTrends."Last Price" := CH_SShip."Unit Price";

        //CH_CustTrends.Updated := true;//Test
        CH_CustTrends."Updated By" := UserId;
        CH_CustTrends."Updated On" := CurrentDateTime;

        CH_CustTrends.Insert(true);
    end;

    local procedure ModifyTrends(ILE: Record "Item Ledger Entry")
    var
        Rec_ILE: Record "Item Ledger Entry";
    begin
        //Week
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CW', Today()), CalcDate('CW', Today()));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Quantity purchased this Week" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;

        //Current Month
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', Today()), CalcDate('CM', Today()));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Quantity purchased this Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;


        //Last Month
        Rec_ILE.Reset();
        Rec_ILE.SetRange("Entry Type", Rec_ILE."Entry Type"::Sale);
        Rec_ILE.SetRange("Document Type", Rec_ILE."Document Type"::"Sales Shipment");
        Rec_ILE.SetRange("Item No.", ILE."Item No.");
        Rec_ILE.SetRange("Source No.", ILE."Source No.");
        Rec_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-2M+1D>', Today()), CALCDATE('<CM>', CALCDATE('<-CM-1D>', Today())));
        if Rec_ILE.FindSet() then begin
            repeat
                CH_CustTrends."Qty purchased Last Month" += -Rec_ILE.Quantity / Rec_ILE."Qty. per Unit of Measure";
            until Rec_ILE.Next() = 0;
        end;


        SalesPrice.Reset();
        SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::Customer);
        SalesPrice.SetRange("Source No.", ILE."Source No.");
        SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        SalesPrice.SetRange("Asset No.", ILE."Item No.");
        SalesPrice.SetRange(Status, SalesPrice.Status::Active);
        SalesPrice.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if SalesPrice.FindLast() then
            CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
        else begin
            Clear(SalesPrice);
            SalesPrice.Reset();
            SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
            SalesPrice.SetRange("Asset No.", ILE."Item No.");
            SalesPrice.SetRange(Status, SalesPrice.Status::Active);
            if SalesPrice.FindLast() then
                CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
            else
                CH_CustTrends."Unit Price" := 0;
        end;

        CH_CustTrends."Last 1 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-2W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 2 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-3W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 3 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-4W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 4 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-5W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 5 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-6W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 6 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-7W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 7 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-8W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 8 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-9W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 3 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-3M>'), CALCDATE('<-CM-2M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Last 6 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-6M>'), CALCDATE('<-CM-5M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        CH_CustTrends."Free Stock Quanyity" := G_Routine.CalculateFreeStockQuantity(ILE."Item No.", ILE."Location Code");


        CH_SShip.Reset();
        CH_SShip.SetRange("Sell-to Customer No.", ILE."Source No.");
        CH_SShip.SetRange("No.", ILE."Item No.");
        CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if CH_SShip.FindLast() then
            CH_CustTrends."Last Price" := CH_SShip."Unit Price";

        //CH_CustTrends.Updated := true;//Test
        CH_CustTrends."Updated By" := UserId;
        CH_CustTrends."Updated On" := CurrentDateTime;

        CH_CustTrends.Modify(true);
    end;

    procedure CreateCustomertrends(SalesH: Record "Sales Header"; CustNumber: Code[100])
    begin

        CH_RecuH.Reset();
        CH_RecuH.SetRange("Customer No.", CustNumber);
        if CH_RecuH.FindSet() then begin
            repeat
                Ch_RecuLine.Reset();
                Ch_RecuLine.SetRange("Standard Sales Code", CH_RecuH.Code);
                Ch_RecuLine.SetRange(Type, Ch_RecuLine.Type::Item);
                if Ch_RecuLine.FindSet() then begin
                    repeat
                        //InsertAndModifyTrends(CH_ILE); //if ILE is created
                        PopulateTrendsForRecurringIfNotILE(Ch_RecuLine, CH_RecuH."Customer No.");
                    until Ch_RecuLine.Next() = 0;
                end;
            until CH_RecuH.Next() = 0;
        end;

        //CH_CustTrends.ModifyAll(Updated, false); //Test
        CH_ILE.Reset();
        CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-8W>', Today), TODAY);
        CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
        CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
        // CH_ILE.SetRange("Source No.", SalesH."Sell-to Customer No.");
        CH_ILE.SetRange("Source No.", CustNumber);
        if CH_ILE.FindSet() then begin
            repeat
                InsertAndModifyTrends(CH_ILE);
            until CH_ILE.Next() = 0;
        end;


        clear(CH_CustTrends);
        CH_CustTrends.SetCurrentKey("Customer No.");
        CH_CustTrends.SetRange("Customer No.", CustNumber);
        PgCutTr.ResetFlag();
        PgCutTr.GetSODetails(SalesH);
        PgCutTr.SetTableView(CH_CustTrends);
        PgCutTr.Run();
    end;

    procedure InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry")
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        if not CH_CustTrends.FindFirst() then
            PopulateTrends(CH_ILE);
        // else
        //     //if not CH_CustTrends.Updated then //Test
        //         ModifyTrends(CH_ILE);
    end;


    procedure CreateOrder(CustNo: Code[100]; var SalesOrderNo: Code[100])
    var
        L_SalesHeader: Record "Sales Header";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        SalesRecSetup: Record "Sales & Receivables Setup";
        L_DocumetNo: Code[20];
    begin
        Clear(SalesOrderNo);
        SalesRecSetup.Get();
        L_SalesHeader.Init();
        L_SalesHeader.Validate("Document Type", L_SalesHeader."Document Type"::Order);
        Clear(L_DocumetNo);
        L_DocumetNo := NoSeriesManagement.GetNextNo(SalesRecSetup."Order Nos.", WORKDATE, TRUE);
        L_SalesHeader."No." := L_DocumetNo;
        L_SalesHeader.Validate("Sell-to Customer No.", CustNo);
        L_SalesHeader.Validate("Bill-to Customer No.", CustNo);
        //L_SalesHeader.Validate("External Document No.", P_POSHeader."Invoice No.");
        L_SalesHeader.Validate("Posting Date", WorkDate());
        L_SalesHeader.Validate("Order Date", WorkDate());
        L_SalesHeader.Validate("Document Date", WorkDate());
        L_SalesHeader.Insert(true);
        SalesOrderNo := L_DocumetNo
    end;

    var
        CH_CustTrends: Record CustomerTrends;
        CH_Items: Record Item;
        CH_SShip: Record "Sales Shipment Line";
        PgCutTr: page "Customer Trends";
        CH_ILE: Record "Item Ledger Entry";
        SalesPrice: Record "Price List Line";

        CH_RecuH: Record "Standard Customer Sales Code";

        Ch_RecuLine: Record "Standard Sales Line";
        G_Routine: Report Populate_CustomerTrends;
}