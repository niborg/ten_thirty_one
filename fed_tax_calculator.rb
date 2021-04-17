require_relative 'tax_tier'

class FedTaxCalculator
  Result = Struct.new(:tax_amount, :effective_tax_rate, keyword_init: true)

  TAX_TIERS = [
    TaxTier.new(range: 0..80_800, rate: 0),
    TaxTier.new(range: 80_801..501_600, rate: 0.15),
    TaxTier.new(range: 501_601..Float::INFINITY, rate: 0.20)
  ].freeze

  def initialize(gain:)
    @gain = gain
  end

  def call
    tax_amount = TAX_TIERS.sum { |tier| tier.tax_applied_to(@gain) }
    effective_tax_rate = tax_amount / @gain.to_f
    Result.new(tax_amount: tax_amount, effective_tax_rate: effective_tax_rate)
  end
end
