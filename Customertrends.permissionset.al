permissionset 80125 Customertrends
{
    Assignable = true;
    Permissions = tabledata CustomerTrends=RIMD,
        tabledata "General Setup - Customer Trend"=RIMD,
        table CustomerTrends=X,
        table "General Setup - Customer Trend"=X,
        report "Customer Trend Details"=X,
        report Populate_CustomerTrends=X,
        codeunit "CT Functions"=X,
        codeunit "Customer Trend Sales Quota"=X,
        codeunit EventSub=X,
        page "Customer Trends"=X,
        page "General Setup - Customer Trend"=X,
        page "Special Promotions"=X,
        query "Daywise Cust Trends quantity"=X;
}