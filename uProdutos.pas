unit uProdutos;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  FMX.Objects, FMX.TabControl, uPrincipal, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, FMX.Edit;

type
  TProcSelecProduto = procedure (pID : Integer; pDescricao: String; pValorVenda: Double) of object;

  TfrmProdutos = class(TForm)
    StyleBook1: TStyleBook;
    TabControl1: TTabControl;
    TabLista: TTabItem;
    TabDados: TTabItem;
    ListView1: TListView;
    rctProdutos: TRectangle;
    lblProdutos: TLabel;
    lblQntLoja: TLabel;
    QrProdutos: TFDQuery;
    QrProdutosID: TFDAutoIncField;
    QrProdutosDESCRICAO: TStringField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    edtDesc: TEdit;
    Label1: TLabel;
    edtCompra: TEdit;
    Label2: TLabel;
    edtVenda: TEdit;
    Label3: TLabel;
    Rectangle1: TRectangle;
    Label4: TLabel;
    Label5: TLabel;
    QrProdutosVENDA: TCurrencyField;
    QrProdutosCOMPRA: TCurrencyField;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rctProdutosClick(Sender: TObject);
    procedure Rectangle1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
  private
    { Private declarations }
  public
    { Public declarations }
    FProcSelecProduto : TProcSelecProduto;
  end;

var
  frmProdutos: TfrmProdutos;

implementation

{$R *.fmx}

procedure TfrmProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmProdutos := Nil;
end;

procedure TfrmProdutos.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  case TabControl1.TabIndex of
    1:
    begin
      if QrProdutos.State in [dsInsert, dsEdit] then
        QrProdutos.Cancel;

      CanClose := False;
      TabControl1.GotoVisibleTab(0);
    end;
  end;
end;

procedure TfrmProdutos.FormCreate(Sender: TObject);
begin
  TabControl1.TabIndex := 0;
  QrProdutos.Connection := frmPrincipal.FC;
  QrProdutos.Open;
end;

procedure TfrmProdutos.ListView1ItemClick(const Sender: TObject; const AItem: TListViewItem);
begin
  if Assigned(FProcSelecProduto) then
  begin
    FProcSelecProduto(QrProdutosID.AsInteger, QrProdutosDESCRICAO.AsString, QrProdutosCOMPRA.AsFloat);
    Close;
  end
  else
  begin
    QrProdutos.Edit;
    edtDesc.Text := QrProdutosDESCRICAO.AsString;
    edtCompra.Text := FormatFloat('#,##0.00', QrProdutosCOMPRA.AsFloat);
    edtVenda.Text :=  FormatFloat('#,##0.00', QrProdutosVENDA.AsFloat);
    TabControl1.GotoVisibleTab(1);
  end;
end;

procedure TfrmProdutos.rctProdutosClick(Sender: TObject);
begin
  QrProdutos.Append;
  QrProdutosCOMPRA.Value := 0;
  edtCompra.Text := '0,00';
  TabControl1.GotoVisibleTab(1);
end;

procedure TfrmProdutos.Rectangle1Click(Sender: TObject);
begin
  if Trim(edtDesc.Text).IsEmpty then
  begin
    ShowMessage('Descrição em branco');
    exit;
  end;

  var I : Extended;

  if not TryStrToFloat(edtVenda.Text, I) then
  begin
    ShowMessage('Valor de venda é inválido');
    exit;
  end;

  QrProdutosDESCRICAO.AsString := edtDesc.Text;
  QrProdutosVENDA.Value := edtVenda.Text.ToDouble;
  QrProdutos.Post;
  TabControl1.GotoVisibleTab(0);
end;

end.
