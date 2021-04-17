require_relative 'tax_tier'

class CaTaxCalculator
  Result = Struct.new(:tax_amount, :effective_tax_rate, keyword_init: true)

  TAX_TIERS = [
    TaxTier.new(range: 0..17_864, rate: 0.01),
    TaxTier.new(range: 17_865..42_350, rate: 0.02),
    TaxTier.new(range: 42_351..66_842, rate: 0.04),
    TaxTier.new(range: 66_843..92_788, rate: 0.06),
    TaxTier.new(range: 92_789..117_268, rate: 0.08),
    TaxTier.new(range: 117_269..599_016, rate: 0.093),
    TaxTier.new(range: 599_017..718_814, rate: 0.103),
    TaxTier.new(range: 718_815..1_198_024, rate: 0.113),
    TaxTier.new(range: 1_198_024..Float::INFINITY, rate: 0.123),
  ].freeze

  def initialize(gain:, income:)
    @income = income
    @gain = gain
  end

  def call
    tax_amount = TAX_TIERS.sum { |tier| tier.tax_applied_to(@income + @gain) } -
                 TAX_TIERS.sum { |tier| tier.tax_applied_to(@income) }
    effective_tax_rate = tax_amount / @gain.to_f
    Result.new(tax_amount: tax_amount, effective_tax_rate: effective_tax_rate)
  end
end
