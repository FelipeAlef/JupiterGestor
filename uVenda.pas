unit uVenda;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Skia, System.Rtti, FMX.Grid.Style, FMX.ScrollBox,
  FMX.Grid, FMX.Skia, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects,
  FMX.Layouts, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope;

type
  TfrmVenda = class(TForm)
    QrVendas: TFDQuery;
    QrItens: TFDQuery;
    DataSource1: TDataSource;
    lytNovaVenda: TLayout;
    lytTop: TLayout;
    Rectangle2: TRectangle;
    Label1: TLabel;
    btVoltar: TSkSvg;
    SkSvg1: TSkSvg;
    lytBottom: TLayout;
    rctAdicionarProduto: TRectangle;
    Label2: TLabel;
    SkSvg2: TSkSvg;
    rctTotalPedido: TRectangle;
    Label4: TLabel;
    lblTotalPedido: TLabel;
    StringGrid1: TStringGrid;
    QrVendasID: TFDAutoIncField;
    QrVendasDATA_VENDA: TDateTimeField;
    QrVendasTOTAL_VENDA: TFloatField;
    QrVendasQUANT_VENDA: TFloatField;
    QrItensID: TFDAutoIncField;
    QrItensID_VENDA: TIntegerField;
    QrItensID_PRODUTO: TIntegerField;
    QrItensDESC_PRODUTO: TStringField;
    QrItensQNT: TFloatField;
    QrItensVALOR: TFloatField;
    QrItensVALOR_TOTAL: TFloatField;
    StyleBook1: TStyleBook;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure QrItensBeforePost(DataSet: TDataSet);
    procedure btVoltarClick(Sender: TObject);
    procedure SkSvg1Click(Sender: TObject);
    procedure StringGrid1EditingDone(Sender: TObject; const ACol,
      ARow: Integer);
    procedure rctAdicionarProdutoClick(Sender: TObject);
  private
    procedure AdicionarProdutoALista(pID: Integer; pDescricao: String;
      pValorVenda: Double);
    procedure CalcularTotais;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVenda: TfrmVenda;

implementation

{$R *.fmx}

uses uPrincipal, uVendas, uProdutos;

procedure TfrmVenda.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmVenda := Nil;
end;

procedure TfrmVenda.FormCreate(Sender: TObject);
begin
  QrItens.Connection := frmPrincipal.FC;
  QrVendas.Connection := frmPrincipal.FC;
  QrVendas.Open;
  QrItens.Open;
  QrVendas.Append;
  QrVendasDATA_VENDA.AsDateTime := now;
  QrVendasTOTAL_VENDA.AsFloat := 0;
  QrVendasQUANT_VENDA.AsFloat := 0;
  QrVendas.Post;
end;

procedure TfrmVenda.QrItensBeforePost(DataSet: TDataSet);
begin
  if QrItens.State = dsInsert then
    QrItensID_VENDA.AsInteger := QrVendasID.AsInteger;

  QrItensVALOR_TOTAL.ReadOnly := False;
  QrItensVALOR_TOTAL.AsFloat := QrItensQNT.AsFloat * QrItensVALOR.AsFloat;
  QrItensVALOR_TOTAL.ReadOnly := True;
end;

procedure TfrmVenda.rctAdicionarProdutoClick(Sender: TObject);
begin
  if not Assigned(frmProdutos) then
    Application.CreateForm(TfrmProdutos, frmProdutos);

  frmProdutos.FProcSelecProduto := AdicionarProdutoALista;
  frmProdutos.Show;
end;

procedure TfrmVenda.SkSvg1Click(Sender: TObject);
begin
  if not Assigned(frmVendas) then
    Application.CreateForm(TfrmVendas, frmVendas);

  frmVendas.Show;
end;

procedure TfrmVenda.StringGrid1EditingDone(Sender: TObject; const ACol, ARow: Integer);
begin
  CalcularTotais;
end;

procedure TfrmVenda.btVoltarClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmVenda.CalcularTotais;
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

    QrVendas.Edit;
    QrVENDAsTOTAL_VENDA.AsFloat := TotalDaCompra;
    QrVendasQUANT_VENDA.AsFloat := QntDaCompra;
    QrVendas.Post;

    lblTotalPedido.Text := FormatFloat('#,##0.00', TotalDaCompra);
  finally
    QrItens.EnableControls;
  end;

end;

procedure TfrmVenda.AdicionarProdutoALista(pID : Integer; pDescricao: String; pValorVenda: Double);
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
