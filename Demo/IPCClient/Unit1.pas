unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, SYIPCIntf, StrUtils, IPCServerTest;

type
  {$METHODINFO ON}
  TIPCClientTest = class
  public
    function ShowMessage(const AMsg: WideString): WideString;
  end;
  {$METHODINFO OFF}
  TForm1 = class(TForm)
    edtSessionName: TEdit;
    lbl1: TLabel;
    btnOpen: TButton;
    memContent: TMemo;
    btnSend: TButton;
    lbl2: TLabel;
    memLog: TMemo;
    btnBindEvent: TButton;
    btnCallShowMessage: TButton;
    btn1: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnBindEventClick(Sender: TObject);
    procedure btnCallShowMessageClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    FServer: TIPCServerTest;
  public
    procedure DoClientMessage(const AClient: IIPCClient; const AState: TIPCState;
      const ASenderID: Cardinal; const AMessage: IIPCMessage);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.DoClientMessage(const AClient: IIPCClient;
  const AState: TIPCState; const ASenderID: Cardinal; const AMessage: IIPCMessage);
begin
  Assert(MainThreadID = GetCurrentThreadId);
  case AState of
    isAfterOpen:
    begin
      memLog.Lines.Add('DoClientMessage1.isAfterOpen:' + IntToStr(AClient.SessionHandle));
      btnOpen.Caption := '�ر�';
    end;
    isAfterClose:
    begin
      memLog.Lines.Add('DoClientMessage1.isAfterClose');
      btnOpen.Caption := '��';
    end;
    isConnect:
    begin
      memLog.Lines.Add('DoClientMessage1.isConnect');
    end;
    isDisconnect:
    begin
      memLog.Lines.Add('DoClientMessage1.isDisconnect');
    end;
    isReceiveData://��״̬�Ĵ��������߳�(Ĭ��)��һ���������߳���(Server/Client��ReciveMessageInThread=True)
    begin
      memLog.Lines.Add('DoClientMessage1.isReceiveData');
      case AMessage.DataType of
        mdtUnknown:
          memLog.Lines.Add('�Զ�������');
        mdtString:
          memLog.Lines.Add('�ַ�����' + AMessage.S);
        mdtInteger:
          memLog.Lines.Add('����:' + IntToStr(AMessage.I));
        mdtDouble:
          memLog.Lines.Add('������:' + FloatToStr(AMessage.D));
        mdtCurrency:
          memLog.Lines.Add('���:' + FloatToStr(AMessage.C));
        mdtDateTime:
          memLog.Lines.Add('����:' + DateTimeToStr(AMessage.DT));

      end;
    end;
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if FServer <> nil then
    FreeAndNil(FServer);
end;

procedure TForm1.btnOpenClick(Sender: TObject);
begin
  if btnOpen.Caption = '��' then
  begin
    if FServer <> nil then
      FreeAndNil(FServer);
    FServer := CreateIPCServerTest(edtSessionName.Text);
    FServer.OnMessage := DoClientMessage;
    FServer.Bind(TIPCClientTest.Create);
    if not FServer.Open(False) then
    begin
      ShowMessage('�򿪻Ựʧ��:'+FServer.LastError);
      Exit;
    end;
  end
  else
  begin
    if FServer <> nil then
      FreeAndNil(FServer);
  end;
end;

procedure TForm1.btnSendClick(Sender: TObject);
begin
  if not FServer.Active then
  begin
    ShowMessage('�Ự��δ�򿪣�');
    Exit;
  end;
  FServer.Send(memContent.Lines.Text);
end;


procedure TForm1.btnBindEventClick(Sender: TObject);
begin
  if btnBindEvent.Caption = '���¼�' then
  begin
    FServer.OnMessage := DoClientMessage;
    btnBindEvent.Caption := '����¼�';
  end
  else
  begin
    FServer.OnMessage := nil;
    btnBindEvent.Caption := '���¼�';
  end;
end;

procedure TForm1.btnCallShowMessageClick(Sender: TObject);
var
  bResult: Boolean;
begin
  if not FServer.Active then
  begin
    ShowMessage('�Ự��δ�򿪣�');
    Exit;
  end;
  bResult := FServer.ShowMessage(memContent.Lines.Text);
  memLog.Lines.Add(Format('���ý��:%s', [BoolToStr(bResult, True)]));
end;

{ TIPCClientTest }

function TIPCClientTest.ShowMessage(const AMsg: WideString): WideString;
begin
  Form1.memLog.Lines.Add('[TIPCClientTest.ShowMessage]'+AMsg);
  Result := '��ã����Ƿ���:' + AMsg;
end;

procedure TForm1.btn1Click(Sender: TObject);
var
  i: Integer;
  tick: Cardinal;
begin
  if not FServer.Active then
  begin
    ShowMessage('�Ự��δ���ӣ�');
    Exit;
  end;
  tick := GetTickCount;
  for i := 0 to 1000 do
  begin
    FServer.Send(memContent.Lines.Text + '_'+ IntToStr(i));
  end;
  tick := GetTickCount - tick;
  memLog.Lines.Add('��ʱ��' + IntToStr(tick));
end;

end.
