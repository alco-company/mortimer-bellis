class ProvidedService < ApplicationRecord
  include Tenantable

  belongs_to :authorized_by, class_name: "User", optional: true, foreign_key: "authorized_by_id"

  scope :by_name, ->(name) { where("name LIKE ?", "%#{name}%") if name.present? }
  scope :by_service, ->(service) { where("service LIKE ?", "%#{service}%") if service.present? }
  scope :by_params, ->(params) { where("params LIKE ?", "%#{params}%") if params.present? }

  validates :name, presence: true, uniqueness: { scope: :tenant_id, message: I18n.t("locations.errors.messages.name_exist") }

  def self.filtered(filter)
    flt = filter.filter

    all
      .by_tenant()
      .by_name(flt["name"])
      .by_service(flt["service"])
      .by_params(flt["params"])
  rescue
    filter.destroy if filter
    all
  end

  def self.form(resource, editable = true)
    ProvidedServices::Form.new resource, editable: editable
  end

  def authorized?
    !params.blank?
  end

  def service_params
    return "" if params.blank?
    params
  end

  def service_params_hash
    JSON.parse(params)
  end

  def service_params=(p)
    p.blank? ?
      self.params = nil :
      self.params= make_json_text(p)
  end

  private
    class ServiceParams
      include ActiveModel::Serializers::JSON

      attr_accessor :access_token, :refresh_token, :token_type, :scope, :expires_at, :expires_in

      def attributes=(hash)
        hash.each do |key, value|
          public_send("#{key}=", value) if attributes.keys.include?(key)
        end
      end

      def attributes
        {
          "access_token" => nil,
          "refresh_token" => nil,
          "token_type" => nil,
          "scope" => nil,
          "expires_at" => nil,
          "expires_in" => nil
        }
      end
    end

    def make_json_text(p)
      sp = case p.class.to_s
      when "String"; ServiceParams.new.from_json(p)
      when "Hash"; ServiceParams.new.from_json(p.to_json)
      when "HTTParty::Response"; ServiceParams.new.from_json(p.parsed_response.to_json)
      else; ServiceParams.new
      end
      sp = set_expires_at(sp)
      sp.to_json
    end

    def set_expires_at(ps)
      return ServiceParams.new if ps.nil?
      unless ps.expires_at
        ps.expires_in ||= 3600
        ps.expires_at = Time.now + ps.expires_in.to_i
      end
      ps
    end
end
