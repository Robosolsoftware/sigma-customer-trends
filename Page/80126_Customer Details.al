page 80126 "Customer Details"
{
    PageType = CardPart;
    SourceTable = Customer;

    layout
    {
        area(Content)
        {
            field(Hospital; Rec.Hospital)
            {
                ApplicationArea = All;
                Caption = 'Exempt from Credit check';
                StyleExpr = L_StylExpressionFforExemptCreditLimit;
            }
            field("Exempt from Overdue check"; Rec."Exempt from Overdue check")
            {
                ApplicationArea = All;
                StyleExpr = L_StylExpressionFforExemptOverDue;
            }
            field("Credit limit Exceeded"; Rec."Credit limit Exceeded")
            {
                ApplicationArea = All;
                StyleExpr = L_StylExpressionFforCreditLimit;
            }
            field("Overdue Balance"; Rec."Overdue Balance")
            {
                ApplicationArea = All;
                StyleExpr = L_StylExpressionFforOverDue;
            }
        }
    }



    var
        L_StylExpressionFforCreditLimit: Text;
        L_StylExpressionFforExemptCreditLimit: Text;


        L_StylExpressionFforOverDue: Text;
        L_StylExpressionFforExemptOverDue: Text;


    trigger OnAfterGetRecord()
    begin
        //Credit Limit+++
        Clear(L_StylExpressionFforCreditLimit);
        if Rec."Credit limit Exceeded" = true then begin
            if Rec.Hospital = true then begin
                L_StylExpressionFforCreditLimit := 'Favorable';
            end else
                L_StylExpressionFforCreditLimit := 'Unfavorable';
        end else
            L_StylExpressionFforCreditLimit := 'None';


        Clear(L_StylExpressionFforExemptCreditLimit);
        if Rec.Hospital = true then
            L_StylExpressionFforExemptCreditLimit := 'Favorable'
        else
            L_StylExpressionFforExemptCreditLimit := 'None';




        //OverDue++++
        Clear(L_StylExpressionFforOverDue);
        if Rec."Overdue Balance" = true then begin
            if Rec."Exempt from Overdue check" = true then begin
                L_StylExpressionFforOverDue := 'Favorable';
            end else
                L_StylExpressionFforOverDue := 'Unfavorable';
        end else
            L_StylExpressionFforOverDue := 'None';


        Clear(L_StylExpressionFforExemptOverDue);
        if Rec."Exempt from Overdue check" = true then
            L_StylExpressionFforExemptOverDue := 'Favorable'
        else
            L_StylExpressionFforExemptOverDue := 'None';
    end;
}
