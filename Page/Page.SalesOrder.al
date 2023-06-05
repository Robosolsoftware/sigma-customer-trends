pageextension 80128 SalesOr_CustTr extends "Sales Order"
{
    layout
    {
        modify("Sell-to Customer No.")
        {
            trigger OnAfterValidate()
            begin
                if (xRec."Sell-to Customer No." = '') AND (Rec."Sell-to Customer No." <> '') then
                    GetCustomerTrendsLines();
            end;
        }
        modify("Sell-to Customer Name")
        {
            trigger OnAfterValidate()
            begin
                if (xRec."Sell-to Customer Name" = '') AND (Rec."Sell-to Customer Name" <> '') then
                    GetCustomerTrendsLines();
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
        addlast(Processing)
        {
            action("Customer Trends")
            {
                ApplicationArea = All;
                Image = CustomerLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


                trigger OnAction()
                var
                    RouRepo: Report Populate_CustomerTrends;
                    ChTrends: Record CustomerTrends;
                    L_EventSub: Codeunit EventSub;

                begin
                    ChTrends.DeleteAll();
                    //RouRepo.AssignCustNofromSO(Rec);
                    L_EventSub.CreateCustomertrends(Rec, Rec."Sell-to Customer No.");

                end;

            }
            action("Get Customer Trends Lines")
            {
                ApplicationArea = All;
                Image = GetLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CH_ILE: Record "Item Ledger Entry";
                    CH_RecuH: Record "Standard Customer Sales Code";
                    EventSub: Codeunit EventSub;
                    Ch_RecuLine: Record "Standard Sales Line";
                    CH_CustTrends: Record CustomerTrends;
                    SalesLn: Record "Sales Line";
                    LineNo: Integer;
                begin
                    CH_CustTrends.DeleteAll();

                    CH_ILE.Reset();
                    CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-8W>', Today), TODAY);
                    CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
                    CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
                    CH_ILE.SetRange("Source No.", Rec."Sell-to Customer No.");
                    if CH_ILE.FindSet() then begin
                        repeat
                            EventSub.InsertAndModifyTrends(CH_ILE);
                        until CH_ILE.Next() = 0;
                    end;


                    CH_RecuH.Reset();
                    CH_RecuH.SetRange("Customer No.", Rec."Sell-to Customer No.");
                    if CH_RecuH.FindSet() then begin
                        repeat
                            Ch_RecuLine.Reset();
                            Ch_RecuLine.SetRange("Standard Sales Code", CH_RecuH.Code);
                            Ch_RecuLine.SetRange(Type, Ch_RecuLine.Type::Item);
                            if Ch_RecuLine.FindSet() then begin
                                repeat
                                    EventSub.PopulateTrendsForRecurringIfNotILE(Ch_RecuLine, CH_RecuH."Customer No.");
                                until Ch_RecuLine.Next() = 0;
                            end;
                        until CH_RecuH.Next() = 0;
                    end;

                    CH_CustTrends.Reset();
                    CH_CustTrends.SetRange("Customer No.", Rec."Sell-to Customer No.");
                    if CH_CustTrends.FindSet() then
                        repeat
                            Clear(LineNo);
                            SalesLn.Reset();
                            SalesLn.SetRange("Document No.", Rec."No.");
                            SalesLn.SetRange("Document Type", Rec."Document Type");
                            if SalesLn.FindLast() then
                                LineNo := SalesLn."Line No." + 10000
                            else
                                LineNo := 10000;

                            SalesLn.Init();
                            SalesLn.Validate("Document Type", Rec."Document Type");
                            SalesLn.Validate("Document No.", Rec."No.");
                            SalesLn.Validate("Line No.", LineNo);
                            SalesLn.Validate(Type, SalesLn.Type::Item);
                            SalesLn.Validate("No.", CH_CustTrends."Item No.");
                            SalesLn.Validate("Unit of Measure Code", CH_CustTrends."Units of Measure");
                            SalesLn.Insert(true);
                        until CH_CustTrends.Next() = 0;

                    CurrPage.Update(true);
                end;

            }
        }

    }

    procedure GetCustomerTrendsLines()
    var
        CH_ILE: Record "Item Ledger Entry";
        CH_RecuH: Record "Standard Customer Sales Code";
        EventSub: Codeunit EventSub;
        Ch_RecuLine: Record "Standard Sales Line";
        CH_CustTrends: Record CustomerTrends;
        SalesLn: Record "Sales Line";
        LineNo: Integer;
    begin
        CH_CustTrends.DeleteAll();

        CH_RecuH.Reset();
        CH_RecuH.SetRange("Customer No.", Rec."Sell-to Customer No.");
        if CH_RecuH.FindSet() then begin
            repeat
                Ch_RecuLine.Reset();
                Ch_RecuLine.SetRange("Standard Sales Code", CH_RecuH.Code);
                Ch_RecuLine.SetRange(Type, Ch_RecuLine.Type::Item);
                if Ch_RecuLine.FindSet() then begin
                    repeat
                        EventSub.PopulateTrendsForRecurringIfNotILE(Ch_RecuLine, CH_RecuH."Customer No.");
                    until Ch_RecuLine.Next() = 0;
                end;
            until CH_RecuH.Next() = 0;
        end;

        CH_ILE.Reset();
        CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<-CW-8W>', Today), TODAY);
        CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
        CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
        CH_ILE.SetRange("Source No.", Rec."Sell-to Customer No.");
        if CH_ILE.FindSet() then begin
            repeat
                EventSub.InsertAndModifyTrends(CH_ILE);
            until CH_ILE.Next() = 0;
        end;


        CH_CustTrends.Reset();
        CH_CustTrends.SetRange("Customer No.", Rec."Sell-to Customer No.");
        if CH_CustTrends.FindSet() then
            repeat
                Clear(LineNo);
                SalesLn.Reset();
                SalesLn.SetRange("Document No.", Rec."No.");
                SalesLn.SetRange("Document Type", Rec."Document Type");
                if SalesLn.FindLast() then
                    LineNo := SalesLn."Line No." + 10000
                else
                    LineNo := 10000;

                SalesLn.Init();
                SalesLn.Validate("Document Type", Rec."Document Type");
                SalesLn.Validate("Document No.", Rec."No.");
                SalesLn.Validate("Line No.", LineNo);
                SalesLn.Validate(Type, SalesLn.Type::Item);
                SalesLn.Validate("No.", CH_CustTrends."Item No.");
                SalesLn.Validate("Unit of Measure Code", CH_CustTrends."Units of Measure");
                SalesLn.Insert(true);
            until CH_CustTrends.Next() = 0;

        //CurrPage.Update(true);
    end;
}