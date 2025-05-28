#
#
# handles the settings
#
module Unitable
  extend ActiveSupport::Concern

  included do
    def units
      [
        [ "hours", I18n.t("time_material.units.hours") ],
        [ "parts", I18n.t("time_material.units.parts") ],
        [ "km", I18n.t("time_material.units.km") ],
        [ "day", I18n.t("time_material.units.day") ],
        [ "week", I18n.t("time_material.units.week") ],
        [ "month", I18n.t("time_material.units.month") ],
        [ "kilogram", I18n.t("time_material.units.kilogram") ],
        [ "cubicMetre", I18n.t("time_material.units.cubicMetre") ],
        [ "set", I18n.t("time_material.units.set") ],
        [ "litre", I18n.t("time_material.units.litre") ],
        [ "box", I18n.t("time_material.units.box") ],
        [ "case", I18n.t("time_material.units.case") ],
        [ "carton", I18n.t("time_material.units.carton") ],
        [ "metre", I18n.t("time_material.units.metre") ],
        [ "package", I18n.t("time_material.units.package") ],
        [ "shipment", I18n.t("time_material.units.shipment") ],
        [ "squareMetre", I18n.t("time_material.units.squareMetre") ],
        [ "session", I18n.t("time_material.units.session") ],
        [ "tonne", I18n.t("time_material.units.tonne") ]
      ]
    end
  end

  class_methods do
  end
end
