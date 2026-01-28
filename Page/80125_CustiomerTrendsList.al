page 80125 "Customer Trends List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Customer Trend Header";
    CaptionML = ENU = 'Customer Trends List',
                ENG = 'Customer Trends List';
    CardPageID = "Customer Trend Card";
    DeleteAllowed = true;
    Editable = true;
    RefreshOnActivate = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    layout
    {
        area(Content)
        {

            repeater(Group)
            {
                field("Entry Number"; Rec."Entry Number")
                {
                    ApplicationArea = All;
                    Caption = 'No.';
                }
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
                    Caption = 'Sell-to Customer Name';
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    Caption = 'Order Date';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    Caption = 'Shipment Date';
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Code';

                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shipping Agent Service Code';
                }

                field("Weekend Shipping Agent Code"; Rec."Weekend Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Caption = 'Weekend Shipping Agent Code';

                }
                field("Weekend Ship. Agnt. Serv. Code"; Rec."Weekend Ship. Agnt. Serv. Code")
                {
                    ApplicationArea = All;
                    //Editable = EditDeliveryDate;
                    Caption = 'Weekend Shipping Agent Service Code';

                }
                field("Min Order Value"; Rec."Min Order Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Min Order Value';
                }

            }
        }

    }

    actions
    {

    }

    trigger OnOpenPage()
    var
        L_UserSetup: Record "User Setup";
    begin
        //For Inventory Calculation++
        Rec.SetFilter("Date Filter", '>=%1', WorkDate());

        //Open List Page for Selected SalesPerson Code++
        L_UserSetup.Reset();
        L_UserSetup.SetRange("User ID", UserId);
        if L_UserSetup.FindFirst() then begin
            L_UserSetup.TestField("Salespers./Purch. Code");
            Rec.SetRange("Salesperson Code", L_UserSetup."Salespers./Purch. Code");
            //Rec.SetRange(SystemCreatedBy, GetUserName(UserId));
        end else
            Error('Salespers./Purch. Code should not be blank. Please check with Admin');

    end;

    procedure GetUserName(UserSecurityId: Code[50]): Text[100]
    var
        Users: Record User;
        tes: page "Warehouse Receipt";
    begin
        Users.Reset();
        Users.SetRange("User Name", UserSecurityId);
        if Users.FindFirst() then
            exit(Users."User Security ID");
    end;


}