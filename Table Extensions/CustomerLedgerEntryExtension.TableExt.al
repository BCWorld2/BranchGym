/// <summary>
/// TableExtension CustomerLedgerEntryExtension (ID 81701) extends Record Cust. Ledger Entry.
/// </summary>
tableextension 81701 CustomerLedgerEntryExtension extends "Cust. Ledger Entry"
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
