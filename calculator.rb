require_relative 'ca_tax_calculator'
require_relative 'fed_tax_calculator'

class Calculator
  Result = Struct.new(
    :original_property_tax_amount,
    :original_property_effective_tax_rate,
    :purchase_property_tax_amount,
    :purchase_property_effective_tax_rate,
    :total_tax,
    :total_effective_tax_rate,
    :total_tax_without_1031,
    :total_effective_tax_rate_without_1031,
    keyword_init: true
  )
  def initialize(model)
    @model = model
  end

  def call
    tax_1 = original_property_ca_tax.tax_amount + original_property_fed_tax.tax_amount
    tax_1_effective_tax_rate = tax_1/@model.original_property_gain.to_f
    tax_2 = purchase_property_ca_tax.tax_amount + purchase_property_fed_tax.tax_amount
    tax_2_effective_tax_rate = begin
      tax_2/@model.purchase_property_gain.to_f
    rescue ZeroDivisionError
      nil
    end

    Result.new(
      original_property_tax_amount: tax_1,
      original_property_effective_tax_rate: tax_1_effective_tax_rate,
      purchase_property_tax_amount: tax_2,
      purchase_property_effective_tax_rate: tax_2_effective_tax_rate || 0,
      total_tax: tax_1 + tax_2,
      total_effective_tax_rate: (tax_1 + tax_2)/(@model.original_sale_price - @model.original_basis),
      total_tax_without_1031: total_tax_without_1031,
      total_effective_tax_rate_without_1031: total_tax_without_1031/(@model.original_sale_price - @model.original_basis)
    )
  end

  private

  def total_tax_without_1031
    ca_tax_without_1031.tax_amount + fed_tax_without_1031.tax_amount
  end

  def ca_tax_without_1031
    @ca_tax_without_1031 ||= begin
      ca_result = CaTaxCalculator.new(
        gain: @model.original_sale_price - @model.original_basis,
        income: @model.income
      ).call
    end
  end

  def fed_tax_without_1031
    @fed_tax_without_1031 ||= begin
      fed_result = FedTaxCalculator.new(
        gain: @model.original_sale_price - @model.original_basis
      ).call
    end
  end

  def original_property_ca_tax
    @original_property_tax ||= CaTaxCalculator.new(
      gain: @model.original_property_gain,
      income: @model.income
    ).call
  end

  def original_property_fed_tax
    @original_property_fed_tax ||= FedTaxCalculator.new(
      gain: @model.original_property_gain
    ).call
  end

  def purchase_property_ca_tax
    @purchase_property_ca_tax ||= CaTaxCalculator.new(
      gain: @model.purchase_property_gain,
      income: @model.income
    ).call
  end

  def purchase_property_fed_tax
    @purchase_property_fed_tax ||= FedTaxCalculator.new(
      gain: @model.purchase_property_gain
    ).call
  end

  def original_property_tax_amount
    @original_property_tax ||= begin
      ca_tax = CaTaxCalculator.new(
        gain: @model.original_property_gain,
        income: @model.income
      )
      fed_tax = FedTaxCalculator.new(gain: @model.original_property_gain)
      ca_tax.tax_amount + fed_tax.tax_amount
    end
  end

  def purchase_property_tax_amount
    @purchase_property_tax_amount ||= begin
      ca_tax = CaTaxCalculator.new(
        gain: @model.purchase_property_gain,
        income: @model.income
      )
      fed_tax = FedTaxCalculator.new(gain: @model.purchase_property_gain)
      ca_tax.tax_amount + fed_tax.tax_amount
    end
  end
end
