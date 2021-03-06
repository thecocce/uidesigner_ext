unit frm_imageconvert;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, fpg_base, fpg_main, fpg_form, fpg_memo, fpg_menu,
  fpg_button, fpg_editbtn, fpg_label;

type

  TImageConvert = class(TfpgForm)
  private
    {@VFD_HEAD_BEGIN: MainForm}
    FilenameEdit1: TfpgFileNameEdit;
    memImages: TfpgMemo;
    Button1: TfpgButton;
    Label1: TfpgLabel;
    btnCopy: TfpgButton;
    btnClear: TfpgButton;
    Button2: TfpgButton;
    {@VFD_HEAD_END: MainForm}
    procedure onclosemain(Sender: TObject; var closeac: Tcloseaction);
    procedure MemoDragEnter(Sender, Source: TObject; AMimeList: TStringList;
      var AMimeChoice: TfpgString; var ADropAction: TfpgDropAction;
      var Accept: boolean);
    procedure MemoDragDrop(Sender, Source: TObject; X, Y: integer; AData: variant);
    function ConvertImage(const AFileName: string): string;
    procedure btnClearClicked(Sender: TObject);
    procedure btnConvertClicked(Sender: TObject);
    procedure btnCopyClicked(Sender: TObject);
    procedure btnQuitClicked(Sender: TObject);
  public
    procedure AfterCreate; override;
  end;

{@VFD_NEWFORM_DECL}

implementation

uses
  fpg_utils;

{@VFD_NEWFORM_IMPL}

procedure TImageConvert.onclosemain(Sender: TObject; var closeac: Tcloseaction);
begin
  closeac := caFree;
end;

procedure TImageConvert.MemoDragEnter(Sender, Source: TObject;
  AMimeList: TStringList; var AMimeChoice: TfpgString;
  var ADropAction: TfpgDropAction; var Accept: boolean);
var
  s: string;
begin
  {TODO: Once Windows DND backend is 100% complete, this IFDEF can be removed.}
  {$IFDEF MSWINDOWS}
  s := 'FileName';
  {$ELSE}
  s := 'text/uri-list';
  {$ENDIF}
  Accept := AMimeList.IndexOf(s) > -1;
  if Accept then
  begin
    if AMimeChoice <> s then
      AMimeChoice := s;
  end;
end;

procedure TImageConvert.MemoDragDrop(Sender, Source: TObject;
  X, Y: integer; AData: variant);
var
  fileName: string;
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;
  try
    sl.Text := AData;
    try
      memImages.BeginUpdate;
      for i := 0 to sl.Count - 1 do
      begin
        fileName := sl[i];
        fileName := StringReplace(fileName, 'file://', '', []);
        memImages.Text := memImages.Text + ConvertImage(fileName);
      end;
    finally
      memImages.EndUpdate;
    end;
  finally
    sl.Free;
  end;
end;

function TImageConvert.ConvertImage(const AFileName: string): string;
const
  Prefix = '     ';
  MaxLineLength = 72;
var
  InStream: TFileStream;
  I, Count: longint;
  b: byte;
  Line, ToAdd: string;
  ConstName: string;

  procedure WriteStr(const St: string);
  begin
    Result := Result + St;
  end;

  procedure WriteStrLn(const St: string);
  begin
    Result := Result + St + LineEnding;
  end;

begin
  InStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    ConstName := 'newimg_' + ChangeFileExt(fpgExtractFileName(AFileName), '');
    WriteStrLn('');
    WriteStrLn('const');

    InStream.Seek(0, soFromBeginning);
    Count := InStream.Size;
    WriteStrLn(Format('  %s: array[0..%d] of byte = (', [ConstName, Count - 1]));
    Line := Prefix;
    for I := 1 to Count do
    begin
      InStream.Read(B, 1);
      ToAdd := Format('%3d', [b]);
      if I < Count then
        ToAdd := ToAdd + ',';
      Line := Line + ToAdd;
      if Length(Line) >= MaxLineLength then
      begin
        WriteStrLn(Line);
        Line := PreFix;
      end;
    end; { for }
    WriteStrln(Line + ');');
    WriteStrLn('');
  finally
    InStream.Free;
  end;
end;

procedure TImageConvert.btnClearClicked(Sender: TObject);
begin
  memImages.Text := '';
end;

procedure TImageConvert.btnConvertClicked(Sender: TObject);
begin
  memImages.BeginUpdate;
  try
    memImages.Text := memImages.Text + ConvertImage(FilenameEdit1.FileName);
  finally
    memImages.EndUpdate;
  end;
end;

procedure TImageConvert.btnCopyClicked(Sender: TObject);
begin
  fpgClipboard.Text := memImages.Text;
end;

procedure TImageConvert.btnquitClicked(Sender: TObject);
begin
  Close;
end;

procedure TImageConvert.AfterCreate;
begin
  {%region 'Auto-generated GUI code' -fold}

  {@VFD_BODY_BEGIN: MainForm}
  Name := 'MainForm';
  SetPosition(441, 156, 700, 378);
  WindowTitle := 'Bitmap Image Conversion into Pascal resource';
  Hint := '';
  ShowHint := True;
  BackGroundColor := $80000001;
  WindowPosition := wpScreenCenter;
  DNDEnabled := True;
  onclose := @onclosemain;

  FilenameEdit1 := TfpgFileNameEdit.Create(self);
  with FilenameEdit1 do
  begin
    Name := 'FilenameEdit1';
    SetPosition(4, 8, 384, 24);
    Anchors := [anLeft,anRight,anTop];
    ExtraHint := '';
    FileName := '';
    Filter := '';
    InitialDir := '';
    TabOrder := 3;
  end;

  memImages := TfpgMemo.Create(self);
  with memImages do
  begin
    Name := 'memImages';
    SetPosition(4, 56, 692, 318);
    Anchors := [anLeft,anRight,anTop,anBottom];
    FontDesc := '#Edit2';
    Hint := '';
    TabOrder := 5;
    AcceptDrops := True;
    OnDragEnter := @MemoDragEnter;
    OnDragDrop := @MemoDragDrop;
  end;

  Button1 := TfpgButton.Create(self);
  with Button1 do
  begin
    Name := 'Button1';
    SetPosition(396, 8, 64, 24);
    Anchors := [anRight,anTop];
    FontDesc := '#Label1';
    GroupIndex := 1;
    Hint := 'Conver bitmap image into Pascal resource';
    ImageName := '';
    TabOrder := 4;
    Text := 'Convert';
    AllowDown := True;
    OnClick := @btnConvertClicked;
  end;

  Label1 := TfpgLabel.Create(self);
  with Label1 do
  begin
    Name := 'Label1';
    SetPosition(4, 36, 315, 16);
    FontDesc := '#Label1';
    Hint := '';
    Text := 'Drop one or more images on the text area below:';
  end;

  btnCopy := TfpgButton.Create(self);
  with btnCopy do
  begin
    Name := 'btnCopy';
    SetPosition(464, 8, 70, 24);
    Anchors := [anRight,anTop];
    FontDesc := '#Label1';
    GroupIndex := 1;
    Hint := 'Copy to clipboard';
    ImageName := 'stdimg.copy';
    TabOrder := 8;
    Text := 'Copy';
    AllowDown := True;
    OnClick := @btnCopyClicked;
  end;

  btnClear := TfpgButton.Create(self);
  with btnClear do
  begin
    Name := 'btnClear';
    SetPosition(540, 8, 60, 24);
    Anchors := [anRight,anTop];
    FontDesc := '#Label1';
    GroupIndex := 1;
    Hint := 'Clear text box';
    ImageName := '';
    TabOrder := 6;
    Text := 'Clear';
    AllowDown := True;
    OnClick := @btnClearClicked;
  end;

  Button2 := TfpgButton.Create(self);
  with Button2 do
  begin
    Name := 'Button2';
    SetPosition(636, 8, 60, 24);
    Anchors := [anRight,anTop];
    FontDesc := '#Label1';
    GroupIndex := 1;
    Hint := 'Close Image Convertor';
    ImageName := 'stdimg.close';
    TabOrder := 7;
    Text := 'Quit';
    AllowDown := True;
    OnClick := @btnquitClicked;
  end;

  {@VFD_BODY_END: MainForm}

  {%endregion}
end;


end.
