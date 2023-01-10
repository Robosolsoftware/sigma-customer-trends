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

                }
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = all;

                }

            }
        }

    }


    actions
    {
        area(Processing)
        {
            action("Past 3 Months")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    CH_CustTrends: Record CustomerTrends;
                    CH_ILE: Record "Item Ledger Entry";
                    Routine: Report Populate_CustomerTrends;
                    SHRec: Record "Sales Header";
                begin
                    SHRec.Reset();
                    if SHRec.get(SHRec."Document Type"::Order, OrderNo) then;

                    CH_ILE.Reset();
                    CH_ILE.SetFilter("Posting Date", '%1..%2', CALCDATE('<CM-4M+1D>', Today), CalcDate('CM', CalcDate('CM-2M', Today)));
                    CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
                    CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
                    CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
                    if CH_ILE.FindSet() then begin
                        repeat
                            Routine.InsertAndModifyTrends(CH_ILE);
                        until CH_ILE.Next() = 0;
                    end;
                end;

            }
            action("Past 6 Months")
            {
                ApplicationArea = All;

                trigger OnAction();
                var
                    CH_CustTrends: Record CustomerTrends;
                    CH_ILE: Record "Item Ledger Entry";
                    Routine: Report Populate_CustomerTrends;
                    SHRec: Record "Sales Header";
                begin
                    SHRec.Reset();
                    if SHRec.get(SHRec."Document Type"::Order, OrderNo) then;
                    CH_ILE.Reset();
                    CH_ILE.SetFilter("Posting Date", '%1..%2', CalcDate('<-CM-6M>', Today()), CalcDate('CM', CalcDate('CM-2M', Today)));
                    CH_ILE.SetRange("Entry Type", CH_ILE."Entry Type"::Sale);
                    CH_ILE.SetRange("Document Type", CH_ILE."Document Type"::"Sales Shipment");
                    CH_ILE.SetRange("Source No.", SHRec."Sell-to Customer No.");
                    if CH_ILE.FindSet() then begin
                        repeat
                            Routine.InsertAndModifyTrends(CH_ILE);
                        until CH_ILE.Next() = 0;
                    end;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        CH_ILE: Record "Item Ledger Entry";
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
    end;

    procedure ResetFlag()
    begin
        Flag := false;
    end;

    procedure GetSODetails(SH: Record "Sales Header")
    begin
        Clear(OrderNo);
        OrderNo := sh."No.";
        Flag := true;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CustTrends: Record CustomerTrends;
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

        end;
    end;


    var
        OrderNo: Code[20];
        Flag: Boolean;
        [InDataSet]
        ColorCode: Text;

}