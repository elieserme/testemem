unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, memds, db, Forms, Controls, Graphics, Dialogs, DBGrids,
  DBCtrls, StdCtrls, fpjson, jsonparser, fphttpclient, base64;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DataSource: TDataSource;
    DBGrid1: TDBGrid;
    DBNavigator1: TDBNavigator;
    Edit1: TEdit;
    Label1: TLabel;
    MemDataset: TMemDataset;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    procedure OpenData;
  public

  end;

var
  Form1: TForm1;

const
  endpoint = 'https://adm.decisao.net';
  table = 'users';
  username = 'admin@gmail.com';
  password = 'admin';

implementation

{$R *.lfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenData;
end;

procedure TForm1.OpenData;
var
  httpcli: TFPHTTPClient;
  Jraw, Jenv, Jrec, Jpag: TJSONData;
  records: TJSONArray;
  recdata: TJSONEnum;
  one_rec: TJSONObject;
begin
  { abro o DataSet }
  MemDataset.Active := True;
  Memo1.Lines.Clear;
  Memo2.Lines.Clear;
  Memo3.Lines.Clear;
  Memo4.Lines.Clear;

  { leio os registros }
  httpcli := TFPHTTPClient.Create(Self);
  httpcli.AddHeader('Authorization', 'Basic '+EncodeStringBase64(username+':'+password));
  httpcli.AddHeader('Accept', 'application/json');
  try

    Jraw := GetJSON(httpcli.Get(endpoint+'/'+table));
    Jenv := GetJSON(Jraw.FindPath('_embedded').AsJSON);
    Jrec := GetJSON(Jenv.FindPath(table).AsJSON);
    Jpag := GetJSON(Jraw.FindPath('page').AsJSON);

    { debug }
    Edit1.Caption := Jpag.FindPath('totalElements').AsString;
    Memo1.Lines.Add(Jraw.AsJSON);
    Memo2.Lines.Add(Jenv.AsJSON);
    Memo3.Lines.Add(Jrec.AsJSON);
    Memo4.Lines.Add(Jpag.AsJSON);

    { leio cada registro }
    records := TJSONArray(Jrec);
    for recdata in records do
    begin
      one_rec := TJSONObject(recdata.Value);
      MemDataset.AppendRecord([
        one_rec.FindPath('name').AsString,
        one_rec.FindPath('email').AsString,
        one_rec.FindPath('password').AsString]);;
    end;
  except
    on e: exception do
    begin
      Memo1.Lines.Text := e.message;
    end;
  end;

end;

end.

