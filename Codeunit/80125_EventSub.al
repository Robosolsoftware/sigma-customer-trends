codeunit 80125 EventSub
{
    trigger OnRun()
    begin

    end;

    procedure PopulateTrendsForRecurringIfNotILE(Ch_RecuLine: Record "Standard Sales Line"; var CustNo: Code[20])
    var
        Rec_ILE: Record "Item Ledger Entry";
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


    local procedure PopulateTrends(ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20])
    var
        Rec_ILE: Record "Item Ledger Entry";
    begin
        CH_CustTrends.Init();
        CH_CustTrends.Validate("Item No.", ILE."Item No.");
        CH_CustTrends.Validate("Customer No.", ILE."Source No.");
        CH_CustTrends.Validate("Salesperson Code", _SalesPersonCode);
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



    local procedure InsertSpecialPromotion(_PriceListLine: Record "Price List Line"; CustNumber: Code[100]; SalesPersonCode: Code[20])
    var
        Rec_ILE: Record "Item Ledger Entry";
    begin
        CH_CustTrends.Init();
        CH_CustTrends.Validate("Item No.", _PriceListLine."Product No.");
        CH_CustTrends.Validate("Customer No.", CustNumber);
        CH_CustTrends.Validate("Salesperson Code", SalesPersonCode);
        if CH_Items.Get(_PriceListLine."Product No.") then;

        CH_CustTrends.Validate("Units of Measure", CH_Items."Sales Unit of Measure");

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
        // CH_CustTrends."Last 1 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-2W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 2 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-3W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 3 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-4W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 4 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-5W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 5 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-6W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 6 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-7W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 7 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-8W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 8 Week Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-9W+1D>'), CALCDATE('<CW-1W>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 3 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-3M>'), CALCDATE('<-CM-2M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Last 6 Months Sales" := G_Routine.Calculate8WeeksSales(CALCDATE('<-CM-6M>'), CALCDATE('<-CM-2M-1D>'), '', ILE."Item No.", CH_CustTrends."Customer No.");
        // CH_CustTrends."Free Stock Quanyity" := G_Routine.CalculateFreeStockQuantity(ILE."Item No.", ILE."Location Code");

        SalesPrice.Reset();
        SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::Customer);
        SalesPrice.SetRange("Source No.", CustNumber);
        SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
        SalesPrice.SetRange("Asset No.", _PriceListLine."Product No.");
        SalesPrice.SetRange(Status, SalesPrice.Status::Active);
        SalesPrice.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if SalesPrice.FindLast() then
            CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
        else begin
            Clear(SalesPrice);
            SalesPrice.Reset();
            SalesPrice.SetRange("Asset Type", SalesPrice."Asset Type"::Item);
            SalesPrice.SetRange("Asset No.", _PriceListLine."Product No.");
            SalesPrice.SetRange(Status, SalesPrice.Status::Active);
            if SalesPrice.FindLast() then
                CH_CustTrends.Validate("Unit Price", SalesPrice."Unit Price")
            else
                CH_CustTrends."Unit Price" := 0;
        end;

        CH_SShip.Reset();
        CH_SShip.SetRange("Sell-to Customer No.", CustNumber);
        CH_SShip.SetRange("No.", _PriceListLine."Product No.");
        CH_SShip.SetRange("Unit of Measure Code", CH_Items."Sales Unit of Measure");
        if CH_SShip.FindLast() then
            CH_CustTrends."Last Price" := CH_SShip."Unit Price";

        //CH_CustTrends.Updated := true;//Test
        CH_CustTrends."Special Promotion" := true;
        CH_CustTrends."Updated By" := UserId;
        CH_CustTrends."Updated On" := CurrentDateTime;

        CH_CustTrends.Insert(true);
    end;

    procedure InsertAndModifyTrends(CH_ILE: Record "Item Ledger Entry"; _SalesPersonCode: Code[20])
    begin
        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Item No.", CH_ILE."Item No.");
        CH_CustTrends.SetRange("Customer No.", CH_ILE."Source No.");
        CH_CustTrends.SetRange("Salesperson Code", _SalesPersonCode);
        if not CH_CustTrends.FindFirst() then
            PopulateTrends(CH_ILE, _SalesPersonCode);
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


    procedure CustomerTrend_GetUnitPrice(_SelltoCustomerNumber: Code[100]; _ItemNumber: Code[20]; _Quantity: Decimal; _OrderDate: Date): Decimal
    var
        L_PriceListLine: Record "Price List Line";
        L_Customer: Record Customer;
        L_Item: Record Item;
        L_CustomerNumber: Code[20];
        L_CurrencyFactor: Decimal;
        CurrencyDate: Date;
        UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        Clear(L_CustomerNumber);
        Clear(L_CurrencyFactor);
        Clear(CurrencyDate);

        L_Customer.Reset();
        L_Customer.SetRange("No.", _SelltoCustomerNumber);
        if L_Customer.FindFirst() then begin
            if L_Customer."Bill-to Customer No." <> '' then
                L_CustomerNumber := L_Customer."Bill-to Customer No."
            else
                L_CustomerNumber := L_Customer."No.";
        end;


        L_Customer.Reset();
        If L_Customer.Get(L_CustomerNumber) then begin
            //1st Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;


            //2nd Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 2");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //3rd Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 3");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //4th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 4");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //5th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 5");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //6th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 6");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //7th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 7");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //8th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 8");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //9th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 9");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //10th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 10");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" <= _Quantity then begin
                            if L_PriceListLine."Unit Price" = 0 then begin
                                L_Item.Reset();
                                L_Item.SetRange("No.", _ItemNumber);
                                if L_Item.FindFirst() then begin
                                    exit(L_Item."Unit Price");
                                end;
                            end else
                                exit(L_PriceListLine."Unit Price");
                        end;
                    end else begin
                        if L_PriceListLine."Unit Price" = 0 then begin
                            L_Item.Reset();
                            L_Item.SetRange("No.", _ItemNumber);
                            if L_Item.FindFirst() then begin
                                exit(L_Item."Unit Price");
                            end;
                        end else
                            exit(L_PriceListLine."Unit Price");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //If Price List not found
            Clear(L_CurrencyFactor);
            Clear(CurrencyDate);
            IF L_Item.Get(_ItemNumber) then begin
                if L_Customer."Currency Code" <> '' then begin
                    if _OrderDate <> 0D then
                        CurrencyDate := _OrderDate
                    else
                        CurrencyDate := WorkDate();

                    if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist(CurrencyDate, L_Customer."Currency Code") then begin
                        L_CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, L_Customer."Currency Code");
                    end else
                        UpdateCurrencyExchangeRates.ShowMissingExchangeRatesNotification(L_Customer."Currency Code");
                end else begin
                    L_CurrencyFactor := 1;
                end;

                //Return Unit Price Price++
                if L_CurrencyFactor > 0 then
                    exit(L_Item."Unit Price" / L_CurrencyFactor)
                else
                    exit(L_Item."Unit Price");
            end;

        end;
    end;


    procedure CustomerTrend_GetLineDiscount(_SelltoCustomerNumber: Code[100]; _ItemNumber: Code[20]; _Quantity: Decimal; _OrderDate: Date): Decimal
    var
        L_PriceListLine: Record "Price List Line";
        L_Customer: Record Customer;
        L_Item: Record Item;
        L_CustomerNumber: Code[20];
    begin
        Clear(L_CustomerNumber);
        L_Customer.Reset();
        L_Customer.SetRange("No.", _SelltoCustomerNumber);
        if L_Customer.FindFirst() then begin
            if L_Customer."Bill-to Customer No." <> '' then
                L_CustomerNumber := L_Customer."Bill-to Customer No."
            else
                L_CustomerNumber := L_Customer."No.";
        end;


        L_Customer.Reset();
        If L_Customer.Get(L_CustomerNumber) then begin
            //1st Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;


            //2nd Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 2");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //3rd Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 3");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //4th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 4");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //5th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 5");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //6th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 6");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //7th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 7");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //8th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 8");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //9th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 9");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //10th Price++
            L_PriceListLine.Reset();
            L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
            L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
            L_PriceListLine.SetRange("Asset No.", _ItemNumber);
            L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
            L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 10");
            L_Item.Reset();
            L_Item.SetRange("No.", _ItemNumber);
            if L_Item.FindFirst() then
                L_PriceListLine.SetRange("Unit of Measure Code", L_Item."Sales Unit of Measure");
            //L_PriceListLine.SetRange("Variant Code", SalesLine."Variant Code");
            L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _OrderDate, 0D);
            L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
            if L_PriceListLine.FindSet() then begin
                repeat
                    if L_PriceListLine."Minimum Quantity" <> 0 then begin
                        if L_PriceListLine."Minimum Quantity" < _Quantity then begin
                            exit(L_PriceListLine."Line Discount %");
                        end;
                    end else begin
                        exit(L_PriceListLine."Line Discount %");
                    end;
                until L_PriceListLine.Next() = 0;
            end;

            //If Price List not found
            exit(0);

        end;
    end;


    // procedure GetOriginalUnitPrice(_CustomerTrend: Record CustomerTrends): Decimal
    // var
    //     L_PriceListLine: Record "Price List Line";
    //     L_Customer: Record Customer;
    //     L_Item: Record Item;
    //     L_CustomerNumber: Code[20];
    //     L_CurrencyFactor: Decimal;
    //     CurrencyDate: Date;
    //     UpdateCurrencyExchangeRates: Codeunit "Update Currency Exchange Rates";
    //     CurrExchRate: Record "Currency Exchange Rate";
    // begin
    //     Clear(L_CustomerNumber);
    //     Clear(L_CurrencyFactor);
    //     Clear(CurrencyDate);


    //     L_Customer.Reset();
    //     L_Customer.SetRange("No.", _CustomerTrend."Customer No.");
    //     if L_Customer.FindFirst() then begin
    //         if L_Customer."Bill-to Customer No." <> '' then
    //             L_CustomerNumber := L_Customer."Bill-to Customer No."
    //         else
    //             L_CustomerNumber := L_Customer."No.";
    //     end;


    //     L_Customer.Reset();
    //     If L_Customer.Get(L_CustomerNumber) then begin
    //         //1st Price++
    //         L_PriceListLine.Reset();
    //         L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
    //         L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
    //         L_PriceListLine.SetRange("Asset No.", _CustomerTrend."Item No.");
    //         L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
    //         L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group");
    //         L_PriceListLine.SetRange("Unit of Measure Code", _CustomerTrend."Units of Measure");
    //         L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
    //         if L_PriceListLine.FindSet() then begin
    //             repeat
    //                 if L_PriceListLine."Minimum Quantity" <> 0 then begin
    //                     if L_PriceListLine."Minimum Quantity" <= _CustomerTrend."Qty. to be added to SO" then begin
    //                         exit(L_PriceListLine."Unit Price");
    //                     end;
    //                 end else begin
    //                     exit(L_PriceListLine."Unit Price");
    //                 end;
    //             until L_PriceListLine.Next() = 0;
    //         end;


    //         //2nd Price++
    //         L_PriceListLine.Reset();
    //         L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
    //         L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
    //         L_PriceListLine.SetRange("Asset No.", _CustomerTrend."Item No.");
    //         L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
    //         L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 2");
    //         L_PriceListLine.SetRange("Unit of Measure Code", _CustomerTrend."Units of Measure");
    //         L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
    //         if L_PriceListLine.FindSet() then begin
    //             repeat
    //                 if L_PriceListLine."Minimum Quantity" <> 0 then begin
    //                     if L_PriceListLine."Minimum Quantity" <= _CustomerTrend."Qty. to be added to SO" then begin
    //                         exit(L_PriceListLine."Unit Price");
    //                     end;
    //                 end else begin
    //                     exit(L_PriceListLine."Unit Price");
    //                 end;
    //             until L_PriceListLine.Next() = 0;
    //         end;


    //         //3rd Price++
    //         L_PriceListLine.Reset();
    //         L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
    //         L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
    //         L_PriceListLine.SetRange("Asset No.", _CustomerTrend."Item No.");
    //         L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
    //         L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 3");
    //         L_PriceListLine.SetRange("Unit of Measure Code", _CustomerTrend."Units of Measure");
    //         L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
    //         if L_PriceListLine.FindSet() then begin
    //             repeat
    //                 if L_PriceListLine."Minimum Quantity" <> 0 then begin
    //                     if L_PriceListLine."Minimum Quantity" <= _CustomerTrend."Qty. to be added to SO" then begin
    //                         exit(L_PriceListLine."Unit Price");
    //                     end;
    //                 end else begin
    //                     exit(L_PriceListLine."Unit Price");
    //                 end;
    //             until L_PriceListLine.Next() = 0;
    //         end;


    //         //4th Price++
    //         L_PriceListLine.Reset();
    //         L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
    //         L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
    //         L_PriceListLine.SetRange("Asset No.", _CustomerTrend."Item No.");
    //         L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
    //         L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 4");
    //         L_PriceListLine.SetRange("Unit of Measure Code", _CustomerTrend."Units of Measure");
    //         L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
    //         if L_PriceListLine.FindSet() then begin
    //             repeat
    //                 if L_PriceListLine."Minimum Quantity" <> 0 then begin
    //                     if L_PriceListLine."Minimum Quantity" <= _CustomerTrend."Qty. to be added to SO" then begin
    //                         exit(L_PriceListLine."Unit Price");
    //                     end;
    //                 end else begin
    //                     exit(L_PriceListLine."Unit Price");
    //                 end;
    //             until L_PriceListLine.Next() = 0;
    //         end;

    //         //5th Price++
    //         L_PriceListLine.Reset();
    //         L_PriceListLine.SetFilter(Status, '%1', L_PriceListLine.Status::Active);
    //         L_PriceListLine.SetRange("Price Type", L_PriceListLine."Price Type"::Sale);
    //         L_PriceListLine.SetRange("Asset No.", _CustomerTrend."Item No.");
    //         L_PriceListLine.SetRange("Source Type", L_PriceListLine."Source Type"::"Customer Price Group");
    //         L_PriceListLine.SetRange("Source No.", L_Customer."Customer Price Group 5");
    //         L_PriceListLine.SetRange("Unit of Measure Code", _CustomerTrend."Units of Measure");
    //         L_PriceListLine.SetFilter("Ending Date", '>%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetFilter("Starting Date", '<%1|%2', _CustomerTrend."Order Date", 0D);
    //         L_PriceListLine.SetRange("Currency Code", L_Customer."Currency Code");
    //         if L_PriceListLine.FindSet() then begin
    //             repeat
    //                 if L_PriceListLine."Minimum Quantity" <> 0 then begin
    //                     if L_PriceListLine."Minimum Quantity" <= _CustomerTrend."Qty. to be added to SO" then begin
    //                         exit(L_PriceListLine."Unit Price");
    //                     end;
    //                 end else begin
    //                     exit(L_PriceListLine."Unit Price");
    //                 end;
    //             until L_PriceListLine.Next() = 0;
    //         end;

    //         //If Price List not found
    //         Clear(L_CurrencyFactor);
    //         Clear(CurrencyDate);
    //         IF L_Item.Get(_CustomerTrend."Item No.") then begin
    //             if L_Customer."Currency Code" <> '' then begin
    //                 if _CustomerTrend."Order Date" <> 0D then
    //                     CurrencyDate := _CustomerTrend."Order Date"
    //                 else
    //                     CurrencyDate := WorkDate();

    //                 if UpdateCurrencyExchangeRates.ExchangeRatesForCurrencyExist(CurrencyDate, L_Customer."Currency Code") then begin
    //                     L_CurrencyFactor := CurrExchRate.ExchangeRate(CurrencyDate, L_Customer."Currency Code");
    //                 end else
    //                     UpdateCurrencyExchangeRates.ShowMissingExchangeRatesNotification(L_Customer."Currency Code");
    //             end else begin
    //                 L_CurrencyFactor := 1;
    //             end;

    //             //Return Unit Price Price++
    //             if L_CurrencyFactor > 0 then
    //                 exit(L_Item."Unit Price" / L_CurrencyFactor)
    //             else
    //                 exit(L_Item."Unit Price");
    //         end;
    //     end;
    // end;

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