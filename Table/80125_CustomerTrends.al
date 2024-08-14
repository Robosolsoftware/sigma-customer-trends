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

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
                DisUnitPrice: Decimal;
                L_PriceListLine: Record "Price List Line";
                L_SalesPriceHeader: Record "Price List Header";
                L_CustomerPriceGroupChanges: Codeunit EventSub;
            begin
                //Min Sell price Validation application only for Normal Item.
                //The below code only for Top Screen Items (We can Add Promotion Items on Top Screen)++
                if CurrFieldNo = 11 then begin
                    if Rec."Special Promotion" = false then begin
                        L_SalesPriceHeader.Reset();
                        L_SalesPriceHeader.SetRange("Special Price Daily", true);
                        if L_SalesPriceHeader.FindFirst() then begin
                            //If not Promotion Item then checking Min Sell Price Validation++
                            L_PriceListLine.Reset();
                            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                            L_PriceListLine.SetRange("Product No.", Rec."Item No.");
                            if not L_PriceListLine.FindFirst() then begin
                                Clear(DisUnitPrice);
                                UserSetup.Reset();
                                UserSetup.SetRange("User ID", UserId);
                                UserSetup.SetRange("Allow to change unit price", true);
                                if not UserSetup.FindFirst() then begin

                                    if Rec."Min Sell Price" > 0 then begin
                                        if Rec."Unit Price" < Rec."Min Sell Price" then begin
                                            Error('Unit price %1 should not be less than Min Sell Price %2. Item No.: %3', Rec."Unit Price", Rec."Min Sell Price", Rec."Item No.");
                                        end;
                                    end else begin
                                        DisUnitPrice := (L_CustomerPriceGroupChanges.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO", Rec."Order Date") / 100) * 10;
                                        if (L_CustomerPriceGroupChanges.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO", Rec."Order Date") - DisUnitPrice) > Rec."Unit Price" then
                                            Error('Unit Price should not be less than 10 percent of current Unit Price. It should be greater than %1. Item No.: %2', L_CustomerPriceGroupChanges.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO", Rec."Order Date") - DisUnitPrice, Rec."Item No.");
                                    end;
                                end;
                            end;
                        end;

                        //If Promostion Item then checking Unit Price should not be less then Promostion Price++
                        L_PriceListLine.Reset();
                        L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                        L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                        L_PriceListLine.SetRange("Product No.", Rec."Item No.");
                        if L_PriceListLine.FindFirst() then begin
                            if L_PriceListLine."Unit Price" > Rec."Unit Price" then
                                Error('Unit Price %1 should not be less then special promotion price %2. For special item %3', Rec."Unit Price", L_PriceListLine."Unit Price", Rec."Item No.");
                        end;

                        IF (xRec."Unit Price" <> Rec."Unit Price") AND (Rec."Qty. to be added to SO" > 0) THEN BEGIN
                            CalculateVatAmount(Rec);
                        END;
                    end;
                end;
            end;
        }
        field(12; "Last Price"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(13; "Qty. to be added to SO"; Decimal)
        {
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;


            trigger OnValidate()
            var
                EventAndSubscriber: Codeunit EventSub;
                L_PriceListLine: Record "Price List Line";
                L_SalesPriceHeader: Record "Price List Header";
                L_CustomerTrend: Record CustomerTrends;
                CompanyLicenseValidation: Codeunit "Check Item License";
                CalledFrom: Option "Sales","Purchase";
                L_Customer: Record Customer;
                L_ShiptoAddress: Record "Ship-to Address";
                L_SalesEventAndFunction: Codeunit "Sales Event & Function";
            begin
                if (Rec."Qty. to be added to SO" <> 0) then begin
                    //Check duplicate Item on both screen of customer trends Top and Bottom++
                    if Rec."Special Promotion" = true then begin
                        L_CustomerTrend.Reset();
                        L_CustomerTrend.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrend.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrend.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrend.SetRange("Special Promotion", false);
                        L_CustomerTrend.SetFilter("Qty. to be added to SO", '>%1', 0);
                        if L_CustomerTrend.FindFirst() then
                            Error('Qty. to be added to SO should be blank on top screen. current value is %1.', L_CustomerTrend."Qty. to be added to SO");
                    end else begin
                        L_SalesPriceHeader.Reset();
                        L_SalesPriceHeader.SetRange("Special Price Daily", true);
                        if L_SalesPriceHeader.FindFirst() then begin
                            L_PriceListLine.Reset();
                            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                            L_PriceListLine.SetRange("Product No.", Rec."Item No.");
                            if L_PriceListLine.FindFirst() then begin
                                if L_PriceListLine."Minimum Quantity" < Rec."Qty. to be added to SO" then
                                    Error('Qty. to be added to SO %1 should be less than minimum quantity %2 for promotion item', Rec."Qty. to be added to SO", L_PriceListLine."Minimum Quantity");
                            end;
                        end;


                        L_CustomerTrend.Reset();
                        L_CustomerTrend.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrend.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrend.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrend.SetRange("Special Promotion", true);
                        L_CustomerTrend.SetFilter("Qty. to be added to SO", '>%1', 0);
                        if L_CustomerTrend.FindFirst() then
                            Error('Qty. to be added to SO should be blank on the Special Promotions screen. current value is %1.', L_CustomerTrend."Qty. to be added to SO");
                    end;

                    if Rec."Special Promotion" = true then begin
                        //Check Min Quantity (For Promotion Item)++
                        if Rec."Minimum Quantity" > Rec."Qty. to be added to SO" then
                            Error('Qty. to be added to SO should not be less than Minimum Quantity %1. Item Number: %2.', Rec."Minimum Quantity", Rec."Item No.");


                        //Check Shipping Restriction for existing Lines++
                        L_SalesEventAndFunction.CheckShippingAgentServiceRestriction(Rec."Item No.", Rec."Shipping Agent Code", Rec."Shipping Agent Service Code");


                        //Company License Validatio++
                        L_Customer.Reset();
                        L_Customer.SetRange("No.", Rec."Customer No.");
                        if L_Customer.FindFirst() then begin
                            if L_Customer."Ship-to Code" <> '' then begin
                                L_ShiptoAddress.Reset();
                                L_ShiptoAddress.SetRange(Code, Rec."Ship-to Code");
                                L_ShiptoAddress.SetRange("Customer No.", Rec."Customer No.");
                                if L_ShiptoAddress.FindFirst() then begin
                                    CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, Rec."Customer No.", L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", Rec."Order Date", Rec."Item No.", L_ShiptoAddress."Post Code");
                                end;
                            end else begin
                                CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, Rec."Customer No.", L_Customer."Customer Posting Group", L_Customer."Country/Region Code", Rec."Order Date", Rec."Item No.", L_Customer."Post Code");
                            end;
                        end;
                    end;

                    //Update Price++
                    if Rec."Special Promotion" = false then
                        Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO", Rec."Order Date"));

                    //Update Discount %
                    if Rec."Special Promotion" = false then
                        Rec.Validate("Line Disc %", EventAndSubscriber.CustomerTrend_GetLineDiscount(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO", Rec."Order Date"));

                    IF ("Qty. to be added to SO" > 0) THEN begin
                        CalculateVatAmount(Rec);
                    end;
                end;
            end;
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
        field(33; "Allocated on SO"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Quantity" where("No." = field("Item No."), "Document Type" = CONST(Order), Type = CONST(Item), "Outstanding Quantity" = filter(> 0), "Saleable Location" = const(true), "Unit of Measure" = field("Units of Measure"), "Shipment Date" = field("Date Filter")));
            DecimalPlaces = 0 : 5;
            Caption = 'Allocated on SO';
        }

        field(34; "Total Physical"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."), "Unit of Measure Code" = field("Units of Measure")));
            Caption = 'Total Physical';
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
            trigger OnValidate()
            begin
                IF ("Shipper Qty" > 0) THEN begin
                    CalculateVatAmount(Rec);
                end;
            end;
        }
        field(38; "Delivery Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(39; Physical; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."), "Unit of Measure Code" = field("Units of Measure"), "Saleable Location" = const(true), "Daily Priority Exist" = field("Variant Code mandatory")));
            Caption = 'Physical';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(40; "Shipping Agent Code"; Text[30])
        {
            Caption = 'Shipping Agent Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";

            trigger OnValidate()
            var
                ShippingAgent: Record "Shipping Agent";
            begin
                if Rec."Shipping Agent Code" <> '' then begin
                    ShippingAgent.Reset();
                    ShippingAgent.SetRange(code, Rec."Shipping Agent Code");
                    ShippingAgent.SetRange(Status, ShippingAgent.Status::Released);
                    if Not ShippingAgent.FindFirst() then
                        Error('Status must be equal to Released in Shipping Agent Services');
                end;
            end;
        }
        field(41; "Shipping Agent Service Code"; Code[10])
        {
            Caption = 'Shipping Agent Service Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));

            trigger OnValidate()
            var
                ShippingAgentServices: Record "Shipping Agent Services";
            begin
                if Rec."Shipping Agent Service Code" <> '' then begin
                    ShippingAgentServices.Reset();
                    ShippingAgentServices.SetRange(code, Rec."Shipping Agent Service Code");
                    ShippingAgentServices.SetRange(Status, ShippingAgentServices.Status::Released);
                    if Not ShippingAgentServices.FindFirst() then
                        Error('Status must be equal to Released in Shipping Agent Services');
                end;
            end;
        }
        // field(42; "Back Orders (Saleable)"; Decimal)
        // {
        //     // CalcFormula = Sum("Sales Line"."Outstanding Quantity" where(Type = const(Item), "No." = FIELD("Item No.")));
        //     Caption = 'Back Orders (Saleable)';
        //     DecimalPlaces = 0 : 5;
        //     Editable = false;
        //     //FieldClass = FlowField;
        // }

        field(43; "Weekend Ship. Agnt. Serv. Code"; Code[10])
        {
            Caption = 'Weekend Shipping Agent Service Code';
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Weekend Shipping Agent Code"));
            ValidateTableRelation = false;
        }
        // field(44; "Total Back Orders"; Decimal)
        // {

        // }
        field(45; "Location Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(46; "Minimum Quantity"; Decimal)
        {

        }
        field(47; "Order Date"; Date)
        {

        }
        field(48; "Ship-to Code"; Code[10])
        {
            TableRelation = "Ship-to Address";
        }
        field(49; "Item Category Code"; Code[20])
        {
            TableRelation = "Item Category";
        }
        field(50; "Customer Price Group"; Code[20])
        {
            TableRelation = "Customer Price Group";
        }
        field(51; "Line Disc %"; Decimal)
        {

        }
        field(52; "Total Allocated on SO"; Decimal)
        {
            AccessByPermission = TableData "Sales Shipment Header" = R;
            CalcFormula = Sum("Sales Line"."Outstanding Quantity" WHERE("Document Type" = CONST(Order), Type = CONST(Item), "No." = FIELD("Item No."), "Unit of Measure Code" = FIELD("Units of Measure"), "Outstanding Qty. (Base)" = filter(> 0), "Shipment Date" = field("Date Filter")));
            Caption = 'Total Allocated on SO';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        field(53; "Qty On Customer Trends"; Decimal)
        {
            CalcFormula = Sum(CustomerTrends."Qty. to be added to SO" where("Item No." = field("Item No."), "Units of Measure" = field("Units of Measure")));
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;

            //This is only For Update Free quantity after enter "Qty. to be added to SO".
        }
        field(54; "Work Description"; Text[2048])
        {

        }
        field(55; "Entry Number"; Integer)
        {
            //AutoIncrement = true;
        }
        field(56; "Special Item on Top SCreen"; Boolean)
        {
            //Dont use this field++
        }
        field(57; RRP; Decimal)
        {
            DecimalPlaces = 0 : 5;
        }
        field(58; "Min Order Value"; Decimal)
        {

        }
        field(59; "Variant Code mandatory"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("Item Variant" where("Item No." = field("Item No.")));
        }
        field(60; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
        }
        field(61; "Weekend Shipping Agent Code"; Text[30])
        {
            Caption = 'Weekend Shipping Agent Code';
            DataClassification = ToBeClassified;
            TableRelation = "Shipping Agent";
            Editable = false;

            trigger OnValidate()
            var
                ShippingAgent: Record "Shipping Agent";
            begin
                if Rec."Weekend Shipping Agent Code" <> '' then begin
                    ShippingAgent.Reset();
                    ShippingAgent.SetRange(code, Rec."Weekend Shipping Agent Code");
                    ShippingAgent.SetRange(Status, ShippingAgent.Status::Released);
                    if Not ShippingAgent.FindFirst() then
                        Error('Status must be equal to Released in Shipping Agent');
                end;
            end;
        }
        field(62; Amount; Decimal)
        {
            DataClassification = ToBeClassified;

        }

        field(64; "VAT amount"; Decimal)
        {
            DataClassification = ToBeClassified;

        }
        field(65; "VAT Prod. Posting Group"; Code[10])
        {
            TableRelation = "VAT Product Posting Group";
            DataClassification = ToBeClassified;

        }
        field(66; "VAT%"; Text[30])
        {
            DataClassification = ToBeClassified;

        }
        field(67; "Amount Including VAT"; Decimal)
        {
            Editable = false;
            DataClassification = ToBeClassified;

        }
        field(68; "Currency Code"; Code[10])
        {
            Editable = false;
            TableRelation = Currency;
            DataClassification = ToBeClassified;

        }
        field(69; "VAT Bus. Posting Group"; Code[20])
        {
            TableRelation = "VAT Business Posting Group";
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                VALIDATE("VAT Prod. Posting Group");
            end;

        }
        field(70; "Line Discount Amount"; Decimal)
        {

        }
    }

    keys
    {
        key(PrimaryKey; "Entry Number", "Item No.", "Customer No.", "Salesperson Code", "Special Promotion")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;
        res: Page "Sales Order";


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

    procedure CalculateVatAmount(VAR P_CustomerTrendLine: Record CustomerTrends)
    var

        L_Customer: Record Customer;
        L_Item: Record Item;
        UnitVatAmount: Decimal;
        L_VatProdPostingSetup: Record "VAT Posting Setup";
    begin


        IF L_Customer.GET(P_CustomerTrendLine."Customer No.") THEN;
        P_CustomerTrendLine."VAT Bus. Posting Group" := L_Customer."VAT Bus. Posting Group";


        if L_Item.Get(P_CustomerTrendLine."Item No.") then begin

            P_CustomerTrendLine."VAT Prod. Posting Group" := L_Item."VAT Prod. Posting Group";

        end;


        CLEAR(UnitVatAmount);
        L_VatProdPostingSetup.RESET;
        IF L_VatProdPostingSetup.GET(P_CustomerTrendLine."VAT Bus. Posting Group", P_CustomerTrendLine."VAT Prod. Posting Group") THEN BEGIN
            if L_VatProdPostingSetup."VAT Calculation Type" = L_VatProdPostingSetup."VAT Calculation Type"::"Reverse Charge VAT" then
                L_VatProdPostingSetup."VAT %" := 0;
            IF L_VatProdPostingSetup."VAT %" <> 0 THEN BEGIN
                P_CustomerTrendLine.Amount := (ROUND(((P_CustomerTrendLine."Unit Price" * P_CustomerTrendLine."Qty. to be added to SO") / ((L_VatProdPostingSetup."VAT %" / 100) + 1)), 0.01, '='));
                P_CustomerTrendLine."Amount Including VAT" := round((P_CustomerTrendLine."Unit Price" * P_CustomerTrendLine."Qty. to be added to SO"), 0.01, '=');
                P_CustomerTrendLine."VAT amount" := P_CustomerTrendLine."Amount Including VAT" - P_CustomerTrendLine.Amount;
                P_CustomerTrendLine."Line Discount Amount" := P_CustomerTrendLine.Amount * (P_CustomerTrendLine."Line Disc %" / 100);
            END ELSE BEGIN
                P_CustomerTrendLine.Amount := P_CustomerTrendLine."Unit Price" * P_CustomerTrendLine."Qty. to be added to SO";
                P_CustomerTrendLine."Amount Including VAT" := ((ROUND((P_CustomerTrendLine.Amount) * (1 + (L_VatProdPostingSetup."VAT %" / 100)), 0.01)));
                P_CustomerTrendLine."VAT amount" := P_CustomerTrendLine."Amount Including VAT" - P_CustomerTrendLine.Amount;
                P_CustomerTrendLine."Line Discount Amount" := P_CustomerTrendLine.Amount * (P_CustomerTrendLine."Line Disc %" / 100);
            END;

        END;
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
        Currency: Record Currency;

        AddItemErrorTxt: TextConst ENU = 'You cannot add items to the order when the status is Released. Please repopen the order inorder to add items',
    ENG = 'You cannot add items to the order as the status is Released. Please repopen the order inorder to add items';
}