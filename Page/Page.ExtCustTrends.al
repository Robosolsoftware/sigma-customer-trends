pageextension 80127 CallRoutine extends "Customer List"
{

    actions
    {
        // Customer list , card sales order lista nd card extensions..scroll down
        addafter("Item References")
        {
            action("Customer Trends")
            {
                ApplicationArea = All;
                Image = CustomerLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


                trigger OnAction()
                begin
                    if not Confirm('Do you wish to view Customer %1 previous orders?', true, Rec."No.") then
                        exit
                    else begin
                        //CurrPage.SetSelectionFilter(Rec);
                        ChTrends.DeleteAll();
                        //RouRepo.AssignCustNo(Rec);
                        G_EventSub.CreateCustomertrends(SalesH, Rec."No.");
                        //Report.Run(50120, false, false, Rec);
                    end;

                end;

            }
        }
    }
    var
        RouRepo: Report Populate_CustomerTrends;
        ChTrends: Record CustomerTrends;
        G_EventSub: Codeunit EventSub;
        SalesH: Record "Sales Header";


}









