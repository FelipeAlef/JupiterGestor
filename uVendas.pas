unit uVendas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Grid,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.DateTimeCtrls;

type
  TfrmVendas = class(TForm)
    StyleBook1: TStyleBook;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    QrItens: TFDQuery;
    QrVendas: TFDQuery;
    DataSource1: TDataSource;
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
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    BindSourceDB2: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB2: TLinkGridToDataSource;
    DateEdit1: TDateEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DataSource1DataChange(Sender: TObject; Field: TField);
    procedure FormCreate(Sender: TObject);
    procedure QrVendasBeforeOpen(DataSet: TDataSet);
    procedure DateEdit1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVendas: TfrmVendas;

implementation

{$R *.fmx}

uses uPrincipal;

procedure TfrmVendas.DataSource1DataChange(Sender: TObject; Field: TField);
begin
  QrItens.Close;
  QrItens.ParamByName('pID_VENDA').AsInteger := QrVendasID.AsInteger;
  QrItens.Open;
end;

procedure TfrmVendas.DateEdit1Change(Sender: TObject);
begin
  QrVendas.Close;
  QrVendas.Open;
end;

procedure TfrmVendas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
  frmVendas := Nil;
end;

procedure TfrmVendas.FormCreate(Sender: TObject);
begin
  QrVEndas.Connection := frmPrincipal.FC;
  QrItens.Connection := frmPrincipal.FC;
  QrVEndas.Open;
  QrItens.Open;
end;

procedure TfrmVendas.QrVendasBeforeOpen(DataSet: TDataSet);
begin
  QrVendas.ParamByName('pData').AsString := FormatDateTime('yyyy-mm-dd', DateEdit1.Date);
end;

end.
