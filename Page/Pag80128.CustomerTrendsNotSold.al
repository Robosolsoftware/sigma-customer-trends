page 80128 CustomerTrendsNotSold
{
    ApplicationArea = All;
    Caption = 'Not Bought in Last 8 weeks';
    PageType = ListPart;
    SourceTable = CustomerTrends;

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
                }
                field("Item Description"; Rec."Item Description")
                {
                    ToolTip = 'Specifies the value of the Item Description field.';
                    ApplicationArea = All;
                }
                field("Last Price"; Rec."Last Price")
                {
                    ToolTip = 'Specifies the value of the Last Price field.';
                    ApplicationArea = All;
                }
                field("New Price"; Rec."New Price")
                {
                    ToolTip = 'Specifies the value of the New Price field.';
                    ApplicationArea = All;
                }
                field("Stock at Other Locations"; Rec."Stock at Other Locations")
                {
                    ToolTip = 'Specifies the value of the Stock at Other Locations field.';
                    ApplicationArea = All;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                    ApplicationArea = All;
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                    ApplicationArea = All;
                }
                field("Free Stock Quanyity"; Rec."Free Stock Quanyity")
                {
                    ToolTip = 'Specifies the value of the Free Stock Quanyity field.';
                    ApplicationArea = All;
                }
                field("Qty. to be added to SO"; Rec."Qty. to be added to SO")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetFilter(Rec."Not Sold for Last 8 Weeks", '%1', true);
    end;


    // procedure ResetFlag()
    // begin
    //     Flag := false;
    // end;

    // procedure GetSODetails(SH: Record "Sales Header")
    // begin
    //     Clear(OrderNo);
    //     OrderNo := sh."No.";
    //     LocationCode := SH."Location Code";
    //     if OrderNo <> '' then
    //         Flag := true
    //     else
    //         Flag := false;
    // end;

    // trigger OnQueryClosePage(CloseAction: Action): Boolean
    // var
    //     CustTrends: Record CustomerTrends;
    //     SalesAndRecSetup: Record "Sales & Receivables Setup";
    //     L_EventSub: Codeunit EventSub;
    //     L_SalesOrderNo: Code[100];
    //     L_SalesOrderCard: Page "Sales Order";
    //     L_SalesH: Record "Sales Header";
    // begin
    //     if Flag then begin
    //         CustTrends.Reset();
    //         CustTrends.SetCurrentKey("Qty. to be added to SO");
    //         CustTrends.SetFilter("Qty. to be added to SO", '<>%1', 0);
    //         if CustTrends.FindSet() then begin
    //             if CustTrends.CheckSOStatus(OrderNo) then begin
    //                 repeat
    //                     CustTrends.InsertSalesLinesfromTrends(OrderNo, CustTrends);
    //                 until CustTrends.Next() = 0;
    //                 Message('Items have been added to Sales order %1', OrderNo);
    //             end;
    //         end;
    //     end else begin
    //         CustTrends.Reset();
    //         CustTrends.SetCurrentKey("Qty. to be added to SO");
    //         CustTrends.SetFilter("Qty. to be added to SO", '<>%1', 0);
    //         if CustTrends.FindSet() then begin
    //             L_EventSub.CreateOrder(Rec."Customer No.", L_SalesOrderNo);
    //             repeat
    //                 CustTrends.InsertSalesLinesfromTrends(L_SalesOrderNo, CustTrends);
    //             until CustTrends.Next() = 0;
    //             //Message('Sales Order Created %1 .');
    //             If Confirm('Sales Order %1 Created, Do you want to open?', true, L_SalesOrderNo) then begin
    //                 Clear(L_SalesOrderCard);
    //                 L_SalesH.Reset();
    //                 L_SalesH.SetRange("Document Type", L_SalesH."Document Type"::Order);
    //                 L_SalesH.SetRange("No.", L_SalesOrderNo);
    //                 if L_SalesH.FindFirst() then begin
    //                     L_SalesOrderCard.SetTableView(L_SalesH);
    //                     L_SalesOrderCard.Run();
    //                 end;
    //             end Else
    //                 exit;
    //         end;
    //     end;
    // end;

    var
        OrderNo: Code[20];
        Flag: Boolean;
        [InDataSet]
        ColorCode: Text;
        EnableWeekWise: Boolean;
        EnableMonthWise: Boolean;
        LocationCode: code[20];
}
