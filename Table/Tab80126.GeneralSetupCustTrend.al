table 80126 "General Setup - Customer Trend"
{
    Caption = 'General Setup - Customer Trend';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(2; "Enable Month Wise"; Boolean)
        {
            Caption = 'Enable Month Wise';
            DataClassification = ToBeClassified;
        }
        field(3; "Enable Week Wise"; Boolean)
        {
            Caption = 'Enable Week Wise';
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
