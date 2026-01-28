page 80129 "Customer Trend Card"
{
    PageType = Card;
    SourceTable = "Customer Trend Header";
    Editable = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Editable = G_EditFields;

                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        L_Customer: Record Customer;
                        L_Location: Record Location;
                        L_Date: Record Date;
                        L_SalesPriceHeader: Record "Price List Header";
                        L_PriceListLine: Record "Price List Line";
                        CTFunctions: Codeunit "CT Functions";
                        L_CustomerTrendLine: Record CustomerTrends;
                    begin
                        if Rec."Customer No." = '' then
                            exit;

                        //Edit Or NonEdit Condition for Line Page++
                        IsLinesEditable := Rec.LinesEditable;
                        CurrPage.Update();

                        if Rec."Customer No." <> xRec."Customer No." then begin
                            L_CustomerTrendLine.Reset();
                            L_CustomerTrendLine.SetRange("Entry Number", Rec."Entry Number");
                            if L_CustomerTrendLine.FindFirst() then
                                Error('You cannot modify the customer number if a customer trend line exists.');
                        end;

                        L_Customer.Reset();
                        L_Customer.SetRange("No.", Rec."Customer No.");
                        if L_Customer.FindFirst() then begin
                            //Check Master Approval++
                            L_Customer.TestField("QAU Approved");
                            L_Customer.TestField(Status, L_Customer.Status::Released);

                            Rec."Customer Name" := L_Customer.Name;
                            Rec."Shipping Agent Code" := L_Customer."Shipping Agent Code";
                            Rec."Shipping Agent Service Code" := L_Customer."Shipping Agent Service Code";
                            Rec."Weekend Shipping Agent Code" := L_Customer."Weekend Shipping Agent Code";
                            Rec."Weekend Ship. Agnt. Serv. Code" := L_Customer."Weekend Ship. Agnt. Serv. Code";
                            Rec."Min Order Value" := L_Customer."Min Order Value";
                            Rec."Order Date" := WorkDate();

                            //Update Shipmet date++
                            L_Date.Reset();
                            L_Date.SetRange(L_Date."Period Type", L_Date."Period Type"::Date);
                            L_Date.SetRange(L_Date."Period Start", Today);
                            if L_Date.FindFirst() then
                                if UpperCase(L_Date."Period Name") = UpperCase('FRIDAY') then begin
                                    if L_Customer."Weekend Ship. Agnt. Serv. Code" <> '' then
                                        //Update Saturday++
                                        Rec."Delivery Date" := CalcDate('<+1D>', Today)
                                    else
                                        //Update Monday
                                        Rec."Delivery Date" := CalcDate('<+3D>', Today);
                                end else
                                    Rec."Delivery Date" := CalcDate('<+1D>', Today);

                            //Get Default Location++
                            L_Location.Reset();
                            L_Location.SetRange("Customer Trend Default Loc", true);
                            if L_Location.FindFirst() then
                                Rec."Location Code" := L_Location.Code;

                            Rec.Modify();
                        end;

                        //Insert Promotion Items++
                        L_SalesPriceHeader.Reset();
                        L_SalesPriceHeader.SetRange("Special Price Daily", true);
                        if L_SalesPriceHeader.FindFirst() then begin
                            L_PriceListLine.Reset();
                            L_PriceListLine.SetRange("Price List Code", L_SalesPriceHeader.Code);
                            L_PriceListLine.SetRange("Asset Type", L_PriceListLine."Asset Type"::Item);
                            if L_PriceListLine.FindSet() then begin
                                repeat
                                    CTFunctions.FromCustomerNumberFIlte_InsertAndModifyTrendsForPromostion(L_PriceListLine, Rec);
                                until L_PriceListLine.Next() = 0;
                            end;
                        end;
                    end;

                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                    begin
                        L_CustomertrendLine.Reset();
                        L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomertrendLine.FindSet() then begin
                            L_CustomertrendLine.ModifyAll("Order Date", Rec."Order Date");
                        end;
                    end;
                }
                field("Delivery Date"; Rec."Delivery Date")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                    begin
                        //Update Shipmet date to existing lines++
                        L_CustomertrendLine.Reset();
                        L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomertrendLine.FindSet() then begin
                            L_CustomertrendLine.ModifyAll("Delivery Date", Rec."Delivery Date");
                        end;
                    end;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                        L_ShippingAgent: Record "Shipping Agent";
                    begin
                        //Check Master Validation++
                        L_ShippingAgent.Reset();
                        L_ShippingAgent.SetRange(Code, Rec."Shipping Agent Code");
                        if L_ShippingAgent.FindFirst() then begin
                            L_ShippingAgent.TestField(Status, L_ShippingAgent.Status::Released);
                        end;



                        //Update existing Line+++
                        if Rec."Shipping Agent Code" <> xRec."Shipping Agent Code" then begin
                            Rec."Shipping Agent Code" := Rec."Shipping Agent Code";
                            Rec."Shipping Agent Service Code" := '';
                        end;
                        L_CustomertrendLine.Reset();
                        L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomertrendLine.FindSet() then begin
                            L_CustomertrendLine.ModifyAll("Shipping Agent Code", Rec."Shipping Agent Code");
                            L_CustomertrendLine.ModifyAll("Shipping Agent Service Code", Rec."Shipping Agent Service Code");
                        end;
                    end;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                        L_ShippingAgentService: Record "Shipping Agent Services";
                    begin
                        //Check Master Validation++
                        L_ShippingAgentService.Reset();
                        L_ShippingAgentService.SetRange("Shipping Agent Code", Rec."Shipping Agent Code");
                        L_ShippingAgentService.SetRange(Code, Rec."Shipping Agent Service Code");
                        if L_ShippingAgentService.FindFirst() then begin
                            L_ShippingAgentService.TestField(Status, L_ShippingAgentService.Status::Released);
                        end;

                        //Update existing Line+++
                        if Rec."Shipping Agent Service Code" <> xRec."Shipping Agent Service Code" then begin
                            L_CustomertrendLine.Reset();
                            L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                            if L_CustomertrendLine.FindSet() then begin
                                L_CustomertrendLine.ModifyAll("Shipping Agent Service Code", Rec."Shipping Agent Service Code");
                            end;
                        end;
                    end;
                }
                field("Weekend Shipping Agent Code"; Rec."Weekend Shipping Agent Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                        L_ShippingAgent: Record "Shipping Agent";
                    begin
                        //Check Master Validation++
                        L_ShippingAgent.Reset();
                        L_ShippingAgent.SetRange(Code, Rec."Weekend Shipping Agent Code");
                        if L_ShippingAgent.FindFirst() then begin
                            L_ShippingAgent.TestField(Status, L_ShippingAgent.Status::Released);
                        end;

                        //Update existing Line+++
                        if Rec."Weekend Shipping Agent Code" <> xRec."Weekend Shipping Agent Code" then begin
                            Rec."Weekend Shipping Agent Code" := Rec."Weekend Shipping Agent Code";
                            Rec."Weekend Ship. Agnt. Serv. Code" := '';
                        end;
                        L_CustomertrendLine.Reset();
                        L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomertrendLine.FindSet() then begin
                            L_CustomertrendLine.ModifyAll("Weekend Shipping Agent Code", Rec."Weekend Shipping Agent Code");
                            L_CustomertrendLine.ModifyAll("Weekend Ship. Agnt. Serv. Code", Rec."Weekend Ship. Agnt. Serv. Code");
                        end;
                    end;
                }
                field("Weekend Ship. Agnt. Serv. Code"; Rec."Weekend Ship. Agnt. Serv. Code")
                {
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                        L_ShippingAgentService: Record "Shipping Agent Services";
                    begin
                        //Check Master Validation++
                        L_ShippingAgentService.Reset();
                        L_ShippingAgentService.SetRange("Shipping Agent Code", Rec."Weekend Shipping Agent Code");
                        L_ShippingAgentService.SetRange(Code, Rec."Weekend Ship. Agnt. Serv. Code");
                        if L_ShippingAgentService.FindFirst() then begin
                            L_ShippingAgentService.TestField(Status, L_ShippingAgentService.Status::Released);
                        end;


                        if Rec."Weekend Ship. Agnt. Serv. Code" <> xRec."Weekend Ship. Agnt. Serv. Code" then begin
                            L_CustomertrendLine.Reset();
                            L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                            if L_CustomertrendLine.FindSet() then begin
                                L_CustomertrendLine.ModifyAll("Weekend Ship. Agnt. Serv. Code", Rec."Weekend Ship. Agnt. Serv. Code");
                            end;
                        end;
                    end;
                }
                field("Min Order Value"; Rec."Min Order Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Work Description"; Rec."Work Description")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        L_CustomertrendLine: Record CustomerTrends;
                    begin
                        L_CustomertrendLine.Reset();
                        L_CustomertrendLine.SetRange("Entry Number", Rec."Entry Number");
                        if L_CustomertrendLine.FindSet() then begin
                            L_CustomertrendLine.ModifyAll("Work Description", Rec."Work Description");
                        end;
                    end;
                }
                field("Total Lines"; Rec."Total Lines")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Qty."; Rec."Total Qty.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }



            part("Special Promotions"; "Special Promotions")
            {
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(true), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No."), "Entry Number" = field("Entry Number");
                UpdatePropagation = Both;
                Editable = true;
            }

            part(Lines; "Customer Trends Subform")
            {
                Caption = 'Lines';
                ApplicationArea = All;
                SubPageLink = "Special Promotion" = const(false), "Salesperson Code" = field("Salesperson Code"), "Customer No." = field("Customer No."), "Entry Number" = field("Entry Number");
                UpdatePropagation = Both;
                Editable = IsLinesEditable;
                Enabled = IsLinesEditable;
            }
        }

        area(FactBoxes)
        {
            part("Customer Details"; "Customer Details")
            {
                SubPageLink = "No." = field("Customer No.");
                ApplicationArea = all;
                Editable = true;
            }
        }

    }
    actions
    {
        area(Processing)
        {

            //Moved this button to KNAPP extension becuase of KNAPP Code++
            // action("Register Sales Order")
            // {
            //     ApplicationArea = All;
            //     Image = Register;

            //     trigger OnAction()
            //     var
            //         CTFunctions: Codeunit "CT Functions";
            //         L_Customertrends: Record CustomerTrends;
            //     begin
            //         if not Confirm('Do you want to register?', false) then
            //             Error('');

            //         if SalesPersonCodeFilter = '' then
            //             Error('SalesPerson/Purchaser Code should not be blank');

            //         if CustomerAccountNoFilter = '' then
            //             Error('Customer Account No. should not be blank');

            //         //Update Latest Delivery Date, and Shipping details++
            //         L_Customertrends.Reset();
            //         L_Customertrends.SetRange("Salesperson Code", SalesPersonCodeFilter);
            //         L_Customertrends.SetRange("Customer No.", CustomerAccountNoFilter);
            //         if L_Customertrends.FindSet() then begin
            //             L_Customertrends.ModifyAll("Delivery Date", DeliveryDate);
            //             L_Customertrends.ModifyAll("Shipping Agent Code", ShippingAgentCodeFilter);
            //             L_Customertrends.ModifyAll("Shipping Agent Service Code", ShippingAgentServiceCodeFilter);
            //             L_Customertrends.ModifyAll("Weekend Ship. Agnt. Serv. Code", WeekendShippingAgentServiceCodeFilter);
            //             L_Customertrends.ModifyAll("Location Code", LocationCodeFilter);
            //         end;

            //         //Create and Update SO++
            //         CTFunctions.CreateAndUpdateSalesOrder(CustomerAccountNoFilter, SalesPersonCodeFilter);
            //     end;
            // }
            //Moved this button to KNAPP extension becuase of KNAPP Code++
            action(Comments)
            {
                ApplicationArea = All;
                Caption = 'Comments';
                Image = ViewComments;
                ToolTip = 'View or add comments for the record.';

                trigger OnAction()
                var
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    L_CommentLine: Record "Comment Line";
                    CommentSheet: Page "Comment Sheet";
                begin
                    Clear(CommentSheet);
                    L_CommentLine.Reset();
                    L_CommentLine.SetRange("No.", Rec."Customer No.");
                    if L_CommentLine.FindFirst() then begin
                        CommentSheet.SetTableView(L_CommentLine);
                        CommentSheet.Run();
                    end;

                end;
            }
            // action("Past Months Details")
            // {
            //     ApplicationArea = All;
            //     Image = Report;
            //     trigger OnAction();
            //     var
            //         CustomerTrendDetails: report "Customer Trend Details";
            //     begin
            //         if Rec."Salesperson Code" = '' then
            //             Error('SalesPerson/Purchaser Code should not be blank.');

            //         if Rec."Customer No." = '' then
            //             Error('Customer Account No. should not be blank.');

            //         if Rec."Delivery Date" = 0D then
            //             Error('Shipment Date should not be blank.');

            //         Clear(CustomerTrendDetails);
            //         CustomerTrendDetails.GetFilters(Rec."Salesperson Code", Rec."Customer No.", Rec."Delivery Date", Rec."Shipping Agent Code", Rec."Shipping Agent Service Code", Rec."Weekend Ship. Agnt. Serv. Code", Rec."Work Description", Rec."Weekend Shipping Agent Code");
            //         CustomerTrendDetails.Run();
            //     end;

            // }
        }
    }
    var
        IsLinesEditable: Boolean;
        G_EditFields: Boolean;
        G_IsFromCallLog: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        IsLinesEditable := Rec.LinesEditable;
    end;

    trigger OnOpenPage()
    begin
        IsLinesEditable := Rec.LinesEditable;
        if G_IsFromCallLog = true then
            G_EditFields := false
        else
            G_EditFields := true;



        //SBB-219++
        if Rec."Entry Number" <> '' then
            Rec.SetRecFilter();
        //SBB-219++
    end;


    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        L_CutomerTrendLine: Record CustomerTrends;
    begin
        L_CutomerTrendLine.Reset();
        L_CutomerTrendLine.SetRange("Salesperson Code", Rec."Salesperson Code");
        L_CutomerTrendLine.SetRange("Customer No.", Rec."Customer No.");
        L_CutomerTrendLine.SetRange("Entry Number", Rec."Entry Number");
        L_CutomerTrendLine.SetFilter("Qty. to be added to SO", '>%1', 0);
        if L_CutomerTrendLine.FindFirst() then
            if not Confirm('Sales Order has not been Registered. Are you sure you want to exit?', false) then
                Error('')
    end;

    procedure IsFromCallLog(_IsFromCallLog: Boolean)
    begin
        Clear(G_IsFromCallLog);
        G_IsFromCallLog := _IsFromCallLog;
    end;

}