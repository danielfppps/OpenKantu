{ This file was automatically created by Typhon. Do not edit!
  This source is only used to compile and install the package.
 }

unit zmsql;

interface

uses
  AllzmsqlRegister, janSQL, janSQLExpression2, janSQLStrings, janSQLTokenizer, 
  mwStringHashList, ZMBufDataset, ZMConnection, ZMQueryDataSet, 
  ZMReferentialKey, ZMBufDataset_parser, QBDBFrm2, QBuilder, QBDirFrm, 
  QBAbout, QBLnkFrm, QBDBFrm, QBEZmsql, ZMQueryBuilder, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('AllzmsqlRegister', @AllzmsqlRegister.Register);
end;

initialization
  RegisterPackage('zmsql', @Register);
end.
