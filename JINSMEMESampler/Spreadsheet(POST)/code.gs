/**
 * Post API
 * @return json object
 */
function doPost(e) {
  
  if(!e) return;
  
  var paramStr = e.parameters.csv;
  paramStr = String(paramStr);
  
  // debug
  //var paramStr = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p\na,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p";
  
  var targetSs = getFirstMatchedSpreadSheet('JINSMEMESampler_spreadsheet');
  var targetSheet = targetSs.getSheetByName('シート1');

  if(!targetSheet) return;
  
  // First row must be parameter names
  var memeDataRng = targetSheet.getDataRange();
  var memeDataVals = memeDataRng.getValues();
  if(!memeDataVals || memeDataVals.length < 1){
    return;
  }
  
  // Make data array[][] to plot spreadsheet range
  var result = {};
  
  var dataVals = [];
  var dataLines = paramStr.split('\n');
  dataLines.forEach(function(element, index, array) {
    var aLine = element.split(',');
    dataVals.push(aLine);
  });

  memeDataRng.offset(memeDataRng.getNumRows(),0,dataLines.length).setValues(dataVals);  // Append data after last data line

  result['dataNum'] = dataLines.length;
  result['result'] = true;
  
  return ContentService.createTextOutput(JSON.stringify(result))
    .setMimeType(ContentService.MimeType.JSON);
}

/**
 * Driveの中から最初に見つかった、targetFileNameのスプレッドシートを取得する
 * @return SpreadSheet 
 */
function getFirstMatchedSpreadSheet(targetFileName)
{
  var resFile = null;
  
  var files = DriveApp.getFilesByName(targetFileName);
  while (files.hasNext()) {
    var file = files.next();
    if(file.getMimeType().indexOf('spreadsheet') != -1){
      resFile = file;
      break;
    }
  }
  return SpreadsheetApp.open(resFile);  //.getSheets()[0];
}

