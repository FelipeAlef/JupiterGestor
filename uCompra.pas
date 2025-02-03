unit uCompra;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Objects, FMX.ListView, FMX.Skia, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Rtti, FMX.Grid.Style, FMX.ScrollBox, FMX.Grid,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope;

type
  TfrmCompra = class(TForm)
    lytNovoPedidos: TLayout;
    lytTop: TLayout;
    Rectangle2: TRectangle;
    Label1: TLabel;
    btVoltar: TSkSvg;
    lytBottom: TLayout;
    rctAdicionarProduto: TRectangle;
    Label2: TLabel;
    SkSvg2: TSkSvg;
    StyleBook1: TStyleBook;
    rctTotalPedido: TRectangle;
    Label4: TLabel;
    lblTotalPedido: TLabel;
    QrCompra: TFDQuery;
    QrItens: TFDQuery;
    QrCompraID: TFDAutoIncField;
    QrCompraDATA_COMPRA: TDateTimeField;
    QrCompraQUANT_COMPRA: TFloatField;
    QrItensID: TFDAutoIncField;
    QrItensID_PRODUTO: TIntegerField;
    QrItensQNT: TFloatField;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    QrItensDESC_PRODUTO: TStringField;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    DataSource1: TDataSource;
    QrItensID_COMPRA: TIntegerField;
    QrCompraTOTAL_COMPRA: TFloatField;
    QrItensVALOR: TFloatField;
    QrItensVALOR_TOTAL: TFloatField;
    SkSvg1: TSkSvg;
    procedure rctAdicionarProdutoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btVoltarClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StringGrid1EditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure QrItensVALORSetText(Sender: TField; const Text: string);
    procedure QrItensBeforePost(DataSet: TDataSet);
    procedure SkSvg1Click(Sender: TObject);
  private
    procedure AdicionarProdutoALista(pID: Integer; pDescricao: String; pValorVenda: Double);
    procedure CalcularTotais;
    procedure AtualizarValorCompraDosProdutos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCompra: TfrmCompra;

implementation

{$R *.fmx}

uses uProdutos, uPrincipal, uCompras;

procedure TfrmCompra.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmCompra := Nil;
end;

procedure TfrmCompra.FormCreate(Sender: TObject);
begin
  QrItens.Connection := frmPrincipal.FC;
  QrCompra.Connection := frmPrincipal.FC;
  QrCompra.Open;
  QrItens.Open;
  QrCompra.Append;
  QrCompraDATA_COMPRA.AsDateTime := now;
  QrCompraTOTAL_COMPRA.AsFloat := 0;
  QrCompraQUANT_COMPRA.AsFloat := 0;
  QrCompra.Post;
end;

procedure TfrmCompra.QrItensBeforePost(DataSet: TDataSet);
begin
  if QrItens.State = dsInsert then
    QrItensID_COMPRA.AsInteger := QrCompraID.AsInteger;

  QrItensVALOR_TOTAL.ReadOnly := False;
  QrItensVALOR_TOTAL.AsFloat := QrItensQNT.AsFloat * QrItensVALOR.AsFloat;
  QrItensVALOR_TOTAL.ReadOnly := True;
end;

procedure TfrmCompra.QrItensVALORSetText(Sender: TField; const Text: string);
var
  FormattedValue: Double;
begin
  // Substituir vírgula por ponto antes de salvar
  if TryStrToFloat(StringReplace(Text, ',', '.', [rfReplaceAll]), FormattedValue) then
    Sender.AsFloat := FormattedValue
  else
    raise Exception.Create('Valor inválido para o campo "Preço".');
end;

procedure TfrmCompra.rctAdicionarProdutoClick(Sender: TObject);
begin
  if not Assigned(frmProdutos) then
    Application.CreateForm(TfrmProdutos, frmProdutos);

  frmProdutos.FProcSelecProduto := AdicionarProdutoALista;
  frmProdutos.Show;
end;

procedure TfrmCompra.AtualizarValorCompraDosProdutos;
const
  SQLUpdate = 'UPDATE Produtos SET Compra = :pCompra WHERE ID = :pID';
var
  Qr : TFDQuery;
begin
  try
    Qr := TFDQuery.Create(nil);
    Qr.Connection := frmPrincipal.FC;

    try
      QrItens.DisableControls;
      QrItens.First;

      while not QrItens.Eof do
      begin
        Qr.ExecSQL(SQLUpdate, [QrItensVALOR.AsFloat, QrItensID_PRODUTO.AsFloat]);
        QrItens.Next;
      end;

    finally
      QrItens.EnableControls;
    end;


  finally
    Qr.DisposeOf;
  end;
end;

procedure TfrmCompra.btVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCompra.SkSvg1Click(Sender: TObject);
begin
  if not Assigned(frmCompras) then
    Application.CreateForm(TfrmCompras, frmCompras);

  frmCompras.Show;
end;

procedure TfrmCompra.StringGrid1EditingDone(Sender: TObject; const ACol, ARow: Integer);
begin
  CalcularTotais;
end;

procedure TfrmCompra.CalcularTotais;
var
  TotalDaCompra : Double;
  QntDaCompra : Double;
begin
  TotalDaCompra := 0;
  QntDaCompra := 0;

  try
//    if QrItens.State in [dsInsert, dsEdit] then
//      QrItens.Post;

    QrItens.DisableControls;
    QrItens.First;

    while not QrItens.Eof do
    begin
      TotalDaCompra := TotalDaCompra + QrItensVALOR_TOTAL.AsFloat;
      QntDaCompra := QntDaCompra + QrItensQNT.AsFloat;
      QrItens.Next;
    end;

    QrCompra.Edit;
    QrCompraTOTAL_COMPRA.AsFloat := TotalDaCompra;
    QrCompraQUANT_COMPRA.AsFloat := QntDaCompra;
    QrCompra.Post;

    lblTotalPedido.Text := FormatFloat('#,##0.00', TotalDaCompra);
    AtualizarValorCompraDosProdutos;
  finally
    QrItens.EnableControls;
  end;

end;

procedure TfrmCompra.AdicionarProdutoALista(pID : Integer; pDescricao: String; pValorVenda: Double);
begin
  with QrItens do
  begin
    if Locate('ID_PRODUTO', pID) then
    begin
      ShowMessage('Produto já adicionado na lista');
      exit;
    end;

    Append;
    QrItensID_PRODUTO.AsInteger := pID;
    QrItensQNT.AsFloat := 1;
    QrItensDESC_PRODUTO.AsString := pDescricao;
    QrItensVALOR.AsFloat := pValorVenda;
    Post;
    CalcularTotais;
  end;
end;

end.
