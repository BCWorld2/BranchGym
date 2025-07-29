/// <summary>
/// Unknown DragnDropPermissions (ID 81700).
/// </summary>
permissionset 81700 DragnDropPermissions
{
    Assignable = true;
    Permissions = //tabledata "Drag&Drop Document Attachment" = RIMD,
                  //table "Drag&Drop Document Attachment" = X,
    page IncDocAttachDragAndDropArea = X,
        tabledata "Drag&Drop Setup" = RIMD,
        table "Drag&Drop Setup" = X,
        page "Drag&Drop Setup" = X,
        codeunit BCW_InitiateCompany = X,
        codeunit "D&DSingleInstance" = X;
}