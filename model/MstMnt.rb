# encoding: utf-8
# Master Maintenance model
require_relative '../util/HtmlUtil'
require_relative './ModelMaster'
require_relative './MstMntTableDTO'

class MstMnt < ModelMaster
  # メンテナンス対象を増やす場合は、このリストにテーブル名を追加する。
  MntableTblList =
    {
    :itemKinds => Proc.new { |id,userid| MstMntItemKindDTO.new(id,userid) },
    :accounts => Proc.new { |id,userid| MstMntAccountDTO.new(id,userid) }
  }

  def self.getMntableTblList
    return MntableTblList
  end

  def self.getItemKindsTblData isSort,includeExpired
    colnames,data = getMntTblData 'itemKinds',isSort,includeExpired
    return data
  end

  def self.getAccountsTblData isSort,includeExpired
    colnames,data = getMntTblData 'accounts',isSort,includeExpired
    return data
  end

  def self.getMntTblData tblname,isSort=false,includeExpired=true
    colnames = []
    data = []

    # メンテナンス対象がMntableTblListに実装されていれば処理実行
    if MntableTblList.keys.include?(tblname.to_sym)
      # get column names
      (getColumns MstMnt::DBNAME, tblname).each do |row|
        colnames.push row.column_name
      end

      # get data
      (getTableData tblname,isSort,includeExpired).each do |row|
        tmpDto = MntableTblList[tblname.to_sym].call row["ID"],row["UserId"]
        tmpDto.setData row
        data.push tmpDto
      end
    else
      #TODO: throw not implemented Exception
      colnames = nil; data = nil
    end
    return colnames,data
  end

  def self.getAllTableList dbname
    if dbname == "" or dbname == nil
      return nil
    end
    begin
      mysqlClient = getMysqlClient
      dbnameEscaped = mysqlClient.escape dbname
      queryStr = <<-QUERY
        select table_schema,table_name,table_rows
        from information_schema.tables
        where table_schema = '#{dbnameEscaped}'
      QUERY
      retArr = []
      mysqlClient.query(queryStr).each do |row|
        tmp = MstMntTableDTO.new
        tmp.table_schema = row["table_schema"]
        tmp.table_name = row["table_name"]
        tmp.table_rows = row["table_rows"]
        retArr.push tmp
      end
      return retArr
    rescue Mysql2::Error => e
      return nil
    end
  end

  def self.getColumns dbname,tablename
    if dbname == "" or dbname == nil or tablename == "" or tablename == nil
      return nil
    end
    begin
      mysqlClient = getMysqlClient
      dbnameEscaped = mysqlClient.escape dbname
      tablenameEscaped = mysqlClient.escape tablename
      queryStr = <<-QUERY
        select table_schema, table_name, column_name, data_type, column_type
        from information_schema.columns
        where table_schema = '#{dbnameEscaped}'
          and table_name = '#{tablenameEscaped}'
      QUERY
      retArr = []
      mysqlClient.query(queryStr).each do |row|
        tmp = MstMntColumnDTO.new
        tmp.table_schema = row["table_schema"]
        tmp.table_name = row["table_name"]
        tmp.column_name = row["column_name"]
        tmp.data_type = row["data_type"]
        tmp.column_type = row["column_type"]
        retArr.push tmp
      end
      return retArr
    rescue Mysql2::Error => e
      return nil
    end
  end

  def self.getTableData tablename,isSort,includeExpired
    if tablename == "" or tablename == nil
      return nil
    end
    begin
      mysqlClient = getMysqlClient
      tablenameEscaped = mysqlClient.escape tablename
      queryStr = <<-QUERY
        select *
        from #{tablenameEscaped}
      QUERY
      queryStr += " where Expired = false " unless includeExpired
      queryStr += " order by SortOrder asc " if isSort
      return mysqlClient.query(queryStr)
    rescue Mysql2::Error => e
      return nil
    end
  end

  private_class_method :getAllTableList, :getColumns, :getTableData

end
