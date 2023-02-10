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
        }
        field(14; "New Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Units of Measure"; code[10])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PrimaryKey; "Item No.", "Customer No.")
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

    procedure CheckSOStatus(OrderNo: Code[20]): Boolean
    begin
        salesH.Reset();
        salesH.SetRange("Document Type", SalesL."Document Type"::Order);
        salesH.SetRange("No.", OrderNo);
        salesH.SetRange(Status, salesH.Status::Open);
        if salesH.FindLast() then
            exit(true)
        else begin
            Message(AddItemErrorTxt);
            exit(false);
        end;
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