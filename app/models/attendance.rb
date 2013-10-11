class Attendance < ActiveRecord::Base
  extend Enumerize
  attr_accessible :fact, :kind, :total, :docket_id

  enumerize :kind, :in => {:lecture => 1, :practice => 2, :laboratory => 3, :research => 4, :design => 5}

  belongs_to :docket
  belongs_to :student

  def self.kind_values
    Hash[kind.values.map{|v| [v.to_s, v.text]} ]
  end

  def to_s
    "#{fact || '-'}/#{total}".html_safe
  end
end
