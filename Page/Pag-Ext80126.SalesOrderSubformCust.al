pageextension 80126 "Sales Order Subform Cust" extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field(Last1WeekSales; Last1WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 1 Week Sales';
            }
            field(Last2WeekSales; Last2WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 2 Week Sales';
            }
            field(Last3WeekSales; Last3WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 3 Week Sales';
            }
            field(Last4WeekSales; Last4WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 4 Week Sales';
            }
            field(Last5WeekSales; Last5WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 5 Week Sales';
            }
            field(Last6WeekSales; Last6WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 6 Week Sales';
            }
            field(Last7WeekSales; Last7WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 7 Week Sales';
            }
            field(Last8WeekSales; Last8WeekSales)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Last 8 Week Sales';
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        Last1WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-2W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last2WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-3W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last3WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-4W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last4WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-5W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last5WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-6W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last6WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-7W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last7WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-8W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
        Last8WeekSales := G_Routine.Calculate8WeeksSales(CALCDATE('<CW-9W+1D>'), CALCDATE('<CW-1W>'), '', Rec."No.", Rec."Sell-to Customer No.");
    end;

    var
        Last1WeekSales: Decimal;
        Last2WeekSales: Decimal;
        Last3WeekSales: Decimal;
        Last4WeekSales: Decimal;
        Last5WeekSales: Decimal;
        Last6WeekSales: Decimal;
        Last7WeekSales: Decimal;
        Last8WeekSales: Decimal;
        G_Routine: Report Populate_CustomerTrends;

}
