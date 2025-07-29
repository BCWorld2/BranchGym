pageextension 81706 PurchaseInvoicesExtension extends "Purchase Invoices"
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
        PurchaseHeader: Record "Purchase Header";
        DragDropSetup: Record "Drag&Drop Setup";
        DDSingleInstance: Codeunit "D&DSingleInstance";
        Dict: Dictionary of [Integer, RecordId];
        i: Integer;
        j: Integer;
    begin
        recref.Open(38);
        CurrPage.SetSelectionFilter(PurchaseHeader);
        Clear(Dict);
        if J = 0 then
            DDSingleInstance.SetMessagePrinted(false);
        J += 1;
        if PurchaseHeader.Count > 1 then begin
            CurrPage.DocAttachDragAndDrop.Page.ClearDictOfRecordIDs();
            repeat
                if PurchaseHeader."No." <> '' then begin
                    i += 1;
                    Dict.add(i, PurchaseHeader.RecordId);
                end;
            until PurchaseHeader.Next() = 0;
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
        CurrPageVisible := DragDropSetup.Purchases;
    end;

    var
        CurrPageVisible: Boolean;
}
