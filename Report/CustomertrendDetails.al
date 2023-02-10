report 80126 "Customer Trend Details"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));
            trigger OnAfterGetRecord()
            begin
                G_CustomerTrends.Reset();
                If G_CustomerTrends.FindFirst() then;

                G_CustomerTrendsPage.GetCustomertrendDetails(G_Months, G_CustomerTrends);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(Months; G_Months)
                    {
                        ApplicationArea = All;
                        OptionCaption = ' ,3M,6M';

                    }
                }
            }
        }

        // actions
        // {
        //     area(processing)
        //     {
        //         action(ActionName)
        //         {
        //             ApplicationArea = All;

        //         }
        //     }
        // }
    }

    // rendering
    // {
    //     layout(LayoutName)
    //     {
    //         Type = RDLC;
    //         LayoutFile = 'mylayout.rdl';
    //     }
    // }

    var
        myInt: Integer;
        G_Months: Option " ","3M","6M";
        G_CustomerTrendsPage: Page "Customer Trends";
        G_CustomerTrends: Record CustomerTrends;
}