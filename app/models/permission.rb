class Permission < ActiveRecord::Base
  extend Enumerize

  include AuthClient::Permission

  acts_as_auth_client_permission roles: %W(administrator manager lecturer)

  attr_accessible :role, :context_id, :user_id, :email, :context_type
  attr_accessor :name

  validates_presence_of :user_id, :if => 'email.nil?'
  validates_presence_of :email,   :if => 'user_id.nil?'
  validates_presence_of :role
  validates_presence_of :context_id, :context_type, :if => :role_manager?

  validates_uniqueness_of :context_id, :scope => :email
  validates_email_format_of :email, :message => 'Неверный формат электронной почты', :if => 'user_id.nil?'

  def self.validates_presence_of(*attr_names)
    new_attrs = []
    option = {}
    attr_names.each do |attr|
      if attr.class == Hash

        next
      end
      new_attrs << attr if attr != :user
    end
    super new_attrs, option
  end

  def self.validates_uniqueness_of(attr_name, options)
    options.merge!({:scope => [:email, :context_id, :context_type]}) if attr_name == :role
    super attr_name, options
  end

  before_validation :set_context_type
  before_validation :reset_context, :if => :role_administrator?

  scope :by_user, ->(_)     { order('email') }
  scope :by_role, ->(role)  { where(:role => role) }

  normalize_attribute :email do |value|
    value.present? ? value.downcase.squish : value
  end

  enumerize :role,
    :in => [:administrator, :manager, :lecturer],
    :default => :manager,
    :predicates => { :prefix => true },
    :scope => true

  def self.activate_for_user(user)
    where(:email => user.email).update_all :user_id => user.id
  end

  def to_s
    ''.tap do |s|
      s << "&lt;#{user.email}&gt; #{user} &mdash; " if user.present?
      s << "&lt;#{email}&gt; роль не активирована &mdash; " if user.nil?
      s << role_text
      s << " &laquo;#{context}&raquo;" if role_manager?
    end.html_safe
  end

  def title
    ''.tap do |s|
      s << "&lt;#{user.email}&gt; #{user}" if user.present?
      s << "&lt;#{email}&gt; <span class='alert'>роль не активирована</span>" if user.nil?
    end
  end

  def label
    return context.abbr if context.is_a?(Subdivision)
    return context.short_name if context.is_a?(Person)
    return 'Админ' if context.nil?
  end

  def context_url
    "".tap do |str|
      if role.lecturer?
        str << "/lecturers/"
      elsif context
        str << "/#{context_type.underscore.pluralize}/"
      elsif role.administrator?
        str << '/periods'
      end
      str << context.id.to_s if context
    end
  end

private
  def set_context_type
    self.context_type ||= 'Subdivision'
  end

  def reset_context
    self.context_id = self.context_type = nil
  end
end

# == Schema Information
#
# Table name: permissions
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  context_id   :integer
#  context_type :string(255)
#  role         :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

