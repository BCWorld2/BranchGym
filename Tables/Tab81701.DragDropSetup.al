table 81701 "Drag&Drop Setup"
{
    Caption = 'Drag&Drop Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';

        }
        field(2; Finance; Boolean)
        {
            Caption = 'Finance';

        }
        field(3; Purchases; Boolean)
        {
            Caption = 'Purchase';

        }
        field(4; Sales; Boolean)
        {
            Caption = 'Sales';

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
