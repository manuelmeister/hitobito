# == Schema Information
#
# Table name: table_displays
#
#  id        :integer          not null, primary key
#  type      :string(255)      not null
#  person_id :integer          not null
#  selected  :text(65535)
#

class TableDisplay < ActiveRecord::Base
  validates_by_schema

  belongs_to :person

  serialize :selected, Array

  def self.register_permission(model_class, permission, *attrs)
    @@permissions ||= {}
    @@permissions[model_class.model_name.singular] ||= {}
    attrs.each { |attr| @@permissions[model_class.model_name.singular][attr.to_s] = permission }
  end

  def self.for(person, parent)
    case parent
    when Group then TableDisplay::People
    when Event then TableDisplay::Participations
    end.find_or_initialize_by(person: person)
  end

  def with_permission_check(path, object)
    name, target = resolve(path, object)
    permission = lookup_permission(target, name)
    yield if permission.blank? || ability.can?(permission.to_sym, target)
  end

  def resolve(path, object)
    *parts, attr = *path.to_s.split('.')
    parts.empty? ? [attr, object] : [attr, parts.inject(object) { |obj, name| obj.send(name) }]
  end

  def ability
    @ability ||= Ability.new(person)
  end

  def lookup_permission(object, name)
    @@permissions ||= {}
    @@permissions.fetch(object.class.model_name.singular, {})[name.to_s]
  end

end
