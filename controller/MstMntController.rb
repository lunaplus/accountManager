# encoding: utf-8
# Master Maintenance Controller
require_relative '../util/HtmlUtil'
require_relative '../model/MstMnt'
require_relative '../model/MstMntTableDTO'

class MstMntController
  def index session,args
    isRedirect = false
    redirectLoc = ""

    menuUrl = HtmlUtil.getMenuUrl

    # テーブル名一覧の取得,セレクトボックス作成
    #tables = MstMnt.getAllTableList MstMnt::DBNAME
    tables = MstMnt.getMntableTblList

    tableSelect = "<select name=\"tablesel\">\n"
    tableList = []
    tables.each do |key,value|
      tableSelect += "  " +
        HtmlUtil.createSelBox(key.to_s,key.to_s)
      tableList.push key.to_s
    end
    tableSelect += "</select>\n"

    # カラム一覧、データの取得,セレクトボックス(Array)作成
    # TODO: Ajaxにて実装
    # implemented: 全部取得しておいて、画面操作で変更
    columnList = []
    dataList = []
    tableList.each do |tablename|
      tmpColumns,tmpData = MstMnt.getMntTblData tablename
      columnList.push tmpColumns
      dataList.push tmpData
    end

    # TODO: メンテ用表形式テーブル表示作成

    form = <<-HTML
    <p>マスタメンテ</p>
    <p>
      #{tableSelect}<br>
      #{columnList}<br>
      #{dataList}
    </p>
    <a href="#{menuUrl}">メニューへ戻る</a>
    HTML

    return form,isRedirect,redirectLoc
  end

end
