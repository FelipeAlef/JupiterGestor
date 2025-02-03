unit uPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Skia,
  FMX.Skia, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListBox,
  FMX.Layouts, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, System.IOUtils;

type
  TfrmPrincipal = class(TForm)
    lytBase: TLayout;
    lytTop: TLayout;
    lytClient: TLayout;
    rctFundo: TRectangle;
    lbMenu: TListBox;
    ListBoxItemLojas: TListBoxItem;
    rctProdutos: TRectangle;
    lytProdutos: TLayout;
    lblProdutos: TLabel;
    lblQntLoja: TLabel;
    SkSvg2: TSkSvg;
    ListBoxItemProdutos: TListBoxItem;
    rctCompras: TRectangle;
    lytPlanejamento: TLayout;
    lblCompras: TLabel;
    lblQntProdutos: TLabel;
    SkSvg1: TSkSvg;
    ListBoxItemSync: TListBoxItem;
    rctSync: TRectangle;
    lytSync: TLayout;
    lblSync: TLabel;
    lblQntSync: TLabel;
    pthSync: FMX.Objects.TPath;
    StyleBook1: TStyleBook;
    ListBoxItemClientes: TListBoxItem;
    rctVendas: TRectangle;
    lytAulas: TLayout;
    lblClientes: TLabel;
    lblQntClientes: TLabel;
    pthClientes: FMX.Objects.TPath;
    SkAnimatedImage1: TSkAnimatedImage;
    FC: TFDConnection;
    QrDeleteZerados: TFDQuery;
    procedure rctProdutosClick(Sender: TObject);
    procedure rctComprasClick(Sender: TObject);
    procedure rctVendasClick(Sender: TObject);
    procedure FCBeforeConnect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

uses uProdutos, uCompra, uVenda;

procedure TfrmPrincipal.FCBeforeConnect(Sender: TObject);
begin
  {$IFDEF ANDROID}
    FC.Params.Database := TPath.Combine(TPath.GetDocumentsPath, 'JupiterDB.db3');
  {$ENDIF}
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  FC.Connected := True;
end;

procedure TfrmPrincipal.rctComprasClick(Sender: TObject);
begin
  QrDeleteZerados.ExecSQL;
  if not Assigned(frmCompra) then
    Application.CreateForm(TfrmCompra, frmCompra);

  frmCompra.Show;
end;

procedure TfrmPrincipal.rctProdutosClick(Sender: TObject);
begin
  QrDeleteZerados.ExecSQL;
  if not Assigned(frmProdutos) then
    Application.CreateForm(TfrmProdutos, frmProdutos);

  frmProdutos.Show;
end;

procedure TfrmPrincipal.rctVendasClick(Sender: TObject);
begin
  QrDeleteZerados.ExecSQL;
  if not Assigned(frmVenda) then
    Application.CreateForm(TfrmVenda, frmVenda);

  frmVenda.Show;
end;

end.
