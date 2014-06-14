# encoding: utf-8
# Detail Item model
require_relative '../util/HtmlUtil'
require_relative './ModelMaster'
require_relative './DetailItemDTO'

class DisbursementAccount < ModelMaster
  DISBURSEMENTLENGTH = 20
  DESCRIPTIONLENGTH = 40

  def self.getItemList year,month,userid
    if year.nil? or month.nil?
      return nil
    else
      return nil if month < 1 or month > 12
    end
    begin
      mysqlClient = getMysqlClient
      dateEscaped = mysqlClient.escape (year.to_s + "-" + month.to_s + "-1")
      userIdEscaped = mysqlClient.escape userid

      subQuery = <<-QUERY
        select d.occurdate, d.disbursement, d.inputdate, d.description,
               i.name as iname, af.name as afname, at.name as atname
          from disbursementaccounts as d
               left join itemkinds i on d.itemkindid = i.id
               left join accounts af on d.accountfrom = af.id
               left join accounts at on d.accountto = at.id
         where i.UserId = '#{userIdEscaped}'
           and d.occurdate between '#{dateEscaped}'
                               and last_day('#{dateEscaped}')
      QUERY

      queryStr = <<-QUERY
        (#{subQuery})
        union
        (select s.occurdate, sum(s.disbursement),
                date_add(max(s.inputdate),interval 1 microsecond),
                '', concat('【日次合計】',s.iname), '', ''
           from (#{subQuery}) s
          group by s.occurdate, s.iname)
        union
        (select last_day(max(s.occurdate)),
                sum(s.disbursement),
                date_add(max(s.inputdate),interval 1 microsecond),
                '', concat('【月次合計】',s.iname), '', ''
           from (#{subQuery}) s
          group by s.iname)
        order by occurdate asc, inputdate asc
      QUERY

      retArr = []
      mysqlClient.query(queryStr).each do |row|
        tmp = DetailItemDTO.new
        #tmp.occurDate = HtmlUtil.parseDate(row["occurdate"])
        tmp.occurDate = row["occurdate"]
        tmp.disbursement = row["disbursement"]
        tmp.description = row["description"]
        tmp.accountFrom = row["afname"]
        tmp.accountTo = row["atname"]
        tmp.itemKinds = row["iname"]
        #tmp.inputDate = HtmlUtil.parseDateTime(row["inputdate"])
        tmp.inputDate = row["inputdate"]
        retArr.push tmp
      end
      return retArr
    rescue Mysql2::Error => e
      return queryStr + "\n<br>\n" + e.message
    end  
  end

  def self.insertItem dto
    # 引数チェック(nil等があるとescapeで例外が出る
    if dto.nil?
      return "Data is nil"
    elsif dto.instance_variables.count < 6
      return "Data is short"
    else
      ret = []
      ret.push "occurDate" if dto.occurDate.nil?
      ret.push "itemKinds" if dto.itemKinds.nil?
      ret.push "disbursement" if dto.disbursement.nil?
      ret.push "accountFrom" if dto.accountFrom.nil?
      ret.push "accountTo" if dto.accountTo.nil?
      ret.push "inputDate" if dto.inputDate.nil?
      return ("Data includes nil (" + ret.join(",") + ")") if ret.count > 0
      return ("Data includes blank (disbursement)") if dto.disbursement == 0
    end
    begin
      mysqlClient = getMysqlClient

      # TODO: insert前にitemKinds.UserId,acounts.UserIdと
      # 登録者のuidの一致チェック
      queryStr = "insert into disbursementaccounts( occurdate, disbursement, description, itemkindid, accountfrom, accountto, inputdate, lastmodified ) values ( "
      arr = []
      arr.push("'" + mysqlClient.escape(HtmlUtil.fmtDate(dto.occurDate)) + "'")
      arr.push(mysqlClient.escape(dto.disbursement.to_s))
      arr.push("'" + mysqlClient.escape(dto.description) + "'")
      arr.push(mysqlClient.escape(dto.itemKinds))
      arr.push(mysqlClient.escape(dto.accountFrom))
      arr.push(mysqlClient.escape(dto.accountTo))
      arr.push("'" + mysqlClient.escape(HtmlUtil.fmtDateTime(dto.inputDate)) + "'")
      arr.push("now()")
      queryStr += arr.join(",") + " )"

      mysqlClient.query(queryStr)
      return ""
    rescue Mysql2::Error => e
      return queryStr + "\n<br>\n" + e.message
    end  
  end

end

