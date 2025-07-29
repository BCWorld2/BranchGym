pageextension 81710 JobJournal extends "Job Journal"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
        {

            field("Dimension Set ID"; Rec."Dimension Set ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Dimension Set ID field.', Comment = '%';
            }
        }
    }
}
