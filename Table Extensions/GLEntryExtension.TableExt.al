/// <summary>
/// TableExtension GLEntryExtension (ID 81700) extends Record G/L Entry.
/// </summary>
tableextension 81700 GLEntryExtension extends "G/L Entry"
{
    fields
    {
        field(81700; "Incoming Document Entry No."; Integer)
        {
            ObsoleteReason = 'Not Used';
            ObsoleteState = Pending;
            ObsoleteTag = 'Dont use';

            Caption = 'Incoming Document Entry No.';
            DataClassification = ToBeClassified;
        }
    }
}
