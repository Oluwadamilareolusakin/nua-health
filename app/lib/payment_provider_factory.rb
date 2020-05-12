class PaymentProviderFactory
  class Provider
    def debit_card(user)
      if user[:is_doctor] == true
        raise CustomError
      end # This is just to raise an error for the purpose of this test
    end    
  end

  class CustomError < StandardError; end # This is a custom error class for the purpose of this test
  
  def self.provider
    @provider ||= Provider.new
  end

end
