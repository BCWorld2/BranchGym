/// <summary>
/// Page IncDocAttachDragAndDropArea (ID 81701).
/// </summary>
page 81701 IncDocAttachDragAndDropArea
{
    ApplicationArea = All;
    Caption = 'Drag And Drop a Document';
    PageType = ListPart;
    UsageCategory = None;
    InsertAllowed = false;
    ModifyAllowed = false;
    RefreshOnActivate = true;
    //SourceTable = "Incoming Document Attachment";
    SourceTable = "Inc. Doc. Attachment Overview";
    SourceTableTemporary = true;
    Permissions = tabledata 17 = RIMD,
    tabledata 21 = RIMD,
    tabledata 25 = RIMD;
    ;

    layout
    {
        area(content)
        {
            usercontrol(FileDragAndDrop; "FDD File Drag and Drop")
            {
                ApplicationArea = All;

                trigger ControlAddinReady()
                begin
                    CurrPage.FileDragAndDrop.InitializeFileDragAndDrop();
                end;

                trigger OnFileUpload(FileName: Text; FileAsText: Text; IsLastFile: Boolean; FilesCount: Integer)
                var
                    PurchaseHeader: Record "Purchase Header";
                    PurchaseHeader2: Record "Purchase Header";
                    Base64Convert: Codeunit "Base64 Convert";
                    TempBlob: Codeunit "Temp Blob";
                    FileInStream: InStream;
                    FileOutStream: OutStream;
                    ExistingDocumentFound: Boolean;
                    RecordID: RecordID;
                    RecordCounter: Integer;

                begin
                    GlobalLinesCount := FilesCount;
                    if (FileCounter = 0) or (FilesCount = 1) then
                        Rec.DeleteAll();

                    TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);
                    Base64Convert.FromBase64(FileAsText.Substring(FileAsText.IndexOf(',') + 1), FileOutStream);
                    TempBlob.CreateInStream(FileInStream, TextEncoding::UTF8);

                    case GlobalRecRef.Number of


                        17:
                            AttachDocumentsToGLEntry(FileName, FilesCount, FileInStream);

                        21:
                            AttachDocumentsToCustLedgerEntry(FileName, FilesCount, FileInStream);

                        25:
                            AttachDocumentsToVendorLedgerEntry(FileName, FilesCount, FileInStream);

                        36:
                            begin
                                RecordCounter := 0;
                                if DictOfRecordIDs.Count > 0 then
                                    foreach RecordID in DictOfRecordIDs.Values do begin
                                        GlobalRecordID := RecordID;
                                        AttachDocumentsToSalesHeader(FileName, FilesCount, FileInStream);
                                        RecordCounter += 1;
                                        FileInStream.ResetPosition();
                                    end
                                else begin


                                    AttachDocumentsToSalesHeader(FileName, FilesCount, FileInStream);
                                    RecordCounter := 1;
                                end;

                                if not DDSingleInstance.GetMessagePrinted() then begin
                                    message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                                    DDSingleInstance.SetMessagePrinted(true);
                                end;
                            end;
                        38:
                            begin
                                RecordCounter := 0;
                                if DictOfRecordIDs.Count > 0 then
                                    foreach RecordID in DictOfRecordIDs.Values do begin
                                        GlobalRecordID := RecordID;

                                        // >> APO-XX
                                        PurchaseHeader.get(GlobalRecordID);
                                        PurchaseHeader2.setrange("Vendor Invoice No.", PurchaseHeader."Vendor Invoice No.");
                                        if PurchaseHeader2.FindSet() then
                                            repeat
                                                GlobalRecordID := PurchaseHeader2.RecordID;
                                                AttachDocumentsToPurchaseHeader(FileName, FilesCount, FileInStream);
                                                RecordCounter := 1;
                                                FileInStream.ResetPosition();
                                            until PurchaseHeader2.next = 0;

                                        //AttachDocumentsToPurchaseHeader(FileName, FilesCount, FileInStream);
                                        //RecordCounter += 1;
                                        //FileInStream.ResetPosition();
                                        // << APO-XX
                                    end
                                else begin
                                    // >> APO-XX
                                    PurchaseHeader.get(GlobalRecordID);
                                    if PurchaseHeader."Vendor Invoice No." <> '' then begin
                                        PurchaseHeader2.setrange("Vendor Invoice No.", PurchaseHeader."Vendor Invoice No.");
                                        if Dialog.Confirm(StrSubstNo(ConfirmMessageLbl, PurchaseHeader2.Count)) then begin
                                            if PurchaseHeader2.FindSet() then
                                                repeat
                                                    GlobalRecordID := PurchaseHeader2.RecordID;
                                                    // << APO-XX
                                                    AttachDocumentsToPurchaseHeader(FileName, FilesCount, FileInStream);
                                                    RecordCounter := 1;
                                                    // >> APO-XX
                                                    FileInStream.ResetPosition();
                                                until PurchaseHeader2.next = 0;
                                            // << APO-XX
                                        end else
                                            message(AbortedMesgLbl);
                                    end else begin
                                        AttachDocumentsToPurchaseHeader(FileName, FilesCount, FileInStream);
                                        RecordCounter := 1;
                                    end;
                                end;

                                if not DDSingleInstance.GetMessagePrinted() then begin
                                    message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount), format(RecordCounter)));
                                    DDSingleInstance.SetMessagePrinted(true);
                                end;
                            end;
                        81:
                            begin
                                RecordCounter := 0;
                                if DictOfRecordIDs.Count > 0 then
                                    foreach RecordID in DictOfRecordIDs.Values do begin
                                        GlobalRecordID := RecordID;
                                        AttachDocumentsToGenJnlLine(FileName, FilesCount, FileInStream);
                                        RecordCounter += 1;
                                        FileInStream.ResetPosition();
                                    end
                                else begin
                                    AttachDocumentsToGenJnlLine(FileName, FilesCount, FileInStream);
                                    RecordCounter := 1;
                                end;

                                if not DDSingleInstance.GetMessagePrinted() then begin
                                    message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                                    DDSingleInstance.SetMessagePrinted(true);
                                end;
                            end;
                    /*
                                            134:
                                                begin
                                                    RecordCounter := 0;
                                                    if DictOfRecordIDs.Count > 0 then
                                                        foreach RecordID in DictOfRecordIDs.Values do begin
                                                            GlobalRecordID := RecordID;
                                                            AttachDocumentsToPostedDocsWithNoIncBuf(FileName, FilesCount, FileInStream);
                                                            RecordCounter += 1;
                                                            FileInStream.ResetPosition();
                                                        end
                                                    else begin
                                                        AttachDocumentsToPostedDocsWithNoIncBuf(FileName, FilesCount, FileInStream);
                                                        RecordCounter := 1;
                                                    end;
                                                    if not DDSingleInstance.GetMessagePrinted() then begin
                                                        message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                                                        DDSingleInstance.SetMessagePrinted(true);
                                                    end;
                                                end;
                                                */
                    end;
                end;

            }
            repeater(Rep)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Name field.';
                }
                field("File Extension"; Rec."File Extension")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the File Extensions field.';
                }

            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(DeleteAllIncomingDocuments)
            {
                ApplicationArea = All;
                Caption = 'Delete All Incoming Documents for all tables';
                ToolTip = 'Deletes all - take care!!!';
                Image = Download;
                Enabled = false;
                Visible = false;

                trigger OnAction()
                var
                    IncomingDocumentAttachment: Record "Incoming Document Attachment";
                    IncomingDocument: Record "Incoming Document";
                    GenJnlLine: Record "Gen. Journal Line";
                    GenJnlLine2: Record "Gen. Journal Line";
                    GLEntry: Record "G/L Entry";
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    SalesHeader: Record "Sales Header";
                    PurchaseHeader: Record "Purchase Header";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin

                    IncomingDocument.DeleteAll();
                    IncomingDocumentAttachment.DeleteAll();
                    GenJnlLine.SetFilter("Incoming Document Entry No.", '<>%1', 0);
                    if GenJnlLine.findset THEN
                        repeat
                            GenJnlLine."Incoming Document Entry No." := 0;
                            GenJnlLine.Modify();
                        until GenJnlLine.next = 0;

                    VendorLedgerEntry.SetFilter("Incoming Document Entry No.", '<>%1', 0);
                    if VendorLedgerEntry.findset THEN
                        repeat
                            VendorLedgerEntry."Incoming Document Entry No." := 0;
                            VendorLedgerEntry.Modify();
                        until VendorLedgerEntry.next = 0;

                    SalesHeader.SetFilter("Incoming Document Entry No.", '<>%1', 0);
                    if SalesHeader.findset THEN
                        repeat
                            SalesHeader."Incoming Document Entry No." := 0;
                            SalesHeader.Modify();
                        until SalesHeader.next = 0;

                    PurchaseHeader.SetFilter("Incoming Document Entry No.", '<>%1', 0);
                    if PurchaseHeader.findset THEN
                        repeat
                            PurchaseHeader."Incoming Document Entry No." := 0;
                            PurchaseHeader.Modify();
                        until PurchaseHeader.next = 0;

                end;
            }

            action(DeleteAllIncomingDocumentsCurrLine)
            {
                ApplicationArea = All;
                Caption = 'Delete All Incoming Documents for the current line';
                ToolTip = 'Deletes all - take care!!!';
                Image = Download;
                Enabled = true;

                trigger OnAction()
                var
                    IncomingDocumentAttachment: Record "Incoming Document Attachment";
                    IncomingDocument: Record "Incoming Document";
                    GenJnlLine: Record "Gen. Journal Line";
                    GenJnlLine2: Record "Gen. Journal Line";
                    GLEntry: Record "G/L Entry";
                    CustLedgerEntry: Record "Cust. Ledger Entry";
                    SalesHeader: Record "Sales Header";
                    PurchaseHeader: Record "Purchase Header";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    case GlobalRecRef.Number of
                        17:
                            begin
                                GLEntry.get(GlobalRecordID);
                                IncomingDocument.SetRange("Posting Date", GLEntry."Posting Date");
                                IncomingDocument.SetRange("Document No.", GLEntry."Document No.");
                                if IncomingDocument.FindFirst() then begin
                                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                                    if IncomingDocumentAttachment.FindSet() then
                                        IncomingDocumentAttachment.DeleteAll();
                                    IncomingDocument.delete();
                                end;
                            end;
                        21:
                            begin
                                CustLedgerEntry.get(GlobalRecordID);
                                IncomingDocument.SetRange("Posting Date", CustLedgerEntry."Posting Date");
                                IncomingDocument.SetRange("Document No.", CustLedgerEntry."Document No.");
                                if IncomingDocument.FindFirst() then begin
                                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                                    if IncomingDocumentAttachment.FindSet() then
                                        IncomingDocumentAttachment.DeleteAll();
                                    IncomingDocument.delete();
                                end;
                            end;
                        25:
                            begin
                                VendorLedgerEntry.get(GlobalRecordID);
                                if VendorLedgerEntry."Incoming Document Entry No." <> 0 then begin
                                    if IncomingDocument.get(VendorLedgerEntry."Incoming Document Entry No.") then
                                        IncomingDocument.Delete;
                                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", VendorLedgerEntry."Incoming Document Entry No.");
                                    IncomingDocumentAttachment.DeleteAll();
                                    VendorLedgerEntry."Incoming Document Entry No." := 0;
                                    VendorLedgerEntry.Modify();
                                end;
                            end;
                        36:
                            begin
                                SalesHeader.get(GlobalRecordID);
                                if SalesHeader."Incoming Document Entry No." <> 0 then begin
                                    if IncomingDocument.get(SalesHeader."Incoming Document Entry No.") then
                                        IncomingDocument.Delete;
                                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", SalesHeader."Incoming Document Entry No.");
                                    IncomingDocumentAttachment.DeleteAll();
                                    SalesHeader."Incoming Document Entry No." := 0;
                                    SalesHeader.Modify();
                                end;
                            end;
                        38:
                            begin
                                PurchaseHeader.get(GlobalRecordID);
                                if PurchaseHeader."Incoming Document Entry No." <> 0 then begin
                                    if IncomingDocument.get(PurchaseHeader."Incoming Document Entry No.") then
                                        IncomingDocument.Delete;
                                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", PurchaseHeader."Incoming Document Entry No.");
                                    IncomingDocumentAttachment.DeleteAll();
                                    PurchaseHeader."Incoming Document Entry No." := 0;
                                    PurchaseHeader.Modify();
                                end;
                            end;

                    end;
                end;
            }
        }
    }


    /// <summary>
    /// ClearDictOfRecordIDs.
    /// </summary>
    procedure ClearDictOfRecordIDs()
    begin
        clear(DictOfRecordIDs);
    end;

    /// <summary>
    /// SetCurrentRecordID.
    /// </summary>
    /// <param name="NewRecordID">RecordID.</param>
    /// <param name="recref">RecordRef.</param>
    /// <param name="Dict">Dictionary of [Integer, RecordID].</param>
    procedure SetCurrentRecordID(NewRecordID: RecordID; recref: RecordRef; Dict: Dictionary of [Integer, RecordID])
    DictOfRecorIDsCount: Integer;
    begin
        GlobalLinesCount := 0;
        GlobalRecordID := NewRecordID;
        GlobalRecRef := recref;
        FileCounter := 0;
        DictOfRecordIDs := Dict;
        DictOfRecorIDsCount := DictOfRecordIDs.Count;

    end;

    /// <summary>
    /// DeleteRec.
    /// </summary>
    procedure DeleteRec()
    begin
        Rec.deleteall;
        CurrPage.Update();
    end;

    local procedure CreateNewIncomingDocumentEntryNo(): Integer
    var
        IncomingDocument: Record "Incoming Document";
    begin
        if IncomingDocument.FindLast() then
            exit(IncomingDocument."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure CreateNewIncomingDocumentEntry(Var IncomingDocument: Record "Incoming Document"; IncDocumentEntryNo: Integer; FileName: Text; PostingDate: Date; DocumentNo: Code[20]; DocumentType: enum "Incoming Related Document Type")
    begin

        IncomingDocument.Reset();
        IncomingDocument.Init();
        IncomingDocument."Entry No." := IncDocumentEntryNo;
        IncomingDocument.Insert(true);

        IncomingDocument."Posting Date" := PostingDate;
        IncomingDocument."Document No." := DocumentNo;
        IncomingDocument."Document Type" := DocumentType;

        IncomingDocument.Validate("Related Record ID", GlobalRecordID);
        IncomingDocument.Description := FileName;
        IncomingDocument.validate(Status, IncomingDocument.Status::Created);
        IncomingDocument."Created By User ID" := UserSecurityId();
        IncomingDocument."Created Date-Time" := CurrentDateTime;
        IncomingDocument.Posted := false;
        IncomingDocument.Released := true;

        IncomingDocument.Modify(true);

    end;

    local procedure SaveDocumentAttachment(var IncomingDocument: Record "Incoming Document"; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; FileName: Text; var Instream: InStream; ReplaceContent: Boolean; PostingDate: Date; DocumentNo: Code[20]): Boolean
    var
        FileManagement: Codeunit "File Management";
        RecordRef: RecordRef;
        OutStream: OutStream;
        StreamLength: Integer;
    begin
        StreamLength := Instream.Length();
        IncomingDocument."Posting Date" := PostingDate;
        IncomingDocument."Document No." := DocumentNo;

        if IncomingDocument.Status in [IncomingDocument.Status::"Pending Approval", IncomingDocument.Status::Failed] then
            IncomingDocument.TestField(Status, IncomingDocument.Status::New);
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment."Line No." := GetIncomingDocumentNextLineNo(IncomingDocument);
        IncomingDocumentAttachment."Posting Date" := PostingDate;
        IncomingDocumentAttachment."Document No." := DocumentNo;

        IncomingDocumentAttachment.Content.CreateOutStream(OutStream);
        if CopyStream(OutStream, Instream) then
            ;

        IncomingDocumentAttachment.Validate("File Extension", LowerCase(CopyStr(FileManagement.GetExtension(FileName), 1, MaxStrLen(IncomingDocumentAttachment."File Extension"))));
        if IncomingDocumentAttachment.Name = '' then
            IncomingDocumentAttachment.Name := CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(IncomingDocumentAttachment.Name));

        if IncomingDocument.Description = '' then begin
            IncomingDocument.Description := CopyStr(IncomingDocumentAttachment.Name, 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument.Modify();
        end;

        if IncomingDocumentAttachment.Insert(true) then
            exit(true);

    end;

    local procedure AddDocumentAttachment(var IncomingDocument: Record "Incoming Document"; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; FileName: Text; Instream: InStream; ReplaceContent: Boolean; PostingDate: Date; DocumentNo: Code[20]; DocumentType: enum "Incoming Related Document Type"): Boolean
    var
        FileManagement: Codeunit "File Management";
        RecordRef: RecordRef;
        OutStream: OutStream;
        LineNo: Integer;
        PrimaryRec: Boolean;
    begin

        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        If IncomingDocumentAttachment.FindLast() then
            LineNo := IncomingDocumentAttachment."Line No." + 10000
        else begin
            LineNo := 10000;
            PrimaryRec := true;
        end;


        IncomingDocumentAttachment.Init();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment."Line No." := LineNo;
        IncomingDocumentAttachment.insert();

        IncomingDocumentAttachment."Posting Date" := PostingDate;
        IncomingDocumentAttachment."Document No." := DocumentNo;
        if PrimaryRec then begin
            IncomingDocumentAttachment."Main Attachment" := true;
            IncomingDocumentAttachment.Default := true;
        end;

        IncomingDocumentAttachment.Content.CreateOutStream(OutStream);
        if CopyStream(OutStream, Instream) then
            ;

        IncomingDocumentAttachment.Validate("File Extension", LowerCase(CopyStr(FileManagement.GetExtension(FileName), 1, MaxStrLen(IncomingDocumentAttachment."File Extension"))));
        IncomingDocumentAttachment.Name := CopyStr(FileManagement.GetFileNameWithoutExtension(FileName), 1, MaxStrLen(IncomingDocumentAttachment.Name));

        IncomingDocument.Description := CopyStr(IncomingDocumentAttachment.Name, 1, MaxStrLen(IncomingDocument.Description));
        IncomingDocument.Modify();

        if IncomingDocumentAttachment.Modify(true) then
            exit(true);

    end;

    local procedure GetIncomingDocumentNextLineNo(IncomingDocument: Record "Incoming Document"): Integer
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if IncomingDocumentAttachment.FindLast() then
            exit(IncomingDocumentAttachment."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure UpdateAllJnlLinesHavingSameDocumentNo(GenJnlLineArg: Record "Gen. Journal Line"; IncomingDocumentEntryNo: Integer; var NoOfLines: Integer)
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetRange("Journal Template Name", GenJnlLineArg."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", GenJnlLineArg."Journal Batch Name");
        //GenJnlLine.SetRange("Document Type", GenJnlLineArg."Document Type");
        GenJnlLine.SetRange("Document No.", GenJnlLineArg."Document No.");
        NoOfLines := GenJnlLine.Count;
        if GenJnlLine.FindSet() then
            GenJnlLine.ModifyAll("Incoming Document Entry No.", GenJnlLineArg."Incoming Document Entry No.");

    end;

    local procedure UpdateHostLines(RecRef: RecordRef; IncomingDocumentEntryNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        FieldRef: FieldRef;
    begin


        case GlobalRecRef.Number of

            25:
                FieldRef := RecRef.Field(VendorLedgerEntry.FieldNo("Incoming Document Entry No."));

            36:
                FieldRef := RecRef.Field(SalesHeader.FieldNo("Incoming Document Entry No."));

            38:
                FieldRef := RecRef.Field(PurchaseHeader.FieldNo("Incoming Document Entry No."));

        end;
        FieldRef.Value(IncomingDocumentEntryNo);
        RecRef.Modify();

    end;

    local procedure AttachDocumentsToGenJnlLine(FileName: Text; FilesCount: Integer; FileInStream: InStream)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        GenJnlLine: Record "Gen. Journal Line";
        FinishedMessageLbl: Label 'Import of %1 files as attachments for %2 Journal Lines has finished successfully';
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        NewEntryNo: Boolean;
        DocumentType: enum "Gen. Journal Document Type";

    begin

        if GenJnlLine.Get(GlobalRecordID) then begin
            FileCounter += 1;
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
            if GenJnlLine."Incoming Document Entry No." <> 0 then
                IncDocumentEntryNo := GenJnlLine."Incoming Document Entry No."
            else begin
                NewEntryNo := true;
                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
            end;

            IncomingDocumentAttachment.Reset();
            if NewEntryNo then begin
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, 0D, '', DocumentType::" ");
                GenJnlLine."Incoming Document Entry No." := IncDocumentEntryNo;
                GenJnlLine.Modify();
            end else
                if IncomingDocument.get(IncDocumentEntryNo) then
                    ;

            SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, 0D, '');

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin

                UpdateAllJnlLinesHavingSameDocumentNo(GenJnlLine, IncDocumentEntryNo, NoOfLines);
                Rec.reset();
                CurrPage.Update(false);
                FileCounter := 0;

            end;//CurrPage.Update(true) does not work due to the appearance of a misleading dialog window popping up
        end;

    end;

    local procedure AttachDocumentsToGLEntry(FileName: Text; FilesCount: Integer; FileInStream: InStream);
    var
        GLEntry: Record "G/L Entry";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        IncomingDocumentPostingDate: Date;
        IncomingDocumentDocumentNo: Code[20];
        IncomingDocumentType: Enum "Incoming Related Document Type";
        ExistingDocumentFound: Boolean;

    begin

        if GLEntry.get(GlobalRecordID) then begin
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no

            case GLEntry."Document Type" of

                GLEntry."Document Type"::" ":
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                        IncomingDocument.SetRange("Document Type", IncomingDocumentType::" ");
                    end;
                GLEntry."Document Type"::"Credit Memo":
                    begin
                        case GLEntry."Gen. Posting Type" of
                            GLEntry."Gen. Posting Type"::Sale:
                                begin
                                    IncomingDocumentType := IncomingDocumentType::"Sales Credit Memo";
                                    IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Sales Credit Memo");
                                end;
                            GLEntry."Gen. Posting Type"::Purchase:
                                begin
                                    IncomingDocumentType := IncomingDocumentType::"Purchase Credit Memo";
                                    IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Purchase Credit Memo");
                                end;
                        end;
                    end;
                GLEntry."Document Type"::"Finance Charge Memo":
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing;
                GLEntry."Document Type"::Invoice:
                    begin
                        case GLEntry."Gen. Posting Type" of
                            GLEntry."Gen. Posting Type"::Sale:
                                begin
                                    IncomingDocumentType := IncomingDocumentType::"Sales Invoice";
                                    IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Sales Invoice");
                                end;
                            GLEntry."Gen. Posting Type"::Purchase:
                                begin
                                    IncomingDocumentType := IncomingDocumentType::"Purchase Invoice";
                                    IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Purchase Invoice");
                                end;
                        end;
                    end;
                GLEntry."Document Type"::Payment:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                GLEntry."Document Type"::Refund:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                GLEntry."Document Type"::Reminder:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                         //IncomingDocument.SetRange("Document Type", GLEntry."Document Type");

            end;


            IncomingDocument.SetRange("Document No.", GLEntry."Document No.");
            IncomingDocument.SetRange("Posting Date", GLEntry."Posting Date");

            if IncomingDocument.Findfirst() then
                repeat
                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                    if IncomingDocumentAttachment.FindFirst() then begin
                        ExistingDocumentFound := true;
                        IncomingDocumentPostingDate := IncomingDocument."Posting Date";
                        IncomingDocumentDocumentNo := IncomingDocument."Document No.";
                        IncomingDocumentType := IncomingDocument."Document Type";
                    end;
                until IncomingDocument.Next() = 0;

            if ExistingDocumentFound then begin

                // if Confirm('There is already an incoming Document Entry for this record, do you want to add one more?', False) then begin

                IncomingDocumentAttachment.Reset();
                AddDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, IncomingDocumentPostingDate, IncomingDocumentDocumentNo, IncomingDocumentType);
                //end

            end else begin

                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, GLEntry."Posting Date", GLEntry."Document No.", IncomingDocumentType);
                SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, GLEntry."Posting Date", GLEntry."Document No.");

            end;

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin
                message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                CurrPage.Update(false); // does not work due to the appearance of a misleading dialog window popping up
            end;
        end;
    end;



    local procedure AttachDocumentsToCustLedgerEntry(FileName: Text; FilesCount: Integer; FileInStream: InStream)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        RecRef: RecordRef;
        IncomingDocumentPostingDate: Date;
        IncomingDocumentDocumentNo: Code[20];
        IncomingDocumentType: Enum "Incoming Related Document Type";
        ExistingDocumentFound: Boolean;
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        NewEntryNo: Boolean;


    begin
        if CustLedgerEntry.get(GlobalRecordID) then begin
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no

            case CustLedgerEntry."Document Type" of

                CustLedgerEntry."Document Type"::" ":
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                        IncomingDocument.SetRange("Document Type", IncomingDocumentType::" ");
                    end;
                CustLedgerEntry."Document Type"::"Credit Memo":
                    begin
                        IncomingDocumentType := IncomingDocumentType::"Sales Credit Memo";
                        IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Sales Credit Memo");
                    end;
                CustLedgerEntry."Document Type"::"Finance Charge Memo":
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing;
                CustLedgerEntry."Document Type"::Invoice:
                    begin
                        IncomingDocumentType := IncomingDocumentType::"Sales Invoice";
                        IncomingDocument.SetRange("Document Type", IncomingDocumentType::"Sales Invoice");
                    end;
                CustLedgerEntry."Document Type"::Payment:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                CustLedgerEntry."Document Type"::Refund:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                CustLedgerEntry."Document Type"::Reminder:
                    begin
                        IncomingDocumentType := IncomingDocumentType::" ";
                    end; // do nothing
                         //IncomingDocument.SetRange("Document Type", GLEntry."Document Type");

            end;


            IncomingDocument.SetRange("Document No.", CustLedgerEntry."Document No.");
            IncomingDocument.SetRange("Posting Date", CustLedgerEntry."Posting Date");

            if IncomingDocument.Findfirst() then
                repeat
                    IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                    if IncomingDocumentAttachment.FindFirst() then begin
                        ExistingDocumentFound := true;
                        IncomingDocumentPostingDate := IncomingDocument."Posting Date";
                        IncomingDocumentDocumentNo := IncomingDocument."Document No.";
                        IncomingDocumentType := IncomingDocument."Document Type";
                    end;
                until IncomingDocument.Next() = 0;

            if ExistingDocumentFound then begin

                // if Confirm('There is already an incoming Document Entry for this record, do you want to add one more?', False) then begin

                IncomingDocumentAttachment.Reset();
                AddDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, IncomingDocumentPostingDate, IncomingDocumentDocumentNo, IncomingDocumentType);
                //end

            end else begin

                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, CustLedgerEntry."Posting Date", CustLedgerEntry."Document No.", IncomingDocumentType);
                SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, CustLedgerEntry."Posting Date", CustLedgerEntry."Document No.");

            end;

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin
                message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                CurrPage.Update(false); // does not work due to the appearance of a misleading dialog window popping up
            end;
        end;
        /*
                if (FilesCount > 1) and (FileCounter = 0) and (not FatalErrorRaised) then begin
                    FatalErrorRaised := true;
                    FileCounter += 1;
                    error(ErrorLbl3);
                end;

                if FatalErrorRaised then
                    exit;

                FileCounter += 1;

                if CustLedgerEntry.get(GlobalRecordID) then begin
                    // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
                    IncomingDocument.SetRange("Posting Date", CustLedgerEntry."Posting Date");
                    IncomingDocument.SetRange("Document No.", CustLedgerEntry."Document No.");
                    if IncomingDocument.Findfirst() then
                        repeat
                            IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                            if IncomingDocumentAttachment.FindFirst() then begin
                                ExistingDocumentFound := true;
                                IncomingDocumentPostingDate := IncomingDocument."Posting Date";
                                IncomingDocumentDocumentNo := IncomingDocument."Document No.";
                            end;
                        until IncomingDocument.Next() = 0;

                    if ExistingDocumentFound and (FileCounter = 1) then begin

                        if Confirm('There is already an incoming Document Entry for this record, do you want to replace it?', False) then begin

                            IncomingDocumentAttachment.Reset();
                            ReplaceDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, IncomingDocumentPostingDate, IncomingDocumentDocumentNo);
                        end

                    end else begin

                        IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
                        CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, CustLedgerEntry."Posting Date", CustLedgerEntry."Document No.");
                        SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, CustLedgerEntry."Posting Date", CustLedgerEntry."Document No.");

                    end;

                    Rec.Init();
                    Rec."Sorting Order" := FileCounter;
                    Rec."Incoming Document Entry No." := IncDocumentEntryNo;
                    rec.Name := FileName;
                    while not Rec.Insert() do
                        Rec."Sorting Order" += 1;
                    NoOfLines := Rec.Count();

                    CustLedgerEntry2.SetRange("Posting Date", CustLedgerEntry."Posting Date");
                    CustLedgerEntry2.SetRange("Document No.", CustLedgerEntry."Document No.");
                    NoOfLines := CustLedgerEntry2.Count;

                    if FileCounter = FilesCount then begin
                        message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                        Rec.Reset();
                        CurrPage.Update(false);// does not work due to the appearance of a misleading dialog window popping up
                        FileCounter := 0;
                        FatalErrorRaised := false;
                    end;
                end;
        */
    end;

    local procedure AttachDocumentsToVendorLedgerEntry(FileName: Text; FilesCount: Integer; FileInStream: InStream)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        RecRef: RecordRef;
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        NewEntryNo: Boolean;
        DocumentType: enum "Gen. Journal Document Type";
    begin

        if VendorLedgerEntry.get(GlobalRecordID) then begin
            FileCounter += 1;
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
            if VendorLedgerEntry."Incoming Document Entry No." <> 0 then
                IncDocumentEntryNo := VendorLedgerEntry."Incoming Document Entry No."
            else begin
                NewEntryNo := true;
                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
            end;

            IncomingDocumentAttachment.Reset();
            if NewEntryNo then begin
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, 0D, '', DocumentType::" ");
                VendorLedgerEntry."Incoming Document Entry No." := IncDocumentEntryNo;
                VendorLedgerEntry.Modify();
            end else
                if IncomingDocument.get(IncDocumentEntryNo) then
                    ;

            SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, 0D, '');

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin
                RecRef.Get(GlobalRecordID);
                UpdateHostLines(RecRef, IncDocumentEntryNo);
                VendorLedgerEntry2.SetRange("Posting Date", VendorLedgerEntry."Posting Date");
                VendorLedgerEntry2.SetRange("Document No.", VendorLedgerEntry."Document No.");
                if VendorLedgerEntry2.findset then
                    repeat
                        VendorLedgerEntry2."Incoming Document Entry No." := IncDocumentEntryNo;
                        VendorLedgerEntry2.Modify();
                    until VendorLedgerEntry2.Next() = 0;

                VendorLedgerEntry2.SetRange("Incoming Document Entry No.", VendorLedgerEntry."Incoming Document Entry No.");
                NoOfLines := VendorLedgerEntry2.Count;
                message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount)));
                Rec.Reset();
                CurrPage.Update(false);
                FileCounter := 0;

            end;//CurrPage.Update(true) does not work due to the appearance of a misleading dialog window popping up

        end;

    end;

    local procedure AttachDocumentsToSalesHeader(FileName: Text; FilesCount: Integer; FileInStream: InStream)
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        RecRef: RecordRef;
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        NewEntryNo: Boolean;
        DocumentType: enum "Gen. Journal Document Type";
    begin

        if SalesHeader.get(GlobalRecordID) then begin
            FileCounter += 1;
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
            if SalesHeader."Incoming Document Entry No." <> 0 then
                IncDocumentEntryNo := SalesHeader."Incoming Document Entry No."
            else begin
                NewEntryNo := true;
                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
            end;

            IncomingDocumentAttachment.Reset();
            if NewEntryNo then begin
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, 0D, '', DocumentType::" ");
                SalesHeader."Incoming Document Entry No." := IncDocumentEntryNo;
                SalesHeader.Modify();
            end else
                if IncomingDocument.get(IncDocumentEntryNo) then
                    ;

            SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, 0D, '');

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin
                RecRef.Get(GlobalRecordID);
                UpdateHostLines(RecRef, IncDocumentEntryNo);
                SalesHeader2.SetRange("Incoming Document Entry No.", SalesHeader."Incoming Document Entry No.");
                NoOfLines := SalesHeader2.Count;
                //message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount), format(NoOfLines)));
                FileCounter := 0;
                Rec.reset();
                CurrPage.Update(false)

            end;//CurrPage.Update(true) does not work due to the appearance of a misleading dialog window popping up

        end;

    end;

    local procedure AttachDocumentsToPurchaseHeader(FileName: Text; FilesCount: Integer; var FileInStream: InStream)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        RecRef: RecordRef;
        IncDocumentEntryNo: Integer;
        NoOfLines: Integer;
        NewEntryNo: Boolean;
        DocumentType: enum "Gen. Journal Document Type";

    begin

        if PurchaseHeader.get(GlobalRecordID) then begin
            FileCounter += 1;
            // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
            if PurchaseHeader."Incoming Document Entry No." <> 0 then
                IncDocumentEntryNo := PurchaseHeader."Incoming Document Entry No."
            else begin
                NewEntryNo := true;
                IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
            end;

            IncomingDocumentAttachment.Reset();
            if NewEntryNo then begin
                CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, 0D, '', DocumentType::" ");
                PurchaseHeader."Incoming Document Entry No." := IncDocumentEntryNo;
                PurchaseHeader.Modify();
            end else
                if IncomingDocument.get(IncDocumentEntryNo) then
                    ;

            SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, 0D, '');

            Rec.Init();
            Rec."Sorting Order" := FileCounter;
            Rec."Incoming Document Entry No." := IncDocumentEntryNo;
            rec.Name := FileName;
            while not Rec.Insert() do
                Rec."Sorting Order" += 1;
            NoOfLines := Rec.Count();

            if FileCounter = FilesCount then begin
                RecRef.Get(GlobalRecordID);
                UpdateHostLines(RecRef, IncDocumentEntryNo);

                PurchaseHeader2.SetRange("Incoming Document Entry No.", PurchaseHeader."Incoming Document Entry No.");
                NoOfLines := PurchaseHeader2.Count;

                //message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount), format(NoOfLines)));
                FileCounter := 0;
                Rec.Reset();
                CurrPage.Update(false)

            end; //CurrPage.Update(true) does not work due to the appearance of a misleading dialog window popping up


        end;

    end;




    /*
        local procedure AttachDocumentsToPostedDocsWithNoIncBuf(FileName: Text; FilesCount: Integer; FileInStream: InStream)
        var
            PostedDocsWithNoIncBuf: Record "Posted Docs. With No Inc. Buf.";
            PostedDocsWithNoIncBuf2: Record "Posted Docs. With No Inc. Buf.";
            IncomingDocumentAttachment: Record "Incoming Document Attachment";
            IncomingDocument: Record "Incoming Document";
            GLEntry: Record "G/L Entry";
            RecRef: RecordRef;
            IncomingDocumentPostingDate: Date;
            IncomingDocumentDocumentNo: Code[20];
            IncDocumentEntryNo: Integer;
            NoOfLines: Integer;
            NewEntryNo: Boolean;
            ExistingDocumentFound: Boolean;
            DocumentType: enum "Gen. Journal Document Type";
            ErrorLbl2: Label 'You can only upload one file for GL Entries';
        begin

            if (FilesCount > 1) and (FileCounter = 0) and (not FatalErrorRaised) then begin
                FatalErrorRaised := true;
                FileCounter += 1;
                error(ErrorLbl2);
            end;

            if FatalErrorRaised then
                exit;

            FileCounter += 1;

            if PostedDocsWithNoIncBuf.get(GlobalRecordID) then begin
                // Find out if any documents exist for the journal line and get the relevant Incoming Document Entry no
                IncomingDocument.SetRange("Posting Date", PostedDocsWithNoIncBuf."Posting Date");
                IncomingDocument.SetRange("Document No.", PostedDocsWithNoIncBuf."Document No.");
                if IncomingDocument.Findfirst() then
                    repeat
                        IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
                        if IncomingDocumentAttachment.FindFirst() then begin
                            ExistingDocumentFound := true;
                            IncomingDocumentPostingDate := IncomingDocument."Posting Date";
                            IncomingDocumentDocumentNo := IncomingDocument."Document No.";
                        end;
                    until IncomingDocument.Next() = 0;

                if ExistingDocumentFound then begin

                    if Confirm('There is already an incoming Document Entry for this record, do you want to replace it?', False) then begin

                        IncomingDocumentAttachment.Reset();
                        //AddDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, IncomingDocumentPostingDate, IncomingDocumentDocumentNo,);
                    end

                end else begin

                    IncDocumentEntryNo := CreateNewIncomingDocumentEntryNo;
                    CreateNewIncomingDocumentEntry(IncomingDocument, IncDocumentEntryNo, FileName, PostedDocsWithNoIncBuf."Posting Date", GLEntry."Document No.", DocumentType::" ");
                    SaveDocumentAttachment(IncomingDocument, IncomingDocumentAttachment, FileName, FileInStream, true, PostedDocsWithNoIncBuf."Posting Date", GLEntry."Document No.");

                end;

                Rec.Init();
                Rec."Sorting Order" := FileCounter;
                Rec."Incoming Document Entry No." := IncDocumentEntryNo;
                rec.Name := FileName;
                while not Rec.Insert() do
                    Rec."Sorting Order" += 1;
                NoOfLines := Rec.Count();

                if FileCounter = FilesCount then begin
                    //message(StrSubstNo(FinishedMessageLbl2, format(GlobalLinesCount), '1'));
                    CurrPage.Update(false); // does not work due to the appearance of a misleading dialog window popping up
                    FileCounter := 0;
                    FatalErrorRaised := false;
                end;
            end;

        end;
    */
    var
        DDSingleInstance: Codeunit "D&DSingleInstance";
        MainRecordRef: RecordRef;
        GlobalRecordID: RecordId;
        GlobalRecRef: RecordRef;
        GlobalLinesCount: Integer;
        GlobalDocumentNo: text;
        GlobalPostingDate: Date;
        FileCounter: Integer;
        MessagePrinted: Boolean;
        ConfirmMessageLbl: Label 'Do you wish to upload files to %1 Orders';
        AbortedMesgLbl: Label 'The operation has been aborted';

        // >> FG-11
        FinishedMessageLbl2: Label 'Import of %1 files as attachments has finished successfully';
        CreateMainDocumentFirstErr: Label 'You must fill in any field to create a main record before you try to attach a document. Refresh the page and try again.';
        // << FG-11
        DictOfRecordIDs: Dictionary of [Integer, RecordId];

}
