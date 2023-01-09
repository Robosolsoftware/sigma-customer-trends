pageextension 80128 SalesOr_CustTr extends "Sales Order"
{

    actions
    {
        // Add changes to page actions here
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