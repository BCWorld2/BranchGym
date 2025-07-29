pageextension 81703 CustomerLedgerEntriesExtension extends "Customer Ledger Entries"
{
    layout
    {
        addbefore(IncomingDocAttachFactBox)
        {

            part(DocAttachDragAndDrop; "IncDocAttachDragAndDropArea")
            {
                ApplicationArea = All;
                ShowFilter = false;
                Visible = CurrPageVisible;
            }

        }
    }

    trigger OnAfterGetCurrRecord()
    var
        recref: RecordRef;
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;

    begin
        recref.Open(21);
        CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
        CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
    end;

    trigger OnOpenPage()
    var
        DragDropSetup: Record "Drag&Drop Setup";
    begin
        DragDropSetup.get();
        CurrPageVisible := DragDropSetup.Sales;
    end;

    var
        CurrPageVisible: Boolean;

}
