unit SYIPCIntf;

interface

const
  IPC_TIMEOUT           = 1000;
  IPC_TIMEOUT_OPENCLOSE = 100;
  IPC_CHAR_SIZE         = SizeOf(WideChar);
  IPC_SESSIONNAME_SIZE  = 40;
  IPC_CALLMETHOD_SIZE   = 100;
  
type
  /// <summary>
  /// IPC��Ϣ���������ͣ����ڱ�ʶIIPCMessage�е���������
  /// </summary>
  TIPCMessageDataType =  Byte; //(
const
  /// <summary>
  /// Ԥ������Ϣ����
  /// </summary>
    mdtUnknown    = 0;
    mdtString     = 1;
    mdtInteger    = 2;
    mdtBoolean    = 3;
    mdtDouble     = 4;
    mdtCurrency   = 5;
    mdtDateTime   = 6;
    mdtFile       = 7;

    mdtCall       = 10;
    mdtCallReturn = 11;
    mdtError      = 12;
    //mdtCallback   = 13;
        
  /// <summary>
  /// �û��Զ�����Ϣ���͵���ʼ���
  /// </summary>
    mdtCustomBase = 56;
  /// <summary>
  /// �û��Զ�����Ϣ���͵������
  /// </summary>
    mdtCustomMax  = 255;
  //);
        
type
  IIPCMessage = interface;
  IIPCServer = interface;
  IIPCClient = interface;

  /// <summary>
  /// IPC״̬������IPCServer/IPCClient��OnMessage�¼���
  /// </summary>
  TIPCState = (
    isAfterOpen,
    isAfterClose,
    isConnect,
    isDisconnect,
    isReceiveData
  );

  TMessageData = {$IF CompilerVersion > 18.5}PByte{$ELSE}PAnsiChar{$IFEND};

  /// <summary>
  /// IPC��Ϣ����
  /// </summary>
  TIPCMessageArray = array of IIPCMessage;
  /// <summary>
  /// IPC��Ϣ�ӿڣ��ýӿڷ�װ�˷���/���յ����ݣ��������Ϣ���ݽ��д���
  /// </summary>
  IIPCMessage = interface
  ['{B866075F-200A-49AC-9992-8403FE9A3108}']
    function GetData: TMessageData;
    function GetDataSize: Cardinal;
    function GetDataType: TIPCMessageDataType;
    function GetReadOnly: Boolean;
    function GetSenderID: Cardinal;
    function GetTopic: Byte;
    function GetI: Int64;
    function GetB: Boolean;
    function GetD: Double;
    function GetC: Currency;
    function GetDT: TDateTime;
    function GetS: WideString;
    function GetTag: Pointer;
    procedure SetDataType(const Value: TIPCMessageDataType);
    procedure SetSenderID(const Value: Cardinal);
    procedure SetI(const Value: Int64);
    procedure SetB(const Value: Boolean);
    procedure SetD(const Value: Double);
    procedure SetC(const Value: Currency);
    procedure SetDT(const Value: TDateTime);
    procedure SetS(const Value: WideString);
    procedure SetTopic(const Value: Byte);
    procedure SetTag(const Value: Pointer);
    
    function Implementor: Pointer;

    /// <summary>
    /// ����ǰIPC��Ϣ��¡һ��
    /// </summary>
    function  Clone: IIPCMessage;
    /// <summary>
    /// ������ݣ��÷���������������õ����ݣ�Data����nil��DataType���ΪmdtCustom
    /// </summary>
    procedure Clear;
    /// <summary>
    /// ��������ΪmdtCustom��IPC��Ϣ������
    /// </summary>
    /// <param name="AData">���ݵ���ʼָ���ַ</param>
    /// <param name="ADataSize">���ݵĳ���(�ֽ�)</param>
    /// <remarks>
    /// �ú����ڲ����AData�����ݽ��п����������ڵ������������AData��������
    /// </remarks>
    procedure SetData(const AData: TMessageData; const ADataSize: Cardinal); overload;
    /// <summary>
    /// ����IPC��Ϣ������(���Զ�����������)
    /// </summary>
    /// <param name="AData">���ݵ���ʼָ���ַ</param>
    /// <param name="ADataSize">���ݵĳ���(�ֽ�)</param>
    /// <param name="ADataType">��������</param>
    /// <remarks>
    /// �ú����ڲ����AData�����ݽ��п����������ڵ������������AData��������
    /// </remarks>
    procedure SetData(const AData: TMessageData; const ADataSize: Cardinal; const ADataType: TIPCMessageDataType); overload;
    /// <summary>
    /// ��IPC������׷������(�÷��������᡿�޸������õ�DataTypeֵ)
    /// </summary>
    /// <param name="AData">��׷�ӵ����ݵ���ʼָ���ַ</param>
    /// <param name="ADataSize">��׷�ӵ����ݵĳ���(�ֽ�)</param>
    procedure Add(const AData: TMessageData; const ADataSize: Cardinal); overload;
    /// <summary>
    /// ��IPC������׷������(�÷������᡿�޸������õ�DataTypeֵ)
    /// </summary>
    /// <param name="AData">��׷�ӵ����ݵ���ʼָ���ַ</param>
    /// <param name="ADataSize">��׷�ӵ����ݵĳ���(�ֽ�)</param>
    /// <param name="ADataType">��������</param>
    procedure Add(const AData: TMessageData; const ADataSize: Cardinal; const ADataType: TIPCMessageDataType); overload;
    /// <summary>
    /// ��IPC������׷���ַ���
    /// </summary>
    /// <param name="AData">��׷�ӵ��ַ���(unicode����)</param>
    /// <remarks>
    /// �ú������Զ�����DataTypeΪmdtString
    /// </remarks>
    procedure Add(const AData: WideString); overload;
    /// <summary>
    /// ���ļ��м���IPC��Ϣ���ݣ��ڼ���֮ǰ����������õ���Ϣ����
    /// </summary>
    /// <param name="AFileName">�����ص��ļ���</param>
    /// <param name="ADataType">ָ�����غ�IPC��Ϣ����������</param>
    /// <returns>�����Ƿ�ɹ�</returns>
    function LoadFromFile(const AFileName: WideString; const ADataType: TIPCMessageDataType = mdtFile): Boolean;
    /// <summary>
    /// ��IPC��Ϣ�����ݱ��浽�ļ���
    /// </summary>
    /// <param name="AFileName">��������ļ���</param>
    /// <param name="bFailIfExist">���ΪTrue���򱣴�ʱ����ļ��Ѵ�����ֱ�ӷ���False��</param>
    /// <returns></returns>
    function SaveToFile(const AFileName: WideString; const bFailIfExist: Boolean = False): Boolean;

    /// <summary>
    /// ��ʶ��IPC��Ϣ�������Ƿ���Ա��޸ģ����ReadOnly����ΪFalse��������������
    /// �޸��йصĺ������ö���ʧ�ܡ�
    /// </summary>
    property ReadOnly: Boolean read GetReadOnly;
    property S: WideString read GetS write SetS;
    property I: Int64 read GetI write SetI;
    property B: Boolean read GetB write SetB;
    property D: Double read GetD write SetD;
    property C: Currency read GetC write SetC;
    property DT: TDateTime read GetDT write SetDT;
    property Data: TMessageData read GetData;
    property DataSize: Cardinal read GetDataSize;
    property DataType: TIPCMessageDataType read GetDataType write SetDataType;
    property SenderID: Cardinal read GetSenderID write SetSenderID;
    /// <summary>
    /// �û��Զ������⣬��ֵ���Ա�IPC����
    /// </summary>
    property Topic: Byte read GetTopic write SetTopic;
    /// <summary>
    /// һ����չ�ֶΣ��û����������洢�κ����ݣ�ע����ֵ���ᱻIPC����
    /// </summary>
    property Tag: Pointer read GetTag write SetTag;
  end;

  /// <summary>
  /// IPC��Ϣ���У����ڻ���IPCServer/IPCClient���첽��Ϣ
  /// </summary>
  PIIPCMessageQueue = ^IIPCMessageQueue;
  IIPCMessageQueue = interface
  ['{0BA65859-6A75-42DB-99E0-237C45358AD1}']
    function  GetCount: Integer;
    function  GetItem(const Index: Integer): IIPCMessage;
    /// <summary>
    /// ��������һ����Ϣ
    /// </summary>
    /// <param name="AItem">���һ����Ϣ</param>
    /// <returns></returns>
    function  Push(const AItem: IIPCMessage): Integer;
    /// <summary>
    /// �������������Ϣ����ȡ����һ����Ϣ������������Ϣ�Ӷ������Ƴ�
    /// </summary>
    /// <param name="AItem">ȡ������Ϣ�����û����Ϣ����Ϊnil��</param>
    /// <returns>�������������Ϣ���򷵻�True, ���򷵻�False</returns>
    function  Pop(out AItem: IIPCMessage): Boolean;
    /// <summary>
    /// �������������Ϣ����ȡ����һ����Ϣ
    /// </summary>
    /// <returns>�����еĵ�һ����Ϣ�����û����Ϊnil</returns>
    function  Peek: IIPCMessage;
    /// <summary>
    /// ��������е�������Ϣ
    /// </summary>
    procedure Clear;
    /// <summary>
    /// ��ǰ�����е���Ϣ����
    /// </summary>
    property Count: Integer read GetCount;
    /// <summary>
    /// ���������Ӷ�����ȡ��Ϣ�������Կ����ڱ�����Ϣ�����е���Ϣ
    /// </summary>
    property Item[const Index: Integer]: IIPCMessage read GetItem; default;
  end;
      
  /// <summary>
  /// IPCServer����Ϣ�����¼�
  /// </summary>
  TIPCServerMessageEvent = procedure (const AServer: IIPCServer; const AState: TIPCState;
    const ASenderID: Cardinal; const AMessage: IIPCMessage) of object;
  /// <summary>
  /// IPCClient����Ϣ�����¼�
  /// </summary>
  TIPCClientMessageEvent = procedure (const AClient: IIPCClient; const AState: TIPCState;
    const ASenderID: Cardinal; const AMessage: IIPCMessage) of object;

  /// <summary>
  /// IPC����˽ӿڣ��ýӿڷ�װ��IPC����˵���ع���
  /// </summary>
  /// <example>
  /// <code>
  ///   LServer := CreateIPCServer("AIPCSessionName");
  ///   LServer.OnMessage := DoServerMessageMethod;
  ///   LServer.Open;
  ///   if not LServer.Send(iClientID, "Hello, I'm server.") then
  ///     LogWarning("��������ʧ��");
  ///   if not LServer.Broadcast("Hello, I'm server.") then
  ///     LogWarning("�㲥����ʧ��");
  /// </code>
  /// </example>
  IIPCServer = interface
  ['{463CF8CA-7115-493B-96A0-03730970D622}']
    function GetActive: Boolean;
    function GetReciveMessageInThread: Boolean;
    function GetReciveMessageToQueue: Boolean;
    function GetSessionName: WideString;
    function GetSessionHandle: Cardinal;
    function GetID: Cardinal;
    function GetClientCount: Integer;
    function GetClientInfos: WideString;
    function GetLastClientID: Cardinal;
    function GetReciveQueue: PIIPCMessageQueue;
    function GetOnMessage: TIPCServerMessageEvent;
    function GetDispatch: IDispatch;
    function GetTag: Pointer;
    function GetLastError: WideString;
    procedure SetActive(const Value: Boolean);
    procedure SetReciveMessageInThread(const Value: Boolean);
    procedure SetReciveMessageToQueue(const Value: Boolean);
    procedure SetSessionName(const Value: WideString);
    procedure SetOnMessage(const Value: TIPCServerMessageEvent);
    procedure SetDispatch(const Value: IDispatch);
    procedure SetTag(const Value: Pointer);
    
    function Implementor: Pointer;
    /// <summary>
    /// ���ָ��SessionName�Ƿ��Ѿ�����
    /// </summary>
    /// <param name="ASessionName">������SessionName</param>
    /// <returns></returns>
    function IsExist(const ASessionName: WideString): Boolean;
    /// <summary>
    /// ����һ��IPC�Ự���ȴ��ͻ��˵����ӣ��ڵ��ø÷���֮ǰ��Ҫ����
    /// SessionName���ԡ�
    /// </summary>
    /// <returns>�����Ƿ�ɹ�</returns>
    function Open: Boolean; overload;
    /// <summary>
    /// ����һ��IPC�Ự
    /// </summary>
    /// <param name="ASessionName">һ��Ψһ��IPC�Ự����</param>
    /// <returns>�����Ƿ�ɹ�</returns>
    function Open(const ASessionName: WideString): Boolean; overload;
    /// <summary>
    /// �ر�IPC����˻Ự
    /// </summary>
    procedure Close;
    /// <summary>
    /// �ж�ָ���Ŀͻ���ID�Ƿ����ӵ��˱������
    /// </summary>
    /// <param name="AClientID"></param>
    /// <returns>����ÿͻ������ӵ��˱�������򷵻�True�����򷵻�False</returns>
    function IsConnect(const AClientID: Cardinal): Boolean;
    /// <summary>
    /// ���IPCServer��û��ʵ��ָ���ķ���
    /// </summary>
    /// <param name="AClientID">�����Ŀͻ���ID</param>
    /// <param name="AMethodName">�����ķ�����</param>
    /// <returns></returns>
    function MethodExist(const AClientID: Cardinal; const AMethodName: WideString): Boolean;
    /// <summary>
    /// �������ӵ�IPCServer�󶨵�Dispatch����ķ���
    /// </summary>
    /// <param name="AClientID">�����õĿͻ���ID</param>
    /// <param name="AMethodName">������</param>
    /// <param name="AParams">���ò���(ע��������֧��IIPCMessage֧�ֵ�����)</param>
    /// <param name="ATimeOut">���ó�ʱʱ��</param>
    /// <returns>����˷������صĽ��</returns>
    function TryCall(const AClientID: Cardinal; const AMethodName: WideString; const AParams: array of OleVariant;
      out AResult: IIPCMessage; const ATimeOut: Cardinal): Boolean;
    function TryCallEx(const AClientID: Cardinal; const AMethodName: WideString; const AParams: array of IIPCMessage;
      out AResult: IIPCMessage; const ATimeOut: Cardinal): Boolean;
    function Call(const AClientID: Cardinal; const AMethodName: WideString;
      const AParams: array of OleVariant; const ATimeOut: Cardinal = IPC_TIMEOUT): IIPCMessage;
    function CallEx(const AClientID: Cardinal; const AMethodName: WideString;
      const AParams: array of IIPCMessage; const ATimeOut: Cardinal = IPC_TIMEOUT): IIPCMessage;
    /// <summary>
    /// ��ָ���ͻ��˷������ݣ�������һϵ�еĲ�ͬ�������͵����غ���
    /// </summary>
    /// <param name="AClientID">Ҫ���͵Ŀͻ���ID</param>
    /// <param name="AData">�����͵�����</param>
    /// <param name="ATimeOut">�ȴ��ͻ��˷��������ʱ��(��ʱʱ��)</param>
    /// <returns>
    ///  ��������
    /// <list type="Boolean">
    /// <item>
    /// <term>False</term>
    /// <description>����ʧ��</description>
    /// </item>
    /// <item>
    /// <term>True</term>
    /// <description>���ͳɹ�</description>
    /// </item>
    /// </list>
    /// </returns>
    function Send(const AClientID: Cardinal; const AData: IIPCMessage; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AClientID: Cardinal; const AData: Pointer; const ADataLen: Cardinal; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AClientID: Cardinal; const AData: WideString; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AClientID: Cardinal; const AData: Int64; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AClientID: Cardinal; const AData: Boolean; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AClientID: Cardinal; const AData: Double; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function SendC(const AClientID: Cardinal; const AData: Currency; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    function SendDT(const AClientID: Cardinal; const AData: TDateTime; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    function SendFile(const AClientID: Cardinal; const AFileName: WideString; ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;

    /// <summary>
    /// ���������ӵ�������˵Ŀͻ��˷���(�㲥)���ݣ�������һϵ�еĲ�ͬ�������͵����غ���
    /// </summary>
    /// <param name="AData">�����͵�����</param>
    /// <param name="AExclude">�㲥ʱ�ų��Ŀͻ���ID(����������ͻ��˷�����Ϣ)</param>
    /// <param name="ATimeOut">��ʱʱ��</param>
    /// <returns>
    ///  ��������
    /// <list type="Boolean">
    /// <item>
    /// <term>False</term>
    /// <description>���ͳ�ʱ</description>
    /// </item>
    /// <item>
    /// <term>True</term>
    /// <description>���ͳɹ�</description>
    /// </item>
    /// </list>
    /// </returns>
    function Broadcast(const AData: IIPCMessage; const AExclude: Cardinal = 0; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Broadcast(const AData: Pointer; const ADataLen: Cardinal; const AExclude: Cardinal = 0; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Broadcast(const AData: WideString; const AExclude: Cardinal = 0; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function BroadcastFile(const AFileName: WideString; const AExclude: Cardinal = 0; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    /// <summary>
    /// �Ự�򿪺󴴽��ķ���ID
    /// </summary>
    property ID: Cardinal read GetID;
    /// <summary>
    /// IPC�Ự����(Ƶ��)���ͻ��˺ͷ����ͨ����������������Ƿ��������
    /// </summary>
    property SessionName: WideString read GetSessionName write SetSessionName;
    /// <summary>
    /// IPC�Ự������ͻ��˺ͷ����ͨ���������������������
    /// </summary>
    property SessionHandle: Cardinal read GetSessionHandle;
    /// <summary>
    /// ��ȡ/���õ�ǰIPC�Ự״̬(����/�رգ��൱�ڵ���Open/Close����)
    /// </summary>
    property Active: Boolean read GetActive write SetActive;
    /// <summary>
    /// ��OnMessage�¼��н�������״̬�Ĵ����Ƿ����һ�������߳���
    /// </summary>
    /// <list type="Boolean">
    /// <item>
    /// <term>False(Ĭ��)</term>
    /// <description>��OnMessage�¼������߳��д�����յ�����</description>
    /// </item>
    /// <item>
    /// <term>True</term>
    /// <description>OnMessage�¼���һ�������߳��д�����յ�����</description>
    /// </item>
    /// </list>
    property ReciveMessageInThread: Boolean read GetReciveMessageInThread write SetReciveMessageInThread;
    /// <summary>
    /// �Ƿ񽫽��ܵ�����Ϣ������Ϣ���У����ΪTrueʱ��OnMessage�¼������ܲ���IsReciveMessage��Ϣ
    /// </summary>
    property ReciveMessageToQueue: Boolean read GetReciveMessageToQueue write SetReciveMessageToQueue;
    /// <summary>
    /// ��ǰ���ӵĿͻ�������
    /// </summary>
    property ClientCount: Integer read GetClientCount;
    /// <summary>
    /// �ͻ���������Ϣ����������һ��JSON�ַ�������ʽΪ��[ { clientID: XXXXXX }, { clientID: XXXXXX } ]
    /// </summary>
    property ClientInfos: WideString read GetClientInfos;
    /// <summary>
    /// ���һ�η�����Ϣ�Ŀͻ���
    /// </summary>
    property LastClientID: Cardinal read GetLastClientID;
    /// <summary>
    /// ��Ϣ���У����ReciveMessageToQueueΪTrue������յ�����Ϣ������ö����У������ǵ���OnMessage�¼�
    /// </summary>
    property ReciveQueue: PIIPCMessageQueue read GetReciveQueue;
    /// <summary>
    /// IPC�����״̬��������ݵ��¼�������
    /// </summary>
    property OnMessage: TIPCServerMessageEvent read GetOnMessage write SetOnMessage;
    /// <summary>
    /// �󶨵�IDispatch����IPC��һ�˿���ͨ��Call/CallEx�����������Dispatch�ķ���
    /// <remarks>
    /// ע�⣺��ΪIPCͨ���Ǻܺ�ʱ�ģ��ҿ�����������������벻Ҫ��IPC���õķ��������ܺ�ʱ�Ĳ���
    /// </remarks>
    /// </summary>
    property Dispatch: IDispatch read GetDispatch write SetDispatch;
    /// <summary>
    /// һ����չ�ֶΣ��û����������洢�κ�����
    /// </summary>
    property Tag: Pointer read GetTag write SetTag;
    /// <summary>
    /// ���һ�δ�����Ϣ
    /// </summary>
    property LastError: WideString read GetLastError;
  end;

  /// <summary>
  /// IPC�ͻ��˽ӿڣ��ýӿڷ�װ��IPC�ͻ��˵���ع���
  /// </summary>
  /// <example>
  /// <code>
  ///   LClient := CreateIPCClient("AIPCSessionName");
  ///   LClient.OnMessage := DoClientMessageMethod;
  ///   LClient.Open;
  ///   if not LClient.Send("Hello, I'm client.") then
  ///     LogWarning("��������ʧ��");
  /// </code>
  /// </example>
  IIPCClient = interface
  ['{D7899668-228D-4B9E-8F7B-842908D9B336}']
    function GetID: Cardinal;
    function GetServerID: Cardinal;
    function GetActive: Boolean;
    function GetReciveMessageInThread: Boolean;
    function GetReciveMessageToQueue: Boolean;
    function GetSessionName: WideString;
    function GetSessionHandle: Cardinal;
    function GetReciveQueue: PIIPCMessageQueue;
    function GetOnMessage: TIPCClientMessageEvent;
    function GetDispatch: IDispatch;
    function GetTag: Pointer;
    function GetLastError: WideString;
    procedure SetActive(const Value: Boolean);
    procedure SetReciveMessageInThread(const Value: Boolean);
    procedure SetReciveMessageToQueue(const Value: Boolean);
    procedure SetSessionName(const Value: WideString);
    procedure SetOnMessage(const Value: TIPCClientMessageEvent);
    procedure SetDispatch(const Value: IDispatch);
    procedure SetTag(const Value: Pointer);
    
    function Implementor: Pointer;

    /// <summary>
    /// ���ASessionName�Ự�Ƿ����(����)
    /// </summary>
    /// <param name="ASessionName">�����ĻỰ����</param>
    /// <returns></returns>
    function IsExist(const ASessionName: WideString): Boolean;
    /// <summary>
    /// ����Ƿ�����������
    /// </summary>
    function IsConnect: Boolean;
    /// <summary>
    /// IPC�ͻ����Ƿ��Ѿ���
    /// </summary>
    function IsOpened: Boolean;
    /// <summary>
    /// ��һ��IPC�Ự�����ӵ��ûỰ�ķ���ˣ����δ�ҵ��򷵻�False���ڵ��ø�
    /// ����֮ǰ��Ҫ������SessionName���ԡ�
    /// </summary>
    /// <param name="AConnectServer">�Ƿ����ӵ�����ˣ����ΪTrue�ǣ���δ�ҵ������ʱ����Fasle</param>
    /// <param name="ATimeOut">���ӷ���˵ĳ�ʱʱ��</param>
    /// <returns>���Ƿ�ɹ�</returns>
    function Open(const bFailIfServerNotExist: Boolean = True; const ATimeOut: Cardinal = IPC_TIMEOUT_OPENCLOSE): Boolean; overload;
    /// <summary>
    /// ��һ��IPC�Ự�����ӵ��ûỰ�ķ���ˣ����δ�ҵ��򷵻�False��
    /// </summary>
    /// <param name="ASessionName">���򿪵ĻỰ����</param>
    /// <param name="AConnectServer">�Ƿ����ӵ�����ˣ����ΪTrue�ǣ���δ�ҵ������ʱ����Fasle</param>
    /// <param name="ATimeOut">���ӷ���˵ĳ�ʱʱ��</param>
    /// <returns>���Ƿ�ɹ�</returns>
    function Open(const ASessionName: WideString;  const bFailIfServerNotExist: Boolean = True;
      const ATimeOut: Cardinal = IPC_TIMEOUT_OPENCLOSE): Boolean; overload;
    /// <summary>
    /// �ر�һ��IPC�Ự���÷�����Ͽ���IPC����˵�����
    /// </summary>
    procedure Close;
    /// <summary>
    /// ���IPCServer��û��ʵ��ָ���ķ���
    /// </summary>
    /// <param name="AMethodName">�����ķ�����</param>
    /// <returns></returns>
    function MethodExist(const AMethodName: WideString): Boolean;
    /// <summary>
    /// �������ӵ�IPCServer�󶨵�Dispatch����ķ���
    /// </summary>
    /// <param name="AMethodName">������</param>
    /// <param name="AParams">���ò���(ע��������֧��IIPCMessage֧�ֵ�����)</param>
    /// <param name="ATimeOut">���ó�ʱʱ��</param>
    /// <returns>����˷������صĽ��</returns>
    function TryCall(const AMethodName: WideString; const AParams: array of OleVariant;
      out AResult: IIPCMessage; const ATimeOut: Cardinal): Boolean;
    function TryCallEx(const AMethodName: WideString; const AParams: array of IIPCMessage;
      out AResult: IIPCMessage; const ATimeOut: Cardinal): Boolean;
    function Call(const AMethodName: WideString; const AParams: array of OleVariant; const ATimeOut: Cardinal = IPC_TIMEOUT): IIPCMessage;
    function CallEx(const AMethodName: WideString; const AParams: array of IIPCMessage; const ATimeOut: Cardinal = IPC_TIMEOUT): IIPCMessage;  
    /// <summary>
    /// ��IPC����˷������ݣ�������һϵ�еĲ�ͬ�������͵����غ���
    /// </summary>
    /// <param name="AData">�����͵�����</param>
    /// <param name="ATimeOut">�ȴ�����˷��������ʱ��(��ʱʱ��)</param>
    /// <returns>
    ///  ��������
    /// <list type="Boolean">
    /// <item>
    /// <term>False</term>
    /// <description>����ʧ��</description>
    /// </item>
    /// <item>
    /// <term>True</term>
    /// <description>���ͳɹ�</description>
    /// </item>
    /// </list>
    /// </returns>
    function Send(const AData: IIPCMessage; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AData: Pointer; const ADataLen: Cardinal; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AData: WideString; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AData: Int64; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AData: Boolean; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function Send(const AData: Double; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean; overload;
    function SendC(const AData: Currency; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    function SendDT(const AData: TDateTime; const ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    function SendFile(const AFileName: WideString; ATimeOut: Cardinal = IPC_TIMEOUT): Boolean;
    /// <summary>
    /// IPC�ͻ��˴򿪺󴴽��Ŀͻ���ID
    /// </summary>
    property ID: Cardinal read GetID;
    /// <summary>
    /// IPC�Ự����(Ƶ��)���ͻ��˺ͷ����ͨ����������������Ƿ��������
    /// </summary>
    property SessionName: WideString read GetSessionName write SetSessionName;
    /// <summary>
    /// IPC�Ự������ͻ��˺ͷ����ͨ���������������������
    /// </summary>
    property SessionHandle: Cardinal read GetSessionHandle;
    /// <summary>
    /// ��ȡ/���õ�ǰIPC�Ự״̬(��/�رգ��൱�ڵ���Open/Close����)
    /// </summary>
    property Active: Boolean read GetActive write SetActive;
    /// <summary>
    /// ��OnMessage�¼��н�������״̬�Ĵ����Ƿ����һ�������߳���
    /// </summary>
    /// <list type="Boolean">
    /// <item>
    /// <term>False(Ĭ��)</term>
    /// <description>��OnMessage�¼������߳��д�����յ�����</description>
    /// </item>
    /// <item>
    /// <term>True</term>
    /// <description>OnMessage�¼���һ�������߳��д�����յ�����</description>
    /// </item>
    /// </list>
    property ReciveMessageInThread: Boolean read GetReciveMessageInThread write SetReciveMessageInThread;
    /// <summary>
    /// �Ƿ񽫽��ܵ�����Ϣ������Ϣ���У����ΪTrueʱ��OnMessage�¼������ܲ���IsReciveMessage��Ϣ
    /// </summary>
    property ReciveMessageToQueue: Boolean read GetReciveMessageToQueue write SetReciveMessageToQueue;
    /// <summary>
    /// ���ӵ���IPC����˵ķ���ID
    /// </summary>
    property ServerID: Cardinal read GetServerID;
    /// <summary>
    /// ��Ϣ���У����ReciveMessageInQueueΪTrue������յ�����Ϣ������ö����У������ǵ���OnMessage�¼�
    /// </summary>
    property ReciveQueue: PIIPCMessageQueue read GetReciveQueue;
    /// <summary>
    /// IPC�ͻ���״̬��������ݵ��¼�������
    /// </summary>
    property OnMessage: TIPCClientMessageEvent read GetOnMessage write SetOnMessage;
    /// <summary>
    /// �󶨵�IDispatch����IPC��һ�˿���ͨ��Call/CallEx�����������Dispatch�ķ���
    /// <remarks>
    /// ע�⣺��ΪIPCͨ���Ǻܺ�ʱ�ģ��ҿ�����������������벻Ҫ��IPC���õķ��������ܺ�ʱ�Ĳ���
    /// </remarks>
    /// </summary>
    property Dispatch: IDispatch read GetDispatch write SetDispatch;
    /// <summary>
    /// һ����չ�ֶΣ��û����������洢�κ�����
    /// </summary>
    property Tag: Pointer read GetTag write SetTag;
    /// <summary>
    /// ���һ�δ�����Ϣ
    /// </summary>
    property LastError: WideString read GetLastError;
  end;

function CreateIPCServer: IIPCServer; overload;
function CreateIPCServer(const ASessionName: WideString): IIPCServer; overload;
function CreateIPCClient: IIPCClient; overload;
function CreateIPCClient(const ASessionName: WideString): IIPCClient; overload;
function CreateIPCMessage(const ADataType: TIPCMessageDataType = mdtUnknown): IIPCMessage;
function CreateIPCMessageReadOnly(const AData: TMessageData;
  const ADataSize: Cardinal; const ADataType: TIPCMessageDataType): IIPCMessage;
  
implementation

uses
  SYIPCImportDef;

function CreateIPCMessage(const ADataType: TIPCMessageDataType): IIPCMessage;
type
  TCreateIPCMessage = function (const ADataType: TIPCMessageDataType): IIPCMessage;
begin
  Result := TCreateIPCMessage(IPCAPI.Funcs[FuncIdx_CreateIPCMessage])(ADataType);
end;

function CreateIPCMessageReadOnly(const AData: TMessageData;
  const ADataSize: Cardinal; const ADataType: TIPCMessageDataType): IIPCMessage;
type
  TCreateIPCMessageReadOnly = function (const AData: TMessageData;
    const ADataSize: Cardinal; const ADataType: TIPCMessageDataType): IIPCMessage;
begin
  Result := TCreateIPCMessageReadOnly(IPCAPI.Funcs[FuncIdx_CreateIPCMessageReadOnly])
    (AData, ADataSize, ADataType);
end;

function CreateIPCServer: IIPCServer;
type
  TCreateIPCServer = function : IIPCServer;
begin
  Result := TCreateIPCServer(IPCAPI.Funcs[FuncIdx_CreateIPCServer]);
end;

function CreateIPCServer(const ASessionName: WideString): IIPCServer;
begin
  Result := CreateIPCServer;
  Result.SessionName := ASessionName;
end;

function CreateIPCClient: IIPCClient;
type
  TCreateIPCClient = function : IIPCClient;
begin
  Result := TCreateIPCClient(IPCAPI.Funcs[FuncIdx_CreateIPCClient]);
end;

function CreateIPCClient(const ASessionName: WideString): IIPCClient;
begin
  Result := CreateIPCClient;
  Result.SessionName := ASessionName;
end;

end.
