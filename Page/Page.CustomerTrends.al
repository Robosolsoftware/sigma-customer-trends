page 80126 "Customer Trends"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CustomerTrends;


    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;

                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;
                    TableRelation = Item;
                    trigger OnValidate()
                    var
                        myInt: Integer;
                    begin
                        FreeStockQty(); //ShubhamM03112022_US_9208
                        StockOtherlocation//ShubhamM04112022_US_9228
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
                }
                field("Quantity purchased this Week"; Rec."Quantity purchased this Week")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;

                }
                field("Quantity purchased this Month"; Rec."Quantity purchased this Month")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;

                }

                field("Qty purchased Last Month"; Rec."Qty purchased Last Month")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = ColorCode;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = ColorCode;
                }

                field("Last Unit Price"; Rec."Last Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                    StyleExpr = ColorCode;
                }
                field("New Price"; Rec."New Price")
                {
                    ApplicationArea = all;
                    StyleExpr = ColorCode;
                }
                field("Free Stock Quanyity"; Rec."Free Stock Quanyity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;
                }
                field("Stock at Other Locations"; Rec."Stock at Other Locations")
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = ColorCode;
                }
                field("Last 1 Week Sales"; Rec."Last 1 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 2 Week Sales"; Rec."Last 2 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 3 Week Sales"; Rec."Last 3 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 4 Week Sales"; Rec."Last 4 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 5 Week Sales"; Rec."Last 5 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 6 Week Sales"; Rec."Last 6 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 7 Week Sales"; Rec."Last 7 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 8 Week Sales"; Rec."Last 8 Week Sales")
                {
                    ApplicationArea = All;
                    Visible = EnableWeekWise;
                    StyleExpr = ColorCode;
                }
                field("Last 3 Months Sales"; Rec."Last 3 Months Sales")
                {
                    ApplicationArea = all;
                    Visible = EnableMonthWise;
                    StyleExpr = ColorCode;
                }
                field("Last 6 Months Sales"; Rec."Last 6 Months Sales")
                {
                    ApplicationArea = all;
                    Visible = EnableMonthWise;
                    StyleExpr = ColorCode;
                }

                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = all;
                    StyleExpr = ColorCode;
                }
            }
        }
        area(factboxes)
        {
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
            // action("Customer Trend Details")
            action("Past Months Details")
            {
                ApplicationArea = All;
                RunObject = report "Customer Trend Details";
                Image = Report;

                trigger OnAction();
                var
                // CH_CustTrends: Record CustomerTrends;
                // CH_ILE: Record "Item Ledger Entry";
                // Routine: Report Populate_CustomerTrends;
                // SHRec: Record "Sales Header";
                begin
                    // SHRec.Reset();
                    // if SHRec.get(SHRec."Document Type"::Order, OrderNo) then;

                    // CH_ILE.Reset();
                    // CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), CalcDate('CM', CalcDate('CM-2M', Today)));
                    // CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
                    // CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
                    // CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
                    // if CH_ILE.FindSet() then begin
                    //     repeat
                    //         Routine.InsertAndModifyTrends(CH_ILE);
                    //     until CH_ILE.Next() = 0;
                    // end;
                end;

            }
            // action("Past 6 Months")
            // {
            //     ApplicationArea = All;

            //     trigger OnAction();
            //     var
            //         CH_CustTrends: Record CustomerTrends;
            //         CH_ILE: Record "Item Ledger Entry";
            //         Routine: Report Populate_CustomerTrends;
            //         SHRec: Record "Sales Header";
            //     begin
            //         SHRec.Reset();
            //         if SHRec.get(SHRec."Document Type"::Order, OrderNo) then;
            //         CH_ILE.Reset();
            //         CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), CalcDate('CM', CalcDate('CM-2M', Today)));
            //         CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            //         CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            //         CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
            //         if CH_ILE.FindSet() then begin
            //             repeat
            //                 Routine.InsertAndModifyTrends(CH_ILE);
            //             until CH_ILE.Next() = 0;
            //         end;
            //     end;
            // }
        }
    }

    trigger OnAfterGetRecord()
    var
        CH_ILE: Record "Item Ledger Entry";
        GenSetupCustTrend: Record "General Setup - Customer Trend";
    begin
        Clear(ColorCode);
        CH_ILE.Reset();
        CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
        CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
        CH_ILE.SetRange("Source No.", Rec."Customer No.");
        CH_ILE.SetRange("Item No.", Rec."Item No.");
        CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-2M+1D>', Today()), Today); //8 weeks
        if CH_ILE.FindLast() then
            ColorCode := 'Favorable'
        else begin

            CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), CalcDate('CM', CalcDate('CM-2M', Today)));
            if CH_ILE.FindLast() then
                ColorCode := 'StrongAccent' //3 Months
            else begin
                CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), CalcDate('<CM-4M>', Today));
                if CH_ILE.FindLast() then
                    ColorCode := 'Attention'//6 Months
                else
                    ColorCode := 'Ambiguous';
                // end;

            end;

        end;

        EnableMonthWise := false;
        EnableWeekWise := false;
        GenSetupCustTrend.Get();
        if GenSetupCustTrend."Enable Week Wise" = true then
            EnableWeekWise := true;
        if GenSetupCustTrend."Enable Month Wise" = true then
            EnableMonthWise := true;

    end;

    procedure GetCustomertrendDetails(L_Months: Option " ","3M","6M"; CH_CustTrends: Record CustomerTrends)
    var
        CH_ILE: Record "Item Ledger Entry";
        Routine: Report Populate_CustomerTrends;
        SHRec: Record "Sales Header";
    begin

        if L_Months = L_Months::"3M" then begin
            CH_ILE.Reset();
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), CalcDate('CM', CalcDate('CM-2M', Today)));
            CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            //CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
            CH_ILE.SetRange("Source No.", CH_CustTrends."Customer No.");
            if CH_ILE.FindSet() then begin
                repeat
                    Routine.InsertAndModifyTrends(CH_ILE);
                until CH_ILE.Next() = 0;
            end;
        end;

        if L_Months = L_Months::"6M" then begin
            CH_ILE.Reset();
            //CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), CalcDate('CM', CalcDate('CM-2M', Today)));
            CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), Today);
            CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
            CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
            //CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
            CH_ILE.SetRange("Source No.", CH_CustTrends."Customer No.");
            if CH_ILE.FindSet() then begin
                repeat
                    Routine.InsertAndModifyTrends(CH_ILE);
                until CH_ILE.Next() = 0;
            end;
        end;
    end;

    procedure ResetFlag()
    begin
        Flag := false;
    end;

    procedure GetSODetails(SH: Record "Sales Header")
    begin
        Clear(OrderNo);
        OrderNo := sh."No.";
        LocationCode := SH."Location Code";
        if OrderNo <> '' then
            Flag := true
        else
            Flag := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustTrends: Record CustomerTrends;
        SalesAndRecSetup: Record "Sales & Receivables Setup";
        L_EventSub: Codeunit EventSub;
        L_SalesOrderNo: Code[100];
        L_SalesOrderCard: Page "Sales Order";
        L_SalesH: Record "Sales Header";
    begin
        if Flag then begin
            CustTrends.Reset();
            CustTrends.SetCurrentKey("Qty. to be added to SO");
            CustTrends.SetFilter("Qty. to be added to SO", '<>%1', 0);
            if CustTrends.FindSet() then begin
                if CustTrends.CheckSOStatus(OrderNo) then begin
                    repeat
                        CustTrends.InsertSalesLinesfromTrends(OrderNo, CustTrends);
                    until CustTrends.Next() = 0;
                    Message('Items have been added to Sales order %1', OrderNo);
                end;
            end;
        end else begin
            CustTrends.Reset();
            CustTrends.SetCurrentKey("Qty. to be added to SO");
            CustTrends.SetFilter("Qty. to be added to SO", '<>%1', 0);
            if CustTrends.FindSet() then begin
                L_EventSub.CreateOrder(Rec."Customer No.", L_SalesOrderNo);
                repeat
                    CustTrends.InsertSalesLinesfromTrends(L_SalesOrderNo, CustTrends);
                until CustTrends.Next() = 0;
                //Message('Sales Order Created %1 .');
                If Confirm('Sales Order %1 Created, Do you want to open?', true, L_SalesOrderNo) then begin
                    Clear(L_SalesOrderCard);
                    L_SalesH.Reset();
                    L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
                    L_SalesH.SetRange("No.", L_SalesOrderNo);
                    if L_SalesH.FindFirst() then begin
                        L_SalesOrderCard.SetTableView(L_SalesH);
                        L_SalesOrderCard.Run();
                    end;
                end Else
                    exit;
            end;
        end;
    end;

    procedure StockOtherlocation()
    var
        L_Item: Record Item;
        IUOM: Record "Item Unit of Measure";
        QtyPerUnitOfMeasure: Decimal;
    begin
        Clear(QtyPerUnitOfMeasure);
        L_Item.Reset();
        L_Item.SetRange("No.", Rec."Item No.");
        L_Item.SetFilter("Location Filter", '<>%1', LocationCode);
        if L_Item.FindFirst() then begin
            IUOM.Reset();
            IUOM.SetFilter("Item No.", Rec."Item No.");
            IUOM.SetFilter(Code, Rec."Units of Measure");
            if IUOM.FindFirst() then begin
                QtyPerUnitOfMeasure := IUOM."Qty. per Unit of Measure";
            end;

            L_Item.CalcFields(Inventory, "Qty. on Sales Order");
            Rec."Stock at Other Locations" := (L_Item.Inventory - L_Item."Qty. on Sales Order") / QtyPerUnitOfMeasure;
        end;
    end;

    procedure FreeStockQty()
    var
        L_Item: Record Item;
        IUOM: Record "Item Unit of Measure";
        QtyPerUnitOfMeasure: Decimal;
    begin
        Clear(QtyPerUnitOfMeasure);
        L_Item.Reset();
        L_Item.SetRange("No.", Rec."Item No.");
        L_Item.SetFilter("Location Filter", '%1', LocationCode);
        if L_Item.FindFirst() then begin
            IUOM.Reset();
            IUOM.SetFilter("Item No.", Rec."Item No.");
            IUOM.SetFilter(Code, Rec."Units of Measure");
            if IUOM.FindFirst() then begin
                QtyPerUnitOfMeasure := IUOM."Qty. per Unit of Measure";
            end;

            L_Item.CalcFields(Inventory, "Qty. on Sales Order");
            Rec."Free Stock Quanyity" := (L_Item.Inventory - L_Item."Qty. on Sales Order") / QtyPerUnitOfMeasure;
        end;
    end;


    var
        OrderNo: Code[20];
        Flag: Boolean;
        [InDataSet]
        ColorCode: Text;
        EnableWeekWise: Boolean;
        EnableMonthWise: Boolean;
        LocationCode: code[20];

}