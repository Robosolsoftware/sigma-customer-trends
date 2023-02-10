pageextension 80125 CustCard extends "Customer Card"
{
    actions
    {
        // Add changes to page actions here
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
                    ChTrends.DeleteAll();
                    //RouRepo.AssignCustNo(Rec);
                    G_EventSub.CreateCustomertrends(SalesH, Rec."No.");
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