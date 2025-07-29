pageextension 81704 GeneralLedgerEntriesExtension extends "General Ledger Entries"
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

    // TODO: Remember to remove this trigger before production deployment!!!!
    // JCH
    actions
    {
        addfirst(IncomingDocument)
        {
            /*
            action(DeleteAll)
            {
                ApplicationArea = All;
                Caption = 'Delete All Incoming Documents for all tables';
                ToolTip = 'Deletes all - take care!!!';
                Image = Download;

                trigger OnAction()
                var
                    IncomingDocumentAttachment: Record "Incoming Document Attachment"; // T133
                    IncomingDocument: Record "Incoming Document";  // T130
                begin
                    IncomingDocument.DeleteAll();
                    IncomingDocumentAttachment.DeleteAll();
                end;

            }
            */
        }
    }


    trigger OnAfterGetCurrRecord()
    var
        recref: RecordRef;
        DragDropSetup: Record "Drag&Drop Setup";
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;
    begin
        recref.Open(17);
        CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
        CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
    end;

    trigger OnOpenPage()
    var
        DragDropSetup: Record "Drag&Drop Setup";
    begin
        DragDropSetup.get();
        CurrPageVisible := DragDropSetup.Finance;
    end;

    var
        CurrPageVisible: Boolean;
}
