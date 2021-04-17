TaxTier = Struct.new(:range, :rate, keyword_init: true) do
  def tax_applied_to(value)
    if value > range.max
      (range.max - range.min) * rate
    elsif range.include?(value)
      (value - range.min) * rate
    else
      0
    end
  end
end
