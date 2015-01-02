{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit zmsql;

interface

uses
  janSQL, janSQLExpression2, janSQLStrings, janSQLTokenizer, mwStringHashList, 
  ZMConnection, ZMQueryDataSet, ZMReferentialKey, zmbufdataset_parser, 
  LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ZMConnection', @ZMConnection.Register);
  RegisterUnit('ZMQueryDataSet', @ZMQueryDataSet.Register);
  RegisterUnit('ZMReferentialKey', @ZMReferentialKey.Register);
end;

initialization
  RegisterPackage('zmsql', @Register);
end.
