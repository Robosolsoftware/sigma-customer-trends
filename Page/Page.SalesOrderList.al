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
                begin
                    ChTrends.DeleteAll();
                    RouRepo.AssignCustNofromSO(Rec);

                end;

            }
        }

    }
}