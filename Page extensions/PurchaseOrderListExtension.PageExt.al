pageextension 81700 PurchaseOrderExtension extends "Purchase Order List"
{
    layout
    {
        addfirst(factboxes)
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
        DragDropSetup: Record "Drag&Drop Setup";
        PurchaseHeader: Record "Purchase Header";
        DDSingleInstance: Codeunit "D&DSingleInstance";
        RecordCount: Integer;
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

            CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(PurchaseHeader.RecordId, recref, Dict);
            CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
        end
        else begin

            CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
            CurrPage.DocAttachDragAndDrop.Page.DeleteRec();

        end;
    end;
    /*
        trigger OnAfterGetRecord()
        var
            recref: RecordRef;
            DragDropSetup: Record "Drag&Drop Setup";
            PurchaseHeader: Record "Purchase Header";
            RecordCount: Integer;
        begin
            CurrPage.SetSelectionFilter(PurchaseHeader);
            RecordCount := PurchaseHeader.Count;
            RecordCount := RecordCount;
        end;
    */

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
