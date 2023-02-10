pageextension 80129 SOList extends "Sales Order List"
{

    actions
    {
        addlast(Processing)
        {
            action("Customer Trends")
            {
                ApplicationArea = All;
                Image = CustomerLedger;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;


                trigger OnAction()
                var
                    RouRepo: Report Populate_CustomerTrends;
                    ChTrends: Record CustomerTrends;
                    L_EventSub: Codeunit EventSub;
                begin
                    ChTrends.DeleteAll();
                    //RouRepo.AssignCustNofromSO(Rec);
                    L_EventSub.CreateCustomertrends(Rec, Rec."Sell-to Customer No.");

                end;

            }
        }

    }
}