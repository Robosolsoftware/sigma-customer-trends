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

            trigger OnValidate()
            var
                CompanyLicenseValidation: Codeunit "Check Item License";
                CalledFrom: Option "Sales","Purchase";
                L_Customer: Record Customer;
                L_ShiptoAddress: Record "Ship-to Address";
            begin
                // //Company License Validatio++
                // L_Customer.Reset();
                // L_Customer.SetRange("No.", CustomerAccountNoFilter);
                // if L_Customer.FindFirst() then begin
                //     if L_Customer."Ship-to Code" <> '' then begin
                //         L_ShiptoAddress.Reset();
                //         L_ShiptoAddress.SetRange(Code, L_Customer."Ship-to Code");
                //         L_ShiptoAddress.SetRange("Customer No.", CustomerAccountNoFilter);
                //         if L_ShiptoAddress.FindFirst() then begin
                //             CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_ShiptoAddress."Country/Region Code", DeliveryDate, Rec."Item No.", L_ShiptoAddress."Post Code");
                //         end;
                //     end else begin
                //         CompanyLicenseValidation.ValidateLicense(CalledFrom::Sales, CustomerAccountNoFilter, L_Customer."Customer Posting Group", L_Customer."Country/Region Code", DeliveryDate, Rec."Item No.", L_Customer."Post Code");
                //     end;
                // end;
            end;

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

            trigger OnValidate()
            var
                UserSetup: Record "User Setup";
                DisUnitPrice: Decimal;
            begin
                //Check Min Sell Price Validation. only for Normal Items. (Top Screen)++
                if Rec."Special Promotion" = false then begin
                    Clear(DisUnitPrice);
                    UserSetup.Reset();
                    UserSetup.SetRange("User ID", UserId);
                    UserSetup.SetRange("Allow to change unit price", true);
                    if not UserSetup.FindFirst() then begin
                        if Rec."Min Sell Price" > 0 then begin
                            if Rec."Unit Price" < Rec."Min Sell Price" then begin
                                Error('Unit price %1 should not be less than Min Sell Price %2. Item No.: %3, Special Promotion: %4.', Rec."Unit Price", Rec."Min Sell Price", Rec."Item No.", Rec."Special Promotion");
                            end;
                        end else begin
                            DisUnitPrice := (xRec."Unit Price" / 100) * 10;
                            if (xRec."Unit Price" - DisUnitPrice) > Rec."Unit Price" then
                                Error('You cannot enter the Unit Price less than 10 percent of current Unit Price. It should be greater than %1. Item No.: %2, Special Promotion: %3.', xRec."Unit Price" - DisUnitPrice, Rec."Item No.", Rec."Special Promotion");
                        end;
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
                CustomerTrendSalesQuota: Codeunit "Customer Trend Sales Quota";
                RecUserSetup: Record "User Setup";
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
                        L_CustomerTrend.Reset();
                        L_CustomerTrend.SetRange("Salesperson Code", Rec."Salesperson Code");
                        L_CustomerTrend.SetRange("Customer No.", Rec."Customer No.");
                        L_CustomerTrend.SetRange("Item No.", Rec."Item No.");
                        L_CustomerTrend.SetRange("Special Promotion", true);
                        L_CustomerTrend.SetFilter("Qty. to be added to SO", '>%1', 0);
                        if L_CustomerTrend.FindFirst() then
                            Error('Qty. to be added to SO should be blank on the Special Promotions screen. current value is %1.', L_CustomerTrend."Qty. to be added to SO");
                    end;

                    //Check Min Quantity (For Promotion Item)++
                    if Rec."Special Promotion" = true then begin
                        if Rec."Minimum Quantity" > Rec."Qty. to be added to SO" then
                            Error('Qty. to be added to SO should not be less than Minimum Quantity %1. Item Number: %2.', Rec."Minimum Quantity", Rec."Item No.");
                    end;



                    if Rec."Special Promotion" = false then begin
                        //user can still add the Special Promotion item on Top section with less than min qty and it should allow (in this case price should be more).
                        L_SalesPriceHeader.Reset();
                        L_SalesPriceHeader.SetRange("Special Price Daily", true);
                        if L_SalesPriceHeader.FindFirst() then begin
                            L_PriceListLine.Reset();
                            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                            L_PriceListLine.SetRange("Product No.", Rec."Item No.");
                            if not L_PriceListLine.FindFirst() then begin
                                Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO"));
                            end;
                        end;
                    end else begin
                        //For Promotion Item only (Promotion Tab)++
                        //Rec.Validate("Unit Price", EventAndSubscriber.CustomerTrend_GetUnitPrice(Rec."Customer No.", Rec."Item No.", Rec."Qty. to be added to SO"));
                    end;

                    //Check Item Sales Quota (For Both Promotion and Normal Item)++
                    IF RecUserSetup.GET(USERID) THEN BEGIN
                        IF NOT RecUserSetup."SO Override MaxQty Calculation" THEN BEGIN
                            CustomerTrendSalesQuota.CheckExceededQty(Rec);
                        END;
                    END ELSE BEGIN
                        CustomerTrendSalesQuota.CheckExceededQty(Rec);
                    END;
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
        field(33; "Qty on SO(Saleable)"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("Sales Line"."Outstanding Quantity" where("No." = field("Item No."),
            Type = CONST(Item),
            "Outstanding Quantity" = filter(> 0),
            "Saleable Location" = const(true),
            "Unit of Measure" = field("Units of Measure")));
            DecimalPlaces = 0 : 5;
            //Caption = 'Qty on Sales Order (Saleable)';
            Caption = 'Allocated on SO';
        }

        field(34; Inventory; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
            "Unit of Measure Code" = field("Units of Measure")));
            //Caption = 'Inventory';
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
        }
        field(38; "Delivery Date"; Date)
        {
            Caption = 'Shipment Date';
        }
        field(39; "Saleable Inventory"; Decimal)
        {
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("Item No."),
            "Saleable Location" = const(true)));
            //Caption = 'Saleable Inventory';
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
            TableRelation = "Shipping Agent Services".Code where("Shipping Agent Code" = field("Shipping Agent Code"));
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