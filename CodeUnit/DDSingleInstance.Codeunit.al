codeunit 81701 "D&DSingleInstance"
{

    SingleInstance = true;
    trigger OnRun()
    begin

    end;

    procedure SetMessagePrinted(MessagePrintedArg: Boolean)
    begin
        MessagePrinted := MessagePrintedArg;
    end;

    procedure GetMessagePrinted(): Boolean
    begin
        exit(MessagePrinted);
    end;

    var
        MessagePrinted: Boolean;
}
