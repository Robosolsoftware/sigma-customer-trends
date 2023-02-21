page 80127 "General Setup - Customer Trend"
{
    ApplicationArea = All;
    Caption = 'General Setup - Customer Trend';
    PageType = Card;
    SourceTable = "General Setup - Customer Trend";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Enable Month Wise"; Rec."Enable Month Wise")
                {
                    ToolTip = 'Show Month Wise columns.';

                    /*trigger OnValidate()
                    begin
                        Message('%1....%2', CALCDATE('<-CM-3M>'), CALCDATE('<-CM-2M-1D>'));
                    end;*/
                }
                field("Enable Week Wise"; Rec."Enable Week Wise")
                {
                    ToolTip = 'Show Week Wise columns.';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
        Rec.RESET;
        IF NOT Rec.GET THEN BEGIN
            Rec.INIT;
            Rec.INSERT;
        END;
    end;
}
