# encoding: utf-8
# Menu Controller
require_relative '../util/HtmlUtil'

class MenuController
  def index session,args
    name = session[HtmlUtil::LOGINNAME]
    isadm = session[HtmlUtil::ISADMIN]
    loginUrl = HtmlUtil.createUrl HtmlUtil::LoginCtrlName
    personUrl = HtmlUtil.createUrl HtmlUtil::PersonCtrlName
    inputUrl = HtmlUtil.createUrl HtmlUtil::InputCtrlName
    stcsUrl = HtmlUtil.createUrl HtmlUtil::StatisticsCtrlName
    mstmntUrl = HtmlUtil.createUrl HtmlUtil::MstMaintenanceCtrlName

    form = <<-HTML
      <p>ようこそ[#{name}]さん</p>
      <p>メニュー画面</p>
      <ul>
        <li><a href="#{inputUrl}">収支入力</a></li>
        <li><a href="#{stcsUrl}">収支統計</a></li>
        <li><a href="#{mstmntUrl}">マスタメンテ</a></li>
        <li><a href="#{personUrl}">ユーザ情報管理</a></li>
    HTML
    form += "        <li>ユーザ管理(管理者メニュー)</li>\n" if isadm
    form += <<-HTML
      </ul>
      <a href="#{loginUrl}">ログアウト(ログイン画面へ)</a>
    HTML
    isRedirect = false
    redirectLoc = ""
    return form,isRedirect,redirectLoc
  end
end
