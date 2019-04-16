unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SYIPCIntf, StdCtrls;

type
  TForm2 = class(TForm)
    edtSessionName: TEdit;
    lbl1: TLabel;
    btnOpen: TButton;
    memContent: TMemo;
    btnSend: TButton;
    lbl2: TLabel;
    memLog: TMemo;
    lstClient: TListBox;
    lbl3: TLabel;
    btnBroadcast: TButton;
    btn1: TButton;
    btnBindEvent: TButton;
    btnCallShowMessage: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnSendClick(Sender: TObject);
    procedure btnBroadcastClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btnBindEventClick(Sender: TObject);
    procedure btnCallShowMessageClick(Sender: TObject);
  private
    FIPCServer: IIPCServer;
  public
    procedure DoServerMessage(const AServer: IIPCServer; const AState: TIPCState;
      const ASenderID: Cardinal; const AMessage: IIPCMessage);
  end;

  {$METHODINFO ON}
  TIPCServerTest = class
  public
    function ShowMessage(const AMsg: WideString): Boolean;
  end;
  {$METHODINFO OFF}

var
  Form2: TForm2;

implementation

{$R *.dfm}

uses
  ObjComAuto;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FIPCServer := CreateIPCServer(edtSessionName.Text);
  FIPCServer.OnMessage := DoServerMessage;
  FIPCServer.Dispatch := TObjectDispatch.Create(TIPCServerTest.Create);
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FIPCServer := nil;
end;

procedure TForm2.btnOpenClick(Sender: TObject);
begin
  if btnOpen.Caption = '����' then
  begin
    if not FIPCServer.Open(edtSessionName.Text) then
      ShowMessage('�����Ựʧ��:'+FIPCServer.LastError);
  end
  else
  begin
    FIPCServer.Close;
  end;
end;

procedure TForm2.DoServerMessage(const AServer: IIPCServer;
  const AState: TIPCState; const ASenderID: Cardinal;
  const AMessage: IIPCMessage);
var
  idx: Integer;
begin
  Assert(MainThreadID = GetCurrentThreadId);
  case AState of
    isAfterOpen:
    begin
      memLog.Lines.Add('DoServerMessage.isAfterOpen:' + IntToStr(AServer.SessionHandle));
      btnOpen.Caption := '�ر�';
    end;
    isAfterClose:
    begin
      memLog.Lines.Add('DoServerMessage.isAfterClose');
      btnOpen.Caption := '����';
    end;
    isConnect:
    begin
      memLog.Lines.Add('DoServerMessage.isConnect');
      if lstClient.Items.IndexOf(IntToStr(ASenderID)) < 0 then
        lstClient.Items.Add(IntToStr(ASenderID));
    end;
    isDisconnect:
    begin
      memLog.Lines.Add('DoServerMessage.isDisconnect');
      idx := lstClient.Items.IndexOf(IntToStr(ASenderID));
      if idx >= 0 then
        lstClient.Items.Delete(idx);
    end;       
    isReceiveData://��״̬�Ĵ��������߳�(Ĭ��)��һ���������߳���(Server/Client��ReciveMessageInThread=True)
    begin
      memLog.Lines.Add('DoServerMessage.isReceiveData');
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

procedure TForm2.btnSendClick(Sender: TObject);
var
  LClientID: Cardinal;
  iResult: Boolean;
begin
  if not FIPCServer.Active then
  begin
    ShowMessage('�Ự��δ������');
    Exit;
  end;
  if lstClient.ItemIndex < 0 then
  begin
    ShowMessage('�������ѡ��һ���������Ŀͻ��ˣ�');
    Exit;
  end;
  LClientID := StrToInt(lstClient.Items[lstClient.ItemIndex]);
  iResult := FIPCServer.Send(LClientID, memContent.Lines.Text);
  memLog.Lines.Add(Format('���ͽ��:%s', [BoolToStr(iResult, True)]));
end;

procedure TForm2.btnBroadcastClick(Sender: TObject);
var
  iResult: Boolean;
begin                
  if not FIPCServer.Active then
  begin
    ShowMessage('�Ự��δ������');
    Exit;
  end;
  iResult := FIPCServer.Broadcast(memContent.Lines.Text);
  memLog.Lines.Add(Format('���ͽ��:%s', [BoolToStr(iResult, True)]));
end;

procedure TForm2.btn1Click(Sender: TObject);
var
  i: Integer;
  LClientID: Cardinal;
  tick: Cardinal;
begin
  if not FIPCServer.Active then
  begin
    ShowMessage('�Ự��δ������');
    Exit;
  end;
  if lstClient.ItemIndex < 0 then
  begin
    ShowMessage('�������ѡ��һ���������Ŀͻ��ˣ�');
    Exit;
  end;
  LClientID := StrToInt(lstClient.Items[lstClient.ItemIndex]);
  tick := GetTickCount;
  for i := 0 to 5000 do
  begin
    FIPCServer.Send(LClientID, memContent.Lines.Text + '_' + IntToStr(i));
  end;
  tick := GetTickCount - tick;
  memLog.Lines.Add('��ʱ��' + IntToStr(tick));
end;

procedure TForm2.btnBindEventClick(Sender: TObject);
begin
  if btnBindEvent.Caption = '���¼�' then
  begin
    FIPCServer.OnMessage := DoServerMessage;
    btnBindEvent.Caption := '����¼�';
  end
  else
  begin
    FIPCServer.OnMessage := nil;
    btnBindEvent.Caption := '���¼�';
  end;
end;

{ TIPCServerTest }

function TIPCServerTest.ShowMessage(const AMsg: WideString): Boolean;
begin
  Form2.memLog.Lines.Add('[TIPCServerTest.ShowMessage]'+AMsg);
  Result := True;
end;

procedure TForm2.btnCallShowMessageClick(Sender: TObject);
var
  LClientID: Cardinal;
  LResult: IIPCMessage;
begin
  if not FIPCServer.Active then
  begin
    ShowMessage('�Ự��δ������');
    Exit;
  end;
  if lstClient.ItemIndex < 0 then
  begin
    ShowMessage('�������ѡ��һ���������Ŀͻ��ˣ�');
    Exit;
  end;
  LClientID := StrToInt(lstClient.Items[lstClient.ItemIndex]);
  LResult := FIPCServer.Call(LClientID, 'ShowMessage', [memContent.Lines.Text]);
  memLog.Lines.Add(Format('���ý��:%s', [LResult.S]));
end;

end.
