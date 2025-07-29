page 81702 "Drag&Drop Setup"
{
    ApplicationArea = All;
    Caption = 'Drag&Drop Setup';
    PageType = Card;
    SourceTable = "Drag&Drop Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Finance; Rec.Finance)
                {
                    ToolTip = 'Specifies the value of the Finance field.', Comment = '%';
                }
                field(Purchases; Rec.Purchases)
                {
                    ToolTip = 'Specifies the value of the Purchases field.', Comment = '%';
                }
                field(Sales; Rec.Sales)
                {
                    ToolTip = 'Specifies the value of the Sales field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ActivateInAllCompanies)
            {
                ApplicationArea = All;
                Caption = 'Activate Drag and Drop in all companies';
                ToolTip = 'Initiates setup and activates Drag and Drop in all companies';
                Image = Setup;
                Enabled = true;

                trigger OnAction()
                var
                    InitDnD: Codeunit BCW_InitiateCompany;
                begin
                    InitDnD.Run();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not rec.get then begin
            rec.init;
            Rec.Insert();
        end;
    end;
}
