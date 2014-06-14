# encoding: utf-8
# Input Controller
require_relative '../util/HtmlUtil'
require_relative '../model/MstMnt'
require_relative '../model/DisbursementAccount'
require_relative '../model/DetailItemDTO'

class InputController
  def update session,args
    # 入力値の取得
    dto = DetailItemDTO.new
    dto.inputDate = HtmlUtil.getToday
    # 日付
    inputYear = args[0]["yearsel"][0].to_i
    inputMonth = args[0]["monthsel"][0].to_i
    inputDay = args[0]["datesel"][0].to_i
    dto.occurDate = HtmlUtil.createDate inputYear,inputMonth,inputDay
    # 科目
    dto.itemKinds = args[0]["itemkindssel"][0]
    # 金額
    dto.disbursement = args[0]["disbursement"][0].gsub(/,/,'').to_i
    # 備考
    dto.description = args[0]["description"][0]
    # 口座from
    dto.accountFrom = args[0]["accountsfromsel"][0]
    session[HtmlUtil::TEMPINPUTFROM] = dto.accountFrom
    # 口座to
    dto.accountTo = args[0]["accountstosel"][0]
    session[HtmlUtil::TEMPINPUTTO] = dto.accountTo

    # 収支記録テーブルへの登録
    errStr = DisbursementAccount.insertItem dto
    unless errStr == ""
      session[HtmlUtil::TEMPINPUTERR] = errStr
    else
      session[HtmlUtil::TEMPINPUTERR] = "登録成功しました。"
    end

    # 入力値からリダイレクトURLのパラメタ作成(入力と同じ日付を保持する)
    redirectArg = [inputYear.to_s,inputMonth.to_s,inputDay.to_s]

    isRedirect = true
    redirectLoc =
      HtmlUtil.createUrl HtmlUtil::InputCtrlName,"index",redirectArg
    return "",isRedirect,redirectLoc
  end

  def index session,args
    isRedirect = false
    redirectLoc = ""

    # エラー時はセッションにメッセージを持たせる
    err = session[HtmlUtil::TEMPINPUTERR]
    err = "" if err == nil
    session[HtmlUtil::TEMPINPUTERR] = ""

    # 口座from,toは前回の値を記録しておく
    preFrom = session[HtmlUtil::TEMPINPUTFROM].to_i
    session[HtmlUtil::TEMPINPUTFROM] = ""
    preTo = session[HtmlUtil::TEMPINPUTTO].to_i
    session[HtmlUtil::TEMPINPUTTO] = ""

    actionUrl = HtmlUtil.createUrl HtmlUtil::InputCtrlName,"update"
    menuUrl = HtmlUtil.getMenuUrl

    # 年月日セレクトボックス作成
    yearSel = HtmlUtil.createYearSel "yearsel"
    monthSel = HtmlUtil.createMonthSel "monthsel"
    dateSel = HtmlUtil.createDateSel "datesel"
    if 4 <= args.size # 1:index, 2:year, 3:month, 4:day
      # defyear = args[2] # yearのデフォルトは要検討
      defmonth = args[2].to_i
      defdate = args[3].to_i
      monthSel = HtmlUtil.createMonthSel "monthsel",defmonth
      dateSel = HtmlUtil.createDateSel "datesel",defdate
    end

    # TODO: 年月日が一度に選べるセレクトボックス
    # TODO: 曜日が自動で表示されるJavascript
    # TODO: 存在しない日付を選択すると最終日に自動修正するJavascript

    # 科目一覧取得
    itemKindsList = MstMnt.getItemKindsTblData true,false
    itemKindsSel = "<select name=\"itemkindssel\">\n"
    itemKindsList.each do |tmpdto|
      itemKindsSel += "<option value=\"#{tmpdto.id}\">#{tmpdto.name}</option>\n"
    end
    itemKindsSel += "</select>\n"

    # 口座一覧取得(from,to)
    accountsList = MstMnt.getAccountsTblData true,false
    accountsToSel = "<select name=\"accountstosel\">\n"
    accountsFromSel = "<select name=\"accountsfromsel\">\n"
    accountsList.each do |tmpdto|
      accountsToSel += "<option value=\"#{tmpdto.id}\" "
      accountsToSel += "selected" if preTo == tmpdto.id
      accountsToSel += ">#{tmpdto.name}</option>\n"
      accountsFromSel += "<option value=\"#{tmpdto.id}\" "
      accountsFromSel += "selected" if preFrom == tmpdto.id
      accountsFromSel += ">#{tmpdto.name}</option>\n"
    end
    accountsToSel += "</select>\n"
    accountsFromSel += "</select>\n"

    form = <<-HTML
      <p>収支入力</p>
      <form action="#{actionUrl}" method="post" accept-charset="UTF-8"
            autocomplete="off" name="inputdata">
      <table>
        <tbody>
          <tr>
            <th>日付</th>
            <td>
    HTML
    form += yearSel + "/" + monthSel + "/" + dateSel
    # form += 日付セレクトボックス
    form += <<-HTML
            </td>
          </tr>
          <tr>
            <th>科目</th>
            <td>
    HTML
    form += itemKindsSel
    form += <<-HTML
            </td>
          </tr>
          <tr>
            <th>金額</th>
            <td>
              <input type="text" size="20" name="disbursement"
               id="disbursement"
               maxlength="#{DisbursementAccount::DISBURSEMENTLENGTH}"
               values="" autocomplete="off">
            </td>
          </tr>
          <tr>
            <th>備考</th>
            <td>
              <input type="text" size="40" name="description"
               id="disbursement"
               maxlength="#{DisbursementAccount::DESCRIPTIONLENGTH}"
               values="" autocomplete="off">
            </td>
          </tr>
          <tr>
            <th>口座from</th>
            <td>
    HTML
    form += accountsFromSel
    form += <<-HTML
            </td>
          </tr>
          <tr>
            <th>口座to</th>
            <td>
    HTML
    form += accountsToSel
    form += <<-HTML
            </td>
          </tr>
        </tbody>
      <table>
      <input type="submit" value="登録"><br>
      </form>
    HTML
    form += HtmlUtil.getJavascriptTags
    form += <<-HTML
<script type="text/javascript">
$(function (){
  $('#disbursement').focus( function(){ formatMoneyFocus(this); }).blur( function(){ formatMoneyBlur(this); })
});
</script>
    HTML

    form += "<p style=\"color:red;\">#{err}</p>" if err != nil and err != ""
    form += <<-HTML
      <a href="#{menuUrl}">メニュー画面へ</a>
    HTML

    return form,isRedirect,redirectLoc
  end
end
