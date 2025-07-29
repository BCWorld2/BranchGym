pageextension 81709 VendorLedgerEntriesExtension extends "Vendor Ledger Entries"
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
        DragDropSetup: Record "Drag&Drop Setup";
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;
    begin
        recref.Open(25);
        CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
        CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
    end;

    trigger OnOpenPage()
    var
        DragDropSetup: Record "Drag&Drop Setup";
    begin
        DragDropSetup.get();
        CurrPageVisible := DragDropSetup.Purchases;
    end;

    var
        CurrPageVisible: Boolean;
}
