codeunit 80128 "Customer Trend Sales Quota"
{
    trigger OnRun()
    begin

    end;

    var
        myInt: Integer;

    procedure CheckExceededQty(_CustomerTrends: Record CustomerTrends)
    var
        Recitem: Record Item;
        CurrentMonthStartDate: Date;
        CurrentYear: Integer;
        currentMonth: Integer;
        CurrentMonth_Text: Text;
        EndDate: Date;
    begin
        Clear(CurrentMonthStartDate);
        Clear(EndDate);

        Recitem.Reset();
        Recitem.SetRange("No.", _CustomerTrends."Item No.");
        if Recitem.FindFirst() then;

        //StartDateEndDateCalculation
        currentMonth := Date2DMY(_CustomerTrends."Order Date", 2);
        CurrentYear := Date2DMY(_CustomerTrends."Order Date", 3);
        if currentMonth > 9 then
            CurrentMonth_Text := Format(currentMonth)
        else
            CurrentMonth_Text := '0' + Format(currentMonth);
        Evaluate(CurrentMonthStartDate, '01' + CurrentMonth_Text + Format(CurrentYear));
        //CurrentMonthStartDate--

        //EndDate++
        EndDate := CalcDate('+1M', CurrentMonthStartDate);
        EndDate := CalcDate('-1D', EndDate);
        //EndDate--


        //Per Order all 12 Validation++
        //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPOQ)-------------
        PerOrderSelCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------2: Selected Customer, All Item, ErrorCode(SCAPOQ)-------------
        PerOrderSelCustomerAllItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPOQ)-------------
        PerOrderSelCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
        PerOrderSelDimensionSelItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
        PerOrderSelDimensionAllItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
        PerOrderSelDimensionSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------7: All Customer, Selected Item, ErrorCode(ASIPOQ)-------------
        PerOrderAllCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------8: All Customer, All Item, ErrorCode(AAPOQ)-------------
        PerOrderAllCustomerAllItemQty(_CustomerTrends, Recitem."Item Category Code");
        //------------9: All Customer, Selected Item Category, ErrorCode(ASICPOQ)-------------
        PerOrderAllCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPOQ)-------------
        PerOrderSelCustomerGroupSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPOQ)-------------
        PerOrderSelCustomerGroupAllItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
        PerOrderSelCustomerGroupSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //Per Order all 12 Validation--

        //Per Day all 12 validation+++++++
        //-------------1: Selected Customer, Selected Item, ErrorCode(SCSIPDQ)-------------
        PerDaySelCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------2: Selected Customer, All Item, ErrorCode(SCAPDQ)-------------
        PerDaySelCustomerAllItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPDQ)-------
        PerDaySelCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------4: Selected Dimension, Selected Item, ErrorCode(SCAPOQ)-------------
        PerDaySelDimensionSelItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPOQ)-------------
        PerDaySelDimensionAllItem(_CustomerTrends, Recitem."Item Category Code");
        //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPOQ)-------------
        PerDaySelDimensionSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------7: All Customer, Selected Item, ErrorCode(ASIPDQ)-------------
        PerDayAllCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------8: All Customer, All Item, ErrorCode(AAPDQ)-------------
        PerDayAllCustomerAllItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPDQ)-------------
        PerDayAllCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPDQ)-------
        PerDaySelCustomerGroupSelItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPDQ)-------------
        PerDaySelCustomerGroupAllItemQty(_CustomerTrends, Recitem."Item Category Code");
        //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPOQ)-------------
        PerDaySelCustomerGroupSelItemCatQty(_CustomerTrends, Recitem."Item Category Code");
        //Per Day all 12 validation------


        //Per Month all 12 validation++
        PerMonthSelCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------2: Selected Customer, All Item, ErrorCode(SCAPMQ)-------------
        PerMonthSelCustomerAllItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------3: Selected Customer, Selected Item Category, ErrorCode(SCSICPMQ)-------
        PerMonthSelCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------4: Selected Dimension, Selected Item, ErrorCode(SCSIPMQ)-------------
        PerMonthSelDimensionSelItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------5: Selected Dimension, All Item, ErrorCode(SCAPMQ)-------------
        PerMonthSelDimensionAllItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------6: Selected Dimension, Selected Item Category, ErrorCode(SCSICPMQ)-------
        PerMonthSelDimensionSelItemCatQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------7: All Customer, Selected Item, ErrorCode(ASIPMQ)-------------
        PerMonthAllCustomerSelItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------8: All Customer, All Item, ErrorCode(AAPMQ)-------------
        PerMonthAllCustomerAllItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------9: All Customer, Selected Item Category, ErrorCode(ASICPMQ)-------------
        PerMonthAllCustomerSelItemCatQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------10: Selected Customer Price Group, Selected Item, ErrorCode(SCGSIPMQ)-------
        PerMonthSelCustomerGroupSelItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------11: Selected Customer Price Group, All Item, ErrorCode(SCGAPMQ)-------------
        PerMonthSelCustomerGroupAllItemQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        //-------------12: Selected Customer Price Group, Selected Item Category, ErrorCode(SCGSICPMQ)-------------
        PerMonthSelCustomerGroupSelItemCatQty(_CustomerTrends, Recitem."Item Category Code", CurrentMonthStartDate, EndDate);
        // //Per Month all 12 validation--
    end;

    procedure PerMonthSelDimensionSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                        WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                        //PerDay Cust Trends Order Qty++++++
                        L_CustomerTrendsPerdayQty.Reset();
                        L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                        L_CustomerTrendsPerdayQty.SETFILTER("Order Date", '%1..%2', Sdate, Edate);
                        L_CustomerTrendsPerdayQty.SetRange("Item Category Code", ItemCat);
                        if L_CustomerTrendsPerdayQty.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                                end;
                            until L_CustomerTrendsPerdayQty.Next() = 0;
                        end;

                        //PerDay Current Cust Trends Order Qty++++++
                        L_CustomerTrend.RESET;
                        L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                        L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                        L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
                        IF L_CustomerTrend.FINDSET THEN BEGIN
                            L_CustomerTrend.CalcSums("Qty. to be added to SO");
                            L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                        end;

                        //PerDay Shipped Qty++++++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        IF L_RemainingQuantity < 0 THEN
                            L_RemainingQuantity := 0;

                        CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;


    procedure PerMonthSelDimensionAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                        WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                        //PerDay Cust Trends Order Qty++++++
                        L_CustomerTrendsPerdayQty.Reset();
                        L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                        L_CustomerTrendsPerdayQty.SETFILTER("Order Date", '%1..%2', Sdate, Edate);
                        L_CustomerTrendsPerdayQty.SetRange("Item No.", _CustomerTrends."Item No.");
                        if L_CustomerTrendsPerdayQty.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                                end;
                            until L_CustomerTrendsPerdayQty.Next() = 0;
                        end;

                        //PerDay Current Cust Trends Order Qty++++++
                        L_CustomerTrend.RESET;
                        L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                        L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                        L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                        IF L_CustomerTrend.FINDSET THEN BEGIN
                            L_CustomerTrend.CalcSums("Qty. to be added to SO");
                            L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                        end;

                        //PerDay Shipped Qty+++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("No.", _CustomerTrends."Item No.");
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        IF L_RemainingQuantity < 0 THEN
                            L_RemainingQuantity := 0;

                        CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;


    procedure PerMonthSelDimensionSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";


        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                        WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                        //PerDay Cust Trends Order Qty++++++
                        L_CustomerTrendsPerdayQty.Reset();
                        L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                        L_CustomerTrendsPerdayQty.SETFILTER("Order Date", '%1..%2', Sdate, Edate);
                        L_CustomerTrendsPerdayQty.SetRange("Item No.", _CustomerTrends."Item No.");
                        if L_CustomerTrendsPerdayQty.FindSet() then begin
                            repeat
                                DefaultDimension_2.Reset();
                                DefaultDimension_2.SetRange("Table ID", 18);
                                DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                                DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                                DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if DefaultDimension_2.FindFirst() then begin
                                    L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                                end;
                            until L_CustomerTrendsPerdayQty.Next() = 0;
                        end;

                        //PerDay Current Cust Trends Order Qty++++++
                        L_CustomerTrend.RESET;
                        L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                        L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                        L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                        IF L_CustomerTrend.FINDSET THEN BEGIN
                            L_CustomerTrend.CalcSums("Qty. to be added to SO");
                            L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                        end;

                        //PerDay Shipped Qty+++++
                        L_SalesShipmentLine.Reset();
                        L_SalesShipmentLine.SetRange("No.", _CustomerTrends."Item No.");
                        L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                        L_SalesShipmentLine.SetFilter("Order Date", '%1..%2', Sdate, Edate);
                        if L_SalesShipmentLine.FindSet() then begin
                            repeat
                                L_DimensionSetEntry.Reset();
                                L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                                L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                                L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                                if L_DimensionSetEntry.FindFirst() then begin
                                    L_DayOrderQty += L_SalesShipmentLine.Quantity;
                                end;
                            until L_SalesShipmentLine.Next() = 0;
                        end;

                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                        IF L_RemainingQuantity < 0 THEN
                            L_RemainingQuantity := 0;

                        CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                    end;
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;

    procedure PerMonthSelCustomerGroupSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;


                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthSelCustomerGroupAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;


                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthSelCustomerGroupSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;



    procedure PerMonthAllCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthAllCustomerAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthAllCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthSelCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            End;
        end;
    end;

    procedure PerMonthSelCustomerAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            end;
        End;
    end;


    procedure PerMonthSelCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20]; Sdate: date; Edate: Date)
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Month");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            if (L_MaxOrderQty."Start Date" <= _CustomerTrends."Order Date") AND (L_MaxOrderQty."End Date" >= _CustomerTrends."Order Date") then begin
                WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                //PerDay Cust Trends Order Qty++++++
                L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
                L_DaywiseCustTrendsquantity.SetRange(L_DaywiseCustTrendsquantity.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DaywiseCustTrendsquantity.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
                L_DaywiseCustTrendsquantity.OPEN;
                WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                    L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
                END;
                L_DaywiseCustTrendsquantity.CLOSE;

                //PerDay Current Cust Trends Order Qty++++++
                L_CustomerTrend.RESET;
                L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                IF L_CustomerTrend.FINDSET THEN BEGIN
                    L_CustomerTrend.CalcSums("Qty. to be added to SO");
                    L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                end;

                //PerDay Shipped Qty++
                L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Sell_to_Customer_No, _CustomerTrends."Customer No.");
                L_DayWiseShippedQty.SetRange(L_DayWiseShippedQty.Ship_to_Code, _CustomerTrends."Ship-to Code");
                L_DayWiseShippedQty.SetFilter(Order_Date, '%1..%2', Sdate, Edate);
                L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
                L_DayWiseShippedQty.OPEN;
                WHILE L_DayWiseShippedQty.READ DO BEGIN
                    L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
                END;
                L_DayWiseShippedQty.CLOSE;

                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                IF L_RemainingQuantity < 0 THEN
                    L_RemainingQuantity := 0;

                CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
            end;

        end;
    end;

    procedure PerDaySelCustomerGroupSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;

    procedure PerDaySelCustomerGroupSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;

    procedure PerDaySelCustomerGroupAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Customer_Price_Group, _CustomerTrends."Customer Price Group");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;


    procedure PerDaySelDimensionSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    //PerDay Cust Trends Order Qty++++++
                    L_CustomerTrendsPerdayQty.Reset();
                    L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                    L_CustomerTrendsPerdayQty.SetRange("Order Date", _CustomerTrends."Order Date");
                    L_CustomerTrendsPerdayQty.SetRange("Item Category Code", ItemCat);
                    if L_CustomerTrendsPerdayQty.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                            end;
                        until L_CustomerTrendsPerdayQty.Next() = 0;
                    end;


                    //PerDay Current Cust Trends Order Qty++++++
                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                    end;

                    //PerDay Shipped Qty+++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("Item Category Code", ItemCat);
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _CustomerTrends."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        L_RemainingQuantity := 0;

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;

    procedure PerDaySelDimensionAllItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";


        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    //PerDay Cust Trends Order Qty++++++
                    L_CustomerTrendsPerdayQty.Reset();
                    L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                    L_CustomerTrendsPerdayQty.SetRange("Order Date", _CustomerTrends."Order Date");
                    L_CustomerTrendsPerdayQty.SetRange("Item No.", _CustomerTrends."Item No.");
                    if L_CustomerTrendsPerdayQty.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                            end;
                        until L_CustomerTrendsPerdayQty.Next() = 0;
                    end;

                    //PerDay Current Cust Trends Order Qty++++++
                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                    end;

                    //PerDay Shipped Qty++++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("No.", _CustomerTrends."Item No.");
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _CustomerTrends."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        L_RemainingQuantity := 0;

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;



    procedure PerDaySelDimensionSelItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
        L_DefaultDimension: Record "Default Dimension";

        //New
        L_SalesLine: Record "Sales Line";
        L_CustomerTrendsPerdayQty: Record CustomerTrends;
        DefaultDimension_2: Record "Default Dimension";
        L_SaleasHeader: Record "Sales Header";
        L_DimensionSetEntry: Record "Dimension Set Entry";
        L_SalesShipmentLine: Record "Sales Shipment Line";
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);
        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    //PerDay Cust Trends Order Qty++++++
                    L_CustomerTrendsPerdayQty.Reset();
                    L_CustomerTrendsPerdayQty.SETFILTER("Salesperson Code", '<>%1', _CustomerTrends."Salesperson Code");
                    L_CustomerTrendsPerdayQty.SetRange("Order Date", _CustomerTrends."Order Date");
                    L_CustomerTrendsPerdayQty.SetRange("Item No.", _CustomerTrends."Item No.");
                    if L_CustomerTrendsPerdayQty.FindSet() then begin
                        repeat
                            DefaultDimension_2.Reset();
                            DefaultDimension_2.SetRange("Table ID", 18);
                            DefaultDimension_2.SetRange("Parent Type", DefaultDimension_2."Parent Type"::Customer);
                            DefaultDimension_2.SetRange("No.", L_CustomerTrendsPerdayQty."Customer No.");
                            DefaultDimension_2.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            DefaultDimension_2.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if DefaultDimension_2.FindFirst() then begin
                                L_DayOrderQty += L_CustomerTrendsPerdayQty."Qty. to be added to SO";
                            end;
                        until L_CustomerTrendsPerdayQty.Next() = 0;
                    end;


                    //PerDay Current Cust Trends Order Qty++++++
                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
                    end;


                    //PerDay Shipped Qty++++++
                    L_SalesShipmentLine.Reset();
                    L_SalesShipmentLine.SetRange("No.", _CustomerTrends."Item No.");
                    L_SalesShipmentLine.SetRange(Type, L_SalesShipmentLine.Type::Item);
                    L_SalesShipmentLine.SetRange("Order Date", _CustomerTrends."Order Date");
                    if L_SalesShipmentLine.FindSet() then begin
                        repeat
                            L_DimensionSetEntry.Reset();
                            L_DimensionSetEntry.SetRange("Dimension Set ID", L_SalesShipmentLine."Dimension Set ID");
                            L_DimensionSetEntry.SetRange("Dimension Code", L_DefaultDimension."Dimension Code");
                            L_DimensionSetEntry.SetRange("Dimension Value Code", L_DefaultDimension."Dimension Value Code");
                            if L_DimensionSetEntry.FindFirst() then begin
                                L_DayOrderQty += L_SalesShipmentLine.Quantity;
                            end;
                        until L_SalesShipmentLine.Next() = 0;
                    end;

                    L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
                    IF L_RemainingQuantity < 0 THEN
                        L_RemainingQuantity := 0;

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;



    procedure PerDaySelCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");
            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;

    procedure PerDaySelCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");
            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;


            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;


            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;


    procedure PerDaySelCustomerAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");
            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Ship_to_Code, _CustomerTrends."Ship-to Code");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);

        end;
    end;


    procedure PerDayAllCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_Category_Code, ItemCat);
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(L_DayWiseShippedQty.Item_Category_Code, ItemCat);
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;

    procedure PerDayAllCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);

        End;
    end;


    procedure PerDayAllCustomerAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_OrderQty: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_DayWiseShippedQty: Query "DayShippe Qty";
        L_DaywiseCustTrendsquantity: Query "Daywise Cust Trends quantity";
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Day");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            //PerDay Cust Trends Order Qty++++++
            L_DaywiseCustTrendsquantity.SETFILTER(L_DaywiseCustTrendsquantity.Salesperson_Code, '<>%1', _CustomerTrends."Salesperson Code");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Customer_No_, _CustomerTrends."Customer No.");
            L_DaywiseCustTrendsquantity.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DaywiseCustTrendsquantity.SETRANGE(L_DaywiseCustTrendsquantity.Item_No_, _CustomerTrends."Item No.");
            L_DaywiseCustTrendsquantity.OPEN;
            WHILE L_DaywiseCustTrendsquantity.READ DO BEGIN
                L_DayOrderQty += L_DaywiseCustTrendsquantity.Sum_Quantity;
            END;
            L_DaywiseCustTrendsquantity.CLOSE;

            //PerDay Current Cust Trends Order Qty++++++
            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_OrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            //PerDay Shipped Qty++
            L_DayWiseShippedQty.SETRANGE(Sell_to_Customer_No, _CustomerTrends."Customer No.");
            L_DayWiseShippedQty.SETRANGE(Order_Date, _CustomerTrends."Order Date");
            L_DayWiseShippedQty.SETRANGE(No, _CustomerTrends."Item No.");
            L_DayWiseShippedQty.OPEN;
            WHILE L_DayWiseShippedQty.READ DO BEGIN
                L_DayOrderQty += L_DayWiseShippedQty.Sum_Quantity;
            END;
            L_DayWiseShippedQty.CLOSE;

            L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity" - L_DayOrderQty;
            IF L_RemainingQuantity < 0 THEN
                L_RemainingQuantity := 0;

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", L_OrderQty);
        end;
    end;


    procedure PerOrderSelCustomerGroupSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_Customer: Record Customer;
        RecItem: Record Item;
        WarningtypeOpion: Text;

    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerTrends."Customer No.");
        if L_Customer.FindFirst() then
            L_MaxOrderQty.SetRange("Sales Code", L_Customer."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SetRange("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            END;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderSelCustomerGroupSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerTrends."Customer No.");
        if L_Customer.FindFirst() then
            L_MaxOrderQty.SetRange("Sales Code", L_Customer."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;

    procedure PerOrderSelCustomerGroupAllItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"Customer Price Group");
        L_Customer.Reset();
        L_Customer.SetRange("No.", _CustomerTrends."Customer No.");
        if L_Customer.FindFirst() then
            L_MaxOrderQty.SetRange("Sales Code", L_Customer."Customer Price Group");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderSelCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        RecItem: Record Item;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN begin
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;


            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderSelCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure CheckingRemainingQty(RemQty: Decimal; Errcode: code[20]; WarningtypeOpion: Text; _TotalMaxQuantity: Decimal; _QuantityRestriction: Option "Per Day","Per Order","Per Month"; _OrderQuanitity: Decimal)
    var
    begin
        if _QuantityRestriction = _QuantityRestriction::"Per Order" then begin
            if _OrderQuanitity > RemQty then begin
                if WarningtypeOpion = 'error' then
                    ERROR('Maximum quantity %1  %2 allowed has been exceeded.You can use only %3 Qty.', _TotalMaxQuantity, _QuantityRestriction, _TotalMaxQuantity)
                else begin
                    Message('Maximum quantity %1  %2 allowed has been exceeded.You can use only %3 Qty.', _TotalMaxQuantity, _QuantityRestriction, _TotalMaxQuantity);
                end;
            end;
        end else begin
            if _OrderQuanitity > RemQty then begin
                if WarningtypeOpion = 'error' then
                    ERROR('Maximum quantity %1  %2 allowed has been exceeded.Remaining quantity is %3.', _TotalMaxQuantity, _QuantityRestriction, RemQty)
                else begin
                    Message('Maximum quantity %1  %2 allowed has been exceeded.Remaining quantity is %3.', _TotalMaxQuantity, _QuantityRestriction, RemQty);
                end;
            end;
        end;


        // IF RemQty < 0 THEN
        //     if WarningtypeOpion = 'error' then
        //         ERROR('Maximum quantity %1  %2 allowed has been exceeded.', _TotalMaxQuantity, _QuantityRestriction)
        //     else
        //         Message('Maximum quantity %1 %2 allowed has been exceeded.', _TotalMaxQuantity, _QuantityRestriction);
    end;


    procedure PerOrderSelDimensionSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        RecItem: Record Item;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
                L_MaxOrderQty.SetRange("Item Code", ItemCat);
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SetRange("Item Category Code", ItemCat);
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
                    END;

                    if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                        L_RemainingQuantity := 0
                    else
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;

    procedure PerOrderSelDimensionAllItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
                    end;

                    if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                        L_RemainingQuantity := 0
                    else
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;

    procedure PerOrderSelDimensionSelItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_DefaultDimension: Record "Default Dimension";
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_DefaultDimension.Reset();
        L_DefaultDimension.SetRange("Table ID", 18);
        L_DefaultDimension.SetRange("Parent Type", L_DefaultDimension."Parent Type"::Customer);
        L_DefaultDimension.SetRange("No.", _CustomerTrends."Customer No.");
        if L_DefaultDimension.FindSet() then begin
            repeat
                Clear(L_DayOrderQty);
                Clear(L_RemainingQuantity);
                Clear(L_OrderQty);
                Clear(WarningtypeOpion);

                L_MaxOrderQty.RESET;
                L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Dimension);
                L_MaxOrderQty.SetRange("Sales Code", L_DefaultDimension."Dimension Code");
                L_MaxOrderQty.SetRange("Dimension Value", L_DefaultDimension."Dimension Value Code");
                L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
                L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
                L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
                L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
                L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
                IF L_MaxOrderQty.FINDFIRST THEN BEGIN
                    WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

                    L_CustomerTrend.RESET;
                    L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
                    L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
                    L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
                    IF L_CustomerTrend.FINDSET THEN BEGIN
                        L_CustomerTrend.CalcSums("Qty. to be added to SO");
                        L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
                    end;

                    if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                        L_RemainingQuantity := 0
                    else
                        L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

                    CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));

                end;
            until L_DefaultDimension.Next() = 0;
        end;
    end;

    procedure PerOrderSelCustomerAllItem(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::Customer);
        L_MaxOrderQty.SetRange("Sales Code", _CustomerTrends."Customer No.");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Ship-to Code", _CustomerTrends."Ship-to Code");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderAllCustomerSelItemCatQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        RecItem: Record Item;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"Item Category");
        L_MaxOrderQty.SetRange("Item Code", ItemCat);
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SetRange("Item Category Code", ItemCat);
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            END;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderAllCustomerAllItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::"All Items");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));
        end;
    end;


    procedure PerOrderAllCustomerSelItemQty(_CustomerTrends: Record CustomerTrends; ItemCat: code[20])
    var
        L_MaxOrderQty: Record "Sales Quota";
        L_DayOrderQty: Decimal;
        L_RemainingQuantity: Decimal;
        L_CustomerTrend: Record CustomerTrends;
        L_OrderQty: Decimal;
        L_Customer: Record Customer;
        WarningtypeOpion: Text;
    begin
        Clear(L_DayOrderQty);
        Clear(L_RemainingQuantity);
        Clear(L_OrderQty);
        Clear(WarningtypeOpion);

        L_MaxOrderQty.RESET;
        L_MaxOrderQty.SETRANGE("Sales Type", L_MaxOrderQty."Sales Type"::"All Customer");
        L_MaxOrderQty.SetRange("Item Type", L_MaxOrderQty."Item Type"::Item);
        L_MaxOrderQty.SetRange("Item Code", _CustomerTrends."Item No.");
        L_MaxOrderQty.SetRange("Quantity Restriction", L_MaxOrderQty."Quantity Restriction"::"Per Order");
        L_MaxOrderQty.SetRange("Restriction Type", L_MaxOrderQty."Restriction Type"::"By Quantity");
        L_MaxOrderQty.SETFILTER("Maximum Quantity", '>%1', 0);
        IF L_MaxOrderQty.FINDFIRST THEN BEGIN
            WarningtypeOpion := Format(L_MaxOrderQty."Warning Type");

            L_CustomerTrend.RESET;
            L_CustomerTrend.SETRANGE("Salesperson Code", _CustomerTrends."Salesperson Code");
            L_CustomerTrend.SETRANGE("Customer No.", _CustomerTrends."Customer No.");
            L_CustomerTrend.SETRANGE("Item No.", _CustomerTrends."Item No.");
            IF L_CustomerTrend.FINDSET THEN BEGIN
                L_CustomerTrend.CalcSums("Qty. to be added to SO");
                L_DayOrderQty := L_CustomerTrend."Qty. to be added to SO";
            end;

            if L_MaxOrderQty."Maximum Quantity" < (L_DayOrderQty + L_OrderQty) then
                L_RemainingQuantity := 0
            else
                L_RemainingQuantity := L_MaxOrderQty."Maximum Quantity";

            CheckingRemainingQty(L_RemainingQuantity, 'SCSIPOQ', WarningtypeOpion, L_MaxOrderQty."Maximum Quantity", L_MaxOrderQty."Quantity Restriction", (L_DayOrderQty + L_OrderQty));

        end;
    end;

    // procedure CheckingRemainingQty(RemQty: Decimal; Errcode: code[20])
    // var
    // begin
    //     IF (RemQty < 0) THEN
    //         ERROR('Maximum quantity allowed has been exceeded. Error Code:' + Errcode);
    // end;
}