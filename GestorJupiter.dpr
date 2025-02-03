program GestorJupiter;

uses
  System.StartUpCopy,
  FMX.Forms,
  FMX.Skia,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uProdutos in 'uProdutos.pas' {frmProdutos},
  uCompra in 'uCompra.pas' {frmCompra},
  uCompras in 'uCompras.pas' {frmCompras},
  uVenda in 'uVenda.pas' {frmVenda},
  uVendas in 'uVendas.pas' {frmVendas};

{$R *.res}

begin
  GlobalUseSkia := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
