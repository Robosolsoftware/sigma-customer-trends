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
                //Insert and Modify the Customer Trends
                CT_Functions.GetCustomertrendDetails(G_Months, G_SalesPersonCode, G_CustomerAccount, G_DeliveryDate, G_ShippingAgentCode, G_ShiipingAgentServiceCode, G_WeekendShiipingAgentServiceCode);

                //Insert and Modify the Customer Trends (Promotions Item)
                CT_Functions.GetCustomertrendDetailsForPromostion(G_SalesPersonCode, G_CustomerAccount, G_DeliveryDate, G_ShippingAgentCode, G_ShiipingAgentServiceCode, G_WeekendShiipingAgentServiceCode);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    field(Months; G_Months)
                    {
                        Caption = 'Date Formula Filter';
                        ApplicationArea = All;
                        OptionCaption = ' ,1W, 2W, 1M, 3M, 6M';
                    }
                }
            }
        }

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        begin
            if CloseAction = CloseAction::OK then
                if G_Months = G_Months::" " then
                    Error('Select Date Formula');
        end;
    }

    var
        G_Months: Option " ","1W","2W","1M","3M","6M";
        CT_Functions: Codeunit "CT Functions";
        G_SalesPersonCode: Code[20];
        G_CustomerAccount: Code[20];
        G_DeliveryDate: Date;
        G_ShippingAgentCode: Code[20];
        G_ShiipingAgentServiceCode: Code[20];
        G_WeekendShiipingAgentServiceCode: Code[20];

    procedure GetFilters(_SalesPersonCode: Code[20]; _CustomerAccount: Code[20]; _DeliveryDate: Date; _ShippingAgentCode: Code[20]; _ShippingAgentServiceCode: Code[20]; _WeekendShippingAgentServiceCode: Code[20])
    begin
        Clear(G_CustomerAccount);
        Clear(G_SalesPersonCode);
        Clear(G_DeliveryDate);
        Clear(G_ShippingAgentCode);
        Clear(G_ShiipingAgentServiceCode);
        Clear(G_WeekendShiipingAgentServiceCode);
        G_CustomerAccount := _CustomerAccount;
        G_SalesPersonCode := _SalesPersonCode;
        G_DeliveryDate := _DeliveryDate;
        G_ShippingAgentCode := _ShippingAgentCode;
        G_ShiipingAgentServiceCode := _ShippingAgentServiceCode;
        G_WeekendShiipingAgentServiceCode := _WeekendShippingAgentServiceCode;

    end;
}