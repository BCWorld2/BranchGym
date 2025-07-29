codeunit 81700 BCW_InitiateCompany
{
    trigger OnRun()
    begin
        IF confirm(ConfirmLbl, false) then begin
            Company.findset;
            repeat
                DragnDrop.ChangeCompany(Company.Name);
                If not DragnDrop.get() then begin
                    DragnDrop.Init();
                    DragnDrop.Finance := true;
                    DragnDrop.Sales := true;
                    DragnDrop.Purchases := true;
                    DragnDrop.insert;
                end;
            Until company.Next() = 0;
        end;
    end;

    var
        Company: record company;
        DragnDrop: record "Drag&Drop Setup";
        ConfirmLbl: label 'Do you want to activate Drag and Drop in all companies?';
}

