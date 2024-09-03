pageextension 80125 "CT Location Card" extends "Location Card"
{
    layout
    {
        // Add changes to page layout here
        addlast(General)
        {
            field("Customer Trend Default Loc"; Rec."Customer Trend Default Loc")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}