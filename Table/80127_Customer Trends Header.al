table 80127 "Customer Trend Header"
{
    DataClassification = CustomerContent;
    Caption = 'Customer Trend Header';
    DataPerCompany = true;


    fields
    {
        field(50000; "Entry Number"; Code[20])
        {

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
        field(50014; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
            TableRelation = Location;
        }
        field(50015; "CallLog Date"; Date)
        {
            Editable = false;
        }
        field(50016; "CallLog Time"; Time)
        {
            Editable = false;
        }
        field(50017; "Total Qty."; Decimal)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = sum(CustomerTrends."Qty. to be added to SO" where("Entry Number" = field("Entry Number")));
        }
        field(50018; "Total Lines"; Integer)
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count(CustomerTrends where("Entry Number" = field("Entry Number")));
        }
    }
    keys
    {
        key(PK; "Entry Number", "Salesperson Code", "Customer No.")
        {
            Clustered = true;
        }
    }

    procedure LinesEditable() IsEditable: Boolean;
    begin
        IsEditable := Rec."Customer No." <> '';
    end;

    trigger OnDelete()
    var
        L_CustomerTrendLine: Record CustomerTrends;

    begin
        L_CustomerTrendLine.Reset();
        L_CustomerTrendLine.SetRange("Entry Number", Rec."Entry Number");
        L_CustomerTrendLine.DeleteAll();
    end;

    trigger OnInsert()
    var
        L_SalesAndRecSetup: Record "Sales & Receivables Setup";
        NoSeriesManagement: Codeunit "No. Series";
        L_UserSetup: Record "User Setup";
    begin
        if Rec."Entry Number" = '' then begin
            L_SalesAndRecSetup.Get();

            L_SalesAndRecSetup.TestField("Customer Trend Nos.");

            Rec."Entry Number" := NoSeriesManagement.GetNextNo(L_SalesAndRecSetup."Customer Trend Nos.", TODAY, TRUE);

            L_UserSetup.Reset();
            L_UserSetup.SetRange("User ID", UserId);
            if L_UserSetup.FindFirst() then begin
                L_UserSetup.TestField("Salespers./Purch. Code");
                Rec."Salesperson Code" := L_UserSetup."Salespers./Purch. Code";
            end else
                Error('Salespers./Purch. Code should not be blank. Please check with Admin');
        end;
    end;
}

