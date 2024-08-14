page 80129 "Customer Trend Card"
{
    PageType = Card;
    SourceTable = CustomerTrendHeader;
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Weekend Shipping Agent Code"; Rec."Weekend Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Weekend Ship. Agnt. Serv. Code"; Rec."Weekend Ship. Agnt. Serv. Code")
                {
                    ApplicationArea = All;
                }
                field("Min Order Value"; Rec."Min Order Value")
                {
                    ApplicationArea = All;
                }
                field("Work Description"; Rec."Work Description")
                {
                    ApplicationArea = All;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                }
            }



            part("Special Promotions"; "Special Promotions")
            {
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(true), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No."), "Entry Number" = field("Entry Number");
                UpdatePropagation = Both;
                Editable = true;
            }

            part(Lines; "Customer Trends Subform")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(false), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No."), "Entry Number" = field("Entry Number");
                UpdatePropagation = Both;
                Editable = true;
            }
        }

    }

}