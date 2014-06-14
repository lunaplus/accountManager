# encoding: utf-8
# MstMnt Table Names DTO

class MstMntTableDTO
  attr_accessor :table_schema, :table_name, :table_rows
  def to_s
    return <<-HOGE
 [:table_schema => '#{@table_schema}',
  :table_name   => '#{@table_name}',
  :table_rows   => '#{@table_rows}']
    HOGE
  end
end

class MstMntColumnDTO
  attr_accessor :table_schema, :table_name, :column_name, :data_type, :column_type
  def to_s
    return <<-FUGA
 [:table_schema => '#{@table_schema}',
  :table_name   => '#{@table_name}',
  :column_name  => '#{@column_name}',
  :data_type    => '#{@data_type}',
  :column_type  => '#{@column_type}']
    FUGA
  end
end

# ItemKinds用DTO
class MstMntItemKindDTO
  attr_accessor :name, :sortOrder, :expired, :lastModified
  attr_reader :id, :userId

  def initialize(id,userid,name="",so="",ex=false,dt="")
    @id = id.to_i
    @userId = userid + ""
    @name = name
    @sortOrder = so
    @expired = ex
    @lastModified = dt
  end

  def setData(row)
    @id = row["ID"]
    @userId = row["UserId"]
    @name = row["Name"]
    @sortOrder = row["SortOrder"]
    @expired = (row["Expired"] == 1)
    @lastModified = row["LastModified"]
  end

  def to_s
    return <<-TXT
[ ID           => #{@id},
  UserId       => #{@userId},
  Name         => #{@name},
  SortOrder    => #{@sortOrder},
  Expired      => #{@expired},
  LastModified => #{@lastModified} ]
    TXT
  end
end

# Accounts用DTO
class MstMntAccountDTO
  attr_accessor :name, :sortOrder, :expired, :lastModified
  attr_reader :id, :userId, :remainder

  def initialize(id,userid,name="",so="",ex=false,rm=0,dt="")
    @id = id.to_i
    @userId = userid + ""
    @name = name
    @sortOrder = so
    @expired = ex
    @remainder = rm
    @lastModified = dt
  end

  def setData(row)
    @id = row["ID"]
    @userId = row["UserId"]
    @name = row["Name"]
    @sortOrder = row["SortOrder"]
    @expired = (row["Expired"] == 1)
    @remainder = row["Remainder"]
    @lastModified = row["LastModified"]
  end

  def to_s
    return <<-TXT
[ ID          => #{@id},
  UserId      => #{@userId},
  Name        => #{@name},
  SortOrder   => #{@sortOrder},
  Expired     => #{@expired},
  Remainder   => #{@remainder},
  LatModified => #{@lastModified} ]
    TXT
  end
end
