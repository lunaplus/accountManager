// 金額入力ボックスの書式変換
function moneyFormat(strarg) {
    var tmpstr = "";
    var str = strarg.split(",").join("");
    for(var i=str.length-1, j=0; i>=0; i--, j++){
        tmpstr = str.charAt(i) + tmpstr;
        if(j % 3 == 2 && i != 0) tmpstr = "," + tmpstr;
    }
    return (tmpstr == "" ? "0" : tmpstr);
}
// 先頭ゼロ消し
function numformat(strarg) {
    var str = strarg;
    while(str.match(/^0[0-9]+/)){
        str = str.substr(1);
    }
    return str;
}

// 金額フォーマット処置
function formatMoneyBlur(target) {
    var str = target.value;
    if(str.match(/[^0-9]+/)){
        alert("数字のみ入力可能です");
        target.focus();
        target.select();
        return false;
    }
    else
　  {
        target.value = numformat(target.value);
        target.value = moneyFormat(target.value);
    }
}
function formatMoneyFocus(target) {
    var str = target.value;
    var tmpstr = str.split(",").join("");
    target.value = tmpstr;
    target.select();
}

// 文字列のバイト長がmaxよりも短ければ真を返します。
function checkByteLength(str, max){
  var count = 0;
  for(var i = 0; i < str.length; i++) {
     if (escape(str.charAt(i)).length < 4) {
        count++;
     }
     else {
        count += 2;
     }
  }
  return (count <= max)
}

// 使用可能文字チェックスクリプト例（長さはフォームのmaxlengthで制御）
function checkCode(target){
    var str =target.value;
    if(str.match( /[^0-9a-zA-Z*-]+/)){
        window.alert("半角英数字、半角アスタリスク(*)、半角ハイフン(-)のみ入力できます");
        target.focus();
        target.select();
        return false;
    }
    target.value = target.value.toUpperCase();
    return true;
}
