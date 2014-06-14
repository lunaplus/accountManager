# encoding: utf-8
# Statistics Controller
require_relative '../util/HtmlUtil'
require_relative '../model/MstMnt'
require_relative '../model/DisbursementAccount'
require_relative '../model/DetailItemDTO'

class StatController
  def index session,args
    isRedirect = false
    redirectLoc = ""

    menuUrl = HtmlUtil.getMenuUrl
    actionUrl = HtmlUtil.createUrl HtmlUtil::StatisticsCtrlName,'index'

    # 年月日セレクトボックス作成
    yearSel = HtmlUtil.createYearSel "yearsel"
    monthSel = HtmlUtil.createMonthSel "monthsel"
    defyear = HtmlUtil.getToday.year
    defmonth = HtmlUtil.getToday.month
    if ENV['REQUEST_METHOD'] == 'POST'
      defyear = args[0]["yearsel"][0].to_i
      defmonth = args[0]["monthsel"][0].to_i
      yearSel = HtmlUtil.createYearSel "yearsel",defyear
      monthSel = HtmlUtil.createMonthSel "monthsel",defmonth
    end

    # 当該年月の収支統計取得
    uid = session[HtmlUtil::LOGINID]
    rsltArr = DisbursementAccount.getItemList defyear,defmonth,uid
    list = ""
    if rsltArr.instance_of?(Array)
      list = <<-TABLE
  <table id="rslttable">
    <tr>
      <th>日付</th>
      <th>科目名</th>
      <th>金額</th>
      <th>備考</th>
      <th>口座from</th>
      <th>口座to</th>
      <th>入力日時</th>
    </tr>
      TABLE
      rsltArr.each do |tmpdto|
        list += <<-TABLE
    <tr>
      <td>#{HtmlUtil.fmtDate(tmpdto.occurDate)}</td>
      <td>#{tmpdto.itemKinds}</td>
      <td class="moneyColumn">￥#{tmpdto.disbursement.to_currency}</td>
      <td>#{tmpdto.description}</td>
      <td>#{tmpdto.accountFrom}</td>
      <td>#{tmpdto.accountTo}</td>
      <td>#{HtmlUtil.fmtDateTime(tmpdto.inputDate)}</td>
    </tr>
        TABLE
      end
      list += "</table>"
    else
      list = rsltArr
    end

    form = <<-HTML
    <h3>収支統計</h3>
    <form name="statsticssel" action="#{actionUrl}" method="post"
          accept-charset="UTF-8" autocomplete="off">
      #{yearSel}/#{monthSel}
      <input type="submit" value="表示">
    </form>

    #{list}

    <p><a href="#{menuUrl}">メニュー画面へ</a></p>
    HTML

    return form,isRedirect,redirectLoc
  end
end
