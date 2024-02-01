page 80128 "Special Promotions"
{
    ApplicationArea = All;
    Caption = 'Special Promotions';
    PageType = ListPart;
    SourceTable = CustomerTrends;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                // field("Customer No."; Rec."Customer No.")
                // {
                //     ToolTip = 'Specifies the value of the Customer No. field.';
                //     ApplicationArea = All;
                //     Editable = false;
                // }
                // field("Customer Name"; Rec."Customer Name")
                // {
                //     ToolTip = 'Specifies the value of the Customer Name field.';
                //     ApplicationArea = All;
                //     Editable = false;
                // }
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
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = all;
                }
                field("Last Price"; Rec."Last Price")
                {
                    ToolTip = 'Specifies the value of the Last Price field.';
                    ApplicationArea = All;
                }
                // field("New Price"; Rec."New Price")
                // {
                //     ToolTip = 'Specifies the value of the New Price field.';
                //     ApplicationArea = All;
                // }
                // field("Stock at Other Locations"; Rec."Stock at Other Locations")
                // {
                //     ToolTip = 'Specifies the value of the Stock at Other Locations field.';
                //     ApplicationArea = All;
                // }

                // field("Free Stock Quanyity"; Rec."Free Stock Quanyity")
                // {
                //     ToolTip = 'Specifies the value of the Free Stock Quanyity field.';
                //     ApplicationArea = All;
                // }
                field(Inventory; Rec.Inventory)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Saleable Inventory"; Rec."Saleable Inventory")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Qty on SO(Saleable)"; Rec."Qty on SO(Saleable)")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Total Available Quantity"; TotalAvailableQty(Rec))
                {
                    ApplicationArea = All;
                    Editable = false;
                    DecimalPlaces = 0 : 5;
                    ToolTip = 'Total Available Qty (Saleable Inventory – Qty on SO(Saleable)';
                    Caption = 'Total Available Quantity(Saleable)';
                }
                field("UnShipped Qty."; Rec."UnShipped Qty.")
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field("Shipper Qty"; Rec."Shipper Qty")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = All;
                }
            }
        }
    }


    local procedure TotalAvailableQty(_Rec: Record CustomerTrends): Decimal
    var
        ItemVariant: Record "Item Variant";
        _LocationCode: Code[20];
        L_ILE: Record "Item Ledger Entry";
        SaleableInventory: Decimal;
        L_SalesLine: Record "Sales Line";
        SaleableQtyOnSO: Decimal;
        item: Record Item;
    begin
        _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory");
        if _Rec."Saleable Inventory" > 0 then
            if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
                exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
            else
                exit(0)
        else
            exit(0);
    end;
}
