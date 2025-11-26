permissionset 80125 Customertrends
{
    Assignable = true;
    Permissions = tabledata CustomerTrends = RIMD,
        tabledata "General Setup - Customer Trend" = RIMD,
        table CustomerTrends = X,
        table "General Setup - Customer Trend" = X,
        report "Customer Trend Details" = X,
        report Populate_CustomerTrends = X,
        codeunit "CT Functions" = X,
        codeunit EventSub = X,
        page "General Setup - Customer Trend" = X,
        page "Special Promotions" = X,
        tabledata "Customer Trend Header" = RIMD,
        table "Customer Trend Header" = X,
        page "Customer Trend Card" = X,
        page "Customer Trends List" = X,
        page "Customer Trends Subform" = X,
        page "Customer Details" = X;
}