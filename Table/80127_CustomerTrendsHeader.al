table 80127 CustomerTrendHeader
{
    DataClassification = CustomerContent;
    Caption = 'Customer Trend Header';
    DataPerCompany = true;


    fields
    {
        field(50000; "Entry Number"; Integer)
        {
            AutoIncrement = true;
        }
        field(50001; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
            Caption = 'SalesPerson/Purchaser Code';
        }
        field(50002; "Customer No."; Code[20])
        {
            Caption = 'Sell to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(50003; "Customer Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
        }
        field(50004; "Order Date"; Date)
        {

        }
        field(50005; "Delivery Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(50006; "Shipping Agent Code"; Text[30])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
        }
        field(50007; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(50008; "Weekend Shipping Agent Code"; Text[30])
        {
            Caption = 'Weekend Shipping Agent Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
            Editable = false;
        }
        field(50009; "Weekend Ship. Agnt. Serv. Code"; Code[10])
        {
            Caption = 'Weekend Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Weekend Shipping Agent Code"));
            ValidateTableRelation = false;
        }
        field(50010; "Min Order Value"; Decimal)
        {

        }
        field(50011; "Work Description"; Text[2048])
        {

        }
        field(50012; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(50013; "Total Amount"; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(CustomerTrends."Amount Including VAT" where("Entry Number" = field("Entry Number")));
        }
    }
    keys
    {
        key(PK; "Entry Number")
        {
            Clustered = true;
        }
    }
}

