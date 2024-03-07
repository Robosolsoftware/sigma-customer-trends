tableextension 80125 "CT Location" extends Location
{
    fields
    {
        // Add changes to table fields here
        field(80125; "Customer Trend Default Loc"; Boolean)
        {
            Caption = 'Customer Trend Default Location';

            trigger OnValidate()
            var
                L_Location: Record Location;
            begin
                if Rec."Customer Trend Default Loc" = true then begin
                    L_Location.Reset();
                    L_Location.SetFilter(Code, '<>%1', Rec.Code);
                    L_Location.SetRange("Customer Trend Default Loc", true);
                    if not L_Location.IsEmpty then
                        Error('Customer Trend Default location should not be more than one');
                end;
            end;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}