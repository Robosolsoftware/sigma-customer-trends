page 80128 "Special Promotions"
{
    ApplicationArea = All;
    Caption = 'Daily Promotions';
    PageType = ListPart;
    SourceTable = CustomerTrends;
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;



    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Min Sell Price"; Rec."Min Sell Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Line Disc %"; Rec."Line Disc %")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Last Price"; Rec."Last Price")
                {
                    ToolTip = 'Specifies the value of the Last Price field.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field(RRP; Rec.RRP)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Total Physical"; Rec."Total Physical")
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Total Physical';
                    ToolTip = 'Total Inventory';
                }
                field("Total Allocated on SO"; Rec."Total Allocated on SO")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Sum of Outstanding Qty on SO across ALL Locations';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Total Allocated on SO';
                }
                field(Physical; Rec.Physical)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Qty available';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Physical';
                }
                field("Allocated on SO"; Rec."Allocated on SO")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Sum of Outstanding SO Qty.';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Allocated on SO';
                }
                field("Shipper Qty"; Rec."Shipper Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the minimum quantity of the product.';
                }
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = All;
                    Editable = Rec."Item No." <> '';

                    trigger OnValidate()
                    var
                        RecUserSetup: Record "User Setup";
                        CustomerTrendSalesQuota: Codeunit "Customer Trend Sales Quota";
                    begin
                        //Check Item Sales Quota (For Both Promotion and Normal Item)++
                        CurrPage.Update();
                        IF RecUserSetup.GET(USERID) THEN BEGIN
                            IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                                CustomerTrendSalesQuota.CheckExceededQty(Rec);
                            END;
                        END ELSE BEGIN
                            CustomerTrendSalesQuota.CheckExceededQty(Rec);
                        END;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetFilter("Date Filter", '>=%1', WorkDate());
    end;
}
