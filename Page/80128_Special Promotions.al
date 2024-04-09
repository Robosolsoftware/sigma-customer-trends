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
                field(Inventory; Rec.Inventory)
                {
                    Editable = false;
                    ApplicationArea = All;
                    Caption = 'Total Physical';
                    ToolTip = 'Total Inventory';
                }
                field(Allocated; Rec.Allocated)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Sum of Outstanding Qty on SO across ALL Locations';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Total Allocated on SO';
                }
                field("Physical"; Rec."Saleable Inventory")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Qty available';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Physical';
                }
                field("Allocated on SO"; Rec."Qty on SO(Saleable)")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Sum of Outstanding SO Qty.';
                    DecimalPlaces = 0 : 5;
                    Caption = 'Allocated on SO';
                }

                //Moved this code on Ochannel Extension for calculation++
                // field("Free (Saleable)"; TotalAvailableQtyForSaleable(Rec))
                // {
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Total Available Qty (Saleable Inventory – Qty on SO(Saleable)';
                //     //Caption = 'Total Available Quantity(Saleable)';
                //     Caption = 'Free (Saleable)';
                // }
                //Moved this code on Ochannel Extension for calculation++
                // field("Back Orders (Saleable)"; Rec."Back Orders (Saleable)")
                // {
                //     Caption = 'Back Orders (Saleable)';
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Unshipped Qty in HD and SH';

                //     trigger OnAssistEdit()
                //     var
                //         L_SalesLine: Record "Sales Line";
                //         Page_SalesLinePage: Page "Sales Lines";
                //     begin
                //         Clear(Page_SalesLinePage);
                //         L_SalesLine.Reset();
                //         L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                //         L_SalesLine.SetRange("No.", Rec."Item No.");
                //         L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
                //         L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                //         L_SalesLine.SetRange("Saleable Location", true);
                //         L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
                //         Page_SalesLinePage.SetTableView(L_SalesLine);
                //         Page_SalesLinePage.Run();
                //     end;
                // }
                // field("Total Back Orders"; Rec."Total Back Orders")
                // {
                //     Caption = 'Back Orders (Saleable)';
                //     ApplicationArea = All;
                //     Editable = false;
                //     DecimalPlaces = 0 : 5;
                //     ToolTip = 'Unshipped Qty across ALL Locations';
                //     trigger OnAssistEdit()
                //     var
                //         L_SalesLine: Record "Sales Line";
                //         Page_SalesLinePage: Page "Sales Lines";
                //     begin
                //         Clear(Page_SalesLinePage);
                //         L_SalesLine.Reset();
                //         L_SalesLine.SetRange("Document Type", L_SalesLine."Document Type"::Order);
                //         L_SalesLine.SetRange(Type, L_SalesLine.Type::Item);
                //         L_SalesLine.SetRange("No.", Rec."Item No.");
                //         L_SalesLine.SetRange("Unit of Measure Code", Rec."Units of Measure");
                //         L_SalesLine.SetFilter("Outstanding Quantity", '>%1', 0);
                //         //L_SalesLine.SetRange("Saleable Location", true);
                //         L_SalesLine.SetFilter("Shipment Date", '<%1', Today);
                //         Page_SalesLinePage.SetTableView(L_SalesLine);
                //         Page_SalesLinePage.Run();
                //     end;
                // }
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


    // local procedure TotalAvailableQtyForSaleable(_Rec: Record CustomerTrends): Decimal
    // var
    //     ItemVariant: Record "Item Variant";
    //     _LocationCode: Code[20];
    //     L_ILE: Record "Item Ledger Entry";
    //     SaleableInventory: Decimal;
    //     L_SalesLine: Record "Sales Line";
    //     SaleableQtyOnSO: Decimal;
    //     item: Record Item;
    // begin
    //     _Rec.CalcFields("Qty on SO(Saleable)", "Saleable Inventory");
    //     if _Rec."Saleable Inventory" > 0 then
    //         if (_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)") > 0 then
    //             exit(_Rec."Saleable Inventory" - _Rec."Qty on SO(Saleable)")
    //         else
    //             exit(0)
    //     else
    //         exit(0);
    // end;
}
