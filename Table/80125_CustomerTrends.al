table 80125 CustomerTrends
{
    DataClassification = CustomerContent;
    Caption = 'Customer Trends';
    DataPerCompany = true;


    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

        }
        field(2; "Item Description"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));

        }
        field(3; "Customer No."; Code[20])
        {
            Caption = 'Sell to Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(4; "Customer Name"; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
        }
        field(5; "Quantity purchased this Week"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Quantity purchased this Month"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(7; "Qty purchased Last Month"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity purchased Last Month';
        }
        // field(8; "Updated"; Boolean)
        // {
        //     DataClassification = CustomerContent;
        // }
        field(9; "Updated By"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Updated On"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(11; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(12; "Last Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Qty. to be added to SO"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(14; "New Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Units of Measure"; code[10])
        {
            DataClassification = CustomerContent;
        }
        field(16; "Last 1 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(17; "Last 2 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(18; "Last 3 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(19; "Last 4 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(20; "Last 5 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(21; "Last 6 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(22; "Last 7 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(23; "Last 8 Week Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(24; "Last 3 Months Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(25; "Last 6 Months Sales"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(26; "Free Stock Quanyity"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(27; "Stock at Other Locations"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(28; "Not Sold for Last 8 Weeks"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(29; "Salesperson Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
            Caption = 'SalesPerson/Purchaser Code';
        }
        field(30; "Special Promotion"; Boolean)
        {

        }
        field(31; "Created By"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(32; "Created On"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(33; "Qty on SO(Saleable)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Quantity" where("No." = field("Item No."), "Outstanding Quantity" = filter(> 0), "Saleable Location" = const(true), "Unit of Measure" = field("Units of Measure")));
            DecimalPlaces = 0 : 5;
            Caption = 'Qty on Sales Order (Saleable)';
            //GHST Customization++
        }

        field(34; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."), "Unit of Measure Code" = field("Units of Measure")));
            Caption = 'Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(36; "Min Sell Price"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(37; "Shipper Qty"; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(38; "Delivery Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(39; "Saleable Inventory"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."), "Saleable Location" = const(true)));
            Caption = 'Saleable Inventory';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Shipping Agent Code"; Text[30])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
        }
        field(41; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
        }
        field(42; "UnShipped Qty."; Decimal)
        {
            CalcFormula = Sum("Sales Line"."Outstanding Quantity" where(Type = const(Item), "No." = FIELD("Item No.")));
            Caption = 'Unshipped Qty';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PrimaryKey; "Item No.", "Customer No.", "Salesperson Code", "Special Promotion")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    procedure InsertSalesLinesfromTrends(OrderNo: Code[20]; CustTrends: Record CustomerTrends)
    var
        Rec_SalesL: Record "Sales Line";
    begin
        SalesL.Reset();
        SalesL.SetRange("Document Type", SalesL."Document Type"::Order);
        SalesL.SetRange("Document No.", OrderNo);
        if SalesL.FindLast() then;

        Rec_SalesL.Init();
        Rec_SalesL.Validate("Document Type", Rec_SalesL."Document Type"::Order);
        Rec_SalesL.Validate("Document No.", OrderNo);
        Rec_SalesL.Validate("Line No.", SalesL."Line No." + 10000);
        Rec_SalesL.Validate(Type, Rec_SalesL.Type::Item);
        Rec_SalesL.Validate("No.", CustTrends."Item No.");
        Rec_SalesL.Validate(Quantity, CustTrends."Qty. to be added to SO");
        if CustTrends."New Price" = 0 then
            Rec_SalesL.Validate("Unit Price", CustTrends."Unit Price")
        else
            Rec_SalesL.Validate("Unit Price", CustTrends."New Price");
        if Rec_SalesL."Shipment Date" < WorkDate() then
            Rec_SalesL.Validate("Shipment Date", WorkDate());

        Rec_SalesL.Insert(true);

    end;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    var
        SalesL: Record "Sales Line";
        salesH: Record "Sales Header";

        AddItemErrorTxt: TextConst ENU = 'You cannot add items to the order when the status is Released. Please repopen the order inorder to add items',
    ENG = 'You cannot add items to the order as the status is Released. Please repopen the order inorder to add items';
}