pageextension 81701 PostDocsWithNoIncDoc extends "Posted Docs. With No Inc. Doc."
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

    trigger OnAfterGetRecord()
    var
        DDSingleInstance: Codeunit "D&DSingleInstance";
    begin
        DDSingleInstance.SetMessagePrinted(false);
    end;


    trigger OnAfterGetCurrRecord()
    var
        PostedDocsWithNoIncBuf: Record "Posted Docs. With No Inc. Buf.";
        recref: RecordRef;
        DragDropSetup: Record "Drag&Drop Setup";
        DDSingleInstance: Codeunit "D&DSingleInstance";
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;
        j: Integer;
    begin
        recref.Open(134);
        CurrPage.SetSelectionFilter(PostedDocsWithNoIncBuf);
        Clear(Dict);
        if J = 0 then
            DDSingleInstance.SetMessagePrinted(false);
        J += 1;
        if PostedDocsWithNoIncBuf.Count > 1 then begin
            CurrPage.DocAttachDragAndDrop.Page.ClearDictOfRecordIDs();
            repeat
                if PostedDocsWithNoIncBuf."Line No." <> 0 then begin
                    i += 1;
                    Dict.add(i, PostedDocsWithNoIncBuf.RecordId);
                end;
            until PostedDocsWithNoIncBuf.Next() = 0;
            CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
            CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
        end
        else begin

            CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
            CurrPage.DocAttachDragAndDrop.Page.DeleteRec();

        end;
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
