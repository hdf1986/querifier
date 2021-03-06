describe Querifier::Config do
  context 'with default config' do
    described_class::DEFAULTS_CONFIGS.each do |attribute, value|
      before do
        described_class.reset!
      end

      it 'responds to the attribute' do
        expect(described_class.respond_to?(attribute)).to be_truthy
      end

      it 'has a default' do
        expect(described_class.send(attribute)).to be(value)
      end
    end
  end

  described_class::DEFAULTS_CONFIGS.each do |attribute, _value|
    context "changing #{attribute}" do
      let!(:n) { rand(300) }

      before do
        described_class.reset!
        Querifier.configure { |c| c.send("#{attribute}=", n) }
      end

      it 'changes to the applied value' do
        expect(described_class.send(attribute)).to be(n)
      end
    end
  end
end
