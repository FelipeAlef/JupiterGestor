unit uCompras;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, System.Rtti, FMX.Grid.Style, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors,
  Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid;

type
  TfrmCompras = class(TForm)
    StyleBook1: TStyleBook;
    QrCOmpras: TFDQuery;
    QrCOmprasID: TFDAutoIncField;
    QrCOmprasDATA_COMPRA: TDateTimeField;
    QrCOmprasTOTAL_COMPRA: TFloatField;
    QrCOmprasQUANT_COMPRA: TFloatField;
    StringGrid1: TStringGrid;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    StringGrid2: TStringGrid;
    QrItens: TFDQuery;
    QrItensID: TFDAutoIncField;
    QrItensID_PRODUTO: TIntegerField;
    QrItensID_COMPRA: TIntegerField;
    QrItensDESC_PRODUTO: TStringField;
    QrItensQNT: TFloatField;
    QrItensVALOR: TFloatField;
    QrItensVALOR_TOTAL: TFloatField;
    DataSource1: TDataSource;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCompras: TfrmCompras;

implementation

{$R *.fmx}

uses uPrincipal;

procedure TfrmCompras.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  QrItens.Close;
  QrItens.ParamByName('pID_COMPRA').AsInteger := QrCOmprasID.AsInteger;
  QrItens.Open;
end;

procedure TfrmCompras.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmCompras := Nil;
end;

procedure TfrmCompras.FormCreate(Sender: TObject);
begin
  QrCOmpras.Connection := frmPrincipal.FC;
  QrItens.Connection := frmPrincipal.FC;
  QrCOmpras.Open;
  QrItens.Open;
end;

end.
