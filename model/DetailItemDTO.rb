# encoding: utf-8
# Detail Item input DTO

class DetailItemDTO
  attr_accessor :occurDate, :itemKinds, :disbursement, :description, :accountFrom, :accountTo, :inputDate

  def to_s
    ret = <<-RET
{ :occurDate    => #{@occurDate},
  :itemKinds    => #{@itemKinds},
  :disbursement => #{@disbursement},
  :description  => #{@description},
  :accountFrom  => #{@accountFrom},
  :accountTo    => #{@accountTo},
  :inputDate    => #{@inputDate} }
    RET
  end
end
