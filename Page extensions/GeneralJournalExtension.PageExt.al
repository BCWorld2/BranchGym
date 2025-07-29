/// <summary>
/// PageExtension GeneralJournalExtension (ID 81702) extends Record General Journal.
/// </summary>
pageextension 81702 GeneralJournalExtension extends "General Journal"
{
    layout
    {
        addbefore(JournalErrorsFactBox)
        {

            part(DocAttachDragAndDrop; "IncDocAttachDragAndDropArea")
            {
                ApplicationArea = All;
                ShowFilter = false;
                Visible = CurrPageVisible;
            }

        }

        // >> FG-11
        modify(Amount)
        {
            ApplicationArea = All;
            Visible = CurrPageVisible;
            trigger OnAfterValidate()
            var
                GenJnlLine: Record "Gen. Journal Line";
                recref: RecordRef;
                i: Integer;
                j: Integer;
            begin
                if Rec.Insert() then
                    commit
                else
                    commit;
                recref.Open(81);
                CurrPage.SetSelectionFilter(GenJnlLine);
                Clear(Dict);
                if J = 0 then
                    J += 1;
                if GenJnlLine.Count >= 1 then begin
                    CurrPage.DocAttachDragAndDrop.Page.ClearDictOfRecordIDs();
                    repeat
                        if (GenJnlLine."Journal Template Name" <> '') and (GenJnlLine."Journal Batch Name" <> '') and (GenJnlLine."Line No." > 0) then begin
                            i += 1;
                            Dict.add(i, GenJnlLine.RecordId);
                        end;
                    until GenJnlLine.Next() = 0;
                    CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
                    CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
                    CurrPage.DocAttachDragAndDrop.Page.Update();
                end;
            end;
        }

        // << FG-11
    }



    trigger OnAfterGetCurrRecord()
    var
        recref: RecordRef;
        GenJnlLine: Record "Gen. Journal Line";
        DragDropSetup: Record "Drag&Drop Setup";
        DDSingleInstance: Codeunit "D&DSingleInstance";

        i: Integer;
        j: Integer;
    begin
        recref.Open(21);
        CurrPage.DocAttachDragAndDrop.Page.SetCurrentRecordID(Rec.RecordId, recref, Dict);
        CurrPage.DocAttachDragAndDrop.Page.DeleteRec();
    end;

    // >> FG-11
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Dict.Add(Dict.Count + 1, Rec.RecordId);
    end;
    // << FG-11

    trigger OnOpenPage()
    var
        DragDropSetup: Record "Drag&Drop Setup";
    begin
        DragDropSetup.get();
        CurrPageVisible:=DragDropSetup.Sales;
    end;

    var
        CurrPageVisible: Boolean;

        // >> FG-11
        Dict: Dictionary of [Integer, RecordId];
    // << FG-11
}
