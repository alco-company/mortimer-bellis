require "rqrcode"
module RqrcodeHelper
  #
  # SVG QR Code Link - generated by calling this helper method
  # @param destination [String] - the URL to encode in the QR code
  #
  def svg_qr_code_link(destination, svg_attributes: {})
    qrcode = RQRCode::QRCode.new(destination)

    # NOTE: showing with default options specified explicitly
    qrcode.as_svg(
      color: "333",
      shape_rendering: "crispEdges",
      module_size: 2,
      standalone: true,
      svg_attributes: svg_attributes,
      use_path: true
    ).html_safe
  end
end
