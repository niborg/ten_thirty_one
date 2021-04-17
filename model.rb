class Model
  ATTRIBUTES = %i[
    income
    filing_status
    original_sale_price
    original_basis
    purchase_price
    purchase_property_sale_price
  ].freeze

  attr_accessor(*ATTRIBUTES)

  def initialize(options = {})
    options.each do |key, value|
      next unless ATTRIBUTES.include?(key.to_sym)

      public_send("#{key}=", value.to_i)
    end
  end

  def original_property_gain
    if purchase_price == 0
      original_sale_price - purchase_price - original_basis
    else
      original_sale_price - purchase_price
    end
  end

  def purchase_property_gain
    return 0 if purchase_price == 0

    (purchase_property_sale_price || purchase_price) - original_basis
  end
end
