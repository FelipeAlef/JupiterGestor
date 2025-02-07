unit uUtils;

interface

uses
  FMX.Forms, FMX.Layouts, System.Classes,
  System.JSON, FireDAC.Comp.Client, System.IOUtils, System.SysUtils,
  System.IniFiles, FMX.SearchBox,

  {$IFDEF MSWINDOWS}
    FireDAC.DApt,
    FireDAC.Stan.Async,
  {$ENDIF}

  {$IFDEF ANDROID} AndroidApi.Helpers,FMX.VirtualKeyboard,Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Telephony,
  Androidapi.JNI.Provider,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os,
  Androidapi.jni.App,
  Androidapi.JNI.Net,
  System.NetEncoding, {$ENDIF}

  FMX.ListView.Types, FMX.TextLayout, System.Types,
  FMX.ListView, FMX.Platform, System.UITypes, FMX.Types;

type
  TUtils = class
  private
    { private declarations }
  public
    { public declarations }
    class procedure MudarCorBarraNotificacao(pCor:Cardinal);
    class procedure MudarCorBarraNavegacao(pCor:Cardinal);
    class function GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
    class function FormataNome(Value:String):String;
    class function StrZero(const strvalor: string;const intComprimento: integer): string;
    class function TestarInteiro(Str:String):boolean;
    class function TestarDouble(Str:String):boolean;
    class procedure AddLog(Caminho:String;Log:String);
    class procedure ListViewSearch(Sender: TObject; Pesquisa : String);
    class function Mask(Mascara, Str: string): string;

    class function GetConexaoSQLite(Banco:String): TFDConnection;

    //Funcoes somente do SQL Server...
    class function GetConexao: TFDConnection;
    class function ExecCommandQuery(const pCommand: string; const pArgs: array of const): Boolean;
    class function GetCountQuery(const pCommand: string; const pArgs: array of const): Integer;
    class function GetQuery(FC:TFDConnection): TFDQuery;
    class function GetValueQuery(const pCommand : string; pArgs : array of const) : Variant;
    //Fim de funcoes somente do SQL Server...

    class function KeyVoltarAndroid(Key:Word):Boolean;
    class procedure FecharTecladoVirtualAndroid;
    class function TecladoVirtualAndroidVisible:Boolean;
    class procedure OpenURL(const URL: string);

    class function ApplicationLocation:String;
    class function LimparLetras(Str: String): String;
    class function LimparNumeros(Str: String): String;
    class procedure GravaINI(Secao, Identificacao, Valor: String);
    class function LerINI(Secao, Identificacao: String; RetDefaut:String=''): String;
  end;

implementation

class function TUtils.LimparNumeros(Str: String): String;
var
  i : integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  if Str[i] in ['A'..'Z'] then
  Result := Result + Str[i];
end;


class function TUtils.LimparLetras(Str: String): String;
var
  i : integer;
begin
  Result := '';
  for i := 1 to Length(Str) do
  if Str[i] in ['0'..'9'] then
    Result := Result + Str[i];
end;

class function TUtils.LerINI(Secao, Identificacao: String; RetDefaut:String=''):String;
var loIniFIle : TInifile;
begin
  if FileExists(GetCurrentDir + '\Config.ini') then
  begin
    loIniFIle := TInifile.Create(GetCurrentDir + '\Config.ini');
    result := loIniFile.ReadString(Secao,Identificacao, RetDefaut);
    loIniFile.Free;
  end;
end;

class procedure TUtils.GravaINI(Secao, Identificacao, Valor: String);
var loIniFIle : TInifile;
begin
  loIniFIle := tIniFile.Create(GetCurrentDir + '\Config.ini');
  loIniFile.WriteString(Secao, Identificacao, Valor);
  loIniFile.Free;
end;

class function TUtils.Mask(Mascara, Str : string) : string;
var
  x, p : integer;
begin
  p := 0;
  Result := '';

  if Str.IsEmpty then
      exit;

  for x := 0 to Length(Mascara) - 1 do
  begin
    if Mascara.Chars[x] = '#' then
    begin
      Result := Result + Str.Chars[p];
      inc(p);
    end
    else
      Result := Result + Mascara.Chars[x];

    if p = Length(Str) then
      break;
  end;
end;

class procedure TUtils.MudarCorBarraNavegacao(pCor: Cardinal);
begin
  {$IFDEF ANDROID}
    TAndroidHelper.Activity.getWindow.setNavigationBarColor(pCor);
  {$ENDIF}
end;

class procedure TUtils.MudarCorBarraNotificacao(pCor: Cardinal);
begin
  {$IFDEF ANDROID}
    TAndroidHelper.Activity.getWindow.setStatusBarColor(pCor);
  {$ENDIF}
end;

class procedure TUtils.ListViewSearch(Sender: TObject; Pesquisa : String);
var
  I: Integer;
  SearchBox: TSearchBox;
  List: TListView;
begin

  List := Sender as TListView;
  List.SearchVisible := True;
  for I := 0 to List.Controls.Count-1 do
    if List.Controls[I].ClassType = TSearchBox then
    begin
      SearchBox := TSearchBox(List.Controls[I]);
      Break;
    end;

  SearchBox.Text := Pesquisa;
  List.SearchVisible := False;
end;

class function TUtils.GetConexaoSQLite(Banco:String): TFDConnection;
const
  DSS = 'C:\Projetos\Konquisti\DSS\Projetos\Fontes\Pedidos\Fontes novos\Android\Win32\Debug\DSS.db3';
begin
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;

  with Result.Params do
  begin
    DriverID := 'SQLite';
    Values['LockingMode'] := 'Normal';

    {$IFDEF MSWINDOWS}
      Database := DSS;
    {$ELSE}
      Database := TPath.Combine(TPath.GetDocumentsPath, Banco + '.db3');
    {$ENDIF}
  end;
end;

class procedure TUtils.AddLog(Caminho:String;Log:String);
var
  S : TStringList;
begin
  try
    S := TStringList.Create;

    try
      if FileExists(Caminho) then
        S.LoadFromFile(Caminho);

      S.Add(DateTimeToStr(now) + ' - ' + LOG);
    except
      on e: exception do
        S.Add(DateTimeToStr(now) + ' - Erro ao tentar adicionar log: ' + E.Message);
    end;
  finally
    S.SaveToFile(Caminho);
    S.DisposeOf;
  end;
end;

class function TUtils.StrZero(const strvalor: string;const intComprimento: integer): string;
var
  strZeros, strRetorno: string;
  intTamanho,intContador : Integer;
begin
  inttamanho := Length(Trim(strValor));
  strZeros := '';
  for intContador := 1 to intComprimento do
  strZeros:= strZeros + '0';
  strRetorno:= Copy(Trim(strZeros)+Trim(strValor),intTamanho+1,intComprimento);
  Result:= strRetorno;
end;

class function TUtils.TestarDouble(Str: String): boolean;
var
  D : Double;
begin
  try
    D := Str.ToDouble;
    Result := True;
  except
    Result := False;
  end;
end;

class function TUtils.TestarInteiro(Str: String): boolean;
var
  I : Integer;
begin
  try
    I := Str.ToInteger;
    Result := True;
  except
    Result := False;
  end;
end;

class function TUtils.GetConexao: TFDConnection;
var
  FBanco, FUsuario, FSenha, FHost : String;

  procedure LoadConfig;
  var loIniFIle : TInifile;
  begin
    if FileExists(GetCurrentDir + '\Config.ini') then
    begin
      loIniFIle := TInifile.Create(GetCurrentDir + '\Config.ini');
      FBanco    := loIniFile.ReadString('Banco','Banco', '');
      FUsuario  := loIniFile.ReadString('Banco','Usuario', '');
      FSenha    := loIniFile.ReadString('Banco','Senha', '');
      FHost     := loIniFile.ReadString('Banco','Host', '');
      loIniFile.Free;
    end;
  end;

begin
  LoadConfig;
  Result := TFDConnection.Create(nil);
  Result.LoginPrompt := False;

  with Result.Params do
  begin
    DriverID := 'MSSQL';
    Database := FBanco;
    username := FUsuario;
    Password := FSenha;
    Values['Server'] := FHost;
  end;
end;

class function TUtils.GetQuery(FC:TFDConnection): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FC;
  Result.Close;
  Result.SQL.Clear;
end;

class function TUtils.ApplicationLocation: String;
begin
  Result := GetCurrentDir;
end;

class function TUtils.ExecCommandQuery(const pCommand: string; const pArgs: array of const): Boolean;
var
  qryTemp : TFDQuery;
  FC : TFDConnection;
begin
  try
    try
      FC := GetConexao;
      qryTemp := GetQuery(FC);
      Result := (QryTemp.ExecSQL(Format(pCommand, pArgs)) > 0);
    except
      on E : Exception do
        raise Exception.Create('Erro no metodo ExecCommandQuery.' + sLineBreak + E.Message);
    end;
  finally
    FreeAndNil(qryTemp);
    FreeAndNil(FC);
  end;
end;

class function TUtils.GetCountQuery(const pCommand: string; const pArgs: array of const):Integer;
var
  Qr :TFDQuery;
  FC :TFDConnection;
begin
  try
    try
      Result := 0;
      FC := GetConexao;
      Qr := GetQuery(FC);
      Qr.Open(Format(pCommand, pArgs));
      Result := Qr.Fields.Fields[0].AsInteger;
    except
      on E : Exception do
        raise Exception.Create('Erro no metodo GetCountQuery.' + sLineBreak + E.Message);
    end;
  finally
    FreeAndNil(Qr);
    FreeAndNil(FC);
  end;
end;

class function TUtils.FormataNome(Value: String): String;
const
  excecao: array[0..5] of string = (' da ', ' de ', ' do ', ' das ', ' dos ', ' e ');
var
  tamanho, j: integer;
  i: byte;
begin
  Result := AnsiLowerCase(Value);
  tamanho := Length(Result);

  for j := 1 to tamanho do
    // Se é a primeira letra ou se o caracter anterior é um espaço
    if (j = 1) or ((j>1) and (Result[j-1]=Chr(32))) then
      Result[j] := AnsiUpperCase(Result[j])[1];

  for i := 0 to Length(excecao) -1 do
    Result := StringReplace(Result,excecao[i],excecao[i],[rfReplaceAll, rfIgnoreCase]);
end;

class function TUtils.GetTextHeight(const D: TListItemText; const Width: single; const Text: string): Integer;
var
  Layout: TTextLayout;
begin
  // Create a TTextLayout to measure text dimensions
  Layout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    Layout.BeginUpdate;
    try
      // Initialize layout parameters with those of the drawable
      Layout.Font.Assign(D.Font);
      Layout.VerticalAlign := D.TextVertAlign;
      Layout.HorizontalAlign := D.TextAlign;
      Layout.WordWrap := D.WordWrap;
      Layout.Trimming := D.Trimming;
      Layout.MaxSize := TPointF.Create(Width, TTextLayout.MaxLayoutSize.Y);
      Layout.Text := Text;
    finally
      Layout.EndUpdate;
    end;
    // Get layout height
    Result := Round(Layout.Height);
    // Add one em to the height
    Layout.Text := 'm';
    Result := Result + Round(Layout.Height);
  finally
    Layout.Free;
  end;
end;

class function TUtils.GetValueQuery(const pCommand: string; pArgs: array of const): Variant;
var
  FC : TFDConnection;
  Qr : TFDQuery;
begin
  try
    try
      FC := GetConexao;
      Qr := GetQuery(FC);
      Qr.Open(Format(pCommand, pArgs));
      Result := Qr.Fields[0].Value;
    except
      on E : Exception do
        raise Exception.Create('Erro no metodo GetValueQuery.' + sLineBreak + E.Message);
    end;
  finally
    FC.connected := False;
    FreeAndNil(Qr);
    FreeAndNil(FC);
  end;
end;

class function TUtils.KeyVoltarAndroid(Key: Word): Boolean;
{$IFDEF ANDROID}
var
  FService : IFMXVirtualKeyboardService;
{$ENDIF}
begin
{$IFDEF ANDROID}
  if (Key = vkHardwareBack) then
  begin
    TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService, IInterface(FService));

    if (FService <> nil) and (TVirtualKeyboardState.Visible in FService.VirtualKeyBoardState) then
    begin
      // Botao back pressionado e teclado visivel...
      // (apenas fecha o teclado)
    end
    else
    begin
      Result := True;
    end;
  end;
{$ENDIF}
end;

class procedure TUtils.FecharTecladoVirtualAndroid;
{$IFDEF ANDROID}
var
  FService: IFMXVirtualKeyboardService;
{$ENDIF}
begin
{$IFDEF ANDROID}
  // Esconde o teclado virtual...
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
                                                    IInterface(FService));
  if (FService <> nil) then
  begin
    FService.HideVirtualKeyboard;
  end;

  FService := nil;
{$ENDIF}
end;

class function TUtils.TecladoVirtualAndroidVisible:Boolean;
{$IFDEF ANDROID}
var
  FService: IFMXVirtualKeyboardService;
{$ENDIF}
begin
{$IFDEF ANDROID}
  TPlatformServices.Current.SupportsPlatformService(IFMXVirtualKeyboardService,
                                                    IInterface(FService));
  Result := (FService <> nil);
  FService := nil;
{$ENDIF}
end;

class procedure TUtils.OpenURL(const URL: string);
{$IFDEF ANDROID}
var
  LIntent: JIntent;
  Data: Jnet_Uri;
{$ENDIF}
begin
{$IFDEF ANDROID}
    LIntent := TJIntent.Create;
    Data := TJnet_Uri.JavaClass.parse(StringToJString(URL));
    LIntent.setData(Data);
    LIntent.setAction(StringToJString('android.intent.action.VIEW'));
    TAndroidHelper.Activity.startActivity(LIntent);
{$ENDIF}
end;

end.
