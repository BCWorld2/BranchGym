pageextension 81707 SalesCreditMemosExtension extends "Sales Credit memos"
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
        recref: RecordRef;
        SalesHeader: Record "Sales Header";
        DDSingleInstance: Codeunit "D&DSingleInstance";
        DragDropSetup: Record "Drag&Drop Setup";
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;
        j: Integer;
    begin
        recref.Open(36);
        CurrPage.SetSelectionFilter(SalesHeader);
        Clear(Dict);
        if J = 0 then
            DDSingleInstance.SetMessagePrinted(false);
        J += 1;
        if SalesHeader.Count > 1 then begin
            CurrPage.DocAttachDragAndDrop.Page.ClearDictOfRecordIDs();
            repeat
                if SalesHeader."No." <> '' then begin
                    i += 1;
                    Dict.add(i, SalesHeader.RecordId);
                end;
            until SalesHeader.Next() = 0;

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
